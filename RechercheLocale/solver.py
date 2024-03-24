from uflp import UFLP
from typing import List, Tuple
import numpy as np
""" 
    Binome 1 : Blanquez Victor (2225992)
    Binome 2 : Dietrich Colin (2226611)
    Description succinte de l'implementation : Nous avons implementé un recherche locale avec des restarts. 
    Le voisinage de chaque solution est l'ensemble des solutions possibles ayant une gare principale en plus
    ou en moins que la solution actuelle. Pour toutes les solutions considérées, les stations sattelites sont
    assignées à la station principale la plus proche. Ce voisinage est connecté mais peut comporter des minimas
    locaux. 
    
    Une première recherche à l'aide d'une solution initiale optimisée est effectuée (bat l'agent secret), 
    ensuite une deuxième à partir d'un autre solution initale optimisée (bat aussi l'agent secret). Ces recherches 
    peuvent nous amener à des minimas locaux. Pour pouvoir sortir de ces minimas et introduire de la diversification, 
    des recherches locales à partir de solutions initiales aléatoires sont ensuite effectuées (n recherches permettent aussi
    de battre l'agent secret).

    Les variables "nbr_random_local_searchs" et "depth_of_search" déclarées au début de la fonction solve()
    peuvent être modifiées pour changer le nombre et la profondeur des recherhes à partir de solution aléatoires.
    Dans le cas ou l'implémentation prend plus de 2 minutes, ce nombre de recherches peut être diminué.
    Le nombre choisi devrait néanmoins respecter la contrainte de temps.
    ...
"""

def solve(problem: UFLP) -> Tuple[List[int], List[int]]:
    """
    Votre implementation, doit resoudre le probleme via recherche locale.

    Args:
        problem (UFLP): L'instance du probleme à résoudre

    Returns:
        Tuple[List[int], List[int]]: 
        La premiere valeur est une liste représentant les stations principales ouvertes au format [0, 1, 0] qui indique que seule la station 1 est ouverte
        La seconde valeur est une liste représentant les associations des stations satellites au format [1 , 4] qui indique que la premiere station est associée à la station pricipale d'indice 1 et la deuxieme à celle d'indice 4
    """
    # number of local searches with a random inital solution and their depth
    nbr_random_local_searchs = 25
    depth_random_local_search = 40 # sufficient to find the minimum of the local searchs (all 3 instances)
    
    # first local search with forced intial solution (beats secret agent)
    sol = local_search(problem, 15, initial_solution=cheap_solution_1)
    cost = problem.calculate_cost(sol[0],sol[1])
    # second local search with another forced intial solution (also beats secret agent)
    new_sol = local_search(problem, 15, initial_solution=cheap_solution_2)
    new_cost = problem.calculate_cost(new_sol[0],new_sol[1])
    # select solution with lowest cost
    if new_cost<cost:
            sol = new_sol
            cost = new_cost
    # n local search with random initial solution (diversification, also beats secret agent)
    for i in range(nbr_random_local_searchs):
        # new solution with local search
        new_sol = local_search(problem, depth_random_local_search, initial_solution=random_solution)
        new_cost = problem.calculate_cost(new_sol[0],new_sol[1])
        # select solution with lowest cost
        if new_cost<cost:
            sol = new_sol
            cost = new_cost
    return sol

def local_search(problem: UFLP, n, initial_solution):
    """Local search with a choice in the initial solution and the depth of the search.

    Args : problem (UFLP): Instance of the problem
    n : depth of the search (number of times neighbours are generated)
    initial_solution : function generating the initial solution (optimized or random)
    """
    # initial solution and cost
    sol = initial_solution(problem)
    cost = problem.calculate_cost(sol[0],sol[1])
    # n-search in neighbours and selection
    for i in range(n):
        solution_changed = False  # Flag to track if a better solution has been found in the neighbours
        # explore neighbour solutions
        neighbours = create_neighbours(problem, sol)
        # select solution with lowest cost
        for neigh in neighbours:
            new_cost = problem.calculate_cost(neigh[0],neigh[1])
            if new_cost < cost:
                sol = neigh
                cost = new_cost
                solution_changed = True
        # If no better neighbour is found, terminate the search
        if not solution_changed:
            break
    return sol

