function matricesResolucion = generaMatrices(Cuerpo)
% generaMatrices: Función que genera matrices para resolver 
% las ecuaciones de movimiento de un fluido en una hoya de una capa. 
% El resultado se entrega en la estructura matricesResolucion la cual 
% tiene las matrices M \partial{chi}/ \partial{t} = i(K + C) chi + f
% Para entender mejor el sistema de ecuaciones se recomienda ver Shimizu e Imberger 2008.


	% Llamo a las principales caracteristicas utilizadas en esta funcion

	% mallaStaggered = Cuerpo.Geometria.Malla.InformacionMalla;
	mallaStaggered = getMalla(Cuerpo);
	mallaStaggered = mallaStaggered.InformacionMalla;	
	
	Neta = length(mallaStaggered.coordenadasEta);
	Nns = length(mallaStaggered.coordenadasU);
	New = length(mallaStaggered.coordenadasV);
	ID = mallaStaggered.ID;
	IDwe = mallaStaggered.IDwe;
	IDns = mallaStaggered.IDns;
	IDeta = mallaStaggered.IDeta;
	howe =  Cuerpo.Geometria.batimetriaKranenburg.hoU;     
	hons =  Cuerpo.Geometria.batimetriaKranenburg.hoV;
	rho = Cuerpo.Fluido.densidadRho;
	kap = Cuerpo.Parametros.kappaVonKarman;
	zo = Cuerpo.Parametros.zoAsperezaAgua;
	g = Cuerpo.Parametros.aceleracionGravedad;

	dx = Cuerpo.Geometria.deltaX;
	dy = Cuerpo.Geometria.deltaY;

	nBIz = mallaStaggered.numeroBordesIzquierdo;
	nBDe = mallaStaggered.numeroBordesDerecho;
	nBSu = mallaStaggered.numeroBordesSuperior;
	nBIn = mallaStaggered.numeroBordesInferior;

	% Asigno vector de forzantes	
	forzanteExterno = sparse(zeros(Neta + New + Nns,1));

	if(strcmpi(Cuerpo.Forzante.tipoForzante, 'vientoUniforme'))
		
		if(strcmpi(Cuerpo.Forzante.parametroCaracteristico1,'uasterisco'))		
			uAsterisco = Cuerpo.Forzante.valorParametroCaracteristico1;
			anguloViento = Cuerpo.Forzante.valorParametroCaracteristico2;
		elseif(strcmpi(Cuerpo.Forzante.parametroCaracteristico1,'anguloViento'))		
			uAsterisco = Cuerpo.Forzante.valorParametroCaracteristico2;
			anguloViento = Cuerpo.Forzante.valorParametroCaracteristico1;
		else
			error('myapp:Chk','Algun error en los nombres de los parametros')
		end
		
		forzanteExterno(Neta + 1: New + Neta,1) = rho*uAsterisco^2*cos(anguloViento);
		forzanteExterno(New + Neta + 1:New + Neta + Nns,1) = rho*uAsterisco^2*sin(anguloViento);
		del = [ID(nBIz,1);ID(nBDe,2);ID(nBSu,3);ID(nBIn,4)]; 
		forzanteExterno(del) = [];

		% Friccion
		uvTildeFriccion = sqrt(20)*uAsterisco; %Perez y de la Fuente 2014
		factorFriccion = Cuerpo.Parametros.factorFriccion; 
		coefFriccionLineal = inline('sqrt(2)*factorFriccion*uvTildeFriccion*ones(length(donde),1)','factorFriccion', 'uvTildeFriccion','donde');

	elseif(strcmpi(Cuerpo.Forzante.tipoForzante, 'oscilacionHorizontalX'))
	
	
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	fila = (1:Neta)';
	
	% Matriz K
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

	% Matriz C

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
	
	% Matriz M
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

	% Elimino variables fantasma. Son nodos E y N que no existen
	feste = find(IDeta(:,1) == 0);
	K21(feste,:) = [];
	K22(feste,:) = [];
	K23(feste,:) = [];

	C21(feste,:) = [];
	C22(feste,:) = [];
	C23(feste,:) = [];

	M21(feste,:) = [];
	M22(feste,:) = [];
	M23(feste,:) = [];

	gnor = find(IDeta(:,2) == 0);
	K31(gnor,:) = [];
	K32(gnor,:) = [];
	K33(gnor,:) = [];

	C31(gnor,:) = [];
	C32(gnor,:) = [];
	C33(gnor,:) = [];

	M31(gnor,:) = [];
	M32(gnor,:) = [];
	M33(gnor,:) = [];

	% Asigno condiciones de borde. Velocidad en bordes nula	
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

	% Ordeno matrices 
	C = sqrt(-1)*[C11,C12,C13;C21,C22,C23;C31,C32,C33];
	K = -sqrt(-1)*[K11,K12,K13;K21,K22,K23;K31,K32,K33]; % Este signo menos está aqui porque la programación de la matriz K. 
% Se puede corregir pero por ahora no tiene mucho sentido
	M = [M11,M12,M13;M21,M22,M23;M31,M32,M33];

	matricesResolucion.M = M;
	matricesResolucion.K = K;
	matricesResolucion.C = C;
	matricesResolucion.f = forzanteExterno;





