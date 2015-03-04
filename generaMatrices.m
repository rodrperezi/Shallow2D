function thisMatrices = generaMatrices(thisMatrices, simulacion)
% function thisMatrices = generaMatrices(thisMatrices, simulacion)
% generaMatrices: Función que genera matrices para resolver 
% las ecuaciones de movimiento de un fluido en una hoya de una capa. 
% El resultado se entrega en la estructura matricesResolucion la cual 
% tiene las matrices M \partial{chi}/ \partial{t} = i(K + C) chi + f
% Para entender mejor el sistema de ecuaciones se recomienda ver Shimizu e Imberger 2008.

% Tengo que pensar la construcción de las matrices para el caso de n capas.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	cuerpo = simulacion.Cuerpo;
	forzantes = simulacion.Forzantes; 
	malla = cuerpo.Geometria.Malla;
	batimetria = cuerpo.Geometria.Batimetria;
	parametros = cuerpo.Parametros;

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

	kap = parametros.kappaVonKarman;
	zo = parametros.zoAsperezaAgua;
	g = parametros.aceleracionGravedad;

	compiladoBatimetria = [hoeta; howe; hons];
	rho = cuerpo.Fluido.densidadRho;
	dx = cuerpo.Geometria.deltaX;
	dy = cuerpo.Geometria.deltaY;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	% Tengo que avisarle al análisis modal (solver) si 
	% quiero resolver el problema impermanente o permanente
	% esto lo define el tipo de forzante aunque tambien
	% se deberia poder escoger por el usuario.
	% O sea, Si el forzante es impermanente, si o si 
	% la resolucion del problema de amplitudes modales
	% debe ser impermanente. Si el forzante es permanente, 	
	% entonces puedo resolver el problema permanente o 
	% impermanente, segun escoja el usuario.
	% Si el forzante externo es impermanente, entonces 
	% el vector de forzantes externos debe ser acompañadp
	% de un vector de tiempo que finalmente determina 
	% el tiempo que gobernará la resolución del problema.

	% El hecho de que un forzante sea impermanente, 
	% donde debería ser especificado? En la creación 
	% del forzante?	

	% Hasta ahora, solo falta construir la matriz de forzantes externos.


	% Los forzantes externos estan almacenados en a lista de forzantes
	% de la simulacion

	listaForzantes = forzantes.ListaForzantes;
	listaForzantesCell = struct2cell(listaForzantes);
	% la lista de forzantes contiene los forzantes que actuaran sobre el cuerpo
	% enumerados de la forma N1 hasta Nn, siendo $n$ el numero de forzantes 
	% que estan actuando sobre el cuerpo.
	% Los forzantes de la lista tienen como propiedades:
	% 	Tipo de forzante, que es el nombre o tipo de forzante
	% 	TipoTemporal que define si el forzante es permanente o impermanente
	% 	Parametros, que es la informacion que define la magnitud del forzante
	% 	Tiempo, el cual es un vector de tiempo en el caso que el forzante sea 
	% 	impermanente
	% 	DireccionX que es la magnitud del forzante segun X
	%	DireccionY que e sla magnitud del forzante segun Y	
	
	% Si quiero asignar los forzantes al vector f entonces
	% las pregutnas que debo responder son
	% Es f un vector impermanente? o Permanente
	% El vector f es la suma del efecto de todos los forzante especificados
	% en la lista de forzantes. Esto aplica tanto a la direccion X como a la
	% direccion Y. Por lo tanto, para construir el vector f, necesito:
	% 
	% 	Saber si alguno de los forzantes es impermanente.
	% 	Si alguno es impermanente, entonces f es una matriz que especifica	
	% 	el forzante en el tiempo e incluye el efecto de los forzantes
	%	permanentes. Si existe mas de un forzante impermanente, 
	% 	entonces debo asegurarme que el efecto de cada forzante impermanente
	% 	se aplique coherentemente en el vector. A que me refiero con esto, 
	% 	construir un forzante f tal que el vector de tiempo para ambos
	% 	forzantes impermanentes sea el mismo. Es decir, 
	% 	debo verificar el deltaT en cada caso, y llevarlos a lo mismo.
	%  	Si el deltaT en cada caso impermanente es el mismo, entonces 
	%  	puedo sumar simplemente los efectos de cada forzante y 
	%  	utilizar u nunico vector de tiempo.
	% 	En caso que la informacion temporal sea distinta, entonces
	% 	debo llevarla a que sea la misma para poder sumarlos.
	% 	Todos lso vectores de tiempo de los forzantes impermanentes	
	% 	deben comenzar con respecto al mismo cero.
	% 	Si existen forzantes permanentes ademas de impermanentes, 
	% 	entonces para tener en cuenta su efecto, debo sumar 
	% 	el valor del forzante a la informacion imperannente
	% 	El forzante permanente, eventualmente puede aplicarse
	% 	a partir de un cierto tiempo, y no siempre.
	% 	En el caso, que no existan forzantes impermanentes
	% 	entonces el vector de forzantes f es unico y debe ser la suma
	%  	de todos los forzantes.	
	
	% Busco alguno de los forzantes es impermanente
	% Creo que esto deberia hacerlo fuera de la generacion de matrices

	totalForzantes = length(listaForzantesCell);
	esImpermanente = zeros(totalForzantes,1);
	
	for iLista = 1:totalForzantes
		
		esImpermanente(iLista) = strcmpi(listaForzantesCell{iLista}.TipoTemporal,'impermanente');

	end
		
	if sum(esImpermanente)  ~= 0 % Alguno de los forzantes es impermanente?
		% Si alguno es impermanente
		cualEsImpermanente = find(esImpermanente == 1);
		cuantosImpermanente = length(cualEsImpermanente);
		deltaTForzante = zeros(cuantosImpermanente,1);
		
		% Comparo los vectores de tiempo en cada caso
		% El paso de tiempo para cada forzante impermanente debe ser 
		% uniforme, es decir, el mismo paso para cada valor especificado
		% en el vector de tiempo. Eventualmente hay que rellenar algun 
		% dato con interpolacion.

		for iVecTiempo = 1:cuantosImpermanente
			cualEs = cualEsImpermanente(iVecTiempo);
			deltaTForzante(iVecTiempo) = abs(listaForzantesCell{cualEs}.Tiempo(2) - listaForzantesCell{cualEs}.Tiempo(1));
			largoVectorTiempo(iVecTiempo) = length(listaForzantesCell{cualEs}.Tiempo);
		end		
				
		if deltaTForzante == deltaTForzante(1)
			% Si todos los deltaT son iguales, entonces estamos bien 
			% y el vector de tiempo que define el tamaño del forzante
			% impermanente será el de menor largo

			vectorMasCorto = min(largoVectorTiempo);
			cualEsMasCorto = find(largoVectorTiempo == vectorMasCorto);
			vectorTiempo = listaForzantesCell{cualEsImpermanente(cualEsMasCorto)}.Tiempo;
		
			% Sabiendo ahora cual es el vector mas corto luego puedo adecuar el largo 
			% de los vectores usando esta informacion
			
		else

			% Busco el mayor deltaT
			deltaTMayor = max(deltaTForzante);
			cualEsMayor = find(deltaTForzante == deltaTMayor);
			vectorTiempo = listaForzantesCell{cualEsImpermanente(cualEsMayor)}.Tiempo;
			% una vez que tengo el mayor deltaT, debo interpolar y readecuar los datos
			% de los vectores que tienen un deltaT distinto. Lo hago despues

		end		

		
		% Hasta aqui ya encontre cuales son los forzantes impermanentes y tengo la 
		% informacion necesaria para redimensionarlos de manera que todos tengan 
		% un tamaño coherente.


		forzanteExterno = sparse(Neta + New + Nns, length(vectorTiempo));
		forzanteExternoAux = forzanteExterno;
		% Superpongo los vectores impermanentes
		
		for iVecTiempo = 1:cuantosImpermanente

			cualEs = cualEsImpermanente(iVecTiempo);
			queSeAsignaX = linterp(listaForzantesCell{cualEs}.Tiempo, listaForzantesCell{cualEs}.DireccionX, vectorTiempo);
			queSeAsignaY = linterp(listaForzantesCell{cualEs}.Tiempo, listaForzantesCell{cualEs}.DireccionY, vectorTiempo);
			% Asigno valor de un forzante en el tiempo
			for iLargoTiempo = 1:length(vectorTiempo)

				forzanteExternoAux(Neta + 1: New + Neta,iLargoTiempo) = queSeAsignaX(iLargoTiempo);% Direccion X
				forzanteExternoAux(New + Neta + 1:New + Neta + Nns,iLargoTiempo) = queSeAsignaY(iLargoTiempo);% Direccion Y
			end

			% Superpongo los forzantes impermanentes	
			forzanteExterno = forzanteExterno + forzanteExternoAux;	
	
		end	

		% Hasta aqui lo que hice entonces fue, superpuse todos los forzantes impermanentes
		% con su correcta adaptacion de los vectores de tiempo
		
		% Superpongo forzantes permanentes
		cualEsPermanente = find(esImpermanente == 0);
		cuantosPermanente = length(cualEsPermanente);
	
		forzanteExternoPerm = sparse(Neta + New + Nns, 1);
		forzanteExternoAuxPerm = sparse(Neta + New + Nns, 1);

	
		for iPermanente = 1:cuantosPermanente
			forzanteExternoAuxPerm(Neta + 1: New + Neta,1) = listaForzantesCell{cualEsPermanente(iPermanente)}.DireccionX;
			forzanteExternoAuxPerm(New + Neta + 1:New + Neta + Nns,1) = listaForzantesCell{cualEsPermanente(iPermanente)}.DireccionY;
			forzanteExternoPerm = forzanteExternoPerm + forzanteExternoAuxPerm;
		end

		forzanteExterno = forzanteExterno + repmat(forzanteExternoPerm, 1, length(vectorTiempo));

		% Se superponen correctamente los forzantes permanentes con los impermanentes

		% En teoria, hasta aqui tengo superpuestos los forzantes permanentes e impermanentes 
		% para el caso en que los impermanentes existen. Ademas esta implementado
		% para el caso en que existen varios impermanentes y con distinto paso 
		% de tiempo.

		% Lo que faltaría agregar para que este procesamiento quede completo, es agregar
		% un forzante permanente a partir de un cierto tiempo. Es decir, el efecto 
		% de un forzante permanente se superpone al impermanente a partir de un cierto tiempo to
		% y viceversa.

		% La seccion de superponer forzantes impermanentes debe ser comprobada que funcione correctamente

		% Ahora y para ir resolviendo otro tipo de problemas	
		% voy a programar las rutinas necesarias para resolver el problema impermanente de la 
		% aceleracionHorizontalOscialatoria


	else
		% Esta seccion esta lista
		% Si no hay forzantes impermanentes
		forzanteExterno = sparse(Neta + New + Nns, 1);
		forzanteExternoAux = sparse(Neta + New + Nns, 1);

		for iForzante = 1:totalForzantes
			forzanteExternoAux(Neta + 1: New + Neta,1) = listaForzantesCell{iForzante}.DireccionX;
			forzanteExternoAux(New + Neta + 1:New + Neta + Nns,1) = listaForzantesCell{iForzante}.DireccionY;
			forzanteExterno = forzanteExterno + forzanteExternoAux;
		end

		vectorTiempo = [];
		
	end