def cheap_solution_1(problem: UFLP):
    """Creation of a specific initital solution :
    Opening only one main station with cheapest opening cost"""
    main_stations = np.zeros(problem.n_main_station, dtype=np.int32) # no opened main station 
    # Opening the cheapest one
    cheap_indice = np.argmin(problem.main_stations_opening_cost)
    main_stations[cheap_indice] = 1
    # Assign satellites to that main station
    satellites = np.zeros(problem.n_satellite_station, dtype=np.int32) + cheap_indice 
    return main_stations.tolist(), satellites.tolist()

def cheap_solution_2(problem: UFLP):
    """Creation of a specific initital solution :
    Opening approximately 1/4 of main stations with cheapest opening cost"""
    # Number of main stations to open (approximately 1/4 of total)
    num_main_stations_to_open = max(1, problem.n_main_station // 4)  # At least 1 station should be open
    # Sort main stations by opening cost
    sorted_indices = np.argsort(problem.main_stations_opening_cost)
    # Open the first num_main_stations_to_open stations with the lowest opening cost
    main_stations = np.zeros(problem.n_main_station, dtype=np.int32)
    main_stations[sorted_indices[:num_main_stations_to_open]] = 1
    # Assign satellites to the nearest main station
    satellites = assign_nearest_mains(problem, main_stations)
    
    return main_stations.tolist(), satellites

def random_solution(problem: UFLP):
    """Creation of a random solution :
    Opening random main stations to indroduce diversification.
    Assign the satellite stations to their nearest main station."""
    # Create a random array of 4 digits (0 or 1)
    main_stations = np.random.randint(2, size=problem.n_main_station, dtype=np.int32)
    # Assign satellites to the nearest main station
    satellites = assign_nearest_mains(problem, main_stations)
    
    return main_stations.tolist(), satellites

def create_neighbours(problem: UFLP, sol):
    """Generate other solutions by changing the number of main stations.
    Adding or removing one main station if it's possible.
    Assign the satellite stations to their nearest main station"""
    current_mains = sol[0]
    neighbours = []
    # Solutions with an additional main station
    if current_mains.count(1) < problem.n_main_station : # check if all main stations are already opened
        for i in range(problem.n_main_station):
            if current_mains[i] == 0: #check if station is not opened
                new_mains = current_mains.copy()
                new_mains[i] = 1
                satellites = assign_nearest_mains(problem, new_mains)      
                neighbours.append((new_mains, satellites))
    # Solutions with one less main station
    if current_mains.count(1) > 1 : #check if only one main station is opened
        for i in range(problem.n_main_station):
            if current_mains[i] == 1: #check if station is opened
                new_mains = current_mains.copy()
                new_mains[i] = 0
                satellites = assign_nearest_mains(problem, new_mains)      
                neighbours.append((new_mains, satellites))
    return neighbours

def assign_nearest_mains(problem, main_stations):
    """Assign sattelites to the nearest main station"""
    satellites = []
    # for all sattelites stations
    for sat_coord in problem.satellite_stations_connection_coordinates:
        min_distance = float('inf')
        closest_main = None
        i = 0
        # for all main stations
        for main_coord in problem.main_stations_coordinates:
            if main_stations[i] == 1: # check if main station is opened
                # calculate distance and keep the nearest main station 
                distance = problem.coordinates_to_cost(sat_coord[0],sat_coord[1],main_coord[0],main_coord[1]) 
                if distance < min_distance:
                    min_distance = distance
                    closest_main = i
            i += 1
        satellites.append(closest_main)
    return satellites
