classdef AnalisisModal < Hidrodinamica

	% HIDRODINAMICA -> ANALISISMODAL es uno de los motores 
	% hidrodinámicos que resuelve el problema del flujo
	% utilizando la teoría del análisis modal (Shimizu e Imberger, 2008)
	% 
	% Construcción:
	% 
	% El constructor de la clase requiere un objeto de clase SIMULACION
	% y un string que especifica el régimen temporal.
	% 
	% 	thisAnalisisModal = AnalisisModal(simulacion, regimenTemporal) 
	% 
	% Dentro de las opciones disponibles para el régimen temporal 
	% existen 'permanente', 'impermanente' o 'modosLibres'.
	% Este último pretende entregar los modos de oscilación libres
	% sin disipación de energía. Sin embargo, la función eig() de
	% Matlab no permite resolver el problema adecuadamente. En caso 
	% de buscar los modos de oscilación libres se recomienda
	% resolver un problema con disipación de energía, es decir, 	
	% especificando un FORZANTE en la simulación y a partir de 
	% estos modos y la función eigs() resolver los modos libres. 
	% El problema lo tiene eig().
	% 
	% Propiedades:
	%
	% >> properties(AnalisisModal)
	%
	%	Properties for class AnalisisModal:
	%
	%	    VyVPropios
	%	    tiempoComputo
	%	    RegimenTemporal
	%	    Solucion
	%	    Solucion2D
	%	    Tiempo
	%	    Tipo


	properties 

	%	Tipo
	%	RegimenTemporal
	%	Solucion
	%	Solucion2D	
	%	Tiempo	
		VyVPropios
		tiempoComputo		
	
	end

	methods

		function thisAnalisisModal = AnalisisModal(simulacion, regimenTemporal)
		% function thisAnalisisModal = AnalisisModal(simulacion, regimenTemporal)
		% Constructor del objeto AnalisisModal

			if nargin == 0
				thisAnalisisModal;
			else
				tic
				thisAnalisisModal.Tipo = 'AnalisisModal';
				thisAnalisisModal.RegimenTemporal = regimenTemporal;
				thisAnalisisModal = calculaVyVPropios(thisAnalisisModal, simulacion);				


% 				if ~strcmpi(regimenTemporal, 'amplituddesdesolucion)')
					
% 					thisAnalisisModal = calculaVyVPropios(thisAnalisisModal, simulacion);	

%				elseif	strcmpi(regimenTemporal, 'amplituddesdesolucion)')
%				
%					solHidro = getHidrodinamica(simulacion);

%					if strcmpi(class(solHidro), 'analisismodal')
%					
%						if isempty(solHidro.VyVPropios)	
%					
%							thisAnalisisModal = calculaVyVPropios(thisAnalisisModal, ...
%									    simulacion);				

%						end
%					
%					else

%						thisAnalisisModal = calculaVyVPropios(thisAnalisisModal, simulacion);	

%					end

