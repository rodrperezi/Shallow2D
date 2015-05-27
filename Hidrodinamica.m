classdef Hidrodinamica < Motor

	% HIDRODINAMICA es la clase que agrupa los motores
	% de cálculo que resuelven el problema hidrodinámico

	properties

		RegimenTemporal
		Solucion
		Solucion2D	
		Tiempo	
		% ObjetoCalculo
		% RegimenTemporal
		% Solucion		
		% Motor
		% SolucionEta
		% SolucionU
		% SolucionV
		% Tiempo

	end

	methods

		function thisHidrodinamica = Hidrodinamica()
				
			if nargin == 0			
				thisHidrodinamica;
			end %if
		end % Hidrodinamica
	end %methods
end %classdef

