classdef Resultados
	% RESULTADOS es un objeto que contiene los resultados 
	% obtenidos en una Simulación. Por ahora se consideran 
	% dos motores de cálculo: AnalisisModal y CrankNicolson
	% Cada una de estas propiedades de la clase alberga en la 
	% una estructura la soluciónCompleta, la solucionEta, 	
	% la solucionU y la solucionV.

	properties

		Hidrodinamica
		Transporte

	end

	methods

		function thisResultados = Resultados(Cuerpo, MotorDeCalculo, varargin)

			% if nargin == 2

				if(strcmp(MotorDeCalculo, 'VolumenesFinitos'))
					thisResultados.Transporte = Transporte(Cuerpo, varargin{2}, varargin{1});
					% keyboard %AQUI ESTA EL ERROR
				else 
					thisResultados.Hidrodinamica = Hidrodinamica(Cuerpo, MotorDeCalculo);
				end

%				if MotorDeCalculo == 'AnalisisModal'	
%					% thisResultados.AnalisisModal = AnalisisModal(Cuerpo);
%					% thisResultados.Hidrodinamica.AnalisisModal = AnalisisModal(Cuerpo);
%					thisResultados.Hidrodinamica = Hidrodinamica(Cuerpo, MotorDeCalculo);
%					
%				elseif MotorDeCalculo == 'CrankNicolson'
%					% thisResultados.CrankNicolson = CrankNicolson(Cuerpo);
%					thisResultados.Hidrodinamica = CrankNicolson(Cuerpo);
%				% elseif MotorDeCalculo == 'VolumenesFinitos'					
%				% 	Transporte.
%					% thisResultados.Transporte.CrankNicolson = CrankNicolson(Cuerpo);

%				end		
			% end		
		end
	end
end
