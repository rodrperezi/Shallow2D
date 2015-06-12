classdef Hidrodinamica < Motor

	% MOTOR -> HIDRODINAMICA es la clase padre de los 
	% motores de cálculo que resuelven el problema hidrodinámico
	% Su función es de agrupar los motores y se puede entender
	% como una clase abstracta que entrega algunas propiedades
	% comunes a los motores.
	% 
	% Construcción:
	% 
	% thisHidrodinamica = Hidrodinamica()
	% 
	% Propiedades: 
	% 
	% >> properties(Hidrodinamica)
	% 
	%	Properties for class Hidrodinamica:
	% 
	%	    RegimenTemporal
	%	    Solucion
	%	    Solucion2D
	%	    Tiempo
	%	    Tipo

	properties

		RegimenTemporal
		Solucion
		Solucion2D	
		Tiempo	


	end

	methods

		function thisHidrodinamica = Hidrodinamica()
	
			if nargin == 0			
				thisHidrodinamica;
			end %if

		end % Hidrodinamica
	end %methods
end %classdef

