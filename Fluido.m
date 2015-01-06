classdef Fluido
    % FLUIDO se entiende como el fluido que caracteriza al cuerpo
    % Como propiedades se ingresan el nombre del fluido 

    properties

	nombreFluido
	densidadRho
	viscosidadNu
        
    end
    
    methods
	function thisFluido = Fluido(nombreFluido, densidadRho, viscosidadNu)

		if nargin ~= 0
			thisFluido.nombreFluido = nombreFluido;	%kg/m3
			thisFluido.densidadRho = densidadRho;	%kg/m3
			thisFluido.viscosidadNu = viscosidadNu; %m2/s
					
		end
        end


    end
    
end


