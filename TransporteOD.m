classdef TransporteOD < Motor

	% MOTOR -> TRANSPORTEOD es la clase padre de los 
	% motores de cálculo que resuelven el problema de transporte
	% de oxígeno.

	properties

		RegimenTemporal
		Solucion
		Solucion2D	
		Tiempo	

	end

	methods

		function thisTransporteOD = TransporteOD()
	
			if nargin == 0			
				thisTransporteOD;
			end %if

		end % TransporteOD
	end %methods
end %classdef

