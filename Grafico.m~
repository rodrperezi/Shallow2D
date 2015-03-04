classdef Grafico < hgsetget

	% Grafico es el objeto que permite implementar cualquiera
	% de los graficos que se encuentran disponibles en el modelo

	properties 

		Handle
		Tipo
	
	end

	methods

		function thisGrafico = Grafico()
					
			thisGrafico;

		end %function Grafico

		function thisGrafico = graficaMalla(varargin)

			malla = getMalla(varargin);

		end %function graficaMalla


		function thisGrafico = graficaBorde(thisGrafico, varargin)

			borde = getBorde(varargin);
			plot(borde.coordenadasXY(:,1), borde.coordenadasXY(:,2))

		end %function graficaBorde







%		function simulacion = asignaMatrices(thisMatrices, simulacion)
%					
%			simulacion.Matrices = generaMatrices(thisMatrices, simulacion);

%		end %function 
		
	end %methods
end % classdef
