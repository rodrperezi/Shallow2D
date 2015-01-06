classdef Simulacion
	% SIMULACION es un objeto que contiene toda la informacion 
	% que describe una simulacion. Se aplica a un cuerpo

	properties

		Cuerpo
		Resultados

	end

	methods

		function thisSimulacion = Simulacion(varargin, MotorDeCalculo)

			if nargin == 2

				switch class(varargin)

					case 'Cuerpo'
						thisSimulacion.Cuerpo = varargin;
						thisSimulacion.Resultados = Resultados(thisSimulacion.Cuerpo, MotorDeCalculo);
						stringAyuda = ['thisSimulacion.Cuerpo = thisSimulacion.Resultados.Hidrodinamica.',MotorDeCalculo,'.CuerpoActualizado;'];
						eval(stringAyuda);
						stringAyuda = ['thisSimulacion.Resultados.Hidrodinamica.',MotorDeCalculo,'.CuerpoActualizado = [];'];
						eval(stringAyuda);

					case 'Simulacion'
						
%						if(strcmp(MotorDeCalculo, 'VolumenesFinitos'))
%							thisSimulacion.Resultados = Resultados(Cuerpo, MotorDeCalculo, 'sinDispersion');
%						else 



							if isempty(varargin.Resultados)
								thisSimulacion.Cuerpo =	varargin.Cuerpo;					
								thisSimulacion.Resultados = Resultados(thisSimulacion.Cuerpo, MotorDeCalculo);
								thisSimulacion = actualizaCuerpo(thisSimulacion, MotorDeCalculo);							
							else
								
								if(strcmp(MotorDeCalculo, 'VolumenesFinitos'))
									thisSimulacion.Cuerpo =	varargin.Cuerpo;
									% keyboard
									resultadosPrevios = varargin.Resultados;
									resultadosNuevos = Resultados(thisSimulacion.Cuerpo, MotorDeCalculo, 'sinDispersion', resultadosPrevios.Hidrodinamica);

									% stringAyuda = ['resultadosPrevios.Transporte.',MotorDeCalculo,' = resultadosNuevos.Hidrodinamica.',MotorDeCalculo,';'];
									% stringAyuda = ['resultadosPrevios.Transporte = resultadosNuevos.Transporte;'];
									resultadosPrevios.Transporte = resultadosNuevos.Transporte;
									% eval(stringAyuda);
									thisSimulacion.Resultados = resultadosPrevios;
									% thisSimulacion = actualizaCuerpo(thisSimulacion, MotorDeCalculo);

								else

									thisSimulacion.Cuerpo =	varargin.Cuerpo;
									resultadosPrevios = varargin.Resultados;
									resultadosNuevos = Resultados(thisSimulacion.Cuerpo, MotorDeCalculo);
									stringAyuda = ['resultadosPrevios.Hidrodinamica.',MotorDeCalculo,' = resultadosNuevos.Hidrodinamica.',MotorDeCalculo,';'];
									eval(stringAyuda);
									thisSimulacion.Resultados = resultadosPrevios;
									thisSimulacion = actualizaCuerpo(thisSimulacion, MotorDeCalculo);
								end					
							end

						% end

					otherwise
					error('myapp:chk', 'Wrong input argument: el primer argumento debe ser de clase Cuerpo o clase Simulacion')

				end
			end		
		end
	end
end

