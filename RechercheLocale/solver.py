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
    init = initial_solution(problem)
    sol = init
    cost = problem.calculate_cost(sol[0],sol[1])
    neighbours = create_neighbours(problem, sol)
    print(sol)
    print(cost) 
    print(neighbours)
    return sol


def initial_solution(problem: UFLP):
    """Opening the main station with cheapest opening cost"""
    main_stations = np.zeros(problem.n_main_station, dtype=np.int32) #no opened main station 
    cheap = np.argmin(problem.main_stations_opening_cost)
    main_stations[cheap] = 1 #opening the cheapest one
    satellites = np.zeros(problem.n_satellite_station, dtype=np.int32) + cheap # associate sattelites with cheapest main station
    return main_stations.tolist(), satellites.tolist()

def create_neighbours(problem: UFLP, sol):
    """Generate other solution by changing the main stations.
    Add or remove a station if it's possible.
    Assign the satellite to the nearest main station"""
    main_stations = sol[0]
    neighbours = []
    # Solution with an additional station
    if main_stations.count(1) < problem.n_main_station : #check if all stations are already opened
        for i in range(problem.n_main_station):
            if main_stations[i] == 0: #check if station is already opened
                new_mains = main_stations.copy()
                new_mains[i] +=1
                neighbours.append(new_mains)
    return neighbours
    
    
    