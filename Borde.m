classdef Borde < hgsetget

	% BORDE	es el objeto que contiene las coordenadas 
	% del borde que delimita la geometria superficial
	
	properties

		tipoBorde
		coordenadasXY
       
  	end
    	
	methods

		function thisBorde = Borde()

			thisBorde;

	        end %function Borde
	
		function thisBorde = generaBordeCircular(thisBorde, radio, centro)
			% function thisBorde = generaBordeCircular(thisBorde, radio, centro)
			% Función que construye las coordenadas para 
			% el borde circular = [xBorde, yBorde]

			xcircular = radio*cos((0:1:359)*pi/180) + centro(1);
			ycircular = radio*sin((0:1:359)*pi/180) + centro(2);
			bordeCircular = [xcircular', ycircular'];
			thisBorde.tipoBorde = 'Circular';
			thisBorde.coordenadasXY = bordeCircular;
		end %function generaBordeCircular

		function thisBorde = generaBordeRectangular(thisBorde, ladoA, ladoB, centro)
			% function thisBorde = generaBordeRectangular(thisBorde, ladoA, ladoB, centro)
			% Función que construye las coordenadas para 
			% el borde rectangular = [xBorde, yBorde]

			xRectangular = [centro(1) - ladoA*0.5, centro(1) + ladoA*0.5];
			xRectangular = [xRectangular, xRectangular(2), xRectangular(1), xRectangular(1)]; 
			yRectangular = [centro(2) - ladoB*0.5, centro(2) - ladoB*0.5];
			yRectangular = [yRectangular, centro(2) + ladoB*0.5, centro(2) + ladoB*0.5, centro(2) - ladoB*0.5 ];
			bordeRectangular = [xRectangular', yRectangular'];
			thisBorde.tipoBorde = 'Rectangular';
			thisBorde.coordenadasXY = bordeRectangular;
		end %function generaBordeRectangular
	end %methods
end %classdef

