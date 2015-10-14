classdef Transporte < Motor

	% MOTOR -> TRANSPORTE es la clase padre de los 
	% motores de cálculo que resuelven el problema de transporte

	properties

		RegimenTemporal
		Tiempo	
		Solucion
		Solucion2D

	end

	methods

		function thisTransporte = Transporte()
	
			if nargin == 0			
				thisTransporte;
			end %if

		end % Transporte
	end %methods
end %classdef

