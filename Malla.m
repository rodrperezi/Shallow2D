classdef Malla
	% MALLA 
	properties 

		TipoDeMalla
		InformacionMalla

	end

	methods

		function thisMalla = Malla(bordeSuperficie, deltaX, deltaY)

			thisMalla.InformacionMalla = generaMallaStaggered(bordeSuperficie, deltaX, deltaY);
			thisMalla.TipoDeMalla = 'Staggered';

		end
	end
end
