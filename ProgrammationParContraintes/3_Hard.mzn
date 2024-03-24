% Colin Dietrich (222661)
% Blanquez Victor (2225992)

include "globals.mzn";

% Énumérations des équipes participant au tournoi
enum equipes = {CO, TA, HO, DA, NA, MU, AL, UT};

% Lieux de rencontres des equipes (0 = pas de rencontre).
% Tout lieu i, tel que 0 < i <= card(equipes), 
% est designé comme le domicile de l'équipe associée par la relation to_enum(equipe, i)
set of int: terrains = 0..card(equipes);

% Étendue du tournoi (en jours)
int: d = 16;
set of int: jours = 1..d;

% Calendrier de placement des matchs
array[equipes, jours] of var terrains: calendrier;

% Nombres de rencontres entre deux equipes
array[equipes, equipes] of var 0..2: rencontres;

% Tuples des dates de match entre deux équipes
array[equipes, equipes] of var tuple (0..d, 0..d): dates;

% Variable objectif à maximiser
var int: objectif_match_espaces;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%

% 1. & 2. Pour effectuer une rencontre, deux équipes doivent être présentes sur le même terrain, et le match doit avoir lieu sur le terrain d'une des deux équipes.
constraint forall(e1, e2 in equipes where e1 < e2)(
  forall(j in jours)(
    (calendrier[e1,j] = calendrier[e2,j] /\ calendrier[e1,j] > 0) -> (to_enum(equipes, calendrier[e1,j]) = e1 \/
    to_enum(equipes, calendrier[e2,j]) = e2) /\ (dates[e1,e2].1 = j \/ dates[e1,e2].2 = j)
  )
);

% S'assurer que si une équipe joue sur un terrain donné, l'équipe hôte de ce terrain joue également sur ce terrain
constraint forall(e in equipes)(
  forall(j in jours where calendrier[e,j] > 0)(
    let { 
      var int: terrainHost = calendrier[e,j]; } 
    in (
      exists(e2 in equipes)(
        e2 = to_enum(equipes, terrainHost) /\ calendrier[e2,j] = terrainHost
      )
    )
  )
);

% 3. Un terrain ne peut accueillir plus de deux équipes.
constraint forall(j in jours)(
  forall(t in terrains where t > 0)(
    count([calendrier[e, j] | e in equipes], t) <= 2
  )
);

% 4. & 5. Si une équipe ne joue pas lors d’une journée, elle est placée sur le terrain n°0, et une équipe n'est pas autorisée à jouer plus de 7 jours sur son propre terrain.
constraint forall(e in equipes)(
  sum(j in jours)(to_enum(equipes, calendrier[e,j]) = e) <= 7
);

% 6. & 7. Les équipes doivent jouer deux fois l’une contre l’autre, et les rencontres doivent être espacées d'au moins 3 jours.
constraint forall(e1, e2 in equipes where e1 < e2)(
  let {
    var set of int: matchDays = {j | j in jours where calendrier[e1,j] = calendrier[e2,j] /\ calendrier[e1,j] > 0}
  } in (
    card(matchDays) = 2
  )
);

% Suivi de l'espacement entre les matchs
array[equipes, equipes] of var jours: espacement_matchs;

constraint forall(e1, e2 in equipes where e1 < e2)(
  let {
    var int: firstMatch = min([j | j in jours where calendrier[e1,j] = calendrier[e2,j] /\ calendrier[e1,j] > 0]),
    var int: secondMatch = max([j | j in jours where calendrier[e1,j] = calendrier[e2,j] /\ calendrier[e1,j] > 0])
  } in (
    % Contrainte pour l'espacement entre les matchs
    espacement_matchs[e1, e2] = secondMatch - firstMatch /\
    % 8. Les deux rencontres de deux équipes doivent avoir lieu sur des terrains différents.
    calendrier[e1,firstMatch] != calendrier[e1,secondMatch]
  )
);

% 7. Deux rencontres de deux équipes doivent être espacées de 3 jours au minimum
constraint forall(e1, e2 in equipes where e1 < e2)(
  espacement_matchs[e1, e2] > 3
);

% Objectif: Maximiser le nombre de fois où deux matchs entre les mêmes équipes sont espacés d'au moins 6 jours.
objectif_match_espaces = sum(e1, e2 in equipes where e1 < e2)(
  if espacement_matchs[e1, e2] > 6 then 1 else 0 endif
);

solve maximize objectif_match_espaces;


%-----------------------------------------------------------------------------%

% Affichage du calendrier par equipes et par jours puis du résultat de la fonction objectif.
% Lorsqu'une équipe ne joue pas, l'emplacement de match reste vide sinon elle contient le nom de l'équipie adverse.
% Si une équipe ne joue pas à domicile, un "@" précède le nom de l'équipe adverse.
output 
["Calendrier:\n"]
++
[if j = 1 then "   " else "" endif ++ if j < 10 then "  j" ++ show(j) else " j" ++ show(j) endif ++ if j = d then "\n" else "" endif | j in jours ]
++
[if j = 1 then show(e1) ++ ":" else "" endif ++ if fix(calendrier[e1,j]) = 0 then "    " else if fix(calendrier[e1,j]) = e1 then "  " ++ concat([if e1 != e2 /\ fix(calendrier[e2,j]) = e1 then show(e2) else "" endif | e2 in equipes])  else " @" ++ show(to_enum(equipes, calendrier[e1,j])) endif endif ++ if j = d then "\n" else "" endif | e1 in equipes, j in jours ]
++
["\nMatchs retour espacés de 6 jours ou plus = " ++ show(objectif_match_espaces) ++ "\n"]
;
