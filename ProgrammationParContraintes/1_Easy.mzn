% Colin Dietrich (222661)
% Blanquez Victor (2225992)

include "globals.mzn";

% Nombre de fréquences à placer
int: m;
% Placements possibles selon le nombre de fréquences
int: n = m*m;

% Définition de la plage de fréquences 
array[1..m] of var 0..n: frequences;

% Calcul des distances entre les différentes fréquences
array[1..(m*(m-1)) div 2] of var 0..n: distances =
    [ frequences[j] - frequences[i] | i in 1..m, j in i+1..m];

% Variable objectif à minimiser
var int: longueur;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%
% La première fréquence commence toujours à 0
constraint frequences[1] = 0;

% Les fréquences sont en ordre croissant
constraint increasing(frequences);

% Toutes les distances sont uniques
constraint all_different(distances);

% On cherche la plage de fréquences la plus courte possible
longueur = frequences[m];
solve minimize longueur;

%-----------------------------------------------------------------------------%

output 
  [show(frequences)]
  ++
  ["\nLongueur de la plage = ", show(longueur)];
