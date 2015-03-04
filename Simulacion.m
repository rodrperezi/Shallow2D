classdef Simulacion < hgsetget

	% SIMULACION es un objeto que contiene toda la informacion 
	% geométrica, forzantes, resultados entre otras
	% caracteristícas de un problema.

	properties

		Cuerpo
		Forzantes
		Matrices
		AnalisisModal
		CrankNicolson

	end

	methods

		function thisSimulacion = Simulacion(thisSimulacion, varargin)

			if nargin == 0

				thisSimulacion;
	
			else

				for iVariable = 1:length(varargin)
				
					switch class(varargin{iVariable})
						case 'Cuerpo'
							thisSimulacion.Cuerpo = varargin{iVariable};
						case 'Forzantes'
							thisSimulacion.Forzantes = varargin{iVariable};
						case 'Matrices'
							thisSimulacion.Matrices = varargin{iVariable};
						case 'AnalisisModal'
							thisSimulacion.AnalisisModal = varargin{iVariable};
						case 'CrankNicolson'
							thisSimulacion.CrankNicolson = varargin{iVariable};
						otherwise 
							error(['Wrong input argument: Clase Simulacion no trabaja con ', class(varargin{iVariable})])

					end%switch
				end%for
			end %if
		end%function Simulacion

	end%methods 
end%classdef 

