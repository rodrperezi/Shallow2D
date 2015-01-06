classdef Hidrodinamica
	% HIDRODINAMICA es un objeto que contiene los resultados
	% de la hidrodinamica para los motores de calculo utilizados.
	properties

		 AnalisisModal
		 CrankNicolson

	end

	methods

		function thisHidrodinamica = Hidrodinamica(Cuerpo, MotorDeCalculo)
			
			if nargin == 2

				switch MotorDeCalculo
					case 'AnalisisModal'
						thisHidrodinamica.AnalisisModal = AnalisisModal(Cuerpo);
					case 'CrankNicolson'
						thisHidrodinamica.CrankNicolson = CrankNicolson(Cuerpo);	
				end

 			end		

		end



%		function thisSimulacion = Simulacion(varargin, MotorDeCalculo)

%			if nargin == 2

%				switch class(varargin)

%					case 'Cuerpo'
%						thisSimulacion.Cuerpo = varargin;
%						thisSimulacion.Resultados = Resultados(thisSimulacion.Cuerpo, MotorDeCalculo);
%						stringAyuda = ['thisSimulacion.Cuerpo = thisSimulacion.Resultados.',MotorDeCalculo,'.CuerpoActualizado;'];
%						eval(stringAyuda);
%						stringAyuda = ['thisSimulacion.Resultados.',MotorDeCalculo,'.CuerpoActualizado = [];'];
%						eval(stringAyuda);

%					case 'Simulacion'
%						
%						if isempty(varargin.Resultados)
%							thisSimulacion.Cuerpo =	varargin.Cuerpo;					
%							thisSimulacion.Resultados = Resultados(thisSimulacion.Cuerpo, MotorDeCalculo);
%							thisSimulacion = actualizaCuerpo(thisSimulacion, MotorDeCalculo);							
%						else
%							thisSimulacion.Cuerpo =	varargin.Cuerpo;
%							resultadosPrevios = varargin.Resultados;
%							resultadosNuevos = Resultados(thisSimulacion.Cuerpo, MotorDeCalculo);
%							stringAyuda = ['resultadosPrevios.',MotorDeCalculo,' = resultadosNuevos.',MotorDeCalculo,';'];
%							eval(stringAyuda);
%							thisSimulacion.Resultados = resultadosPrevios;
%							thisSimulacion = actualizaCuerpo(thisSimulacion, MotorDeCalculo);												
%						end

%					otherwise
%					error('myapp:chk', 'Wrong input argument: el primer argumento debe ser de clase Cuerpo o clase Simulacion')

%				end
% 			end		
% 		end
	end
end

