classdef Matrices < hgsetget

	% MATRICES es el objeto que contiene las matrices utilizadas
	% en la resolución del problema del analisis modal. 
	% El problema que resuelve son las ecuaciones de continuidad
	% y momentum linealizas expresadas como 
	% M \partial \chi = i(K + C) \chi + f. 
	% Para mayor información con respecto al significado de cada término
	% ver Shimizu e Imberger (2008)

	properties 

		M		
		K
		C
		f
		Tiempo
		compiladoBatimetria

	end

	methods

		function thisMatrices = Matrices()
					
			thisMatrices;

		end %function Matrices

		function simulacion = asignaMatrices(thisMatrices, simulacion)
					
			simulacion.Matrices = generaMatrices(thisMatrices, simulacion);

		end %function asignaMatrices
		
	end %methods
end % classdef
