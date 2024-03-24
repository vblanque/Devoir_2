% Colin Dietrich (222661)
% Blanquez Victor (2225992)
% Le modèle trouve une solution optimale maximisant notre objectif pour n=8 en environs 24s

include "globals.mzn";

% États possibles pour une case du terrain
% V = Vide
% B = Tour bleue
% R = Tour rouge
enum etat = {V, B, R};

% Dimension du terrain (carré)
int: n;
set of int: dim = 1..n;

% État du terrain
array[dim, dim] of var etat: terrain;

% Variable objectif à maximiser
var int: total_commun;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%
% Contrainte pour s'assurer qu'il n'y a pas de tours adverses sur les mêmes lignes (verticales, horizontales) ou diagonales
constraint forall(i, j in dim where terrain[i,j] != V)(
  % Compter les occurrences non autorisées sur la ligne horizontale
  count([terrain[i,l] | l in dim where l != j], (if terrain[i,j] = B then R else B endif)) = 0 /\
  % Compter les occurrences non autorisées sur la ligne verticale
  count([terrain[k,j] | k in dim where k != i], (if terrain[i,j] = B then R else B endif)) = 0 /\
  % Diagonale principale : i+j est constant
  count([terrain[k, j + i - k] | k in dim where k != i /\ j + i - k in dim], (if terrain[i,j] = B then R else B endif)) = 0 /\
  % Diagonale secondaire : i-j est constant
  count([terrain[k, j - i + k] | k in dim where k != i /\ j - i + k in dim], (if terrain[i,j] = B then R else B endif)) = 0
);


% Contrainte pour avoir un nombre égal de tours bleues et rouges
constraint count(array1d(terrain), B) = total_commun;
constraint count(array1d(terrain), R) = total_commun;


% contrainte symétrique: la première ligne ne contient pas de tour bleue
constraint count([terrain[1,j] | j in dim], B) = 0;


% contrainte symétrique: rupture de symétrie lexicographique
constraint (
    % symétrie de rotation de 90 degrés (ou symétrie de réflexion diagonale secondaire)
    lex_lesseq(array1d(terrain), [ terrain[j,i] | i in reverse(1..n), j in 1..n ]) /\
    % symétrie de rotation de 180 degrés
    lex_lesseq(array1d(terrain), [ terrain[i,j] | i,j in reverse(1..n) ]) /\
    % symétrie de rotation de 270 degrés
    lex_lesseq(array1d(terrain), [ terrain[j,i] | i,j in reverse(1..n) ])
);

solve maximize total_commun;

%-----------------------------------------------------------------------------%
output 
["Terrain :\n"]
++
[if j = 1 then "["  endif ++ if fix(terrain[i,j]) == V then "_" else show(terrain[i,j]) endif ++ if j = n then "]\n" else "," endif | i in 1..n, j in 1..n]
++
["\n"]
++
["Total de tours commun: " ++ show(total_commun)]
