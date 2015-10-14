classdef Simulacion < hgsetget

	% SIMULACION es un objeto que contiene la informacion 
	% que caracteriza a un problema. Conceptualmente,
	% sobre un CUERPO de fluido actúa una serie de FORZANTEs
	% a partir de los cuales se construyen las MATRICES  
	% que representan numéricamente al problema.
	% 
	% Construcción:
	% 
	% Los objetos de esta clase se pueden construir de varias formas.
	% Una de ellas es mediante
	% 
	% 	thisSimulacion = Simulacion(thisSimulacion, varargin)
	% 
	% varargin puede contener objetos que sean de clase CUERPO, MATRICES
	% o RESULTADOS y el constructor los asigna automáticamente.
	% Otra forma de construir un objeto de la clase es crear un objeto 
	% vacío y agregar los elementos mediante la función específica
	% 
	%	thisSimulacion = Simulacion(); 
	% 	thisSimulacion = addObjeto(thisSimulacion, objeto);
	% 
	% La función addObjeto no existe sino que es una referencia conceptual
	% que permite ejemplificar como se agregan los objetos. Así, si se 
	% desea agregar un objeto de clase CUERPO entonces el comando 
	% sería
	% 
	% 	thisSimulacion = addCuerpo(thisSimulacion, cuerpo);
	% 
	% Otros ejemplos
	% 	
	% 	thisSimulacion = addForzante(thisSimulacion, forzante);
	% 	thisSimulacion = addMatrices(thisSimulacion, matrices);
	% 	thisSimulacion = addResultados(thisSimulacion, resultados);
	% 
	% Para ver un listado detallado de las funciones que contiene la clase
	% ejecutar methods(Simulacion)
	% 
	% Propiedades:	
	% 
	% >> properties(Simulacion)
	% 
	%	Properties for class Simulacion:
	% 
	%	    Nombre
	%	    Cuerpo
	%	    ListaForzantes
	%	    Matrices
	% 	    Resultados
	% 


	properties

		Nombre
		Cuerpo
		ListaForzantes %Hidrodinamicos
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
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		function thisSimulacion = addCuerpo(thisSimulacion, cuerpo)
				
			thisSimulacion.Cuerpo = cuerpo;			
					
		end %function addCuerpo
		
		function thisSimulacion = addNombre(thisSimulacion, varargin)
					
			if length(varargin) > 1
				error('La simulación puede tener solo un nombre')
			end 
				
			if ~strcmpi(class(varargin{1}), 'char')
				error('El nombre debe ser un string')
			end
	
			thisSimulacion.Nombre = varargin{1};			
					
		end %function addNombre

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
					% objResuelto = eval(['res.', propiedades{cual}]);
					% arregloObj = [];
					% alArreglo = objResuelto;
 					% arregloObj = [arregloObj, alArreglo];
					% keyboard				
				end %if
				
				if isempty(objeto.Solucion)
					error(['El objeto de clase ', class(objeto),' aun no ha sido computado'])	
				else
					% alArregloNew = objeto;					
					% arregloObj = [arregloObj, alArregloNew];
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

		function forzante = getForzante(simulacion)
				
			forzante = simulacion.ListaForzantes{1};			
					
		end %function getForzante

		function cuerpo = getCuerpo(simulacion)
				
			cuerpo = simulacion.Cuerpo;			
					
		end %function getCuerpo

		function geo = getGeometria(simulacion)
				% keyboard
			geo = simulacion.Cuerpo.Geometria;			
					
		end %function getGeometria

		function resultados = getResultados(simulacion)
				
			resultados = simulacion.Resultados;			
					
		end %function getResultados

		function hidrodinamica = getHidrodinamica(simulacion)
				
			hidrodinamica = simulacion.Resultados.Hidrodinamica;			
					
		end %function getHidrodinamica

		function transporte = getTransporte(simulacion)
				
			transporte = simulacion.Resultados.Transporte;			
					
		end %function getTransproteOD

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

		function [numeroNodosEta varargout] = getNumeroNodos(simulacion)
			if nargin == 1
				malla = getMalla(simulacion);
				numeroNodosEta = malla.numeroNodosEta;
				numeroNodosU = malla.numeroNodosU;
				numeroNodosV = malla.numeroNodosV;
	
				argoutExtra = max(nargout,1)-1;
				argoutAux = [numeroNodosU, numeroNodosV];		
				for k = 1:argoutExtra, varargout(k) = {argoutAux(k)}; end
			end
		end %function getNumeroNodos

		function [thisSimulacion varargout]= solucion2D(thisSimulacion, cualSolucion, varargin)
		% function varargout = solucion2D(thisSimulacion)
		% Función que transforma el vector de solución en 
		% matrices bidimensionales. cualSolucion es un string
		% que especifica si se debe llevar a dos dimensiones 
		% la solucion 'Hidrodinamica' o la solucion de 'Transporte'

			% if nargin == 2
		
			if strcmpi(cualSolucion, 'hidrodinamica')
				if isempty(thisSimulacion.Resultados) 
					error(['La simulacion aún no tiene resuelta la Hidrodinámica'])
				else
					claseSolucion = class(thisSimulacion.Resultados.Hidrodinamica);
					solucion = thisSimulacion.Resultados.Hidrodinamica.Solucion;
					% str = ['solucion = thisSimulacion.Resultados.Hidrodinamica.', claseSolucion, '.Solucion'];
					% eval(str)

					evolTemporal = length(solucion(1,:));
					malla = getMalla(thisSimulacion);
					coordenadasEta2DX = malla.coordenadasEta2DX;
					[xDentro yDentro] = find(~isnan(coordenadasEta2DX'));
					[mFilas nCol] = size(coordenadasEta2DX);

					if evolTemporal ~= 1

						solucionEta2D = NaN(mFilas, nCol, evolTemporal);
						solucionU2D = solucionEta2D;
						solucionV2D = solucionEta2D;
						
						barraEspera = waitbar(0,'Transformando solución a 2D...');

						for iTiempo = 1:evolTemporal
						
							waitbar(iTiempo/evolTemporal)

							[eta u v] = getEtaUV(thisSimulacion, solucion(:,iTiempo));

							for iSol = 1:length(xDentro) 
								solucionEta2D(yDentro(iSol), xDentro(iSol), iTiempo) = eta(iSol);
								solucionU2D(yDentro(iSol), xDentro(iSol), iTiempo) = u(iSol);
								solucionV2D(yDentro(iSol), xDentro(iSol), iTiempo) = v(iSol);
							end %for
						end %for

						close(barraEspera)

					else
						solucionEta2D = NaN(mFilas, nCol);
						solucionU2D = solucionEta2D;
						solucionV2D = solucionEta2D;

						barraEspera = waitbar(0,'Transformando solución a 2D...');

						[eta u v] = getEtaUV(thisSimulacion, solucion);

						for iSol = 1:length(xDentro) 

							waitbar(iSol/length(xDentro))

							solucionEta2D(yDentro(iSol), xDentro(iSol)) = eta(iSol);
							solucionU2D(yDentro(iSol), xDentro(iSol)) = u(iSol);
							solucionV2D(yDentro(iSol), xDentro(iSol)) = v(iSol);
						end %for

						close(barraEspera)					
			
					end %if

					solucion2D.solucionEta2D = solucionEta2D;
					solucion2D.solucionU2D = solucionU2D;
					solucion2D.solucionV2D = solucionV2D;
					thisSimulacion.Resultados.Hidrodinamica.Solucion2D = solucion2D;
					% str = ['thisSimulacion.Resultados.Hidrodinamica.', claseSolucion, '.Solucion2D = solucion2D'];
					% eval(str)				

				end %if
			elseif strcmpi(cualSolucion, 'modo')
				% En este caso, varargin contiene la estructura modal

				malla = getMalla(thisSimulacion);
				coordenadasEta2DX = malla.coordenadasEta2DX;
				[xDentro yDentro] = find(~isnan(coordenadasEta2DX'));
				[mFilas nCol] = size(coordenadasEta2DX);

				solucionEta2D = NaN(mFilas, nCol);
				solucionU2D = solucionEta2D;
				solucionV2D = solucionEta2D;
				
				if isempty(varargin)
					error('No se ha especificado la estructura modal')
				end
	
				[eta u v] = getEtaUV(thisSimulacion, varargin{1});

				for iSol = 1:length(xDentro) 

					solucionEta2D(yDentro(iSol), xDentro(iSol)) = eta(iSol);
					solucionU2D(yDentro(iSol), xDentro(iSol)) = u(iSol);
					solucionV2D(yDentro(iSol), xDentro(iSol)) = v(iSol);

				end %for

				estructura2D.eta2D = solucionEta2D;
				estructura2D.U2D = solucionU2D;
				estructura2D.V2D = solucionV2D;

				varargout{1} = estructura2D;

			elseif strcmpi(cualSolucion, 'transporteod')
				if isempty(thisSimulacion.Resultados.TransporteOD) 
					error(['La simulacion aún no tiene resuelto el TransporteOD'])
				else
					% solucion
					% str = ['solucion = simulacion.Resultados.Hidrodinamica.', claseSolucion];
					% eval(str)
				end
			else 
				error(['La solucion especificada no existe en la simulación'])
			end
		end % function solucion2D

		function [solucionEta varargout] = getEtaUV(thisSimulacion, solucionCompleta)
			if nargin == 2
				malla = getMalla(thisSimulacion);
				[numeroNodosEta numeroNodosU numeroNodosV]= getNumeroNodos(thisSimulacion);
			
				SOL = solucionCompleta;
				Neta = numeroNodosEta;
				Nu = numeroNodosU;
				Nv = numeroNodosV;
			
				IDwe = malla.matrizIDwe;
				IDns = malla.matrizIDns;
				nBIz = malla.numeroBordesIzquierdo;
				nBDe = malla.numeroBordesDerecho;
				nBSu = malla.numeroBordesSuperior;
				nBIn = malla.numeroBordesInferior;
			
				eta = SOL(1:Neta);
			
				uaux = sparse(zeros(Nu,1));
				vaux = sparse(zeros(Nv,1));
			
				ku = 1;
				kv = 1;
			
				for iNodosU = 1:Nu
				    if(sum(iNodosU == [IDwe(nBIz,1);IDwe(nBDe,2)])==0);
					% Como los bordes son eliminados en la generacion 	
					% de matrices producto de la asignación de la 
					% condición de borde de velocidad nula, debo
					% saltarme los nodos que son borde.
				       	uaux(iNodosU) = SOL(Neta + ku); 
				       	ku = ku+1;
				    end
				end
				    
				for iNodosV = 1:Nv
				    if(sum(iNodosV == [IDns(nBSu,1);IDns(nBIn,2)])==0);
				       	vaux(iNodosV) = SOL(Neta + kv + Nu - length([IDwe(nBIz,1);IDwe(nBDe,2)]));
				       	kv= kv+1;
				    end    
				end
			
				for iNodosEta = 1:Neta
					% Promedio los valores de u y v para las posiciones
					% de los nodos Eta
				    u(iNodosEta,1) = mean(uaux(IDwe(iNodosEta,:)));
				    v(iNodosEta,1) = mean(vaux(IDns(iNodosEta,:)));
				end
	
				solucionEta = eta;
				solucionU = u;
				solucionV = v;
	
				argoutExtra = max(nargout,1)-1;
				argoutAux = {solucionU, solucionV};		
				for k = 1:argoutExtra, varargout(k) = {argoutAux{k}}; end
			end	
		end

		function [nodosUBorde nodosVBorde] = getNodosBorde(simulacion)
			
			malla = getMalla(simulacion);
			IDwe = malla.matrizIDwe;
			IDns = malla.matrizIDns;
			nBIz = malla.numeroBordesIzquierdo;
			nBDe = malla.numeroBordesDerecho;
			nBSu = malla.numeroBordesSuperior;
			nBIn = malla.numeroBordesInferior;
			nodosUBorde = [IDwe(nBIz,1);IDwe(nBDe,2)];
			nodosVBorde = [IDns(nBSu,1);IDns(nBIn,2)];
			% keyboard
		end
			
		function serie = getSerieVelocidad(simulacion, coordenadas)

			solHidro = getHidrodinamica(simulacion);

			if ~strcmpi(solHidro.RegimenTemporal, 'impermanente')
			
				error('La simulacion debe ser impermanente para poder extraer una serie')
			
			end

			tiempo = solHidro.Tiempo;
			malla = getMalla(simulacion);
			[nEta nU nV] = getNumeroNodos(simulacion);
			[nBU nBV] = getNodosBorde(simulacion);
			coordenadasU = malla.coordenadasU;
			coordenadasV = malla.coordenadasV;

			nUNew = nU - length(nBU);
			nVNew = nV - length(nBV);

			coordenadasU(nBU,:) = [];
			coordenadasV(nBV,:) = [];
			
			serieU = zeros(length(tiempo),1);
			serieV = serieU;
			solucion = solHidro.Solucion;

			barraEspera = waitbar(0, 'Extrayendo serie de velocidad...');

			for iTiempo = 1:length(tiempo)
				waitbar(iTiempo/length(tiempo))
 				interpU = TriScatteredInterp(coordenadasU(:,1), coordenadasU(:,2), ...
					  full(solucion(nEta + 1: nEta + nUNew, iTiempo))); % Interpolador u
 				interpV = TriScatteredInterp(coordenadasV(:,1), coordenadasV(:,2), ...
					  full(solucion(nEta + nUNew + 1: end, iTiempo))); % Interpolador u
				serieU(iTiempo) = interpU(coordenadas(1), coordenadas(2));
				serieV(iTiempo) = interpV(coordenadas(1), coordenadas(2));
			end %for

			close(barraEspera)
			serie.serieU = serieU;
			serie.serieV = serieV;

		end % function getSerieVelocidad
	
		function wed = numeroWedderburn(simulacion)

			forz = getForzante(simulacion);

			if ~strcmpi(class(forz), 'vientouniforme')

				error('El número de Wedderburn está definido sólo para VientoUniforme')

			end

			L = longitudCaracteristica(simulacion);

			par = getParametros(simulacion);
			g = par.aceleracionGravedad;
			bat = getBatimetria(simulacion);
			hom = mean(bat.hoNodosEta);
			uAst = forz.uAsterisco;

			wed = g*hom^2/(uAst^2*L);

		end % function numeroWedderburn
	
		function froude = numeroFroude(simulacion)

			forz = getForzante(simulacion);

			if ~strcmpi(class(forz), 'vientouniforme')

				error('El número de Froude está definido sólo para VientoUniforme')

			end

			par = getParametros(simulacion);
			g = par.aceleracionGravedad;
			bat = getBatimetria(simulacion);
			hom = mean(bat.hoNodosEta);
			uAst = forz.uAsterisco;

			froude = uAst/sqrt(g*hom);

		end % function numeroFroude

		function reynolds = numeroReynolds(simulacion)

			par = getParametros(simulacion);
			nu = par.viscosidadNu;
			bat = getBatimetria(simulacion);
			heta = bat.hoNodosEta;
			solHidro = getHidrodinamica(simulacion);			
			[eta u v] = getEtaUV(simulacion, solHidro.Solucion(:,end));
			modV = sqrt(u.^2 + v.^2);
			reynolds = modV.*(heta + eta)/nu;

		end % function numeroReynolds

		function modVel = moduloVelocidad(simulacion)

			solHidro = getHidrodinamica(simulacion);			
			[eta u v] = getEtaUV(simulacion, solHidro.Solucion(:,end));
			modVel = sqrt(u.^2 + v.^2);

		end % function moduloVelocidad

		function hom = profundidadMedia(sim)

			bat = getBatimetria(sim);
			hom = mean(bat.hoNodosEta);

		end % function profundidadMedia

		function rel = relacionAspecto(sim)

			L = longitudCaracteristica(sim);
			bat = getBatimetria(sim);
			hom = mean(bat.hoNodosEta);

			rel = L/hom;

		end % function relacionAspecto

		function eleCarac = longitudCaracteristica(sim)
			% Reviasr definición de longitud
			malla = getMalla(sim);
			Lx = max(malla.coordenadasU(:,1)) - ... 	
			     min(malla.coordenadasU(:,1));
			Ly = max(malla.coordenadasV(:,2)) - ... 	
			     min(malla.coordenadasV(:,2));
			eleCarac = max([Lx Ly]);

		end % function longitudCaracteristica

		function tiempoCarac = tiempoCaracteristico(sim)

			L = longitudCaracteristica(sim);
			par = getParametros(sim);
			g = par.aceleracionGravedad;
			hom = profundidadMedia(sim);
			tiempoCarac = 2*L/sqrt(g*hom);

		end % function tiempoCaracteristico

		function [errorAjuste varargout] = validaKranenburg(simulacion, varargin)

			if ~strcmpi(class(simulacion.ListaForzantes{1}), 'vientouniforme')
				error('La distribución de velocidad de Kranenburg es sólo válida para un forzante de clase VientoUniforme')
			end

			if ~strcmpi(class(simulacion.Cuerpo.Geometria), 'geokranenburg')
				error('La distribución de velocidad de Kranenburg es sólo válida para una geometria de clase GeoKranenburg')
			end

			% Detecta direccion del viento 
			viento = simulacion.ListaForzantes{1};

			if quant(cos(viento.anguloDireccion),1e-15) ~= 0
				direccionPerfil = 'y';
			elseif quant(sin(viento.anguloDireccion),1e-15) ~= 0 
				direccionPerfil = 'x';
			else
				error(['Por construcción de la función, la dirección ' ...
					'del viento debe estar alineada con algún ' ...
					' eje principal, x o y'])
			end

			malla = getMalla(simulacion);
			geo = getGeometria(simulacion);
			alturaH = geo.alturaH;
			radioR = geo.radioR;
			centro = geo.centroMasa;
			parametros = getParametros(simulacion);
			zo = parametros.zoAsperezaAgua;
			kappaVonKarman = parametros.kappaVonKarman;
			lnZ = log(alturaH/zo);
			uAsterisco = viento.uAsterisco;
			velAdKran = inline('-0.5 + sqrt(0.5 - 0.5*(sqrt((coord - centro).^2))/R)', 'coord', 'centro', 'R');

			solHidro = getHidrodinamica(simulacion);

			[eta u v] = getEtaUV(simulacion, solHidro.Solucion(:,end)); % Se asume que si la solucion es impermanente, el ultimo tiempo es el Regimen Permanente

			coordenadasEta = malla.coordenadasEta;
			interpU = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(u)); % Interpolador u
			interpV = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(v)); % Interpolador v
			bat = getBatimetria(simulacion);
			interphoEta = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), bat.hoNodosEta); % hoeta

			if strcmpi(direccionPerfil, 'x') 

				buscaPosPerfil = malla.coordenadasEta2DY;
				minPosPerfil = min(min(buscaPosPerfil));
				fraccionPosicion = 0.5;
				posPerfil = minPosPerfil + fraccionPosicion*abs(max(max(buscaPosPerfil)) - minPosPerfil); 
				[fila col] = find(buscaPosPerfil <= posPerfil);
				entradaPosterior = min(fila);				
				entradaAnterior = entradaPosterior - 1;
				largoCoordenadas = length(malla.coordenadasEta2DX(:, 1));
				coordenadasPerfil = [malla.coordenadasEta2DX(entradaAnterior,:)', posPerfil*ones(largoCoordenadas,1)]; % Falta ver bien como se obtienen las coordenadas
				labelXPlot = '$x [m]$';
				coordXPlot = 1;
				uInterp = interpU(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				vInterp = interpV(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				hoInterp = interphoEta(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				velInterpAdim = -kappaVonKarman*sqrt(uInterp.^2 + vInterp.^2)/(lnZ*uAsterisco);
				velInterpAdim = velInterpAdim.*sign(vInterp);
				pegaInicio = min(malla.coordenadasV(:,2));
				pegaFinal = max(malla.coordenadasV(:,2));


			elseif strcmpi(direccionPerfil, 'y') 

				buscaPosPerfil = malla.coordenadasEta2DX;
				minPosPerfil = min(min(buscaPosPerfil));
				fraccionPosicion = 0.5;
				posPerfil = minPosPerfil + fraccionPosicion*abs(max(max(buscaPosPerfil)) - minPosPerfil); 
				[fila col] = find(buscaPosPerfil <= posPerfil);
				entradaAnterior = max(col);
				entradaPosterior = entradaAnterior + 1;	
				largoCoordenadas = length(malla.coordenadasEta2DY(:, 1));
				coordenadasPerfil = [posPerfil*ones(largoCoordenadas,1), malla.coordenadasEta2DY(:, entradaAnterior)];
				labelXPlot = '$y [m]$';
				coordXPlot = 2;
				uInterp = interpU(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				vInterp = interpV(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				hoInterp = interphoEta(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				velInterpAdim = -kappaVonKarman*sqrt(uInterp.^2 + vInterp.^2)/(lnZ*uAsterisco);
				velInterpAdim = velInterpAdim.*sign(uInterp);
				pegaInicio = min(malla.coordenadasU(:,2));
				pegaFinal = max(malla.coordenadasU(:,2));

			end

			coordPerfilKran = min(coordenadasPerfil(:,coordXPlot)):(max(coordenadasPerfil(:,coordXPlot)) - ... 
					  min(coordenadasPerfil(:,coordXPlot)))/100:max(coordenadasPerfil(:,coordXPlot));

			coordPerfilKran = [pegaInicio, coordPerfilKran, pegaFinal];

			if ~isempty(varargin) && varargin{1} == 1
				pl = plot(coordPerfilKran, velAdKran(coordPerfilKran, centro(coordXPlot), radioR), 'k','linewidth', 1.5);
				hold on 
				sc = scatter(coordenadasPerfil(:,coordXPlot), velInterpAdim);
%				velAdKran = inline('0.5 + sqrt(0.5 - 0.5*(sqrt((coord - centro).^2))/R)', 'coord', 'centro', 'R');
%				pl = plot(coordPerfilKran, velAdKran(coordPerfilKran, centro(coordXPlot), radioR), 'k','linewidth', 1.5);
%				hold on 
%				sc = scatter(coordenadasPerfil(:,coordXPlot), hoInterp/alturaH);
%				% keyboard

				hold off
				xlabel(labelXPlot, 'interpreter', 'latex')	
				ylabel('$\frac{U_o \kappa}{u_* \ln{Z}}$', 'interpreter', 'latex')
				handle.plot = pl;
				handle.scatter = sc;

				varargout{1} = handle;

				if length(varargin) == 2 
				
					if varargin{2} == 1

						velAd = velAdKran(coordPerfilKran, centro(coordXPlot), radioR);
						velCarac.velAdProm = abs(mean(velAd));
						velCarac.velAdMax = max(velAd);
						velCarac.velAdPromPos = mean(velAd(velAd > 0));
						velCarac.velAdPromNeg = abs(mean(velAd(velAd < 0)));
						velCarac.velProm = velCarac.velAdProm*(lnZ*uAsterisco/kappaVonKarman);
						velCarac.velMax = velCarac.velAdMax*(lnZ*uAsterisco/kappaVonKarman);
						velCarac.velPromPos = velCarac.velAdPromPos*(lnZ*uAsterisco/kappaVonKarman);
						velCarac.velPromNeg = velCarac.velAdPromNeg*(lnZ*uAsterisco/kappaVonKarman);
						varargout{2} = velCarac;

					end
				end

			end

			difVel = abs(velAdKran(coordenadasPerfil(:,coordXPlot), centro(coordXPlot), radioR) - velInterpAdim);
			fNan = find(~isnan(difVel));
			difVel = difVel(fNan);
			errorAjuste = sqrt(sum(difVel.^2));
			% keyboard
		end % function validacionKranenburg

		function calculos = calculosDeltaCorregido(simulacion)

			calculos = [];
			bat = getBatimetria(simulacion);
			unoSobreHoMedio = mean(1./bat.hoNodosEta);
			solHidro = getHidrodinamica(simulacion);
			[eta u v]= getEtaUV(simulacion, solHidro.Solucion);
			etaMax = max(eta); %positivo
			etaMin = min(eta); %negativo
			deltaModelo = etaMax*unoSobreHoMedio;
			L = longitudCaracteristica(simulacion);
			forz = getForzante(simulacion);
			uAsterisco = getUAsterisco(forz);
			coefFriccion = forz.coeficienteFriccion;
			par = getParametros(simulacion);
			g = par.aceleracionGravedad;
			unoSobreWed = (L*uAsterisco^2/g)*(unoSobreHoMedio)^2;
			wed = 1/unoSobreWed; 
			promModVelSobreHoMedio = mean(sqrt(u.^2 + v.^2)./bat.hoNodosEta);
			froudeTilde = sqrt((coefFriccion/g)*promModVelSobreHoMedio);
			deltaCorregido = 0.5*(unoSobreWed - froudeTilde^2*L*unoSobreHoMedio);

			calculos.wed = wed;
			calculos.froudeTilde = froudeTilde;
			calculos.L = L;
			calculos.unoSobreHoMedio = unoSobreHoMedio;
			calculos.promModVelSobreHoMedio = promModVelSobreHoMedio;
			calculos.uAsterisco = uAsterisco;
			calculos.coefFriccion = coefFriccion;
			calculos.deltaModelo = deltaModelo;
			calculos.deltaCorregido = deltaCorregido;

		end %function calculosDeltaCorregido

		function calculos = calculosFlujosOxigeno(sim)

			calculos = [];
			trans = getTransporte(sim);
			masa = getMasa(trans);
			cSat = masa.concSaturacion;
			fSed = masa.FlujosVerticales.flujoSed;
			S = fSed.S;
			kt = fSed.kt;
			fAtm = masa.FlujosVerticales.flujoAtm;
			kl = fAtm.kl; 

			% Calculo concentracion de mezcla completa
			concPos = 0:cSat/100:cSat;

			for iC = 1:length(concPos)
				flujosPos(iC) = fSed.funcion(S, mean(kt), ... 
				concPos(iC)) + fAtm.funcion(kl, cSat, ...
				concPos(iC));	
			end

			cMezclaCompleta = linterp(-flujosPos, ...
			concPos, 0);
			distConc = trans.Solucion;
			cPromedio = mean(distConc);
			unoSobreDFsedMC = 1/fSed.dFuncion(S, mean(kt), cMezclaCompleta);
			unoSobreDFsedProm = mean(1./fSed.dFuncion(S, kt, distConc));
			unoSobrePromKt = 1/mean(kt);
			PromUnoSobreKt = mean(1./kt);

			fSedProm = mean(fSed.funcion(S, kt, distConc));
			fSedMC = fSed.funcion(S, mean(kt), cMezclaCompleta);
			fAtmProm = mean(fAtm.funcion(kl, cSat, distConc));
			fAtmMC = fAtm.funcion(kl, cSat, cMezclaCompleta);

			deltaFConVF = (S/(2*kl*cSat))*(PromUnoSobreKt - unoSobrePromKt ...
					+ unoSobreDFsedProm - unoSobreDFsedMC);
			deltaFSinVF = (S/(2*kl*cSat))*(PromUnoSobreKt - unoSobrePromKt ...
					- unoSobreDFsedMC);
			% deltaFDesdeFlujos = (abs(fSedProm) - abs(fSedMC))/(kl*cSat);
			deltaFDesdeFlujos = (fSedProm - fSedMC)/(kl*cSat);
			deltaFDesdeConc = (cPromedio - cMezclaCompleta)/(cSat);

			pecletPromedio =  mean(pecletVertical(trans, sim));
			wed = numeroWedderburn(sim);
			relAsp = relacionAspecto(sim);
			hom = profundidadMedia(sim);
			reynoldsProm = mean(numeroReynolds(sim));
			velProm = mean(moduloVelocidad(sim));
			L = longitudCaracteristica(sim);
			tAdveccionProm = mean(L/moduloVelocidad(sim));
		
			bat = getBatimetria(sim);
			heta = bat.hoNodosEta;
			solHidro = getHidrodinamica(sim);
			eta = getEtaUV(sim, solHidro.Solucion(:,end));
			tDifVertProm = mean((heta + eta)./abs(fSed.dFuncion(S, kt, cMezclaCompleta) - kl));
	
			calculos.deltaFConVF = deltaFConVF;
			calculos.deltaFSinVF = deltaFSinVF;
			calculos.deltaFDesdeFlujos = deltaFDesdeFlujos;
			calculos.deltaFDesdeConc = deltaFDesdeConc;
			calculos.cPromedio = cPromedio;
			calculos.cMezclaCompleta = cMezclaCompleta;
			calculos.fAtmProm = fAtmProm;
			calculos.fAtmMC = fAtmMC;						
			calculos.fSedProm = fSedProm;
			calculos.fSedMC = fSedMC;
			calculos.pecletPromedio = pecletPromedio;
			calculos.wed = wed;
			calculos.relAsp = relAsp;
			calculos.hom = hom;
			calculos.reynoldsProm = reynoldsProm;
			calculos.velProm = velProm;
			calculos.kt = kt;
			calculos.ktProm = mean(kt);
			calculos.kl = kl;
			calculos.tDifVertProm = tDifVertProm;
			calculos.tAdveccionProm = tAdveccionProm;
		end %calculosFlujosOxigeno

		function areaTotal = areaSuperficial(simulacion)

			[deltaX deltaY] = getDeltaX(simulacion);
			nEta = getNumeroNodos(simulacion);
			areaTotal = nEta*deltaX*deltaY;

		end %areaSuperficial


		function calculos = energiaDesdeSolucion(simulacion, varargin)

			solHidro = getHidrodinamica(simulacion);

			if strcmpi(class(solHidro), 'analisismodal')

				vectoresDerechaMasR = solHidro.VyVPropios.ProblemaDerecha.Vectores.MasR;
				vectoresDerechaMenosR = solHidro.VyVPropios.ProblemaDerecha.Vectores.MenosR;
				vectoresDerechaOmegaCero = solHidro.VyVPropios.ProblemaDerecha.Vectores.OmegaCero;
				vectoresIzquierdaMasR = solHidro.VyVPropios.ProblemaIzquierda.Vectores.MasR;
				vectoresIzquierdaMenosR = solHidro.VyVPropios.ProblemaIzquierda.Vectores.MenosR;
				vectoresIzquierdaOmegaCero = solHidro.VyVPropios.ProblemaIzquierda.Vectores.OmegaCero;
				valoresOmegaCero = solHidro.VyVPropios.ProblemaDerecha.Valores.OmegaCero;
				valoresDerechaMasR = solHidro.VyVPropios.ProblemaDerecha.Valores.MasR;

				[M, K, C] = getMatrices(simulacion);
				[nEta, nU, nV] = getNumeroNodos(simulacion);
				areaTotal = areaSuperficial(simulacion);
				eTildeDerechaMasR = dot(vectoresIzquierdaMasR, M*vectoresDerechaMasR)*areaTotal;
				eTildeDerechaOmegaCero = dot(vectoresIzquierdaOmegaCero, ...
							 M*vectoresDerechaOmegaCero)*areaTotal;

%				iOMGeTildeDerMasR = i*(real(valoresDerechaMasR).' +  ... 
%						    i*imag(valoresDerechaMasR).').*eTildeDerechaMasR;
%				iOMGeTildeDerOmegaCero = i*(real(valoresOmegaCero).' +  ... 
%						    i*imag(valoresOmegaCero).').*eTildeDerechaOmegaCero;

				iOMGeTildeDerMasR = i*dot(vectoresIzquierdaMasR, (K+C)*vectoresDerechaMasR)*areaTotal;
				% iOMGeTildeDerMenosR = i*dot(vectoresIzquierdaMenosR, ... 
				%  		      (K+C)*vectoresDerechaMenosR)*areaTotal;
				iOMGeTildeDerOmegaCero = i*dot(vectoresIzquierdaOmegaCero, ...
				 			 (K+C)*vectoresDerechaOmegaCero)*areaTotal;

				solTiempo = solHidro.Solucion;
				cuantosMasR = length(vectoresDerechaMasR(1,:));
				cuantosOmegaCero = length(vectoresDerechaOmegaCero(1,:));

				if strcmpi(varargin{1}, 'permanente') 

					forzanteExterno = simulacion.Matrices.f;
					fTildeMasR = dot(vectoresIzquierdaMasR, repmat(forzanteExterno, 1, cuantosMasR))*areaTotal;
					% fTildeMenosR = dot(vectoresIzquierdaMenosR, repmat(forzanteExterno, 1, cuantosMasR))*areaTotal;
					fTildeOmegaCero = dot(vectoresIzquierdaOmegaCero, repmat(forzanteExterno, 1, ...
							  cuantosOmegaCero))*areaTotal;

					ampMasR = -fTildeMasR./(iOMGeTildeDerMasR);
%					tRP = 10000000;
%					ampMasRAnalitica = ;
					% ampMenosR = -fTildeMenosR./(iOMGeTildeDerMenosR);
					ampOmegaCero = -fTildeOmegaCero./(iOMGeTildeDerOmegaCero);

					solModosR = sparse(length(vectoresIzquierdaMasR(:,1)),1);
					solModosOmegaCero = solModosR;
					solAcumulada = solModosR;

					tiempoForzante = 1;

					energiaModoR = zeros(cuantosMasR, length(tiempoForzante));
					energiaPotModoR = energiaModoR;
					energiaCinModoR = energiaModoR;
					wPuntoModoR = energiaModoR;
					dPuntoModoR = energiaModoR;
					energiaOmegaCero = zeros(cuantosOmegaCero, length(tiempoForzante));
					energiaPotOC = energiaOmegaCero;
					energiaCinOC = energiaOmegaCero;
					wPuntoOC = energiaOmegaCero;
					dPuntoOC = energiaOmegaCero;

					for iModo = 1:cuantosMasR

						solAuxiliar = 2*real(ampMasR(iModo)*vectoresDerechaMasR(:,iModo));
						energiaModoR(iModo, :) = 0.5*dot(solAuxiliar, M*solAuxiliar)*areaTotal;
						MsolAux = M*solAuxiliar;
						energiaPotModoR(iModo, :) = 0.5*dot(solAuxiliar(1:nEta), MsolAux(1:nEta))*areaTotal;
						energiaCinModoR(iModo, :) = 0.5*dot(solAuxiliar(nEta+1:end), MsolAux(nEta+1:end))*areaTotal;
						wPuntoModoR(iModo, :) = dot(forzanteExterno, solAuxiliar)*areaTotal;
						dPuntoModoR(iModo, :) = -sqrt(-1)*dot(solAuxiliar, C*solAuxiliar)*areaTotal;


						solModosR = solModosR + solAuxiliar;

					end

					energiaAcumModoR = 0.5*dot(solModosR, M*solModosR)*areaTotal
					energiaAcumModoR2 = sum(energiaModoR)

					for iModo = 1:cuantosOmegaCero
				
						solAuxiliar = ampOmegaCero(iModo)*vectoresDerechaOmegaCero(:,iModo);
						energiaOmegaCero(iModo, :) = 0.5*dot(solAuxiliar, M*solAuxiliar)*areaTotal;
						MsolAux = M*solAuxiliar;
						energiaPotOC(iModo, :) = 0.5*dot(solAuxiliar(1:nEta), MsolAux(1:nEta))*areaTotal;
						energiaCinOC(iModo, :) = 0.5*dot(solAuxiliar(nEta+1:end), MsolAux(nEta+1:end))*areaTotal;
						wPuntoOC(iModo, :) = dot(forzanteExterno, solAuxiliar)*areaTotal;
						dPuntoOC(iModo, :) = -sqrt(-1)*dot(solAuxiliar, C*solAuxiliar)*areaTotal;

						solModosOmegaCero = solModosOmegaCero + solAuxiliar;
							
					end

					energiaAcumModoOC = 0.5*dot(solModosOmegaCero, M*solModosOmegaCero)*areaTotal
					energiaAcumModoOC2 = sum(energiaOmegaCero)



					solAcumulada = solModosR + solModosOmegaCero;
					graficaEta(Grafico(), simulacion, solAcumulada(1:nEta))
					% solAcumulada = solModosR;

					calculos.ampMasR = ampMasR;
					calculos.energiaModoR = energiaModoR;
					calculos.energiaPotModoR = energiaPotModoR;
					calculos.energiaCinModoR = energiaCinModoR;
					calculos.ampOmegaCero = ampOmegaCero;
					calculos.energiaOmegaCero = energiaOmegaCero;
					calculos.energiaPotOC = energiaPotOC;
					calculos.energiaCinOC = energiaCinOC;
					calculos.energiaTotalAntigua = 0.5*dot(solTiempo, M*solTiempo)*areaTotal;
					calculos.energiaTotalNueva = 0.5*dot(solAcumulada, M*solAcumulada)*areaTotal;
					MsolAcum = M*solAcumulada;
					calculos.energiaPotencial = 0.5*dot(solAcumulada(1:nEta), MsolAcum(1:nEta))*areaTotal;
					calculos.energiaCinetica = 0.5*dot(solAcumulada(nEta+1:end), MsolAcum(nEta+1:end))*areaTotal;
					calculos.energiaTotalModos = sum(energiaModoR) + sum(energiaOmegaCero);
					calculos.energiaTotalModosPot = sum(energiaPotModoR) + sum(energiaPotOC);
					calculos.energiaTotalModosCin = sum(energiaCinModoR) + sum(energiaCinOC);
					calculos.wPunto = dot(forzanteExterno, solAcumulada)*areaTotal;
					calculos.dPunto = -sqrt(-1)*dot(solAcumulada, C*solAcumulada)*areaTotal;
					calculos.wPuntoFor = sum(wPuntoModoR) + sum(wPuntoOC);
					calculos.dPuntoFor = sum(dPuntoModoR) + sum(dPuntoOC);
					
					calculos.solAcumulada = solAcumulada;
					calculos.wed = numeroWedderburn(simulacion);

%					keyboard

				elseif strcmpi(varargin{1}, 'impermanente')

					if isempty(solHidro.Tiempo)

						% Si el forzante es constante en el tiempo. 
						% Entonces creo un vector de tiempo arbitrario

						tCarac = tiempoCaracteristico(simulacion);
						tiempoCalculo = (0:0.05:60)*tCarac; 
						% Este vector de tiempo ha resuelto 
						% satisfactoriamente casos para Wed < 3700
						% Se probó con dt = 0.01 y no hubo cambios
						% importantes en la solución. Sin embargo
						% lo ideal sería definir el tiempo 
						% caracteristico del problema en función 
						% del numero de Wedderburn, ya que incluye
						% el efecto del viento. Revisar			
						deltaT = abs(tiempoCalculo(1)-tiempoCalculo(2));
						nTiempoCalculo = length(tiempoCalculo);
					
						forzanteExterno = simulacion.Matrices.f;
						forzanteExterno = repmat(forzanteExterno, 1, nTiempoCalculo);

					else

						% Si el forzante varía en el tiempo. 
						% Entonces tomo los datos de tiempo del forzante
						tiempoCalculo = solHidro.Tiempo;
						deltaT = abs(tiempoCalculo(1)-tiempoCalculo(2)); %asumo deltaT constante
						nTiempoCalculo = length(tiempoCalculo);

					end %if

%					aTildeDerechaMasR = sparse(length(tiempoCalculo), cuantosVectoresR);
%					aTildeDerechaMenosR = aTildeDerechaMasR;
%					aTildeDerechaOmegaCero = sparse(length(tiempoCalculo), cuantosVectoresOmegaCero);
					ampMasR = sparse(cuantosMasR, length(tiempoCalculo));
					% ampMenosR = ampMasR;
					ampOmegaCero = sparse(cuantosOmegaCero, length(tiempoCalculo));

					solModosR = sparse(length(vectoresIzquierdaMasR(:,1)), nTiempoCalculo);
					solModosOmegaCero = solModosR;
					solAcumulada = solModosR;

					energiaModoR = ampMasR;
					energiaPotModoR = energiaModoR;
					energiaCinModoR = energiaModoR;
					energiaOmegaCero = ampOmegaCero;
					energiaPotOC = energiaOmegaCero;
					energiaCinOC = energiaOmegaCero;		
					% barraEspera = waitbar(0,'Please wait..');

					% Loop para el tiempo

					iOMGeTildeDerMasR = iOMGeTildeDerMasR.';
					eTildeDerechaMasR = eTildeDerechaMasR.';
					iOMGeTildeDerOmegaCero = iOMGeTildeDerOmegaCero.';
					eTildeDerechaOmegaCero = eTildeDerechaOmegaCero.';

					for iTiempo = 2:nTiempoCalculo
						% waitbar(iTiempo/nTiempoCalculo)
						iTiempo/nTiempoCalculo

						fTMasRTmUno = dot(vectoresIzquierdaMasR, ...
						              repmat(forzanteExterno(:,iTiempo-1), 1, cuantosMasR))*areaTotal;
						fTMasRT = dot(vectoresIzquierdaMasR, ... 
							  repmat(forzanteExterno(:,iTiempo), 1, cuantosMasR))*areaTotal;
						fTildeMasRProm = 0.5*(fTMasRTmUno + fTMasRT);
						fTildeMasRProm = fTildeMasRProm.';
						% ampMasR(iTiempo,:) = ((0.5*iOMGeTildeDerMasR + eTildeDerechaMasR/deltaT).*aTildeDerechaMasR(iTiempo-1,:) + fTildeMasRProm)./(eTildeDerechaMasR/deltaT - 0.5*iOMGeTildeDerMasR); 
						% keyboard
						ampMasR(:, iTiempo) = ((0.5*iOMGeTildeDerMasR + eTildeDerechaMasR/deltaT).*ampMasR(:, iTiempo-1) ... 	
								      + fTildeMasRProm)./(eTildeDerechaMasR/deltaT - 0.5*iOMGeTildeDerMasR); 


%						fTMenosRTmUno = dot(vectoresIzquierdaMenosR, ...
%						              repmat(forzanteExterno(:,iTiempo-1), 1, cuantosVectoresR))*areaTotal;
%						fTMenosRT = dot(vectoresIzquierdaMenosR, ... 
%							  repmat(forzanteExterno(:,iTiempo), 1, cuantosVectoresR))*areaTotal;
%						fTildeMenosRProm = 0.5*(fTMenosRTmUno + fTMenosRT);

%						aTildeDerechaMenosR(iTiempo,:) = ((0.5*iOMGeTildeDerMenosR + eTildeDerechaMenosR/deltaT).*aTildeDerechaMenosR(iTiempo-1,:) + fTildeMenosRProm)./(eTildeDerechaMenosR/deltaT - 0.5*iOMGeTildeDerMenosR); 

						fTOmCeroTmUno = dot(vectoresIzquierdaOmegaCero, ...
						              repmat(forzanteExterno(:,iTiempo-1), 1, cuantosOmegaCero))*areaTotal;
						fTOmCeroT = dot(vectoresIzquierdaOmegaCero, ... 
							  repmat(forzanteExterno(:,iTiempo), 1, cuantosOmegaCero))*areaTotal;
						fTildeOmCeroProm = 0.5*(fTOmCeroTmUno + fTOmCeroT);
						fTildeOmCeroProm = fTildeOmCeroProm.';

						% aTildeDerechaOmegaCero(iTiempo,:) = ((0.5*iOMGeTildeDerOmegaCero + eTildeDerechaOmegaCero/deltaT).*aTildeDerechaOmegaCero(iTiempo-1,:) + fTildeOmCeroProm)./(eTildeDerechaOmegaCero/deltaT - 0.5*iOMGeTildeDerOmegaCero);
						ampOmegaCero(:, iTiempo) = ((0.5*iOMGeTildeDerOmegaCero + eTildeDerechaOmegaCero/deltaT).*ampOmegaCero(:, iTiempo-1) ... 
									   + fTildeOmCeroProm)./(eTildeDerechaOmegaCero/deltaT - 0.5*iOMGeTildeDerOmegaCero);  

						for iModo = 1:cuantosMasR

							% solAuxiliar = 2*real(ampMasR(iModo)*vectoresDerechaMasR(:,iModo));
							solAuxiliar = 2*real(ampMasR(iModo, iTiempo)*vectoresDerechaMasR(:,iModo));
							energiaModoR(iModo, iTiempo) = 0.5*dot(solAuxiliar, M*solAuxiliar)*areaTotal;
							MsolAux = M*solAuxiliar;
							energiaPotModoR(iModo, iTiempo) = 0.5*dot(solAuxiliar(1:nEta), MsolAux(1:nEta))*areaTotal;
							energiaCinModoR(iModo, iTiempo) = 0.5*dot(solAuxiliar(nEta+1:end), MsolAux(nEta+1:end))*areaTotal;
							% solModosR = solModosR + solAuxiliar;
							solModosR(:,iTiempo) = solModosR(:,iTiempo) + solAuxiliar;

						end

						for iModo = 1:cuantosOmegaCero
				
							% solAuxiliar = ampOmegaCero(iModo)*vectoresDerechaOmegaCero(:,iModo);
							solAuxiliar = ampOmegaCero(iModo, iTiempo)*vectoresDerechaOmegaCero(:,iModo);
							energiaOmegaCero(iModo, iTiempo) = 0.5*dot(solAuxiliar, M*solAuxiliar)*areaTotal;
							MsolAux = M*solAuxiliar;
							energiaPotOC(iModo, iTiempo) = 0.5*dot(solAuxiliar(1:nEta), MsolAux(1:nEta))*areaTotal;
							energiaCinOC(iModo, iTiempo) = 0.5*dot(solAuxiliar(nEta+1:end), MsolAux(nEta+1:end))*areaTotal;
							% solModosOmegaCero = solModosOmegaCero + solAuxiliar;
							solModosOmegaCero(:,iTiempo) = solModosOmegaCero(:,iTiempo) + solAuxiliar;
							
						end

					end % for iTiempo

					solAcumulada = solModosR + solModosOmegaCero;

					wPunto = dot(forzanteExterno, solAcumulada)*areaTotal;
					dPunto = -sqrt(-1)*dot(solAcumulada, C*solAcumulada)*areaTotal;

					calculos.ampMasR = ampMasR;
					calculos.energiaModoR = energiaModoR;
					calculos.energiaPotModoR = energiaPotModoR;
					calculos.energiaCinModoR = energiaCinModoR;
					calculos.ampOmegaCero = ampOmegaCero;
					calculos.energiaOmegaCero = energiaOmegaCero;
					calculos.energiaPotOC = energiaPotOC;
					calculos.energiaCinOC = energiaCinOC;
					calculos.energiaTotal = 0.5*dot(solAcumulada, M*solAcumulada)*areaTotal;
					MsolAcum = M*solAcumulada;
					calculos.energiaPotencial = 0.5*dot(solAcumulada(1:nEta, :), MsolAcum(1:nEta, :))*areaTotal;
					calculos.energiaCinetica = 0.5*dot(solAcumulada(nEta+1:end, :), MsolAcum(nEta+1:end, :))*areaTotal;
					calculos.energiaTotalModos = sum(energiaModoR) + sum(energiaOmegaCero);
					calculos.energiaTotalModosPot = sum(energiaPotModoR) + sum(energiaPotOC);
					calculos.energiaTotalModosCin = sum(energiaCinModoR) + sum(energiaCinOC);
					calculos.wPunto = wPunto;
					calculos.dPunto = dPunto;
					calculos.solAcumulada = solAcumulada;
								

				end %if

			end %if

		end %energiaDesdeSolucion


		function calculos = calculosEnergia(simulacion)

			calculos = [];
			[M, K, C] = getMatrices(simulacion);
			f = simulacion.Matrices.f;

			solHidro = getHidrodinamica(simulacion);
			wed = numeroWedderburn(simulacion);
			wPunto = dot(f, solHidro.Solucion(:,end))*areaSuperficial(simulacion);	
			mSol = M*solHidro.Solucion(:,end);
			nEta = getNumeroNodos(simulacion);
			eTotal = 0.5*dot(solHidro.Solucion(:,end), mSol)*areaSuperficial(simulacion);	
			ePot = 0.5*dot(solHidro.Solucion(1:nEta,end), mSol(1:nEta))*areaSuperficial(simulacion);	
			eCin = 0.5*dot(solHidro.Solucion(nEta + 1:end,end), mSol(nEta + 1:end))* ... 
			       areaSuperficial(simulacion);	

			calculos.wed = wed;
			calculos.wPunto = wPunto;
			calculos.eTotal = eTotal;
			calculos.ePot = ePot;
			calculos.eCin = eCin;

		end %function calculosEnergia


	end%methods 
end%classdef 

%%%%%%%%%%%%%%%%%%%%%%%% THRASH



