classdef Geometria

    % GEOMETRIA se entiende como las caracteristicas físicas
    % que identifican a un cuerpo. Entre ellas se incluye el borde ,
    % la batimetría,  la malla y otros parametros. En este caso 
    % la Geometria esta especialmente adecuada a kranenburg.	

    properties

	centroMasa 
	radioKranenburg
	alturaKranenburg
	bordeSuperficie
	Malla
	batimetriaKranenburg
	deltaX
	deltaY
       
    end
    
    methods
	function thisGeometria = Geometria(radioKranenburg, alturaKranenburg, centroMasa) 

		if nargin ~= 0
			
			thisGeometria.centroMasa = centroMasa; % [coordenada_x m, coordenada_y m]
			thisGeometria.radioKranenburg = radioKranenburg; %m
			thisGeometria.alturaKranenburg = alturaKranenburg; %m
			thisGeometria.bordeSuperficie = generaBordeCircular(radioKranenburg, centroMasa);
			thisGeometria.deltaX = 0.1*thisGeometria.radioKranenburg;
			thisGeometria.deltaY = thisGeometria.deltaX;
			thisGeometria.Malla = Malla(thisGeometria.bordeSuperficie, thisGeometria.deltaX, thisGeometria.deltaY);
			thisGeometria.batimetriaKranenburg = generaBatimetriaKranenburg(radioKranenburg, centroMasa, alturaKranenburg, thisGeometria.bordeSuperficie, thisGeometria.Malla);
		end
        end


    end
    
end
