classdef Batimetria < hgsetget

	% BATIMETRIA es el objeto que contiene las coordenadas 
	% de la malla y su correspondiente valor de batimetria

	properties

		tipoBatimetria
		hoNodosEta
		hoNodosU
		hoNodosV
       
	end
    
	methods

		function thisBatimetria = Batimetria()
		% function thisBatimetria = Batimetria()    
		% Constructor del objeto batimetria
			thisBatimetria;
	        end %function Batimetria

		function thisBatimetria = batimetriaKranenburg(thisBatimetria, geometria)

			thisBatimetria = generaBatimetriaKranenburg(thisBatimetria, geometria);
			thisBatimetria.tipoBatimetria = 'Kranenburg';
		
		end %function batimetriaKranenburg
	end %methods
end %classdef



