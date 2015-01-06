function malla = generaMallaStaggered(borde, deltaX, deltaY)
% Rodrigo Pérez I. 
% Rutina que construye la malla staggered dados un borde que delimite
% la superficie de la laguna y los valores del espaciamiento espacial 
% deltaX y deltaY.

%%% Busco Puntos que están dentro del borde que delimita la superficie libre
	nodosEtaDentroBorde = puntosDentroBorde(borde, deltaX, deltaY);  % Matriz de indice de nodos eta que estan dentro del borde
	[xDentroBorde yDentroBorde] = find(nodosEtaDentroBorde'==1); % Identifico coordenadas matriciales de puntos dentro del borde

	xEta = min(borde(:,1)) + deltaX/2: deltaX : max(borde(:,1)) - deltaX/2;
	yEta = max(borde(:,2)) - deltaY/2: -deltaY: min(borde(:,2)) + deltaY/2;

	coordenadasEta = [xEta(xDentroBorde)', yEta(yDentroBorde)']; % Coordenadas espaciales de nodos eta.
	numeroNodosEta = length(coordenadasEta(:,1)); 

	[m n] = size(nodosEtaDentroBorde);
	geo = sparse([zeros(m+2,1),[zeros(1,n);nodosEtaDentroBorde + 0;zeros(1,n)],zeros(m+2,1)]); % Agrego filas de ceros por arriba y abajo y columnas con ceros por izquierda y derecha.
	geoSupInf = diff(geo);   % Bordes superiores e inferiores. Bordes superiores tienen valor 1 e inferiores -1
	geoIzqDer = diff(geo')'; % Bordes Izquierdos y derechos. Bordes izquierdos tienen valor 1 y derechos -1

%% Identifico coordenadas de los nodos que son borde
	[bordeDerechoX bordeDerechoY] = find(geoIzqDer == -1); %Bordes Derechos 
	[bordeInferiorX bordeInferiorY] = find(geoSupInf == -1); %Bordes Inferiores
	[bordeIzquierdoX bordeIzquierdoY] = find(geoIzqDer == 1); %Bordes Izquierdos 
	[bordeSuperiorX bordeSuperiorY] = find(geoSupInf == 1); %Bordes Superiores

	[xNumeroNodosEta yNumeroNodosEta] = find(geo == 1); % Posiciones x e y de nodos \eta.
	geoIzqDer = sparse(zeros(size(geo)));

	% Enumero nodos \eta. El extremo superior izquierdo es el primero
	% y el extremo inferior derecho es el último.
	for iEnum = 1:numeroNodosEta 
		geoIzqDer(xNumeroNodosEta(iEnum),yNumeroNodosEta(iEnum)) = iEnum;    
	end
	geoIzqDer = geoIzqDer';

	% Calculo cuandos nodos son borde derecho, superior, izquierdo, inferior.
	numeroBordesDerecho = zeros(length(bordeDerechoX),1);
	numeroBordesSuperior = zeros(length(bordeSuperiorX),1);
	numeroBordesIzquierdo = zeros(length(bordeIzquierdoX),1);
	numeroBordesInferior = zeros(length(bordeInferiorX),1);

	% Reconozco bordes según su número identificador (geoIzqDer)
	for iBorde = 1:length(numeroBordesIzquierdo) 
		numeroBordesIzquierdo(iBorde) = geoIzqDer(bordeIzquierdoX(iBorde), bordeIzquierdoY(iBorde)+1);
	end
	numeroBordesIzquierdo = sort(numeroBordesIzquierdo);

	for iBorde = 1:length(numeroBordesInferior) 
		numeroBordesInferior(iBorde) = geoIzqDer(bordeInferiorX(iBorde),bordeInferiorY(iBorde));
	end
	numeroBordesInferior = sort(numeroBordesInferior);

	for iBorde = 1:length(numeroBordesDerecho) 
		numeroBordesDerecho(iBorde) = geoIzqDer(bordeDerechoX(iBorde),bordeDerechoY(iBorde));
	end
	numeroBordesDerecho = sort(numeroBordesDerecho);

	for iBorde = 1:length(numeroBordesSuperior) 
		numeroBordesSuperior(iBorde) = geoIzqDer(bordeSuperiorX(iBorde)+1,bordeSuperiorY(iBorde));
	end
	numeroBordesSuperior = sort(numeroBordesSuperior);

	numeroNodosU = numeroNodosEta + length(bordeDerechoX);
	numeroNodosV = numeroNodosEta + length(bordeSuperiorX);

% Creo matriz ID para reconocer cuales son los nodos de velocidad que 
% rodean a un nodo central \eta. La fila i de la matriz ID corresponde al 
% nodo central i.

% Los nodos w y e son los que siguen a continuación de los nodos \eta en 
% numeración y luego le siguen los norte y sur. Es decir la numeración es
% (\eta, w, e, n, s)

	ID = zeros(numeroNodosEta,4); % Nodos de velocidad w,e,n,s
	ID(1,:) = [numeroNodosEta + 1, numeroNodosEta + 2, 0, 0];
	auxde = zeros(numeroNodosEta,1);
	auxde(numeroBordesDerecho(1:end-1)+1) = 1;

	% Los siguientes ID son para reconocer que nodos \eta rodean a un
	% al nodo central i. Eventualmente alguno de estos identificadores
	% será utilizado pero no todos. Los había pensado para volumenes
	% finitos con esquema lineal.
		
	IDeta = zeros(numeroNodosEta,2); % Nodos eta: E, N
	IDetaC = zeros(numeroNodosEta,6); % Nodos eta: W, E, E+1, S, N, N+1
	IDetaCup = zeros(numeroNodosEta,3); % Nodos eta: W(P-1), P, E (P+1)
	IDetaCdo = zeros(numeroNodosEta,3); % Nodos eta: W(P-1), P, E (P+1)

	% Variables auxiliares para construir ID
	vnor = zeros(size(geo));
	vsur = vnor;
	binf = 0;
	bsup = 0;
	yaux = 1;
	aux1 = 0;
	aux2 = aux1;
	
	% Coordenadas de nodos u (w,e) y v (n,s).	
	coordenadasU = [];
	coordenadasV = zeros(numeroNodosV,2);

	% Construcción de matriz ID

	for i = 1:numeroNodosEta

		if(yNumeroNodosEta(i)>yaux) 
			if(yNumeroNodosEta(i) > 2) aux1 = sum(geoSupInf(yNumeroNodosEta(i)-2,:)==-1);end;
			aux2 = sum(geoSupInf(yNumeroNodosEta(i)-1,:)==1);
			binf = binf + aux1;
			bsup = bsup + aux2;
			yaux = yNumeroNodosEta(i);
		end;

		if(yNumeroNodosEta(i) > 2) aux1 = sum(geoSupInf(yNumeroNodosEta(i)-1,1:xNumeroNodosEta(i))==-1);end; 
		aux2 = sum(geoSupInf(yNumeroNodosEta(i),1:xNumeroNodosEta(i))==1);
		vnor(yNumeroNodosEta(i),xNumeroNodosEta(i)) = i + binf + aux1;
		vsur(yNumeroNodosEta(i),xNumeroNodosEta(i)) = i + bsup + aux2;

		if(i==1); ID(i,3:4) = [vnor(yNumeroNodosEta(i),xNumeroNodosEta(i)) + numeroNodosEta + numeroNodosU , vsur(yNumeroNodosEta(i),xNumeroNodosEta(i)) + numeroNodosEta + numeroNodosU]; 
		else ID(i,:) = [ID(i-1,2) + auxde(i), ID(i-1,2) + auxde(i) + 1, vnor(yNumeroNodosEta(i),xNumeroNodosEta(i)) + numeroNodosEta + numeroNodosU , vsur(yNumeroNodosEta(i),xNumeroNodosEta(i)) + numeroNodosEta + numeroNodosU];
		end;

		IDeta(i,:) = [geoIzqDer(yNumeroNodosEta(i),xNumeroNodosEta(i) + 1), geoIzqDer(yNumeroNodosEta(i)-1,xNumeroNodosEta(i))];
		IDetaC(i,:) = [geoIzqDer(yNumeroNodosEta(i),xNumeroNodosEta(i) - 1), geoIzqDer(yNumeroNodosEta(i),xNumeroNodosEta(i) + 1), 0, geoIzqDer(yNumeroNodosEta(i)+1,xNumeroNodosEta(i)), geoIzqDer(yNumeroNodosEta(i)-1,xNumeroNodosEta(i)), 0];

		IDetaCup(i,:) = [geoIzqDer(yNumeroNodosEta(i)-1,xNumeroNodosEta(i) - 1), geoIzqDer(yNumeroNodosEta(i)-1,xNumeroNodosEta(i)), geoIzqDer(yNumeroNodosEta(i)-1,xNumeroNodosEta(i)+1)];
		IDetaCdo(i,:) = [geoIzqDer(yNumeroNodosEta(i)+1,xNumeroNodosEta(i) - 1), geoIzqDer(yNumeroNodosEta(i)+1,xNumeroNodosEta(i)), geoIzqDer(yNumeroNodosEta(i)+1,xNumeroNodosEta(i)+1)];

		if(IDetaC(i,2) ~= 0)  IDetaC(i,3) = geoIzqDer(yNumeroNodosEta(i),xNumeroNodosEta(i) + 2); end;
		if(IDetaC(i,5) ~= 0)  IDetaC(i,6) = geoIzqDer(yNumeroNodosEta(i)-2,xNumeroNodosEta(i)); end;
    
		coordenadasU = [coordenadasU;[coordenadasEta(i,1)-0.5*deltaX,coordenadasEta(i,2)]];
		f = find(i == numeroBordesDerecho);
		if(~isempty(f)); coordenadasU = [coordenadasU; [coordenadasEta(i,1)+0.5*deltaX,coordenadasEta(i,2)]];end;
		coordenadasV(vnor(yNumeroNodosEta(i),xNumeroNodosEta(i)),:) = [coordenadasEta(i,1), coordenadasEta(i,2) + 0.5*deltaX];
		if(coordenadasV(vsur(yNumeroNodosEta(i),xNumeroNodosEta(i)),:) == [0 0]); coordenadasV(vsur(yNumeroNodosEta(i),xNumeroNodosEta(i)),:) = [coordenadasEta(i,1), coordenadasEta(i,2) - 0.5*deltaX];end;
	end

	IDwe = ID(:,1:2) - numeroNodosEta;
	IDns = ID(:,3:4) - numeroNodosEta - numeroNodosU;

	malla.numeroNodosEta = numeroNodosEta;
	malla.numeroNodosU = numeroNodosU;
	malla.numeroNodosV = numeroNodosV;
	malla.coordenadasEta = coordenadasEta;
	malla.coordenadasU = coordenadasU;
	malla.coordenadasV = coordenadasV;
	malla.ID = ID;
	malla.IDC = IDetaC;
	malla.IDeta = IDeta;
	malla.IDwe = IDwe;
	malla.IDns = IDns;
	malla.numeroBordesIzquierdo = numeroBordesIzquierdo;
	malla.numeroBordesDerecho = numeroBordesDerecho;
	malla.numeroBordesSuperior = numeroBordesSuperior;
	malla.numeroBordesInferior = numeroBordesInferior;



