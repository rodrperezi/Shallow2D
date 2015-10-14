classdef VolumenesFinitos < Transporte

	properties

		Flujos
		Masa
		tiempoComputo
		ConcentracionInicial
		

	end %properties

	methods
		
		function thisVolumenesFinitos = VolumenesFinitos(thisVolumenesFinitos, simulacion, varargin)

			if nargin == 0
				thisVolumenesFinitos;
			else 
				thisVolumenesFinitos = asignaPropiedad(thisVolumenesFinitos, varargin{:});

				regTemporal = thisVolumenesFinitos.RegimenTemporal;
				masa = thisVolumenesFinitos.Masa;
				flujos = thisVolumenesFinitos.Flujos;
				condInicial = thisVolumenesFinitos.ConcentracionInicial;
				
				if(~isempty(regTemporal) && ~isempty(masa) && ~isempty(flujos))
					
					if strcmpi(regTemporal, 'impermanente') && ~isempty(condInicial)

						thisVolumenesFinitos = volumenesFinitos(thisVolumenesFinitos, ...
						simulacion);			

					elseif strcmpi(regTemporal, 'permanente')

						thisVolumenesFinitos = volumenesFinitos(thisVolumenesFinitos, ...
						simulacion);			

					end %if

					simulacion = addResultados(simulacion, thisVolumenesFinitos);


				end %if
			end %if

		end %VolumenesFinitos

		function thisVolumenesFinitos = volumenesFinitos(thisVolumenesFinitos, simulacion)

			if isempty(simulacion.Resultados) 
						
				error(['La simulacion aún no tiene resuelta la Hidrodinámica'])
				
			end
			
			tic
			%%%% Aqui se aplica la resolucion

			regTemporal = thisVolumenesFinitos.RegimenTemporal;
			% flujos = thisVolumenesFinitos.Flujos;
			% masa = thisVolumenesFinitos.Masa;
			
			if strcmpi(regTemporal, 'permanente')
			
				solHidro = getHidrodinamica(simulacion);
				
				if strcmpi(solHidro.RegimenTemporal, 'permanente')

					sol = solHidro.Solucion;

				elseif strcmpi(solHidro.RegimenTemporal, 'impermanente')
			
					% asumo que si quiero ver 
					% la solucion en el regimen permanente
					% de una simulacion impermanente entonces
					% la ultima columna de la hidrodinamica
					%  es el regimen permanente

					sol = solHidro.Solucion(:,end);

				end

				% Defino coeficientes de transporte
				% keyboard
				coefTransEta = coefTransporte(thisVolumenesFinitos, simulacion, sol);

				% Itero volumenes finitos hasta alcanzar estado de equilibrio
				thisVolumenesFinitos.Solucion = iteraVolFinitos(thisVolumenesFinitos, simulacion, ...
						        sol, coefTransEta);	

			elseif strcmpi(regTemporal, 'impermanente')

				solHidro = getHidrodinamica(simulacion);
				
				if strcmpi(solHidro.RegimenTemporal, 'impermanente')

					nEta = getNumeroNodos(simulacion);
					sol = solHidro.Solucion;
					solVF = sparse(zeros(size(sol(1:nEta,:))));
					tiempo = solHidro.Tiempo;
					deltaT = tiempo(2) - tiempo(1); %Asumo deltaT uniforme


					etaInicial = sol(1:nEta,1);
					concInicial = thisVolumenesFinitos.ConcentracionInicial;

					if length(etaInicial) ~= length(concInicial)

						error('La concentracion inicial debe ser un vector del tamaño de eta')

					end

					variaTempo.eta0 = etaInicial;
					variaTempo.cp0 = concInicial;
					variaTempo.deltaT = deltaT;
					solVF(:,1) = concInicial;

					barraEspera = waitbar(0, 'Resolviendo volumenes finitos');
					
					for iT = 2:length(tiempo)
				
						waitbar(iT/length(tiempo))

						% Defino coeficientes de transporte
						% keyboard
						coefTransEta = coefTransporte(thisVolumenesFinitos, simulacion, sol(:,iT));

						% Itero volumenes finitos hasta alcanzar estado de equilibrio
						solVF(:,iT) = iteraVolFinitos(thisVolumenesFinitos, simulacion, ...
									sol(:,iT), coefTransEta, variaTempo);	

						variaTempo.eta0 = sol(1:nEta,iT);
						variaTempo.cp0 = solVF(:,iT);

					end

					close(barraEspera)

					thisVolumenesFinitos.Solucion = solVF;
					thisVolumenesFinitos.Tiempo = tiempo;

				elseif strcmpi(solHidro.RegimenTemporal, 'permanente')
			
					error(['No puedes resolver volumenes finitos impermanente ' ...
					      'si el regimen temporal de la hidrodinamica es permanente'])

				end %if

			end %if

			thisVolumenesFinitos.tiempoComputo = toc;

		end %function volumenesFinitos

		function coefTransEta = coefTransporte(thisVolumenesFinitos, simulacion, solucion)

			coefDispersion = coeficientesDispersion(thisVolumenesFinitos, simulacion, solucion);
			coefTransEta = leyDePotencia(thisVolumenesFinitos, simulacion, coefDispersion);
			% keyboard

		end %function coefTransporte
	
		function coefDispersion = coeficientesDispersion(thisVolumenesFinitos, simulacion, solucion)
			% keyboard
			% Extraigo parametros para calculo de los coeficientes
			parametros = getParametros(simulacion);
			malla = getMalla(simulacion);	
			bat = getBatimetria(simulacion);
			forza = getForzante(simulacion);
			coefFriccion = forza.coeficienteFriccion;

			masa = thisVolumenesFinitos.Masa;
			coefDifusion = masa.coefDifusion;
		
			hoWE = bat.hoNodosU;
			hoNS = bat.hoNodosV;

			eL = parametros.dispLong;
			eT = parametros.dispTrans;

			[Neta Nu Nv] = getNumeroNodos(simulacion);

			IDwe = malla.matrizIDwe;
			IDns = malla.matrizIDns;
			IDuwe = zeros(Nu,2);
			IDvns = zeros(Nv,2);

			nBDe = malla.numeroBordesDerecho;
			nBIz = malla.numeroBordesIzquierdo;
			nBSu = malla.numeroBordesSuperior;
			nBIn = malla.numeroBordesInferior;

			% Velocidades auxiliares para cálculo de ángulo de linea
			% de corriente. El ángulo de la linea de corriente 
			% con respecto al eje de coordenadas fijo (x,y)
			% se calcula como el arcotangente entre las 
			% componentes de la velocidad en cada nodo. Como 
			% necesito conocer el ángulo en los nodos de velocidad
			% entonces hay que promediar las velocidades "v" para 
			% nodos "u" y lo mismo para los nodos "v" pero promediando
			% las velocidades en los nodos "u".

			% Vectores para almacenar velocidades promedio
			% También necesito promediar las deformaciones de la 
			% superficie libre hacia los nodos de velocidad
			% para calcular los coeficientes de dispersion

			flujos = thisVolumenesFinitos.Flujos;

			% La idea es conocer las velocidades u en los nodos v 
			% y viceversa

			[nEta nU nV] = getNumeroNodos(simulacion);
			[nBU nBV] = getNodosBorde(simulacion);
			coordenadasEta = malla.coordenadasEta;
			coordenadasU = malla.coordenadasU;
			coordenadasV = malla.coordenadasV;
			nUNew = nU - length(nBU);
			nVNew = nV - length(nBV);

			% Elimino coordenadas de los nodos de velocidad
			% que son bordes
			% coordBordeU = coordenadasU(nBU,:);
			% coordBordeV = coordenadasV(nBV,:);
			% coordenadasU(nBU,:) = [];
			% coordenadasV(nBV,:) = [];
			% uBorde = zeros(length(coordBordeU(:,1)), 1);
			% vBorde = zeros(length(coordBordeV(:,1)), 1);
			
			eta = full(solucion(1: nEta));

			noBordeU = 1:nU;
			noBordeU(nBU) = [];
			noBordeV = 1:nV;
			noBordeV(nBV) = [];

			velU = zeros(nU, 1);
			velV = zeros(nV, 1);
			velU(noBordeU) = full(solucion(nEta + 1: nEta + nUNew));
			velV(noBordeV) = full(solucion(nEta + nUNew + 1: end));

			% Construyo interpoladores
			interpEta = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), ...
				  eta); % Interpolador eta 
			interpU = TriScatteredInterp(coordenadasU(:,1), coordenadasU(:,2), velU); % Interpolador u
			interpV = TriScatteredInterp(coordenadasV(:,1), coordenadasV(:,2), velV); % Interpolador V

			% Interpolo velocidades u a los nodos v y viceversa
			uInterpNodoV = interpU(coordenadasV(:,1), coordenadasV(:,2));
			uInterpNodoV(isnan(uInterpNodoV)) = 0;
			vInterpNodoU = interpV(coordenadasU(:,1), coordenadasU(:,2));
			vInterpNodoU(isnan(vInterpNodoU)) = 0;
				
			% Calculo modulo de velocidades en nodos u y v respectivamente
			modVelWE = sqrt(velU.^2 + vInterpNodoU.^2);	
			modVelNS = sqrt(velV.^2 + uInterpNodoV.^2);	
			uAstWE = sqrt(coefFriccion*modVelWE);
			uAstNS = sqrt(coefFriccion*modVelNS);
 
			% Interpolo eta a los nodos de velocidad
			etaWE = interpEta(coordenadasU(:,1), coordenadasU(:,2)); 
			etaNS = interpEta(coordenadasV(:,1), coordenadasV(:,2));
			etaWE(isnan(etaWE)) = 0;
			etaNS(isnan(etaNS)) = 0;
