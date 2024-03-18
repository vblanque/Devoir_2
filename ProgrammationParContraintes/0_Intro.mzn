include "globals.mzn";

 var 1000..9999: nombre;

array[1..4] of var 1..9: chiffres;

% Constraint 1: The number is even, so the last digit must be even
constraint chiffres[4] mod 2 = 0;

% Constraint 2: 0 is not allowed, already ensured by the domain of 'chiffres'

% Constraint 3: All digits are different
constraint all_different(chiffres);

% Constraint 4: The thousands digit is greater than the hundreds digit
constraint chiffres[1] > chiffres[2];

% Constraint 5: The tens digit is less than the units digit
constraint chiffres[3] < chiffres[4];

% Constraint 6: The hundreds digit is greater than the units digit
constraint chiffres[2] > chiffres[4];

% Constraint 7: The sum of the digits is greater than 15
constraint sum(chiffres) > 15;

% Constraint 8: Minimize the product of the last three digits
solve minimize chiffres[2] * chiffres[3] * chiffres[4];

nombre = 1000*chiffres[1] + 100*chiffres[2] + 10*chiffres[3] + chiffres[4];

output [
  show(nombre)
];