% 				end


				if(~strcmpi(regimenTemporal, 'modoslibres'))
					thisAnalisisModal = amplitudModal(thisAnalisisModal, simulacion);
				end
				thisAnalisisModal.tiempoComputo = toc;
				% [Solucion2D.Eta Solucion2D.U Solucion2D.V] = solucion2D(simulacion, thisAnalisisModal.Solucion);
				% thisAnalisisModal.Solucion2D = Solucion2D;

			end %if
		end %function AnalisisModal

		function thisAnalisisModal = calculaVyVPropios(thisAnalisisModal, simulacion)
			% function thisAnalisisModal = calculaVyVPropios(thisAnalisisModal, simulacion)
			% Calcula valores y vectores propios por la derecha resolviendo
			% el problema
			% 
			% 	[vectoresDerecha, valoresDerecha]= eig(full([K + C]), full(M));
			% 
			% A partir de este resultado obtiene los valores y vectores 
			% propios por la izquierda 
			% 
			% 	valoresIzquierda = conj(valoresDerecha);
			% 	vectoresIzquierda = vectoresDerecha;
			% 
			% Para mayor información en la definición del problema
			% ver Shimizu e Imberger (2008).

				[M, K, C] = getMatrices(simulacion);
			
			% Resuelvo problema por la derecha. 
				[vectoresDerecha, valoresDerecha]= eig(full([K + C]), full(M));
				% [vectoresIzquierda, valoresIzquierda]= eig(full([K + C]'), full(M));
				valoresDerecha = diag(valoresDerecha);
				% valoresIzquierda = diag(valoresIzquierda);

			% Corto decimales que sean menores que la precision del programa

				corta = 1e-15;
				vectoresDerecha = quant(real(vectoresDerecha), corta) + i*quant(imag(vectoresDerecha), corta);
				valoresDerecha = quant(real(valoresDerecha), corta) + i*quant(imag(valoresDerecha), corta);
%				vectoresIzquierda = quant(real(vectoresIzquierda), corta) + i*quant(imag(vectoresIzquierda), corta);
%				valoresIzquierda = quant(real(valoresIzquierda), corta) + i*quant(imag(valoresIzquierda), corta);

			
			% Normaliza vectores propios de manera que tengan norma unitaria

				normaDerecha = zeros(1,length(valoresDerecha));

				for iNorma = 1:length(valoresDerecha)
					normaDerecha(iNorma) = norm(vectoresDerecha(:,iNorma));
				end

				vectoresDerecha = vectoresDerecha./(repmat(normaDerecha, length(valoresDerecha), 1));

%				normaIzquierda = zeros(1,length(valoresIzquierda));

%				for iNorma = 1:length(valoresIzquierda)
%					normaIzquierda(iNorma) = norm(vectoresIzquierda(:,iNorma));
%				end

%				vectoresIzquierda = vectoresIzquierda./(repmat(normaIzquierda, length(valoresIzquierda), 1));


			% Busco y borro valores propios nulos

				fNuloDer = find(abs(valoresDerecha) < eps);
				valoresDerechaNulo = valoresDerecha(fNuloDer);
				vectoresDerechaNulo = vectoresDerecha(:,fNuloDer);
				valoresDerecha(fNuloDer) =  [];
				vectoresDerecha(:,fNuloDer) =  [];

%				fNuloIzq = find(abs(valoresIzquierda) < eps);
%				valoresIzquierdaNulo = valoresIzquierda(fNuloIzq);
%				vectoresIzquierdaNulo = vectoresIzquierda(:,fNuloIzq);
%				valoresIzquierda(fNuloIzq) =  [];
%				vectoresIzquierda(:,fNuloIzq) =  [];


			% Busco y ordeno vectores con omega positivo.

				fDerecha = find(real(valoresDerecha) > 0);
				valoresDerechaMasR = valoresDerecha(fDerecha);
				vectoresDerechaMasR = vectoresDerecha(:,fDerecha);
				[valoresDerechaMasR indDerPos] = sort(valoresDerechaMasR);
				vectoresDerechaMasR = vectoresDerechaMasR(:,indDerPos);

%				fIzquierda = find(real(valoresIzquierda) > 0);
%				valoresIzquierdaMasR = valoresIzquierda(fIzquierda);
%				vectoresIzquierdaMasR = vectoresIzquierda(:,fIzquierda);
%				[valoresIzquierdaMasR indIzqPos] = sort(valoresIzquierdaMasR);
%				vectoresIzquierdaMasR = vectoresIzquierdaMasR(:,indIzqPos);


			% Busco vectores con omega cero.
				% keyboard
				fDerechaOmegaCero = find(real(valoresDerecha) == 0);
				valoresDerechaOmegaCero = valoresDerecha(fDerechaOmegaCero);
				vectoresDerechaOmegaCero = vectoresDerecha(:,fDerechaOmegaCero);

%				fIzquierdaOmegaCero = find(real(valoresIzquierda) == 0);
%				valoresIzquierdaOmegaCero = valoresIzquierda(fIzquierdaOmegaCero);
%				vectoresIzquierdaOmegaCero = vectoresIzquierda(:,fIzquierdaOmegaCero);

			% Ordena las partes imaginarias de los valores con omega cero. De menor a mayor

				[valoresDerechaOmegaCero indDerechaOmegaCero]= sort(valoresDerechaOmegaCero);
				vectoresDerechaOmegaCero = vectoresDerechaOmegaCero(:,indDerechaOmegaCero);

%				[valoresIzquierdaOmegaCero indIzquierdaOmegaCero]= sort(valoresIzquierdaOmegaCero);
%				vectoresIzquierdaOmegaCero = vectoresIzquierdaOmegaCero(:,indIzquierdaOmegaCero);


			% Asigno problema de la izquierda en funcion del problema por la derecha. 
			% Para entender la relacion entre ambos, ver Memoria.

				VectoresDerecha.MasR = vectoresDerechaMasR;
				VectoresDerecha.MenosR = conj(vectoresDerechaMasR);
				VectoresDerecha.OmegaCero = vectoresDerechaOmegaCero;

				ValoresDerecha.MasR = valoresDerechaMasR;		
				ValoresDerecha.MenosR = -conj(valoresDerechaMasR);
				ValoresDerecha.OmegaCero = valoresDerechaOmegaCero;		

				ProblemaDerecha.Vectores = VectoresDerecha;
				ProblemaDerecha.Valores = ValoresDerecha;

%				VectoresIzquierda.MasR = vectoresIzquierdaMasR;
%				VectoresIzquierda.MenosR = conj(vectoresIzquierdaMasR);
%				VectoresIzquierda.OmegaCero = vectoresIzquierdaOmegaCero;

%				ValoresIzquierda.MasR = valoresIzquierdaMasR;		
%				ValoresIzquierda.MenosR = -conj(valoresIzquierdaMasR);
%				ValoresIzquierda.OmegaCero = valoresIzquierdaOmegaCero;		

%				ProblemaIzquierda.Vectores = VectoresDerecha;
%				ProblemaIzquierda.Valores = ValoresIzquierda;
		
				ValoresIzquierda.MasR = conj(ValoresDerecha.MasR);
				ValoresIzquierda.MenosR = conj(ValoresDerecha.MenosR);
				ValoresIzquierda.OmegaCero = conj(ValoresDerecha.OmegaCero);		

				ProblemaIzquierda.Vectores = VectoresDerecha;
				ProblemaIzquierda.Valores = ValoresIzquierda;

				VyVPropios.ProblemaDerecha = ProblemaDerecha;
				VyVPropios.ProblemaIzquierda = ProblemaIzquierda;
				thisAnalisisModal.VyVPropios = VyVPropios;

		end %function calculaVyVPropios

		function thisAnalisisModal = amplitudModal(thisAnalisisModal, simulacion, varargin)
		
			% Para realizar el calculo de las amplitudes modales, 	
			% necesito los vyvpropios, el forzante externo y las 
			% matrices
			
				geometria = simulacion.Cuerpo.Geometria;
				deltaX = geometria.Malla.deltaX;
				deltaY = geometria.Malla.deltaY;
				[M, K, C] = getMatrices(simulacion);
				forzanteExterno = simulacion.Matrices.f;
				tiempoForzante = simulacion.Matrices.Tiempo;
				problemaDerecha = thisAnalisisModal.VyVPropios.ProblemaDerecha;
				problemaIzquierda = thisAnalisisModal.VyVPropios.ProblemaIzquierda;

				vectoresDerechaMasR = problemaDerecha.Vectores.MasR;
				vectoresDerechaMenosR = problemaDerecha.Vectores.MenosR;
				vectoresDerechaOmegaCero = problemaDerecha.Vectores.OmegaCero;

				vectoresIzquierdaMasR = problemaIzquierda.Vectores.MasR;
				vectoresIzquierdaMenosR = problemaIzquierda.Vectores.MenosR;
				vectoresIzquierdaOmegaCero = problemaIzquierda.Vectores.OmegaCero;

				cuantosVectoresR = length(problemaIzquierda.Valores.MasR);					
				cuantosVectoresOmegaCero = length(problemaIzquierda.Valores.OmegaCero);

				nEta = getNumeroNodos(simulacion);
				areaTotal = nEta*deltaX*deltaY;

		        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				eTildeDerechaMasR = dot(vectoresIzquierdaMasR, M*vectoresDerechaMasR)*areaTotal;
				eTildeDerechaMenosR = dot(vectoresIzquierdaMenosR, M*vectoresDerechaMenosR)*areaTotal;
				eTildeDerechaOmegaCero = dot(vectoresIzquierdaOmegaCero, M*vectoresDerechaOmegaCero)*areaTotal;

				iOMGeTildeDerMasR = i*dot(vectoresIzquierdaMasR, (K+C)*vectoresDerechaMasR)*areaTotal;
				iOMGeTildeDerMenosR = i*dot(vectoresIzquierdaMenosR, (K+C)*vectoresDerechaMenosR)*areaTotal;
				iOMGeTildeDerOmegaCero = i*dot(vectoresIzquierdaOmegaCero, (K+C)*vectoresDerechaOmegaCero)*areaTotal;

				if strcmpi(thisAnalisisModal.RegimenTemporal, 'permanente')
					% Si el problema se resuelve utilizando el régimen permanente,
					% existen dos situaciones. Una en que el forzante externo 
					% varíe temporalmente, como por ejemplo en el caso de un 
					% forzante oscilatorio en el régimen permanente, o 
					% que el forzante sea constante en el tiempo.
					% Esta sección tiene que ser capaz de resolver ambos casos
				
					if isempty(tiempoForzante)
						% Este es el caso en que el forzante es permanente

						fTildeMasR = dot(vectoresIzquierdaMasR, repmat(forzanteExterno, 1, cuantosVectoresR))*areaTotal;
						fTildeMenosR = dot(vectoresIzquierdaMenosR, repmat(forzanteExterno, 1, cuantosVectoresR))*areaTotal;
						fTildeOmegaCero = dot(vectoresIzquierdaOmegaCero, repmat(forzanteExterno, 1, cuantosVectoresOmegaCero))*areaTotal;

						aTildeDerechaMasR = -fTildeMasR./(iOMGeTildeDerMasR);
						aTildeDerechaMenosR = -fTildeMenosR./(iOMGeTildeDerMenosR);
						aTildeDerechaOmegaCero = -fTildeOmegaCero./(iOMGeTildeDerOmegaCero);

						% keyboard

						solModosR = sparse(length(vectoresIzquierdaMasR(:,1)),1);
						solModosOmegaCero = solModosR;
						solAcumulada = solModosR;

						%%%%%%%%%%%%%%%%%%%%%%%%%% SUMO MODOS R %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						for iModo = 1:cuantosVectoresR
				
							solAuxiliar = aTildeDerechaMasR(iModo)*vectoresDerechaMasR(:,iModo) + aTildeDerechaMenosR(iModo)*vectoresDerechaMenosR(:,iModo);
							solModosR = solModosR + solAuxiliar;

						end
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

						%%%%%%%%%%%%%%%%% SUMO MODOS OMEGA = 0 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						for iModo = 1:cuantosVectoresOmegaCero
				
							solAuxiliar = aTildeDerechaOmegaCero(iModo)*vectoresDerechaOmegaCero(:,iModo);
							solModosOmegaCero = solModosOmegaCero + solAuxiliar;
													
						end
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


						solAcumulada = solModosR + solModosOmegaCero;

%						sPlot(1) = subplot(2,2,1);
%						graficaModo(simulacion, solModosR)
%						sPlot(2) = subplot(2,2,2);
%						graficaModo(simulacion, solModosOmegaCero)
%						sPlot(3) = subplot(2,2,3);
%			sdfsdsdffsdfaf			graficaModo(simulacion, solAcumulada)

						% keyboard				
						testImag = sum(imag(solAcumulada)./real(solAcumulada));
	
						if testImag < 1e-12				
							thisAnalisisModal.Solucion = real(solAcumulada);
						else 
							thisAnalisisModal.Solucion = solAcumulada;
						end
			
					
					else
						error('No puedes resolver un forzante impermanente con el método permanente')
				
					end % if
				
				elseif strcmpi(thisAnalisisModal.RegimenTemporal, 'impermanente')
					% Si el problema se resuelve utilizando el régimen impermanente
					% nuevamente existen dos situaciones. La primera sería aquella en que
					% el forzante es impermanente y tiene especificado un vector de tiempo
					% define su evolución. La segunda es aquella en el que el forzante es 
					% constante en el tiempo y no existe un vector de tiempo 
					% para resolver el problema. En este último caso, se crea
					% un vector de tiempo arbitrario.

					if(isempty(tiempoForzante))

						% Si el forzante es constante en el tiempo. 
						% Entonces creo un vector de tiempo arbitrario

						tFinal = 25000; %segundos
						deltaT = 20; %segundos
						tiempoCalculo = 0:deltaT:tFinal;
						nTiempoCalculo = length(tiempoCalculo);
						forzanteExterno = repmat(forzanteExterno, 1, nTiempoCalculo);

					else

						% Si el forzante varía en el tiempo. 
						% Entonces tomo los datos de tiempo del forzante

						tiempoCalculo = tiempoForzante;
						deltaT = abs(tiempoCalculo(1)-tiempoCalculo(2)); %asumo deltaT constante
						nTiempoCalculo = length(tiempoCalculo);

					end

					% Variables que almacenan resultados

					aTildeDerechaMasR = sparse(length(tiempoCalculo), cuantosVectoresR);
					aTildeDerechaMenosR = aTildeDerechaMasR;
					aTildeDerechaOmegaCero = sparse(length(tiempoCalculo), cuantosVectoresOmegaCero);

					solModosR = sparse(length(vectoresIzquierdaMasR(:,1)), nTiempoCalculo);
					solModosOmegaCero = solModosR;
					solAcumulada = solModosR;

					barraEspera = waitbar(0,'Please wait..');

					% Loop para el tiempo

					for iTiempo = 2:nTiempoCalculo
						waitbar(iTiempo/nTiempoCalculo)

						fTMasRTmUno = dot(vectoresIzquierdaMasR, ...
						              repmat(forzanteExterno(:,iTiempo-1), 1, cuantosVectoresR))*areaTotal;
						fTMasRT = dot(vectoresIzquierdaMasR, ... 
							  repmat(forzanteExterno(:,iTiempo), 1, cuantosVectoresR))*areaTotal;
						fTildeMasRProm = 0.5*(fTMasRTmUno + fTMasRT);

						aTildeDerechaMasR(iTiempo,:) = ((0.5*iOMGeTildeDerMasR + eTildeDerechaMasR/deltaT).*aTildeDerechaMasR(iTiempo-1,:) + fTildeMasRProm)./(eTildeDerechaMasR/deltaT - 0.5*iOMGeTildeDerMasR); 


						fTMenosRTmUno = dot(vectoresIzquierdaMenosR, ...
						              repmat(forzanteExterno(:,iTiempo-1), 1, cuantosVectoresR))*areaTotal;
						fTMenosRT = dot(vectoresIzquierdaMenosR, ... 
							  repmat(forzanteExterno(:,iTiempo), 1, cuantosVectoresR))*areaTotal;
						fTildeMenosRProm = 0.5*(fTMenosRTmUno + fTMenosRT);

						aTildeDerechaMenosR(iTiempo,:) = ((0.5*iOMGeTildeDerMenosR + eTildeDerechaMenosR/deltaT).*aTildeDerechaMenosR(iTiempo-1,:) + fTildeMenosRProm)./(eTildeDerechaMenosR/deltaT - 0.5*iOMGeTildeDerMenosR); 

						fTOmCeroTmUno = dot(vectoresIzquierdaOmegaCero, ...
						              repmat(forzanteExterno(:,iTiempo-1), 1, cuantosVectoresOmegaCero))*areaTotal;
						fTOmCeroT = dot(vectoresIzquierdaOmegaCero, ... 
							  repmat(forzanteExterno(:,iTiempo), 1, cuantosVectoresOmegaCero))*areaTotal;
						fTildeOmCeroProm = 0.5*(fTOmCeroTmUno + fTOmCeroT);

						aTildeDerechaOmegaCero(iTiempo,:) = ((0.5*iOMGeTildeDerOmegaCero + eTildeDerechaOmegaCero/deltaT).*aTildeDerechaOmegaCero(iTiempo-1,:) + fTildeOmCeroProm)./(eTildeDerechaOmegaCero/deltaT - 0.5*iOMGeTildeDerOmegaCero); 

						%%%%%%%%%%%%%%%%%%%%%%%%%% SUMO MODOS R %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						for iModo = 1:cuantosVectoresR
					
							solAuxiliar = aTildeDerechaMasR(iTiempo, iModo)*vectoresDerechaMasR(:,iModo) + aTildeDerechaMenosR(iTiempo, iModo)*vectoresDerechaMenosR(:,iModo);
							solModosR(:,iTiempo) = solModosR(:,iTiempo) + solAuxiliar;

						end
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

						%%%%%%%%%%%%%%%%% SUMO MODOS OMEGA = 0 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						for iModo = 1:cuantosVectoresOmegaCero
					
							solAuxiliar = aTildeDerechaOmegaCero(iTiempo, iModo)*vectoresDerechaOmegaCero(:,iModo);
							solModosOmegaCero(:,iTiempo) = solModosOmegaCero(:,iTiempo) + solAuxiliar;
		
						end
						%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

					end % for iTiempo

					close(barraEspera)
	
					solAcumulada = solModosR + solModosOmegaCero;
					thisAnalisisModal.Solucion = solAcumulada;
					thisAnalisisModal.Tiempo = tiempoCalculo;

				elseif strcmpi(thisAnalisisModal.RegimenTemporal, 'amplituddesdesolucion')
					% Este caso es aquel en el que la simulacion ha sido resuelta
					% por algun otro metodo (Crank Nicolson) y a partir de ella quiero 
					% extraer la amplitud de oscilacion de cada modo en el tiempo 
					% Basta con sólo calcular la amplitud modal por la derecha
					% para +r. Los de OmegaCero deben ser calculados tambien.

					% Calculo amplitudes para cada modo dada la solucion 
					solHidro = getHidrodinamica(simulacion);

					if length(solHidro) ~= 1
		
						error('Aun no se implementa el caso en que la Hidrodinamica tiene mas de un elemento')					
		
					end

					solTiempo = solHidro.Solucion;

					% Calculo para vectores Mas R. Recordar que vectores de izquierda son iguales a los de la derecha

					cuantosMasR = length(vectoresDerechaMasR(1,:));
					ampMasR = zeros(cuantosMasR, length(tiempoForzante));
					energiaModoR = zeros(cuantosMasR, length(tiempoForzante));

					for iModo = 1:cuantosMasR
			
						ampMasR(iModo, :) = dot(repmat(vectoresDerechaMasR(:,iModo), 1, length(tiempoForzante)), M*solTiempo)*areaTotal/(eTildeDerechaMasR(iModo));
						energiaModoR(iModo, :) = real(eTildeDerechaMasR(iModo)*conj(ampMasR(iModo, :)).*ampMasR(iModo, :));

					end

					cuantosOmegaCero = length(vectoresDerechaOmegaCero(1,:));
					ampOmegaCero = zeros(cuantosOmegaCero, length(tiempoForzante));
					energiaOmegaCero = zeros(cuantosOmegaCero, length(tiempoForzante));

					for iModo = 1:cuantosOmegaCero
			
						ampOmegaCero(iModo, :) = dot(repmat(vectoresDerechaOmegaCero(:,iModo), 1, length(tiempoForzante)), M*solTiempo)*areaTotal/(eTildeDerechaOmegaCero(iModo));
						energiaOmegaCero(iModo, :) = 0.5*real(eTildeDerechaOmegaCero(iModo)*conj(ampOmegaCero(iModo, :)).*ampOmegaCero(iModo, :));

					end

%					plot(tiempoForzante, sum(real(energiaModoR)))
%					hold on 
%					graficaEnergiaTiempo(Grafico(), simulacion)
			
					sol.ampMasR = ampMasR;
					sol.energiaModoR = energiaModoR;
					sol.ampOmegaCero = ampOmegaCero;
					sol.energiaOmegaCero = energiaOmegaCero;
					thisAnalisisModal.Solucion = sol;
					thisAnalisisModal.Tiempo = tiempoForzante;

				else

					error('Régimen temporal no definido')
				end %if
		end %function amplitudModal
	end %methods
end % classdef

%%%%%%%%%%%%%%%%%%%%%%% THRASH
		 	