% keyboard
			thetaWE = atan2(vInterpNodoU, velU);
			f1 = find(thetaWE <= 0);
			thetaWE(f1) = thetaWE(f1) + 2*pi;

			thetaNS = atan2(velV, uInterpNodoV);
			f2 = find(thetaNS <= 0);
			thetaNS(f2) = thetaNS(f2) + 2*pi;

			coefDispersion.velU = velU; % velocidades de los nodos que no son borde
			coefDispersion.velV = velV;
			
			coefDispersion.kxxwe = uAstWE.*[hoWE + etaWE].*(eL*cos(thetaWE).^2 + eT*sin(thetaWE).^2) + coefDifusion;
			coefDispersion.kyyns = uAstNS.*[hoNS + etaNS].*(eL*sin(thetaNS).^2 + eT*cos(thetaNS).^2) + coefDifusion;

			if strcmpi(flujos, 'adveccion') || strcmpi(flujos, 'adveccionverticales')
				
				coefDispersion.kxxwe = coefDispersion.kxxwe*0;
				coefDispersion.kyyns = coefDispersion.kyyns*0;

			elseif strcmpi(flujos, 'dispersion') || strcmpi(flujos, 'dispersionverticales')

				coefDispersion.velU = coefDispersion.velU*0;
				coefDispersion.velV = coefDispersion.velV*0;
			
			elseif strcmpi(flujos, 'advecciondispersion') || strcmpi(flujos, 'advecciondispersionverticales')		
				
			else

				error('Error de sintaxis: Los flujos especificados no son correctos')
			end

		end % function coeficientesDispersion

		function leyPotencia = leyDePotencia(thisVolumenesFinitos, simulacion, coefDipersion)
			% keyboard
			malla = getMalla(simulacion);
			bat = getBatimetria(simulacion);
			IDwe = malla.matrizIDwe;
			IDns = malla.matrizIDns;
			howe = bat.hoNodosU;
			hons = bat.hoNodosV;

			nBDe = malla.numeroBordesDerecho;
			nBIz = malla.numeroBordesIzquierdo;
			nBSu = malla.numeroBordesSuperior;
			nBIn = malla.numeroBordesInferior;

			kxxwe = coefDipersion.kxxwe;
			kyyns = coefDipersion.kyyns;
			uaux = coefDipersion.velU;
			vaux = coefDipersion.velV;

			[dx dy] = getDeltaX(simulacion);

			% m3/s
			De = [howe(IDwe(:,2))].*kxxwe(IDwe(:,2))*dy/dx;
			Dw = [howe(IDwe(:,1))].*kxxwe(IDwe(:,1))*dy/dx;
			Ds = [hons(IDns(:,2))].*kyyns(IDns(:,2))*dx/dy;
			Dn = [hons(IDns(:,1))].*kyyns(IDns(:,1))*dx/dy;

			%m3/s
			Fe = [howe(IDwe(:,2))].*uaux(IDwe(:,2))*dy; 
			Fw = [howe(IDwe(:,1))].*uaux(IDwe(:,1))*dy;
			Fs = [hons(IDns(:,2))].*vaux(IDns(:,2))*dx;
			Fn = [hons(IDns(:,1))].*vaux(IDns(:,1))*dx;

			aE = De.*max(0,(1-0.1*abs(Fe./De)).^5) + max(0,-Fe);
			aW = Dw.*max(0,(1-0.1*abs(Fw./Dw)).^5) + max(0,Fw);
			aN = Dn.*max(0,(1-0.1*abs(Fn./Dn)).^5) + max(0,-Fn);
			aS = Ds.*max(0,(1-0.1*abs(Fs./Ds)).^5) + max(0,Fs);
			IDetaC = malla.matrizIDetaC; % Nodos eta: W, E, S, N
