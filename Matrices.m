classdef Matrices < hgsetget

	% MATRICES es el objeto que contiene las matrices utilizadas
	% en la resolución del problema del analisis modal. 
	% El problema que resuelve son las ecuaciones de continuidad
	% y momentum linealizas expresadas como 
	% M \partial_t \chi = i(K + C) \chi + f. 
	% Para mayor información con respecto al significado de cada término
	% ver Shimizu e Imberger (2008)

	properties 

		M		
		K
		C
		f
		Tiempo
		Tipo
		
	end

	methods

		function thisMatrices = Matrices(simulacion, varargin)

			% La construccion de las matrices K y M no requiere especificar 
			% el forzante. Por otro lado, la matriz C si requiere conocer
			% el forzante dado que el coeficiente de friccion 
			% depende de esto.
					
			thisMatrices;

			if(isempty(varargin))
				thisMatrices.Tipo = 'Dimensional';
				thisMatrices = matricesMK(thisMatrices, simulacion);
				thisMatrices = vectorForzante(thisMatrices, simulacion);
				thisMatrices = matrizC(thisMatrices, simulacion);
			elseif(strcmpi(varargin, 'modoslibres'))	
				thisMatrices.Tipo = 'ModosLibres';
				thisMatrices = matricesMK(thisMatrices, simulacion);
				thisMatrices.C = sparse(zeros(size(thisMatrices.K)));			
			elseif(strcmpi(varargin, 'adimensional'))	
				thisMatrices.Tipo = 'Adimensional';
				thisMatrices = matricesMK(thisMatrices, simulacion);
				thisMatrices = vectorForzante(thisMatrices, simulacion);
				thisMatrices = matrizC(thisMatrices, simulacion);
			end

		end %function Matrices


		function thisMatrices = matricesMK(thisMatrices, simulacion)
					
			cuerpo = getCuerpo(simulacion);
			malla = getMalla(cuerpo);
			batimetria = getBatimetria(cuerpo);
			parametros = getParametros(cuerpo);

			Neta = malla.numeroNodosEta;
			Nns = malla.numeroNodosV;
			New = malla.numeroNodosU;
			ID = malla.matrizID;
			IDwe = malla.matrizIDwe;
			IDns = malla.matrizIDns;
			IDeta = malla.matrizIDeta;
			nBIz = malla.numeroBordesIzquierdo;
			nBDe = malla.numeroBordesDerecho;
			nBSu = malla.numeroBordesSuperior;
			nBIn = malla.numeroBordesInferior;

			hoeta =  batimetria.hoNodosEta;
			howe =  batimetria.hoNodosU;
			hons =  batimetria.hoNodosV;
			hprom = 0.971*cuerpo.Geometria.alturaH;	% Especial para Kranenburg

			kap = parametros.kappaVonKarman;
			zo = parametros.zoAsperezaAgua;
			g = parametros.aceleracionGravedad;

			rho = cuerpo.Fluido.densidadRho;
			dx = malla.deltaX;
			dy = malla.deltaY;
	
			fila = (1:Neta)';
	
			% Construcción Matriz K

			K11 = sparse(Neta, Neta);
			K12 = sparse([fila;fila],[IDwe(:,2);IDwe(:,1)], g*[howe(IDwe(:,2))/dx; -howe(IDwe(:,1))/dx]);
			K13 = sparse([fila;fila],[IDns(:,1);IDns(:,2)], g*[hons(IDns(:,1))/dy; -hons(IDns(:,2))/dy]);
			etaEsteExiste = find(IDeta(:,1) ~= 0);
			K21 = sparse([fila;fila(etaEsteExiste)],[fila;IDeta(etaEsteExiste,1)], ... 
			      g*[-howe(IDwe(:,2))/dx; howe(IDwe(etaEsteExiste,2))/dx]);
			K22 = sparse(Neta, New);
			K23 = sparse(Neta, Nns);
			etaNorteExiste = find(IDeta(:,2) ~= 0);
			K31 = sparse([fila; fila(etaNorteExiste)],[fila; IDeta(etaNorteExiste,2)], ...
			      g*[-hons(IDns(:,1))/dy; hons(IDns(etaNorteExiste,1))/dy]);
			K32 = sparse(Neta, New);
			K33 = sparse(Neta, Nns);

			% Construcción Matriz M

			M11 = sparse(fila,fila,g);
			M12 = K32;
			M13 = K23;
			M21 = K11;
			M22 = sparse(fila,IDwe(:,2),howe(IDwe(:,2)));
			M23 = M13;
			M31 = M21;
			M32 = M12;
			M33 = sparse([fila; Neta],[IDns(:,1); Nns], [hons(IDns(:,1)); 0]);

			% Elimino variables fantasma. Se eliminan los nodos \eta 
			% E y N que no existen. Esto equivale a eliminar las 
			% filas o ecuaciones que incluyen estas variables

			indiceEsteNoExiste = find(IDeta(:,1) == 0);
			K21(indiceEsteNoExiste,:) = [];
			K22(indiceEsteNoExiste,:) = [];
			K23(indiceEsteNoExiste,:) = [];

			M21(indiceEsteNoExiste,:) = [];
			M22(indiceEsteNoExiste,:) = [];
			M23(indiceEsteNoExiste,:) = [];

			indiceNorteNoExiste = find(IDeta(:,2) == 0);
			K31(indiceNorteNoExiste,:) = [];
			K32(indiceNorteNoExiste,:) = [];
			K33(indiceNorteNoExiste,:) = [];

			M31(indiceNorteNoExiste,:) = [];
			M32(indiceNorteNoExiste,:) = [];
			M33(indiceNorteNoExiste,:) = [];

			% Asigno condiciones de borde. Velocidad en bordes nula		
			% Debería poder especificar una velocidad en los bordes	
			% eventualmente. En ese caso no sé si debo eliminar las 
			% columnas de las variables a resolver.

			K12(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];
			K22(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];
			K32(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];

			M12(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];
			M22(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];
			M32(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];


			K13(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
			K23(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
			K33(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];

			M13(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
			M23(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
			M33(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];

			% Ordeno submatrices

			K = i*rho*[K11,K12,K13;K21,K22,K23;K31,K32,K33];  
			M = rho*[M11,M12,M13;M21,M22,M23;M31,M32,M33];

			if(strcmpi(thisMatrices.Tipo, 'adimensional'))
				longCar = 2*cuerpo.Geometria.radioR; %Especial para Kranenburg
				K = K*longCar/(rho*g*hprom);
				M = 0.5*[M11/g,M12,M13;M21,M22/hprom,M23;M31,M32,M33/hprom];
			end

			thisMatrices.M = M;
			thisMatrices.K = K;

%			borrarBordes = [ID(nBIz,1);ID(nBDe,2);ID(nBSu,3);ID(nBIn,4)]; 
%			compiladoBatimetria(borrarBordes) = [];
			% thisMatrices.compiladoBatimetria = compiladoBatimetria;

		end %function matricesMK

		function thisMatrices = vectorForzante(thisMatrices, simulacion)
			
			% Por ahora, implemento la construccion matricial 
			% del forzante, pensando en que este puede 
			% ser permanente o impermanente. Además,
			% si bien ya había programado el caso en que 
			% varios forzantes actúan sobre un cuerpo (THRASH),
			% considero ahora que solo existe un único forzante
			% actuando sobre un sistema.

			% Obtengo algunos datos básicos.

			% forzantes = getForzantes(simulacion);
			listaForzantes = getListaForzantes(simulacion);
			cuerpo = getCuerpo(simulacion);
			malla = getMalla(cuerpo);

			Neta = malla.numeroNodosEta;
			Nns = malla.numeroNodosV;
			New = malla.numeroNodosU;
			ID = malla.matrizID;
			nBIz = malla.numeroBordesIzquierdo;
			nBDe = malla.numeroBordesDerecho;
			nBSu = malla.numeroBordesSuperior;
			nBIn = malla.numeroBordesInferior;
			parametros = getParametros(cuerpo);
			g = parametros.aceleracionGravedad;
			rho = cuerpo.Fluido.densidadRho;
			hprom = 0.971*cuerpo.Geometria.alturaH;	% Especial para Kranenburg

			% Cargo lista de forzantes y arroja error si es que 
			% hay más de uno actuando sobre el sistema.
			
			% listaForzantes = forzantes.ListaForzantes;
			% listaForzantesCell = struct2cell(listaForzantes);
			% totalForzantes = length(listaForzantesCell);
			totalForzantes = length(listaForzantes);
			
			% keyboard

			if(totalForzantes > 1) 
				error('Solo debes usar un forzante. Aún no implementas que se superpongan.')
			end						

			% Ahora interesa saber si el forzante es permanente o impermanente
			% para construirlo matricialmente.
		
			% esImpermanente = strcmpi(listaForzantesCell{1}.RegimenTemporal,'impermanente');
			esImpermanente = strcmpi(listaForzantes{1}.RegimenTemporal,'impermanente');
	
			if(esImpermanente)
				% Si es impermanente, entonces obtengo su 
				% vector de tiempo para construir la matriz
				% que lo caracteriza

				% vectorTiempo = listaForzantesCell{1}.Tiempo;
				vectorTiempo = listaForzantes{1}.Tiempo;
				deltaTForzante = abs(vectorTiempo(2) - vectorTiempo(1));
				largoVectorTiempo = length(vectorTiempo);

%				queSeAsignaX = listaForzantesCell{1}.DireccionX;
%				queSeAsignaY = listaForzantesCell{1}.DireccionY;

				queSeAsignaX = listaForzantes{1}.DireccionX;
				queSeAsignaY = listaForzantes{1}.DireccionY;


				% Esta forma de asignación, asume que el forzante actúa uniformemente
				% en el espacio			
				forzanteExterno = sparse(Neta + New + Nns, largoVectorTiempo);
				% keyboard
				% forzanteExterno(Neta + 1: New + Neta, :) = repmat(queSeAsignaX, New, 1); % DireccionX			
				% forzanteExterno(New + Neta + 1: New + Neta + Nns, :) = repmat(queSeAsignaY, Nns, 1); % DireccionY
				forzanteExterno(Neta + 1: New + Neta, :) = queSeAsignaX; % DireccionX			
				forzanteExterno(New + Neta + 1: New + Neta + Nns, :) = queSeAsignaY; % DireccionY

			else 
				% Si es permanente	
					
				forzanteExterno = sparse(Neta + New + Nns, 1);
				queSeAsignaX = listaForzantes{1}.DireccionX;
				queSeAsignaY = listaForzantes{1}.DireccionY;

				forzanteExterno(Neta + 1: New + Neta,1) = queSeAsignaX;
				forzanteExterno(New + Neta + 1:New + Neta + Nns,1) = queSeAsignaY;
				vectorTiempo = [];

			end

			% Borro las filas del vector de forzantes que corresponden 
			% a los nodos que son bordes

			borrarBordes = [ID(nBIz,1);ID(nBDe,2);ID(nBSu,3);ID(nBIn,4)]; 
			forzanteExterno(borrarBordes, :) = [];

			if(strcmpi(thisMatrices.Tipo, 'adimensional'))
				longCar = 2*cuerpo.Geometria.radioR; %Especial para Kranenburg
				forzanteExterno = forzanteExterno*longCar/(rho*g*hprom^2);
				tiempoCar = 2*longCar/(sqrt(g*hprom));
				vectorTiempo = vectorTiempo/tiempoCar;
			end

			thisMatrices.f = forzanteExterno;
			thisMatrices.Tiempo = vectorTiempo;

		end % function vectorForzante

		function thisMatrices = matrizC(thisMatrices, simulacion)

			% Para la construccion de la matriz C necesito 
			% conocer previamente el forzante externo 
			% puesto que el coeficiente de friccion lineal 
			% depende del tipo de forzante.
			% Cargo información básica.

			% forzantes = getForzantes(simulacion);
			listaForzantes = getListaForzantes(simulacion);
			cuerpo = getCuerpo(simulacion);
			malla = getMalla(cuerpo);
			parametros = getParametros(cuerpo);

			Neta = malla.numeroNodosEta;
			Nns = malla.numeroNodosV;
			New = malla.numeroNodosU;
			ID = malla.matrizID;
			IDwe = malla.matrizIDwe;
			IDns = malla.matrizIDns;
			IDeta = malla.matrizIDeta;
			nBIz = malla.numeroBordesIzquierdo;
			nBDe = malla.numeroBordesDerecho;
			nBSu = malla.numeroBordesSuperior;
			nBIn = malla.numeroBordesInferior;
			hprom = 0.971*cuerpo.Geometria.alturaH;	% Especial para Kranenburg			
	
			rho = cuerpo.Fluido.densidadRho;
			g = parametros.aceleracionGravedad;
			fila = (1:Neta)';

			% Cargo lista de forzantes y arroja error si es que 
			% hay más de uno actuando sobre el sistema.
			
			% listaForzantes = forzantes.ListaForzantes;
			% listaForzantesCell = struct2cell(listaForzantes);
			% totalForzantes = length(listaForzantesCell);
			totalForzantes = length(listaForzantes);
			
			if(totalForzantes > 1) 
				error('Solo debes usar un forzante. Aún no implementas que se superpongan.')
			end

			% Debo calcular el coeficiente de fricción lineal.
			% Para la batimetría de Kranenburg, se ha visto 
			% que el coeficiente de fricción lineal se puede
			% calcular como \tilde{cf} = \sqrt{2} f  \tilde{u}
			% siendo \tilde{u} = \sqrt{20}*uAsterisco. 
			% Para mayor información en este caso, ver 
			% Pérez y de la Fuente (2014).

			% Cálculo del coeficiente de fricción
						
			% Obtengo el tipo de Forzante
			
			% tipoForzante = listaForzantesCell{1}.Tipo;
			tipoForzante = listaForzantes{1}.Tipo;						
		
			switch tipoForzante
				case 'vientoUniforme'
					uAsterisco = getUAsterisco(listaForzantes{1});
					uTilde = sqrt(20)*uAsterisco;
					factorFriccion = parametros.factorFriccion;	
					coefFriccionLineal = sqrt(2)*factorFriccion*uTilde;
				case 'acelHoriOsci'
					bat = getCompiladoBatimetria(simulacion);
					amplitud = getAmplitud(listaForzantes{1});
					frecAngular = getFrecAngular(listaForzantes{1});
					uTilde = sqrt(20)*sqrt(amplitud*frecAngular^2*mean(bat));
					factorFriccion = parametros.factorFriccion;
					coefFriccionLineal = sqrt(2)*factorFriccion*uTilde;
				case 'serieAceleracionOsci'
					bat = getCompiladoBatimetria(simulacion);
					amplitud = getAmplitud(listaForzantes{1});
					frecAngular = getFrecAngular(listaForzantes{1});
					uTilde = sqrt(20)*sqrt(amplitud*frecAngular^2*mean(bat));
					factorFriccion = parametros.factorFriccion;
					% coefFriccionLineal = sqrt(2)*factorFriccion*uTilde;
					coefFriccionLineal = 2.5*sqrt(2)*factorFriccion*uTilde;
					% 2.5 parece ser un buen número para ajustar velMedidas
				otherwise 
					error(['No se ha definido un coeficiente de fricción para ', tipoForzante])
			end

			% Construcción Matriz C

			C11 = sparse(Neta, Neta);
			C12 = sparse(Neta, New);
			C13 = sparse(Neta, Nns);
			C21 = sparse(Neta, Neta);
			C22 = sparse(fila, IDwe(:,2), coefFriccionLineal*ones(length(IDwe(:,2)),1));
			C23 = sparse(Neta, Nns);
			C31 = sparse(Neta, Neta);
			C32 = sparse(Neta, New);
			C33 = sparse([fila; Neta], [IDns(:,1); Nns], [coefFriccionLineal*ones(length(IDns(:,1)),1); 0]);

			% Elimino variables fantasma. Se eliminan los nodos \eta 
			% E y N que no existen. Esto equivale a eliminar las 
			% filas o ecuaciones que incluyen estas variables

			indiceEsteNoExiste = find(IDeta(:,1) == 0);
			C21(indiceEsteNoExiste,:) = [];
			C22(indiceEsteNoExiste,:) = [];
			C23(indiceEsteNoExiste,:) = [];

			indiceNorteNoExiste = find(IDeta(:,2) == 0);
			C31(indiceNorteNoExiste,:) = [];
			C32(indiceNorteNoExiste,:) = [];
			C33(indiceNorteNoExiste,:) = [];

			% Asigno condiciones de borde. Velocidad en bordes nula		
			% Debería poder especificar una velocidad en los bordes	
			% eventualmente. En ese caso no sé si debo eliminar las 
			% columnas de las variables a resolver.

			C12(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];
			C22(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];
			C32(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];

			C13(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
			C23(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
			C33(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];

			C = i*rho*[C11,C12,C13;C21,C22,C23;C31,C32,C33];

			if(strcmpi(thisMatrices.Tipo, 'adimensional'))
				longCar = 2*cuerpo.Geometria.radioR; %Especial para Kranenburg
				C = C*longCar/(rho*hprom*sqrt(g*hprom));
			end

			thisMatrices.C = C;

		end % function matrizC
	end %methods
end % classdef







%%%%%%%%%%%%%%%%%%%%%%% THRASH

%		function simulacion = coeficienteFriccion(thisMatrices, simulacion)
%					

%		end %function asignaMatrices


%		function simulacion = asignaMatrices(thisMatrices, simulacion)
%					
%			simulacion.Matrices = generaMatrices(thisMatrices, simulacion);
%		end %function asignaMatrices

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


		% function simulacion = vectorForzante(thisMatrices, simulacion)
					
			% simulacion.Matrices = generaMatrices(thisMatrices, simulacion);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%	% Tengo que avisarle al análisis modal (solver) si 
%	% quiero resolver el problema impermanente o permanente
%	% esto lo define el tipo de forzante aunque tambien
%	% se deberia poder escoger por el usuario.
%	% O sea, Si el forzante es impermanente, si o si 
%	% la resolucion del problema de amplitudes modales
%	% debe ser impermanente. Si el forzante es permanente, 	
%	% entonces puedo resolver el problema permanente o 
%	% impermanente, segun escoja el usuario.
%	% Si el forzante externo es impermanente, entonces 
%	% el vector de forzantes externos debe ser acompañadp
%	% de un vector de tiempo que finalmente determina 
%	% el tiempo que gobernará la resolución del problema.

%	% El hecho de que un forzante sea impermanente, 
%	% donde debería ser especificado? En la creación 
%	% del forzante?	

%	% Hasta ahora, solo falta construir la matriz de forzantes externos.


%	% Los forzantes externos estan almacenados en a lista de forzantes
%	% de la simulacion

%	listaForzantes = forzantes.ListaForzantes;
%	listaForzantesCell = struct2cell(listaForzantes);
%	% la lista de forzantes contiene los forzantes que actuaran sobre el cuerpo
%	% enumerados de la forma N1 hasta Nn, siendo $n$ el numero de forzantes 
%	% que estan actuando sobre el cuerpo.
%	% Los forzantes de la lista tienen como propiedades:
%	% 	Tipo de forzante, que es el nombre o tipo de forzante
%	% 	TipoTemporal que define si el forzante es permanente o impermanente
%	% 	Parametros, que es la informacion que define la magnitud del forzante
%	% 	Tiempo, el cual es un vector de tiempo en el caso que el forzante sea 
%	% 	impermanente
%	% 	DireccionX que es la magnitud del forzante segun X
%	%	DireccionY que e sla magnitud del forzante segun Y	
%	
%	% Si quiero asignar los forzantes al vector f entonces
%	% las pregutnas que debo responder son
%	% Es f un vector impermanente? o Permanente
%	% El vector f es la suma del efecto de todos los forzante especificados
%	% en la lista de forzantes. Esto aplica tanto a la direccion X como a la
%	% direccion Y. Por lo tanto, para construir el vector f, necesito:
%	% 
%	% 	Saber si alguno de los forzantes es impermanente.
%	% 	Si alguno es impermanente, entonces f es una matriz que especifica	
%	% 	el forzante en el tiempo e incluye el efecto de los forzantes
%	%	permanentes. Si existe mas de un forzante impermanente, 
%	% 	entonces debo asegurarme que el efecto de cada forzante impermanente
%	% 	se aplique coherentemente en el vector. A que me refiero con esto, 
%	% 	construir un forzante f tal que el vector de tiempo para ambos
%	% 	forzantes impermanentes sea el mismo. Es decir, 
%	% 	debo verificar el deltaT en cada caso, y llevarlos a lo mismo.
%	%  	Si el deltaT en cada caso impermanente es el mismo, entonces 
%	%  	puedo sumar simplemente los efectos de cada forzante y 
%	%  	utilizar u nunico vector de tiempo.
%	% 	En caso que la informacion temporal sea distinta, entonces
%	% 	debo llevarla a que sea la misma para poder sumarlos.
%	% 	Todos lso vectores de tiempo de los forzantes impermanentes	
%	% 	deben comenzar con respecto al mismo cero.
%	% 	Si existen forzantes permanentes ademas de impermanentes, 
%	% 	entonces para tener en cuenta su efecto, debo sumar 
%	% 	el valor del forzante a la informacion imperannente
%	% 	El forzante permanente, eventualmente puede aplicarse
%	% 	a partir de un cierto tiempo, y no siempre.
%	% 	En el caso, que no existan forzantes impermanentes
%	% 	entonces el vector de forzantes f es unico y debe ser la suma
%	%  	de todos los forzantes.	
%	
%	% Busco alguno de los forzantes es impermanente
%	% Creo que esto deberia hacerlo fuera de la generacion de matrices

%	totalForzantes = length(listaForzantesCell);
%	esImpermanente = zeros(totalForzantes,1);
%	
%	for iLista = 1:totalForzantes
%		
%		esImpermanente(iLista) = strcmpi(listaForzantesCell{iLista}.TipoTemporal,'impermanente');

%	end
%		
%	if sum(esImpermanente)  ~= 0 % Alguno de los forzantes es impermanente?
%		% Si alguno es impermanente
%		cualEsImpermanente = find(esImpermanente == 1);
%		cuantosImpermanente = length(cualEsImpermanente);
%		deltaTForzante = zeros(cuantosImpermanente,1);
%		
%		% Comparo los vectores de tiempo en cada caso
%		% El paso de tiempo para cada forzante impermanente debe ser 
%		% uniforme, es decir, el mismo paso para cada valor especificado
%		% en el vector de tiempo. Eventualmente hay que rellenar algun 
%		% dato con interpolacion.

%		for iVecTiempo = 1:cuantosImpermanente
%			cualEs = cualEsImpermanente(iVecTiempo);
%			deltaTForzante(iVecTiempo) = abs(listaForzantesCell{cualEs}.Tiempo(2) - listaForzantesCell{cualEs}.Tiempo(1));
%			largoVectorTiempo(iVecTiempo) = length(listaForzantesCell{cualEs}.Tiempo);
%		end		
%				
%		if deltaTForzante == deltaTForzante(1)
%			% Si todos los deltaT son iguales, entonces estamos bien 
%			% y el vector de tiempo que define el tamaño del forzante
%			% impermanente será el de menor largo

%			vectorMasCorto = min(largoVectorTiempo);
%			cualEsMasCorto = find(largoVectorTiempo == vectorMasCorto);
%			vectorTiempo = listaForzantesCell{cualEsImpermanente(cualEsMasCorto)}.Tiempo;
%		
%			% Sabiendo ahora cual es el vector mas corto luego puedo adecuar el largo 
%			% de los vectores usando esta informacion
%			
%		else

%			% Busco el mayor deltaT
%			deltaTMayor = max(deltaTForzante);
%			cualEsMayor = find(deltaTForzante == deltaTMayor);
%			vectorTiempo = listaForzantesCell{cualEsImpermanente(cualEsMayor)}.Tiempo;
%			% una vez que tengo el mayor deltaT, debo interpolar y readecuar los datos
%			% de los vectores que tienen un deltaT distinto. Lo hago despues

%		end		

%		
%		% Hasta aqui ya encontre cuales son los forzantes impermanentes y tengo la 
%		% informacion necesaria para redimensionarlos de manera que todos tengan 
%		% un tamaño coherente.


%		forzanteExterno = sparse(Neta + New + Nns, length(vectorTiempo));
%		forzanteExternoAux = forzanteExterno;
%		% Superpongo los vectores impermanentes
%		
%		for iVecTiempo = 1:cuantosImpermanente

%			cualEs = cualEsImpermanente(iVecTiempo);
%			queSeAsignaX = linterp(listaForzantesCell{cualEs}.Tiempo, listaForzantesCell{cualEs}.DireccionX, vectorTiempo);
%			queSeAsignaY = linterp(listaForzantesCell{cualEs}.Tiempo, listaForzantesCell{cualEs}.DireccionY, vectorTiempo);
%			% Asigno valor de un forzante en el tiempo
%			for iLargoTiempo = 1:length(vectorTiempo)

%				forzanteExternoAux(Neta + 1: New + Neta,iLargoTiempo) = queSeAsignaX(iLargoTiempo);% Direccion X
%				forzanteExternoAux(New + Neta + 1:New + Neta + Nns,iLargoTiempo) = queSeAsignaY(iLargoTiempo);% Direccion Y
%			end

%			% Superpongo los forzantes impermanentes	
%			forzanteExterno = forzanteExterno + forzanteExternoAux;	
%	
%		end	

%		% Hasta aqui lo que hice entonces fue, superpuse todos los forzantes impermanentes
%		% con su correcta adaptacion de los vectores de tiempo
%		
%		% Superpongo forzantes permanentes
%		cualEsPermanente = find(esImpermanente == 0);
%		cuantosPermanente = length(cualEsPermanente);
%	
%		forzanteExternoPerm = sparse(Neta + New + Nns, 1);
%		forzanteExternoAuxPerm = sparse(Neta + New + Nns, 1);

%	
%		for iPermanente = 1:cuantosPermanente
%			forzanteExternoAuxPerm(Neta + 1: New + Neta,1) = listaForzantesCell{cualEsPermanente(iPermanente)}.DireccionX;
%			forzanteExternoAuxPerm(New + Neta + 1:New + Neta + Nns,1) = listaForzantesCell{cualEsPermanente(iPermanente)}.DireccionY;
%			forzanteExternoPerm = forzanteExternoPerm + forzanteExternoAuxPerm;
%		end

%		forzanteExterno = forzanteExterno + repmat(forzanteExternoPerm, 1, length(vectorTiempo));

%		% Se superponen correctamente los forzantes permanentes con los impermanentes

%		% En teoria, hasta aqui tengo superpuestos los forzantes permanentes e impermanentes 
%		% para el caso en que los impermanentes existen. Ademas esta implementado
%		% para el caso en que existen varios impermanentes y con distinto paso 
%		% de tiempo.

%		% Lo que faltaría agregar para que este procesamiento quede completo, es agregar
%		% un forzante permanente a partir de un cierto tiempo. Es decir, el efecto 
%		% de un forzante permanente se superpone al impermanente a partir de un cierto tiempo to
%		% y viceversa.

%		% La seccion de superponer forzantes impermanentes debe ser comprobada que funcione correctamente

%		% Ahora y para ir resolviendo otro tipo de problemas	
%		% voy a programar las rutinas necesarias para resolver el problema impermanente de la 
%		% aceleracionHorizontalOscialatoria


%	else
%		% Esta seccion esta lista
%		% Si no hay forzantes impermanentes
%		forzanteExterno = sparse(Neta + New + Nns, 1);
%		forzanteExternoAux = sparse(Neta + New + Nns, 1);

%		for iForzante = 1:totalForzantes
%			forzanteExternoAux(Neta + 1: New + Neta,1) = listaForzantesCell{iForzante}.DireccionX;
%			forzanteExternoAux(New + Neta + 1:New + Neta + Nns,1) = listaForzantesCell{iForzante}.DireccionY;
%			forzanteExterno = forzanteExterno + forzanteExternoAux;
%		end

%		vectorTiempo = [];
%		
%	end

%%keyboard
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Borro las filas del vector de forzantes que corresponden 
%% a los nodos que son bordes

%borrarBordes = [ID(nBIz,1);ID(nBDe,2);ID(nBSu,3);ID(nBIn,4)]; 
%forzanteExterno(borrarBordes, :) = [];
%compiladoBatimetria(borrarBordes) = [];



		% end %function matricesMKC


