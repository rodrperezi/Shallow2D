classdef AnalisisModal < Motor

	% ANALISISMODAL es el motor que procesa la información 
	% utilizando la teoría del análisis modal

	properties 

		TipoTemporal
		Solucion	
		Tiempo	
		VyVPropios		
	
	end

	methods

		function thisAnalisisModal = AnalisisModal(simulacion, tipoTemporal)
					
			thisAnalisisModal;
			thisAnalisisModal.Tipo = 'AnalisisModal';
			thisAnalisisModal.TipoTemporal = tipoTemporal;
			thisAnalisisModal = analisisModal(thisAnalisisModal, simulacion);
	
		end %function AnalisisModal

		function thisAnalisisModal = analisisModal(thisAnalisisModal, simulacion)
	
			cuerpo = simulacion.Cuerpo;
			forzantes = simulacion.Forzantes;
			matrices = simulacion.Matrices;
	
			thisAnalisisModal = calculaVyVPropios(thisAnalisisModal, matrices);
			thisAnalisisModal = amplitudModal(thisAnalisisModal, simulacion);

			% keyboard

			% Hasta aqui todo bien, se resuelve el problema de valores y vectores 
			% propios. Me falta ver la influencia de los valores propios 	
			% con omega = 0 sobre la solucion final.

			% thisAnalisisModal = amplitudModal(thisAnalisisModal, matrices);


			% keyboard
		
			% En esta seccion deberia implementar el calcula de la solucion 	
			% al problema del analisis modal, es decir, calcular las 
			% amplitudes modales y superponer la serie de amplitudes
			% por modos para encontrar la solucion final.	
			% Por lo tanto, puedo generar una rutina que haga el calculo 
			% de las amplitudes modales, y otras que hagan la superposicion, 
			% calculo de la energia, etc.


			% la idea de esta funcion es que
			% tome las matrices especificadas en la	
			% simulacion y las procese para obtener 	
			% el resultado pedido.
			% 
			% Las matrices especificadas en la simulacion son 
			% M, K, C y el forzante externo f. Ademas, se incluye un 
			% vector de tiempo y un compilado de la batimetría
			% que sirve para multiplicar el vector de forzantes
			% en el caso que corresponda como por ejemplo 
			% en presencia de la aceleración horizontal.
			% El compilado de batimetria aparace por promediar verticalmente
			% Las ecuaciones de momentum.

		end
		
		function thisAnalisisModal = calculaVyVPropios(thisAnalisisModal, matrices)
		% function valoresVectoresPropios = calculaVyVPropios(matrices)
		% Calcula valores y vectores propios por la derecha y por la 
		% izquierda. Para mayor información en la definición del problema
		% ver Shimizu e Imberger (2008)

			M = matrices.M;
			K = matrices.K;
			C = matrices.C;
			ProblemaDerecha.valores = [];
			ProblemaDerecha.vectores = [];
			% [ProblemaDerecha.vectores, ProblemaDerecha.valores]= eig(full([K + C]), full(M));
			[ProblemaDerecha.vectores, ProblemaDerecha.valores]= eig(full([K + C]), full(M),'qz');
			ProblemaDerecha.valores = diag(ProblemaDerecha.valores);
			% ProblemaDerecha.vectores = sparse(ProblemaDerecha.vectores);
			ProblemaDerecha.vectores = ProblemaDerecha.vectores;
	
			ProblemaIzquierda.valores = [];
			ProblemaIzquierda.vectores = [];
			% [ProblemaIzquierda.vectores, ProblemaIzquierda.valores]	= eig(full([K + C]'), full(M));
			[ProblemaIzquierda.vectores, ProblemaIzquierda.valores]	= eig(full([K + C]'), full(M),'qz');
			ProblemaIzquierda.valores = diag(ProblemaIzquierda.valores);
			% ProblemaIzquierda.vectores = sparse(ProblemaIzquierda.vectores);
			ProblemaIzquierda.vectores = ProblemaIzquierda.vectores;

			vyVPropios.ProblemaDerecha = ProblemaDerecha;
			vyVPropios.ProblemaIzquierda = ProblemaIzquierda;

			thisAnalisisModal.VyVPropios = vyVPropios;
			thisAnalisisModal = ordenaModos(thisAnalisisModal);
			
			% Los valores propios están ordenados de una forma sublime
			% En los vectores propios hay un desorden. El problema con los 
			% vectores viene desde el cálculo mismo que realiza 
			% el programa. Se puede verificar que los vectores propios
			% de +r y -r no cumplen la relación especificada 
			% en Shimizu e Imberger (2008) tal que \chi(+r) = \chi(-r)*
			% donde el asterisco indica conjugado. Esta falla se repite 
			% tanto para el problema con fricción y como para el problema 
			% sin fricción.

		end %function calculaVyVPropios


		function thisAnalisisModal = amplitudModal(thisAnalisisModal, simulacion)
		
			% Para realizar el calculo de las amplitudes modales, 	
			% lo que necesito son los vyvpropios, el forzante 
			% externo y la matriz M.
		
			geometria = simulacion.Cuerpo.Geometria;
			deltaX = geometria.deltaX;
			deltaY = geometria.deltaY;
			numeroNodosEta = geometria.Malla.numeroNodosEta;
			areaNumerica = deltaX*deltaY*numeroNodosEta;
			matrices = simulacion.Matrices;			
			M = matrices.M;
			K = matrices.K;
			C = matrices.C;
			forzanteExterno = matrices.f;
			problemaDerecha = thisAnalisisModal.VyVPropios.ProblemaDerecha;
			problemaIzquierda = thisAnalisisModal.VyVPropios.ProblemaIzquierda;
	
			valoresDerechaMasR = problemaDerecha.MasR.valores;
			vectoresDerechaMasR = problemaDerecha.MasR.vectores;
			valoresDerechaMenosR = problemaDerecha.MenosR.valores;
			vectoresDerechaMenosR = problemaDerecha.MenosR.vectores;
			valoresDerechaOmegaNulo = problemaDerecha.OmegaNulo.valores;
			vectoresDerechaOmegaNulo = problemaDerecha.OmegaNulo.vectores;

			valoresIzquierdaMasR = problemaIzquierda.MasR.valores;
			vectoresIzquierdaMasR = problemaIzquierda.MasR.vectores;
			valoresIzquierdaMenosR = problemaIzquierda.MenosR.valores;
			vectoresIzquierdaMenosR = problemaIzquierda.MenosR.vectores;
			valoresIzquierdaOmegaNulo = problemaIzquierda.OmegaNulo.valores;
			vectoresIzquierdaOmegaNulo = problemaIzquierda.OmegaNulo.vectores;

			% Debo calcular los términos etilde(r), tanto para masR, menosR y para omega = 0

			eTildeDerechaMasR = dot(vectoresIzquierdaMasR, M*vectoresDerechaMasR)*areaNumerica;
			eTildeDerechaMenosR = dot(vectoresIzquierdaMenosR, M*vectoresDerechaMenosR)*areaNumerica;
			eTildeDerechaOmegaNulo = dot(vectoresIzquierdaOmegaNulo, M*vectoresDerechaOmegaNulo)*areaNumerica;
			iOMGeTildeDerMasR = i*dot(vectoresIzquierdaMasR, (K+C)*vectoresDerechaMasR)*areaNumerica;
			iOMGeTildeDerMenosR = i*dot(vectoresIzquierdaMenosR, (K+C)*vectoresDerechaMenosR)*areaNumerica;
			iOMGeTildeDerOmegaNulo = i*dot(vectoresIzquierdaOmegaNulo, (K+C)*vectoresDerechaOmegaNulo)*areaNumerica;

			eTildeIzquierdaMasR = dot(vectoresDerechaMasR, M*vectoresIzquierdaMasR)*areaNumerica;
			eTildeIzquierdaMenosR = dot(vectoresDerechaMenosR, M*vectoresIzquierdaMenosR)*areaNumerica;

			% Aquí aún no incluyo lo que ocurriría con los términos con omega = 0

			keyboard

			if strcmpi(thisAnalisisModal.TipoTemporal, 'permanente')
				% Si el problema se resuelve utilizando el régimen permanente,
				% existen dos situaciones. Una en que el forzante externo 
				% varíe temporalmente, como por ejemplo en el caso de un 
				% forzante oscilatorio en el régimen permanente, o 
				% que el forzante sea constante en el tiempo.
				% Esta sección tiene que ser capaz de resolver ambos casos
				
				if isempty(matrices.Tiempo)
					% Este es el caso en que el forzante es permanente
					cuantosVectoresR = length(valoresIzquierdaMasR);					
					cuantosVectoresOmegaNulo = length(valoresIzquierdaOmegaNulo);
					fTildeMasR = dot(vectoresIzquierdaMasR, repmat(forzanteExterno, 1, cuantosVectoresR))*areaNumerica;
					fTildeMenosR = dot(vectoresIzquierdaMenosR, repmat(forzanteExterno, 1, cuantosVectoresR))*areaNumerica;
					fTildeOmegaNulo = dot(vectoresIzquierdaOmegaNulo, repmat(forzanteExterno, 1, cuantosVectoresOmegaNulo))*areaNumerica;

					aTildeDerechaMasR = -fTildeMasR./(iOMGeTildeDerMasR);
					aTildeDerechaMenosR = -fTildeMenosR./(iOMGeTildeDerMenosR);
					aTildeDerechaOmegaNulo = -fTildeOmegaNulo./(iOMGeTildeDerOmegaNulo);
						
					solAcumulada = sparse(length(vectoresIzquierdaMasR(:,1)),1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SIN VECTORES CON OMEGA = 0 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%					for iRModo = 1:repite
%				
%						solAuxiliar = aTildeDerechaMasR(iRModo)*vectoresDerechaMasR(:,iRModo) + aTildeDerechaMenosR(iRModo)*vectoresDerechaMenosR(:,iRModo);
%						solAcumulada = solAcumulada + solAuxiliar;
%													
%					end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CONSIDERANDO VECTORES CON OMEGA = 0 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					for iRModo = 1:cuantosVectoresR
				
						solAuxiliar = aTildeDerechaMasR(iRModo)*vectoresDerechaMasR(:,iRModo) + aTildeDerechaMenosR(iRModo)*vectoresDerechaMenosR(:,iRModo);
						solAcumulada = solAcumulada + solAuxiliar;
													
					end

					% Ahora sumo los vectores que tienen omega = 0
					for iOmegaNulo = 1:cuantosVectoresOmegaNulo
				
						solAuxiliar = aTildeDerechaOmegaNulo(iOmegaNulo)*vectoresDerechaOmegaNulo(:,iOmegaNulo);
						solAcumulada = solAcumulada + solAuxiliar;
													
					end
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			
					thisAnalisisModal.Solucion = solAcumulada;

	
				else
					
				end
				
			

			elseif strcmpi(thisAnalisisModal, 'impermanente')
				% Si el problema se resuelve utilizando el régimen impermanente
				% nuevamente existen dos situaciones. La primera sería aquella en que
				% el forzante es impermanente y tiene especificado un vector de tiempo
				% que lo define. La segunda es aquella en el que el forzante es 
				% constante en el tiempo y no existe un vector de tiempo 
				% para resolver el problema. En este último caso, se crea
				% un vector de tiempo arbitrario.


			else
				error('Tipo temporal no definido')
			end






			
%%%			matricesResolucion = Cuerpo.Matrices;
%%%			b = matricesResolucion.f;
%%%			M = matricesResolucion.M;
%%			% valoresVectoresPropios = Cuerpo.valoresVectoresPropios;
%%			
%%			%vr = valoresVectoresPropios.vectoresPropios.derechos;
%%			%dr = valoresVectoresPropios.valoresPropios.derechos;
%%			%vl = valoresVectoresPropios.vectoresPropios.izquierdos;
%%			%dl = valoresVectoresPropios.valoresPropios.izquierdos;

%%			vr = vectoresPropiosDerechos(Cuerpo);
%%			vl = vectoresPropiosIzquierdos(Cuerpo);
%%			drp2 = valoresPropiosDerechos(Cuerpo);
%%			dlp2 = valoresPropiosIzquierdos(Cuerpo);
%%			
%%			flag = 1e-8;
%%			
%%			% drp2 = diag(dr);
%%			% dlp2 = diag(dl);
%%			
%%			vrp2 = vr;
%%			vlp2 = vl;
%%			
%%			omegadr = quant(real(drp2),flag);
%%			gammadr = quant(imag(drp2),flag);
%%			
%%			drp2 = omegadr + sqrt(-1)*gammadr;
%%			
%%			omegadl = quant(real(dlp2),flag);
%%			gammadl = quant(imag(dlp2),flag);
%%			
%%			dlp2 = omegadl + sqrt(-1)*gammadl;
%%			
%%			fdiagcero = find(abs(drp2) <= flag);
%%			fsincero = 1:length(drp2);
%%			fsincero(fdiagcero) = [];
%%			
%%			% keyboard




			
%%			mvr = M*vrp2;
%%			mvrc = M*conj(vrp2);
%%			mvl = M*vlp2;
%%			mvlc = M*conj(vlp2);
%%			
%%			% ftilde = sparse(zeros(length(vlp2),1));
%%			% etilde = ftilde;
%%			
%%			% Para + r
%%				% for i = 1:length(vlp2)
%%				% 	ftilde(i) = vlp2(:,i)'*b;
%%				% 	etilde(i) = vlp2(:,i)'*mvr(:,i);
%%				% end
%%			
%%			ftilde = dot(vlp2,repmat(b,1,length(vlp2)));
%%			ftilde = ftilde.';
%%			etilde = dot(vlp2,mvr);
%%			etilde = etilde.';
%%			
%%			iomegamenosgamma = sqrt(-1)*omegadr - gammadr;
%%			atilde = -ftilde(fsincero)./(iomegamenosgamma(fsincero).*etilde(fsincero));
%%			atilde2 = zeros(length(atilde)+length(fdiagcero),1);
%%			atilde2(fsincero) = atilde;
%%			
%%			
%%			%ftilderm = ftilde;
%%			%etilderm = ftilde;
%%			
%%			%for i = 1:length(vlp2)
%%			%	ftilderm(i) = vlp2(:,i).'*b;
%%			%	etilderm(i) = vlp2(:,i).'*mvrc(:,i);
%%			%end
%%			
%%			%ftilderm = dot(vlp2,repmat(b,1,length(vlp2)));
%%			%ftilderm = conj(ftilderm);
%%			%ftilderm = ftilderm.';
%%			%etilde = dot(vlp2,mvrc);
%%			%ftilderm = conj(ftilderm);
%%			%etilde = etilde.';


%%			%iomegamenosgammarm = -sqrt(-1)*omegadr - gammadr;
%%			%atilderm = -ftilderm(fsincero)./(iomegamenosgammarm(fsincero).*etilderm(fsincero));
%%			%atilde2rm = zeros(length(atilderm)+length(fdiagcero),1);
%%			%atilde2rm(fsincero) = atilderm;

%%			% Sumatoria
%%			SOLam = zeros(length(vrp2),1);
%%			Chivsmod = sparse(zeros(length(vrp2),length(atilde2)));

%%			for i = 1:length(vrp2)
%%			   	Chivsmod(:,i) = real(atilde2(i)*vrp2(:,i)); % Valores para +r y -r están todos incluidos en atilde2.
%%			    	SOLam = SOLam + Chivsmod(:,i);
%%			end

%%			analisisModal = SOLam;

%%			%mchi = M*Chivsmod;
%%			%Etvsmod = sum(Chivsmod.*mchi)/4;
%%			%Epvsmod = sum(Chivsmod(1:Neta,:).*mchi(1:Neta,:))/4;
%%			%Ekvsmod = sum(Chivsmod(Neta:end,:).*mchi(Neta:end,:))/4;
		end

			
		function thisAnalisisModal = ordenaModos(thisAnalisisModal)
			
			problemaDerecha = thisAnalisisModal.VyVPropios.ProblemaDerecha;
			problemaIzquierda = thisAnalisisModal.VyVPropios.ProblemaIzquierda;
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			% Esta parametro permite cortar el valor de los valores propios
			% calculados. En el fondo, es una tolerancia, puesto que producto
			% del calculo numerico y de la precision del programa, a partir
			% de la posicion 1e-10 (mas o menos), los valores propios
			% que deberían ser iguales, pueden ser distintos. Esta diferencia
			% no tiene influencia en el fenomeno, por lo tanto, la descarto.
			precisionCalculo = 1e-8;
			
			omegaDerecha = quant(real(problemaDerecha.valores), precisionCalculo);
			gammaDerecha = quant(imag(problemaDerecha.valores), precisionCalculo);
			omegaIzquierda = quant(real(problemaIzquierda.valores), precisionCalculo);
			gammaIzquierda = quant(imag(problemaIzquierda.valores), precisionCalculo);
			valoresDerechos = omegaDerecha + i*gammaDerecha;
			valoresIzquierdos = omegaIzquierda + i*gammaIzquierda;

			vectoresDerechos = problemaDerecha.vectores;
			vectoresIzquierdos = problemaIzquierda.vectores;

			% keyboard

			% Ya adecué los datos, ahora debo eliminar del calculo, el/los 	
			% modo que tiene modulo del valor propio igual a cero	
			% Para conocer el efecto que tienen en la solucion,	
			% me gustaría aislar todos los modos que tienen omega = 0
			% y caso aparte es el modo que tiene omega y gamma = 0
			

			% Busca modo con valor propio == 0
			cualEsCeroDerecho = find(abs(valoresDerechos) == 0);
			cualEsCeroIzquierdo = find(abs(valoresIzquierdos) == 0);
			valorDerechoNulo = valoresDerechos(cualEsCeroDerecho);
			valorIzquierdoNulo = valoresIzquierdos(cualEsCeroIzquierdo);
			valoresDerechos(cualEsCeroDerecho) = [];
			valoresIzquierdos(cualEsCeroIzquierdo) = [];


			% keyboard
			% Almaceno el vector propio que tiene valor propio nulo			
			vectorVPNuloDerecho = vectoresDerechos(:,cualEsCeroDerecho);
			vectorVPNuloIzquierdo = vectoresDerechos(:,cualEsCeroIzquierdo);

			% Elimino el/los modos con valor propio nulo
			vectoresDerechos(:,cualEsCeroDerecho) = [];				
			vectoresIzquierdos(:,cualEsCeroIzquierdo) = [];

			% Busco modos con omega == 0
			omegaEsCeroDerecho = find(real(valoresDerechos) == 0);
			omegaEsCeroIzquierdo = find(real(valoresIzquierdos) == 0);
			
			% Guardo y elimino del vector de valores propios, aquellos con omega == 0
			valoresOmegaCeroDerecho = valoresDerechos(omegaEsCeroDerecho);
			valoresOmegaCeroIzquierdo = valoresIzquierdos(omegaEsCeroIzquierdo);
			valoresDerechos(omegaEsCeroDerecho) = [];
			valoresIzquierdos(omegaEsCeroIzquierdo) = [];

			% Guardo y elimino del vector de vectores propios, aquellos con omega == 0
			vectoresOmegaCeroDerecho = vectoresDerechos(:,omegaEsCeroDerecho);
			vectoresOmegaCeroIzquierdo = vectoresIzquierdos(:,omegaEsCeroIzquierdo);
			vectoresDerechos(:,omegaEsCeroDerecho) = [];
			vectoresIzquierdos(:,omegaEsCeroIzquierdo) = [];

			[valoresOmegaCeroDerecho IndiceDerechoNulo] = sort(valoresOmegaCeroDerecho, 'ascend');  
			vectoresOmegaCeroDerecho = vectoresOmegaCeroDerecho(:,IndiceDerechoNulo);

			[valoresOmegaCeroIzquierdo IndiceIzquierdoNulo] = sort(valoresOmegaCeroIzquierdo, 'ascend');  
			vectoresOmegaCeroIzquierdo = vectoresOmegaCeroIzquierdo(:,IndiceIzquierdoNulo);

			% Hasta aquí tengo correctamente separados, los vectores
			% y valores propios con abs(omega + igamma) == 0 y 
			% aquellos con gamma = 0

			% Ahora, me gustaría ordenar los modos según el signo de la
			% frecuencia de oscilacion omega, es decir, identificar
			% claramente, cuales son los vectores propios que pertenecen
			% a +r y los que pertenecen a -r (ver Shimizu e Imberger 2008)
			% Esto tiene que ser realizado tanto para el problema 
			% por la izquierda como para el problema por la derecha

			cualOmegaPositivoDerecho = find(real(valoresDerechos) > 0); 
			cualOmegaPositivoIzquierdo = find(real(valoresIzquierdos) > 0);
			cualOmegaNegativoDerecho = find(real(valoresDerechos) < 0); 
			cualOmegaNegativoIzquierdo = find(real(valoresIzquierdos) < 0); 

			valoresDerechosMasR = valoresDerechos(cualOmegaPositivoDerecho);
			valoresDerechosMenosR = valoresDerechos(cualOmegaNegativoDerecho);
			valoresIzquierdosMasR = valoresIzquierdos(cualOmegaPositivoIzquierdo);
			valoresIzquierdosMenosR = valoresIzquierdos(cualOmegaNegativoIzquierdo);
			
			vectoresDerechosMasR = vectoresDerechos(:,cualOmegaPositivoDerecho);
			vectoresDerechosMenosR = vectoresDerechos(:,cualOmegaNegativoDerecho);
			vectoresIzquierdosMasR = vectoresIzquierdos(:,cualOmegaPositivoIzquierdo);
			vectoresIzquierdosMenosR = vectoresIzquierdos(:,cualOmegaNegativoIzquierdo);

			% Ahora ordeno los omegas positivos de menor a mayor
			% y aplico el mismo orden para los vectores, tanto para la derecha
			% como para la izquierda

			[valoresDerechosMasR IndiceDerechoMasR] = sort(valoresDerechosMasR, 'ascend');  
			vectoresDerechosMasR = vectoresDerechosMasR(:,IndiceDerechoMasR);
			[valoresDerechosMenosR IndiceDerechoMenosR] = sort(valoresDerechosMenosR, 'ascend');  
			vectoresDerechosMenosR = vectoresDerechosMenosR(:,IndiceDerechoMenosR);

			[valoresIzquierdosMasR IndiceIzquierdoMasR] = sort(valoresIzquierdosMasR, 'ascend');  
			vectoresIzquierdosMasR = vectoresIzquierdosMasR(:,IndiceIzquierdoMasR);
			[valoresIzquierdosMenosR IndiceIzquierdoMenosR] = sort(valoresIzquierdosMenosR, 'ascend');  
			vectoresIzquierdosMenosR = vectoresIzquierdosMenosR(:,IndiceIzquierdoMenosR);
			keyboard %REVISAR QUE PASARIA EN EL CASO DE FRICCION CERO PARECE QUE CAGA
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			masRDerecha.valores = valoresDerechosMasR;
			masRDerecha.vectores = vectoresDerechosMasR;
			menosRDerecha.valores = valoresDerechosMenosR;
			menosRDerecha.vectores = vectoresDerechosMenosR;
			omegaNuloDerecha.valores = valoresOmegaCeroDerecho;
			omegaNuloDerecha.vectores = vectoresOmegaCeroDerecho;
			vPropioNuloDerecha.valores = valorDerechoNulo;
			vPropioNuloDerecha.vectores = vectorVPNuloDerecho;
			masRIzquierda.valores = valoresIzquierdosMasR;
			masRIzquierda.vectores = vectoresIzquierdosMasR;
			menosRIzquierda.valores = valoresIzquierdosMenosR;
			menosRIzquierda.vectores = vectoresIzquierdosMenosR;
			omegaNuloIzquierda.valores = valoresOmegaCeroIzquierdo;
			omegaNuloIzquierda.vectores = vectoresOmegaCeroIzquierdo;
			vPropioNuloIzquierda.valores = valorIzquierdoNulo;
			vPropioNuloIzquierda.vectores = vectorVPNuloIzquierdo;
			ProblemaDerecha.MasR = masRDerecha;
			ProblemaDerecha.MenosR = menosRDerecha;
			ProblemaDerecha.OmegaNulo = omegaNuloDerecha;
			ProblemaDerecha.vPropioNulo = vPropioNuloDerecha;
			ProblemaIzquierda.MasR = masRIzquierda;
			ProblemaIzquierda.MenosR = menosRIzquierda;
			ProblemaIzquierda.OmegaNulo = omegaNuloIzquierda;
			ProblemaIzquierda.vPropioNulo = vPropioNuloIzquierda;

			vyVPropios.ProblemaDerecha = ProblemaDerecha;
			vyVPropios.ProblemaIzquierda = ProblemaIzquierda;

			thisAnalisisModal.VyVPropios = vyVPropios;
		end %function ordenaModos
	end %methods
end % classdef
