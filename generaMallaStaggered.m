function thisMalla = generaMallaStaggered(thisMalla, Geometria)
% Rutina que construye la malla staggered dado un borde y una geometria

% borde = getBorde(geometria);

borde = Geometria.Borde.coordenadasXY;
deltaX = Geometria.deltaX;
deltaY = Geometria.deltaY;

	%% Busco Puntos que están dentro del borde que delimita la superficie libre
	% Matriz de indice de nodos eta que estan dentro del borde
	nodosEtaDentroBorde = puntosDentroBorde(borde, deltaX, deltaY);
	% Identifico coordenadas matriciales de puntos dentro del borde
	[xDentroBorde yDentroBorde] = find(nodosEtaDentroBorde'==1); 

 	xEta = min(borde(:,1)) + deltaX/2: deltaX : max(borde(:,1)) - deltaX/2;
 	yEta = max(borde(:,2)) - deltaY/2: -deltaY: min(borde(:,2)) + deltaY/2;

	coordenadasEta = [xEta(xDentroBorde)', yEta(yDentroBorde)']; % Coordenadas espaciales de nodos eta.
	numeroNodosEta = length(coordenadasEta(:,1)); 

	[m n] = size(nodosEtaDentroBorde);
	% Agrego filas de ceros por arriba y abajo y columnas con ceros por izquierda y derecha.
	geo = sparse([zeros(m+2,1),[zeros(1,n);nodosEtaDentroBorde + 0;zeros(1,n)],zeros(m+2,1)]); 
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

	% Calculo cuantos nodos son borde derecho, superior, izquierdo, inferior.
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

	% El siguiente ID es para reconocer que nodos \eta rodean a un
	% al nodo central i. 

	IDeta = zeros(numeroNodosEta,2); % Nodos eta: E, N

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

	% Construcción de matriz ID REVISAR
	for i = 1:numeroNodosEta

		if(yNumeroNodosEta(i)>yaux) 
			if(yNumeroNodosEta(i) > 2) aux1 = sum(geoSupInf(yNumeroNodosEta(i)-2,:)==-1);end;
			aux2 = sum(geoSupInf(yNumeroNodosEta(i)-1,:)==1);
			binf = binf + aux1;
			bsup = bsup + aux2;
			yaux = yNumeroNodosEta(i);
		end;

		if(yNumeroNodosEta(i) > 2)
			aux1 = sum(geoSupInf(yNumeroNodosEta(i)-1,1:xNumeroNodosEta(i))==-1);
		end
		
		aux2 = sum(geoSupInf(yNumeroNodosEta(i),1:xNumeroNodosEta(i))==1);
		vnor(yNumeroNodosEta(i),xNumeroNodosEta(i)) = i + binf + aux1;
		vsur(yNumeroNodosEta(i),xNumeroNodosEta(i)) = i + bsup + aux2;

		if(i==1)
			ID(i,3:4) = [vnor(yNumeroNodosEta(i),xNumeroNodosEta(i)) + numeroNodosEta + numeroNodosU , vsur(yNumeroNodosEta(i),xNumeroNodosEta(i)) + numeroNodosEta + numeroNodosU]; 
		else
			ID(i,:) = [ID(i-1,2) + auxde(i), ID(i-1,2) + auxde(i) + 1, vnor(yNumeroNodosEta(i),xNumeroNodosEta(i)) + numeroNodosEta + numeroNodosU , vsur(yNumeroNodosEta(i),xNumeroNodosEta(i)) + numeroNodosEta + numeroNodosU];
		end;

		IDeta(i,:) = [geoIzqDer(yNumeroNodosEta(i),xNumeroNodosEta(i) + 1), geoIzqDer(yNumeroNodosEta(i)-1,xNumeroNodosEta(i))];
		coordenadasU = [coordenadasU;[coordenadasEta(i,1)-0.5*deltaX,coordenadasEta(i,2)]];
		f = find(i == numeroBordesDerecho);

		if(~isempty(f))
			coordenadasU = [coordenadasU; [coordenadasEta(i,1)+0.5*deltaX,coordenadasEta(i,2)]];
		end
		
		coordenadasV(vnor(yNumeroNodosEta(i),xNumeroNodosEta(i)),:) = [coordenadasEta(i,1), coordenadasEta(i,2) + 0.5*deltaX];

		if(coordenadasV(vsur(yNumeroNodosEta(i),xNumeroNodosEta(i)),:) == [0 0])
			coordenadasV(vsur(yNumeroNodosEta(i),xNumeroNodosEta(i)),:) = [coordenadasEta(i,1), coordenadasEta(i,2) - 0.5*deltaX];
		end
	end %for

	IDwe = ID(:,1:2) - numeroNodosEta;
	IDns = ID(:,3:4) - numeroNodosEta - numeroNodosU;

	thisMalla.numeroNodosEta = numeroNodosEta;
	thisMalla.numeroNodosU = numeroNodosU;
	thisMalla.numeroNodosV = numeroNodosV;
	thisMalla.coordenadasEta = coordenadasEta;
	thisMalla.coordenadasU = coordenadasU;
	thisMalla.coordenadasV = coordenadasV;
	thisMalla.matrizID = ID;
	thisMalla.matrizIDeta = IDeta;
	thisMalla.matrizIDwe = IDwe;
	thisMalla.matrizIDns = IDns;
	thisMalla.numeroBordesIzquierdo = numeroBordesIzquierdo;
	thisMalla.numeroBordesDerecho = numeroBordesDerecho;
	thisMalla.numeroBordesSuperior = numeroBordesSuperior;
	thisMalla.numeroBordesInferior = numeroBordesInferior;





