classdef Simulacion < hgsetget

	% SIMULACION es un objeto que contiene la informacion 
	% que caracteriza a un problema. Conceptualmente
	% sobre un CUERPO de fluido actúa una serie de FORZANTES
	% a partir de los cuales se construyen las MATRICES  
	% que representan numéricamente al problema.
	% 
	% >> properties(Simulacion)
	% 
	%	Properties for class Simulacion:
	% 
	%	    Cuerpo
	%	    ListaForzantes
	%	    Matrices
	% 	    Resultados
	% 
	

	properties

		Cuerpo
		ListaForzantes
		Matrices
		Resultados

	end

	methods

		function thisSimulacion = Simulacion(thisSimulacion, varargin)
		% function thisSimulacion = Simulacion(thisSimulacion, varargin)
		% Constructor de la clase Simulacion

			if nargin == 0

				thisSimulacion;
	
			else

				for iVariable = 1:length(varargin)
				
					switch class(varargin{iVariable})
						case 'Cuerpo'
							thisSimulacion.Cuerpo = varargin{iVariable};
						% case 'Forzantes'
						% 	thisSimulacion.Forzantes = varargin{iVariable};
						case 'Matrices'
							thisSimulacion.Matrices = varargin{iVariable};
						case 'Resultados'
							thisSimulacion.Resultados = varargin{iVariable};
						otherwise 
							error(['Wrong input argument: Clase Simulacion no trabaja con ', class(varargin{iVariable})])

					end%switch
				end%for
			end %if
		end %function Simulacion
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
		
		function thisSimulacion= addMatrices(thisSimulacion, matrices)

			if strcmpi(class(matrices), 'Matrices')
				thisSimulacion.Matrices = matrices;
			else					
				error(['El objeto es de clase ' , class(matrices) ...
				  , '. Debe ser de clase Matrices'])
			end %if

		end %addMatrices
		
		function thisSimulacion= addResultados(thisSimulacion, objeto)
		% Por ahora esta funcion admite solo un resultado para 	
		% la hidrodinamica y el transporte.	
			superclase = superclasses(objeto);
			superclase = superclase{1}; % Me quedo con la clase que antecede 
			propiedades = properties(Resultados);
			% Veo si la clase que antecede es hidrodinamica o transporte
			existe = strcmpi(propiedades, superclase); 

			if(sum(existe) == 1)
			% Si es que existe
				cual = find(existe);	

				if isempty(thisSimulacion.Resultados)			
				% Si es que aún no se crean Resultados para la simulacion
				% los creo.
					res = Resultados();
				else
				% Si es que ya han sido creados los Resultados
				% los invoco
					res = thisSimulacion.Resultados;			
				end %if
				
				if isempty(objeto.Solucion)
					error(['El objeto de clase ', class(objeto),' aun no ha sido computado'])	
				else
					str = ['res.',propiedades{cual}, ' = objeto;'];
					eval(str)
					thisSimulacion.Resultados = res;
				end
			
			else 
				error(['El objeto de clase ', class(objeto),' no corresponde a Resultados'])
			end %if			
		end %addResultados

		function thisSimulacion = addForzante(thisSimulacion, forzante)
			
			listaForzantes = thisSimulacion.ListaForzantes;

			if ~isempty(listaForzantes) 		
				% Si es que la lista no esta vacía
				cuantosForzantes = length(listaForzantes);
		 	else
				% Si es que la lista de forzantes está vacía
				% entonces construye una celda
				listaForzantes = {};
				cuantosForzantes = 0;
		 	end
			
			% Una vez que agregas un forzante a la simulacion, 
			% el forzante debe interactuar con esta para utilizar 
			% su información. Por ejemplo, en 
			% el caso de un viento uniforme, se debe extraer
			% la densidad del fluido para multiplicar al parámetro
			% uAsterisco. 
			% keyboard
			forzante = adaptaForzante(forzante, thisSimulacion);
			
			% Agrega el forzante a la lista
			% y reasigna la lista a la simulacion
			listaForzantes{cuantosForzantes + 1} = forzante;
			thisSimulacion.ListaForzantes = listaForzantes;

		end %addForzante
			
		function thisSimulacion = delForzante(thisSimulacion, aBorrar)

			% Al borrar un elemento de una celda, se borra la 
			% entrada pero la celda no pierde ese espacio de memoria.
			% Es decir, si de una celda de dos elementos se borra
			% uno, el tamaño de la celda (de la lista de forzantes)
			% sigue siendo dos.
			listaForzantes = thisSimulacion.ListaForzantes;

			if(~isempty(listaForzantes))

				if length(listaForzantes) == 1
					% Si es que la lista de Forzantes tiene un 		
					% único forzante, entonces borra la lista
					listaForzantes = {};
				elseif(aBorrar > 1 && aBorrar < length(listaForzantes))
					% Si es que se borra algún elemento intermedio
					listaForzantes{aBorrar} = [];
					listaForzantes = [listaForzantes{1:aBorrar-1}, listaForzantes{aBorrar+1:end}];
				elseif(aBorrar == length(listaForzantes))
					% Si es que se borra el último elemento
					listaForzantes = listaForzantes{1:end-1};
				elseif(aBorrar > length(listaForzantes))
					% Si es que se quiere borrar un elemento 
					% mayor al largo de la lista   
					error('Intentas borrar un elemento que no existe en la lista')
				end
			else
				warning('La lista de forzantes está vacía')
			
			end

			thisSimulacion.ListaForzantes = listaForzantes;

		end %delForzante

		function thisSimulacion = replaceForzante(thisSimulacion, aReemplazar, forzante)
			
			listaForzantes = thisSimulacion.ListaForzantes;
			listaForzantes{aReemplazar} = forzante;

			if ~isempty(listaForzantes) 	
				% Si es que la lista de forzantes no está vacía	
				if(aReemplazar <= length(listaForzantes))
					% Si es que se borra algún elemento dentro de las 
					% dimensiones de la lista
					listaForzantes{aReemplazar} = forzante;
				elseif(aBorrar > length(listaForzantes))
					% Si es que se quiere reemplazar un elemento 
					% mayor al largo de la lista   
					error('Intentas reemplazar un elemento que no existe en la lista')
				end
			else
				warning('La lista de forzantes está vacía')
			end

			thisSimulacion.ListaForzantes = listaForzantes;

		end %replaceForzante

		function [M, K, C] = getMatrices(simulacion)
			
			matrices = simulacion.Matrices;
			M = matrices.M;
			K = matrices.K;
			C = matrices.C;
		
		end %function getMatrices

		function cuerpo = getCuerpo(simulacion)
				
			cuerpo = simulacion.Cuerpo;			
					
		end %function getCuerpo

		function borde = getBorde(simulacion)
				
			borde = simulacion.Cuerpo.Geometria.Borde;			
					
		end %function getBorde

		function listaForzantes = getListaForzantes(simulacion)
				
			listaForzantes = simulacion.ListaForzantes;			
					
		end %function getListaForzantes

		function malla = getMalla(simulacion)
				
			malla = simulacion.Cuerpo.Geometria.Malla;			
					
		end %function getMalla

		function batimetria = getBatimetria(simulacion)
				
			batimetria = simulacion.Cuerpo.Geometria.Batimetria;			
					
		end %function getBatimetria

		function parametros = getParametros(simulacion)
				
			parametros = simulacion.Cuerpo.Parametros;			
					
		end %function getParametros

		function fluido = getFluido(simulacion)
				
			fluido = simulacion.Cuerpo.Fluido;			
					
		end %function getFluido

		function [deltaX deltaY] = getDeltaX(simulacion)
				
			deltaX = simulacion.Cuerpo.Geometria.Malla.deltaX;			
			deltaY = simulacion.Cuerpo.Geometria.Malla.deltaY;			
					
		end %function getDeltaX

		function compiladoBatimetria = getCompiladoBatimetria(simulacion)

			batimetria = getBatimetria(simulacion);
			hoeta =  batimetria.hoNodosEta;
			howe =  batimetria.hoNodosU;
			hons =  batimetria.hoNodosV;
			compiladoBatimetria = [hoeta;howe;hons];
					
		end %function getCompiladoBatimetria

		

	end%methods 
