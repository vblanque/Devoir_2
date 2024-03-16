from uflp import UFLP
from typing import List, Tuple
import numpy as np
""" 
    Binome 1 : Blanquez Victor (2225992)
    Binome 2 : Nom Prenom (Matricule)
    Description succinte de l'implementation :
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
    # initial solution and cost
    init = initial_solution(problem)
    sol = init
    best_cost = problem.calculate_cost(sol[0],sol[1])
    # 
    for i in range(10):
        # explore neighbour solutions
        neighbours = create_neighbours(problem, sol)
        # select solution with lowest cost
        for neigh in neighbours:
            cost = problem.calculate_cost(neigh[0],neigh[1])
            if cost < best_cost:
                sol = neigh
                best_cost = cost
    return sol


def initial_solution(problem: UFLP):
    """Opening the main station with cheapest opening cost"""
    main_stations = np.zeros(problem.n_main_station, dtype=np.int32) #no opened main station 
    cheap = np.argmin(problem.main_stations_opening_cost)
    main_stations[cheap] = 1 #opening the cheapest one
    satellites = np.zeros(problem.n_satellite_station, dtype=np.int32) + cheap # associate sattelites with cheapest main station
    return main_stations.tolist(), satellites.tolist()

def create_neighbours(problem: UFLP, sol):
    """Generate other solutions by changing the number of main stations.
    Adding or removing one main station if it's possible.
    Assign the satellite stations to their nearest main station"""
    current_mains = sol[0]
    neighbours = []
    # Solutions with an additional main station
    if current_mains.count(1) < problem.n_main_station : #check if all main stations are already opened
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
