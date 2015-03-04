function borde = generaBordeCircular(Radio, Centro)
% Rodrigo Pérez I.
% generaBordeCircular: Función que construye las coordenadas 
% para el borde = [xBorde, yBorde]

if nargin == 1
	Centro = [0, 0];
end

xcircular = Radio*cos((0:1:359)*pi/180) + Centro(1);
ycircular = Radio*sin((0:1:359)*pi/180) + Centro(2);
borde = [xcircular', ycircular'];