% keyboard
			% Condiciones de Borde
			aE(nBDe) = 0; IDetaC(nBDe,2) = 1;
			aW(nBIz) = 0; IDetaC(nBIz,1) = 1;
			aN(nBSu) = 0; IDetaC(nBSu,4) = 1;
			aS(nBIn) = 0; IDetaC(nBIn,3) = 1;

			coefTransporte.aE = aE;
			coefTransporte.aW = aW;
			coefTransporte.aN = aN;
			coefTransporte.aS = aS;
			leyPotencia.coefTransporte = coefTransporte;	
			leyPotencia.IDetaC = IDetaC; % Nodos eta: W, E, S, N

		end % function leyDePotencia

		function concIterK = iteraVolFinitos(thisVolumenesFinitos, simulacion, sol, coefTransEta, varargin)

			flujos = thisVolumenesFinitos.Flujos;
			masa = thisVolumenesFinitos.Masa;
			
			% keyboard

			if strcmpi(flujos, 'advecciondispersionverticales') || strcmpi(flujos, 'adveccionverticales') ...
                           || strcmpi(flujos, 'dispersionverticales')

				claseMasa = class(masa);
				eval(['masa = ', claseMasa, '(masa, simulacion, sol);'])
				thisVolumenesFinitos.Masa = masa;

				% keyboard
			
			end

			% keyboard

			% La idea de esta funcion es iterar y ajustar
			% la concentracion espacial que satisface con algun criterio 
			% de convergencia. En el caso de que existan 
			% flujos verticales, el criterio de convergencia 
			% es teoricamente que el promedio espaicl de los flujos
			% verticales por la superficie es igual al promedio 
			% al promedio espacial de los flujos verticales por 
			% el fondo

			
			coefTransporte = coefTransEta.coefTransporte;
			IDC = coefTransEta.IDetaC; % Nodos eta: W, E, S, N
			aW = coefTransporte.aW;
			aE = coefTransporte.aE;
			aN = coefTransporte.aN;
			aS = coefTransporte.aS;
			nEta = getNumeroNodos(simulacion);
			[deltaX deltaY] = getDeltaX(simulacion);

			% Entrego una adivinanza inicial para comenzar las 
			% iteraciones. La idea es que este valor sea lo 
			% suficientemente alto para estar lejos
			% de la convergencia pero que efectivamente el estado
			% de equilibrio sea alcanzable. El valor inicial 
			% es ahora 5 veces la concentracion caracteristica 
			% de la masa. 

			concSaturacion = thisVolumenesFinitos.Masa.concSaturacion;
			concInicial = ones(nEta,1)*concSaturacion*5; 

			% La condicion inicial eventualmente puede 
			% ser especificada

			% Iteraciones hasta convergencia
			% Aun no veo que ocurre si la masa transportada
			% tiene flujos verticales y el usuario 
			% solicita resolverlos
			
			errorVF = 10;
			concIterK = concInicial;
			fila = (1:nEta)';
			xCoefTrans = [fila; fila; fila; fila; fila];
			yCoefTrans = [fila; IDC(:,1); IDC(:,2); IDC(:,4); IDC(:,3)]; %aP, -aW, -aE, -aN, -aS

			k = 0;

			switch thisVolumenesFinitos.RegimenTemporal

				case 'permanente'

					while errorVF > 1e-12

						k = k+1 
						% Calculo flujos verticales. Son funcion de la 	
						% concentracion

						F0 = F0VF(masa, concIterK);
						F1 = F1VF(masa, concIterK); 

						% Por ahora hago esto solo para el RP
						% Falta modificar coeficientes bVF y aP 
						% para el caso en que estamos resolviendo el RI
						bVF = F0*deltaX*deltaY;
						aP = aE + aW + aN + aS - F1*deltaX*deltaY;
	
						% Asigno coeficientes a matriz para invertir
						matrixG = sparse(xCoefTrans, yCoefTrans, [aP; -aW; ...
							  -aE; -aN; -aS]);
						concIterKMas = matrixG\bVF;
						fC = find(concIterKMas < 0);
						concIterKMas(fC) = 0;
						% errorVF = sqrt(sum(abs(concIterKMas - concIterK).^2));
						errorVF = errorVolFinitos(masa, simulacion, ...
							  concIterKMas, concIterK);
						concIterK = concIterKMas;
						
						if k > 100 
							% concIterK = zeros(size(concIterK));
							concIterK = concIterKMas*NaN;
							break

						end
					end %while

				case 'impermanente'

					variaTempo = varargin{1};
					deltaT = variaTempo.deltaT;
					cp0 = variaTempo.cp0;
					eta0 = variaTempo.eta0;
					bat = getBatimetria(simulacion);
					heta = bat.hoNodosEta;
					eta = sol(1:nEta);

					while errorVF > 1e-15

						k = k+1 
						% Calculo flujos verticales. Son funcion de la 	
						% concentracion

						F0 = F0VF(masa, concIterK);
						F1 = F1VF(masa, concIterK); 

						% Por ahora hago esto solo para el RP
						% Falta modificar coeficientes bVF y aP 
						% para el caso en que estamos resolviendo el RI
						bVF = heta.*cp0*deltaX*deltaY/deltaT + F0*deltaX*deltaY;
						aP = aE + aW + aN + aS + (heta - eta + eta0)*deltaX*deltaY/deltaT - F1*deltaX*deltaY;
	
						% Asigno coeficientes a matriz para invertir
						matrixG = sparse(xCoefTrans, yCoefTrans, [aP; -aW; ...
							  -aE; -aN; -aS]);
						concIterKMas = matrixG\bVF;
						fC = find(concIterKMas < 0);
						concIterKMas(fC) = 0;
						errorVF = sqrt(sum(abs(concIterKMas - concIterK).^2));
						% errorVF = errorVolFinitos(masa, simulacion, ...
						%	   concIterKMas, concIterK)
						concIterK = concIterKMas;

						if k > 100 
							concIterK = concIterKMas*NaN;
							break
						end

					end %while
			end %switch

		end % function iteraVolFinitos


		function thisVolumenesFinitos = asignaPropiedad(thisVolumenesFinitos, varargin)

			% Debo detectar en varargin si
			% los strings ingresados en las
			% posiciones impares son propiedades
			% de la clase		

			nInput = length(varargin);
			
			% El largo de varargin debe ser par

			if  mod(nInput, 2) || nInput == 0

				error(['Falta especificar un valor o propiedad ' ...
				      'en el constructor de la clase'])
				
			end
	
			posPropiedades = linspace(1, nInput-1, nInput*0.5);
			posValores = linspace(2, nInput, nInput*0.5);				

			propInput = cell(nInput*0.5,2);

			for iInput = 1:nInput*0.5		
				
				if ~strcmpi(class(varargin{posPropiedades(iInput)}), ...
					   'char')					
					error(['Las propiedades a asignar deben ser' ...
					      ' especificadas en un string con el nombre' ...
					      ' de la propiedad'])	
	
				end
			
				propInput{iInput, 1} = varargin{posPropiedades(iInput)};
				propInput{iInput, 2} = varargin{posValores(iInput)};

				isProp = isprop(thisVolumenesFinitos, propInput{iInput, 1});

				if isProp
			
					eval(['thisVolumenesFinitos.', propInput{iInput, 1} ...
					    ' = propInput{iInput, 2};' ])				
				else
					error(['La propiedad ', propInput{iInput, 1}, ...
						' no es parte del objeto ', class(thisVolumenesFinitos)])
				end				

			end 	
		
			% keyboard

			% La celda propInput tiene la informacion de
			% la propiedad que queiro asignar en el objeto 
			% en la primera columna y el valor que esta
			% deberia tener en la segunda columna

		end% funcion asignaPropiedad

		function masa = getMasa(thisVolumenesFinitos)

			masa = thisVolumenesFinitos.Masa;

		end %getMasa

		function flujos = getFlujos(thisVolumenesFinitos)

			flujos = thisVolumenesFinitos.Flujos;

		end %getFlujos

		function numPecletVert = pecletVertical(thisVolumenesFinitos, simulacion)

			malla = getMalla(simulacion);
			Lx = max(malla.coordenadasU(:,1)) - ... 	
			     min(malla.coordenadasU(:,1));
			Ly = max(malla.coordenadasV(:,2)) - ... 	
			     min(malla.coordenadasV(:,2));
			L = max([Lx Ly]);

			solHidro = getHidrodinamica(simulacion);
			[eta u v] = getEtaUV(simulacion, solHidro.Solucion(:,end));
			modV = sqrt(u.^2 + v.^2);
			bat = getBatimetria(simulacion);
			heta = bat.hoNodosEta;

			masa = getMasa(thisVolumenesFinitos);
			fAtm = masa.FlujosVerticales.flujoAtm;
			kl = fAtm.kl;
			fSed = masa.FlujosVerticales.flujoSed;
			kt = fSed.kt;
			S = fSed.S;
			cTilde = cMezclaCompleta(masa);
			% numPecletVert =	modV.*(heta + eta)/(L*abs(fSed.dFuncion(S,mean(kt), cTilde) - kl));
			numPecletVert =	modV.*(heta + eta)./(L*abs(fSed.dFuncion(S, kt, cTilde) - kl));
		end %function pecletVertical

		function flujoSed = flujoSedimentos(thisVolumenesFinitos)

			masa = getMasa(thisVolumenesFinitos);
			fSed = masa.FlujosVerticales.flujoSed;
			kt = fSed.kt;
			S = fSed.S;
			concentracion = thisVolumenesFinitos.Solucion;
			flujoSed = fSed.funcion(S, kt, concentracion);

		end %function flujoSedimentos

	end %methods
end %classdef

%%%%%%%%%%%%%%%%%%%%%%%%% THRASH