end%classdef 


%%%%%%%%%%%%%%%%%%%%%%%% THRASH


%		function thisForzante = adaptaForzante(thisSimulacion, thisForzante);
%			
%			switch thisForzante.Tipo
%				case 'vientoUniforme'
%					fluido = getFluido(thisSimulacion);
%					rho = fluido.densidadRho;
%					uAsterisco = getUAsterisco(thisForzante);
%					anguloDireccion = getAnguloDireccion(thisForzante);
%					thisForzante.DireccionX = rho*uAsterisco^2*cos(anguloDireccion);
%					thisForzante.DireccionY = rho*uAsterisco^2*sin(anguloDireccion);
%					% keyboard
%				case 'acelHoriOsci'
%					nCiclos = 4;
%					datosPorCiclo = 20;
%					thisForzante.Tiempo = 0:(2*pi/omegaOscilacion)/(datosPorCiclo):nCiclos*(2*pi/omegaOscilacion).';
%					tiempo = thisForzante.Tiempo;
%					thisForzante.DireccionX = sparse(amplitud*omegaOscilacion^2*sin(omegaOscilacion*tiempo)*cos(anguloDireccion));
%					thisForzante.DireccionY = sparse(amplitud*omegaOscilacion^2*sin(omegaOscilacion*tiempo)*sin(anguloDireccion));
%				otherwise
%					error('No existe el tipo de forzante');
%			
%			end
%		end %adaptaForzante

%			num = str2num(aBorrar(2:end));
%			cuantos = length(fields(estructuraForzantes));
%			estructuraForzantes = rmfield(estructuraForzantes, aBorrar);

%			if num ~= cuantos

%				for iField = num:cuantos-1
%					str = ['estructuraForzantes.N', num2str(iField),' = estructuraForzantes.N',num2str(iField+1),';'];
%					eval(str)
%				end		
%	
%				estructuraForzantes = rmfield(estructuraForzantes, ['N',num2str(cuantos)]);

%			end

%			thisForzantes.ListaForzantes = estructuraForzantes;
