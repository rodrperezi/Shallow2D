classdef Resultados
	% Descripción General: 
	% 
	% RESULTADOS es un objeto que contiene la solución obtenida
	% al aplicar un motor de cálculo sobre un objeto de 
	% clase CUERPO. Tiene dos propiedades: un objeto de 
	% clase HIDRODINAMICA y otro de clase TRANSPORTE. Estos 
	% contienen la solución al problema hidrodinámico y de
	% transporte de masa, respectivamente.
	%  
	% Construcción: 
	% 
	% Se aplica a un objeto de clase CUERPO y se debe especificar
	% el motor de cálculo. 
	% 
	% Ej: 
	% 
	%  resEjemplo = Resultados(cuerpoEjemplo, 'MotorEjemplo');
	% 	
	% Por ahora, los motores de cálculo disponibles son:	
	% 'AnalisisModal' y 'CrankNicolson'.

	properties

		Hidrodinamica
		Transporte

	end

	methods

		function thisResultados = Resultados(Cuerpo, MotorDeCalculo, varargin)


				if(strcmp(MotorDeCalculo, 'VolumenesFinitos'))
					thisResultados.Transporte = Transporte(Cuerpo, varargin{2}, varargin{1});
					% keyboard %AQUI ESTA EL ERROR
				else 
					thisResultados.Hidrodinamica = Hidrodinamica(Cuerpo, MotorDeCalculo);
				end
		end
	end
end