%keyboard


% Borro las filas del vector de forzantes que corresponden 
% a los nodos que son bordes

borrarBordes = [ID(nBIz,1);ID(nBDe,2);ID(nBSu,3);ID(nBIn,4)]; 
forzanteExterno(borrarBordes, :) = [];
compiladoBatimetria(borrarBordes) = [];

% Friccion POR AHORA PONGO CUALQUIER COSA COMO FRICCION	
% uvTildeFriccion = sqrt(20)*uAsterisco; %Perez y de la Fuente 2014
uAsterisco = listaForzantes.N1.Parametros.uAsterisco;
uvTildeFriccion = 0*sqrt(20)*uAsterisco; %Perez y de la Fuente 2014
factorFriccion = parametros.factorFriccion; 
coefFriccionLineal = inline('sqrt(2)*factorFriccion*uvTildeFriccion*ones(length(donde),1)','factorFriccion', 'uvTildeFriccion','donde');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fila = (1:Neta)';
	
	% Construcción Matriz K

	K11 = sparse(zeros(Neta));
	K12 = sparse([fila;fila],[IDwe(:,1);IDwe(:,2)],rho*g*[howe(IDwe(:,1))/dx; -howe(IDwe(:,2))/dx]);
	K13 = sparse([fila;fila],[IDns(:,1);IDns(:,2)],rho*g*[-hons(IDns(:,1))/dy; hons(IDns(:,2))/dy]);
	feste = find(IDeta(:,1) ~= 0);
	K21 = sparse([fila;fila(feste)],[fila;IDeta(feste,1)],rho*[g*howe(IDwe(:,2))/dx; -g*howe(IDwe(feste,2))/dx]);
	K22 = sparse(max(fila),max(IDwe(:,2)));
	K23 = sparse(zeros(Neta, Nns));
	gnor = find(IDeta(:,2) ~= 0);
	K31 = sparse([fila;fila(gnor)],[fila;IDeta(gnor,2)],rho*[g*hons(IDns(:,1))/dy; -g*hons(IDns(gnor,1))/dy]);
	K32 = sparse(zeros(Neta, New));

	% Construcción Matriz C

	if(sum(find(IDns(:,1) == Nns))~=1)
	    % C33 = sparse([fila;max(fila)],[IDns(:,1);Nns], [-rho*cfprim(kap,zo,hons(IDns(:,1)),uvtilde,uvtilde);0]);
		C33 = sparse([fila;max(fila)],[IDns(:,1);Nns], [rho*coefFriccionLineal(factorFriccion, uvTildeFriccion,hons(IDns(:,1)));0]);
	else
	    % C33 = sparse(fila,IDns(:,1), -rho*cfprim(kap,zo,hons(IDns(:,1)),uvtilde,uvtilde));
		C33 = sparse(fila,IDns(:,1), rho*coefFriccionLineal(factorFriccion, uvTildeFriccion,hons(IDns(:,1))));
	end

	[m,n] = size(C33);	
	K33 = sparse(m,n);

	C11 = K11;
	[m,n] = size(K12);
	C12 = sparse(m,n);
	[m,n] = size(K13);
	C13 = sparse(m,n);
	[m,n] = size(K21);
	C21 = sparse(m,n);
	C22 = sparse(fila,IDwe(:,2), rho*coefFriccionLineal(factorFriccion, uvTildeFriccion,howe(IDwe(:,2))));
	[m,n] = size(K23);
	C23 = sparse(m,n);
	[m,n] = size(K31);
	C31 = sparse(m,n);
	[m,n] = size(K32);
	C32 = sparse(m,n);
	
	% Construcción Matriz M

	M11 = sparse(fila,fila,rho*g);
	M12 = K32;
	M13 = K23;
	M21 = K11;
	M22 = sparse(fila,IDwe(:,2),rho*howe(IDwe(:,2)));
	M23 = M13;
	M31 = M21;
	M32 = M12;

	if(sum(find(IDns(:,1) == Nns))~=1)
	    M33 = sparse([fila;max(fila)],[IDns(:,1);Nns], [rho*hons(IDns(:,1));0]);
	else
	    M33 = sparse(fila,IDns(:,1),rho*hons(IDns(:,1)));
	end

	% Elimino variables fantasma. Se eliminan los nodos \eta 
	% E y N que no existen. Esto equivale a eliminar las 
	% filas o ecuaciones que incluyen estas variables

	indiceEsteNoExiste = find(IDeta(:,1) == 0);
	K21(indiceEsteNoExiste,:) = [];
	K22(indiceEsteNoExiste,:) = [];
	K23(indiceEsteNoExiste,:) = [];

	C21(indiceEsteNoExiste,:) = [];
	C22(indiceEsteNoExiste,:) = [];
	C23(indiceEsteNoExiste,:) = [];

	M21(indiceEsteNoExiste,:) = [];
	M22(indiceEsteNoExiste,:) = [];
	M23(indiceEsteNoExiste,:) = [];

	indiceNorteNoExiste = find(IDeta(:,2) == 0);
	K31(indiceNorteNoExiste,:) = [];
	K32(indiceNorteNoExiste,:) = [];
	K33(indiceNorteNoExiste,:) = [];

	C31(indiceNorteNoExiste,:) = [];
	C32(indiceNorteNoExiste,:) = [];
	C33(indiceNorteNoExiste,:) = [];

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

	C12(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];
	C22(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];
	C32(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];

	M12(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];
	M22(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];
	M32(:,[IDwe(nBIz,1);IDwe(nBDe,2)]) = [];

	K13(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
	K23(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
	K33(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];

	C13(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
	C23(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
	C33(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];

	M13(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
	M23(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];
	M33(:,[IDns(nBSu,1);IDns(nBIn,2)]) = [];

	% Ordeno submatrices

	C = sqrt(-1)*[C11,C12,C13;C21,C22,C23;C31,C32,C33];
	% Este signo menos (el que viene) está aqui por como 
	% está programada la matriz K. 	
	K = -sqrt(-1)*[K11,K12,K13;K21,K22,K23;K31,K32,K33]; 
	M = [M11,M12,M13;M21,M22,M23;M31,M32,M33];

	thisMatrices.M = M;
	thisMatrices.K = K;
	thisMatrices.C = C;
	thisMatrices.f = forzanteExterno;
	thisMatrices.Tiempo = vectorTiempo;
	thisMatrices.compiladoBatimetria = compiladoBatimetria;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


