classdef Parametros
	% Descripción General:
	% 
	% PARAMETROS es una clase que construye un objeto con las 
	% propiedades y/o parámetros utilizados en el cálculo.
	% Aceleración de gravedad y la constante de von Kármán 
	% son algunos ejemplos.     
    
    properties

	aceleracionGravedad
	kappaVonKarman
	zoAsperezaAgua
	densidadRho
	viscosidadNu
	factorFriccion
	densidadAire
	difusionOD
	saturacionOD
	porosidadPhi
	dispLong 
	dispTrans 
	factorUTilde

    end

	methods

		function thisParametros = Parametros()

			thisParametros.aceleracionGravedad = 9.81; % [m/s2]
			thisParametros.kappaVonKarman = 0.41;
			thisParametros.zoAsperezaAgua = 0.0028; % [m] %Liang 06
			thisParametros.densidadRho = 1000; % [kg/m3]
			thisParametros.densidadAire = 1.2; % [kg/m3]
			thisParametros.viscosidadNu = 1.15e-6; % [m/s2]
			thisParametros.factorFriccion = 0.011; % de la Fuente et al. 2014
			thisParametros.difusionOD = 1.82e-9; % [m2/s] (Steinberger 1999)
			thisParametros.saturacionOD = 8.82e-3; % [kg/m3] (Steinberger 1999)
			thisParametros.porosidadPhi = 0.9; % [m2/s] (Steinberger 1999)
			thisParametros.dispLong = 5.93; % Elder
			thisParametros.dispTrans = 0.23; % Elder
			thisParametros.factorUTilde = sqrt(20);
			
		end

	end

end
	

