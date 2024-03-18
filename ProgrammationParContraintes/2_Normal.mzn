% Colin Dietrich (222661)
% Blanquez Victor (2225992)

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
constraint forall(i in dim, j in dim where terrain[i,j] != V) (
  % Vérifier les lignes horizontales et verticales
  forall(k in dim where k != i) (
    terrain[k,j] != (if terrain[i,j] = B then R else B endif)
  ) /\
  forall(l in dim where l != j) (
    terrain[i,l] != (if terrain[i,j] = B then R else B endif)
  )
  /\
  % Vérifier les diagonales
  % Diagonale principale : i+j est constant
  forall(k in dim where k != i) (
    let { int: l = j + i - k; } in
    if l in dim then terrain[k,l] != (if terrain[i,j] = B then R else B endif) else true endif
  )
  /\
  % Diagonale secondaire : i-j est constant
  forall(k in dim where k != i) (
    let { int: l = j - i + k; } in
    if l in dim then terrain[k,l] != (if terrain[i,j] = B then R else B endif) else true endif
  )
);

% Contrainte pour avoir un nombre égal de tours bleues et rouges
constraint sum(i in dim, j in dim)(terrain[i,j] = B) = sum(i in dim, j in dim)(terrain[i,j] = R);

% Maximiser le nombre total de tours de chaque type
total_commun = sum(i in dim, j in dim)(terrain[i,j] = B);

% contrainte symétrique: la première tour qui apparaît dans l'ordre de lecture doit être bleue, éliminant ainsi les solutions qui permutent simplement les positions des tours bleues et rouges.
constraint exists(i, j in dim where (forall(k in 1..i-1, l in dim)(terrain[k,l] = V) /\ forall(l in 1..j-1)(terrain[i,l] = V)))(terrain[i,j] = B);

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
