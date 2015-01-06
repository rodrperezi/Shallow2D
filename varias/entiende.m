clear all 
close all 

R = 1;
geo.Borde = genera_borde_circular(R);

deltax = 0.1*R;
deltay = deltax;

% [Ineta aid bid] = puntos_dentro_borde(geo.Borde, deltax, deltay);
Inside_eta = puntos_dentro_borde(geo.Borde, deltax, deltay);

xeta = min(geo.Borde(:,1)) + deltax/2: deltax : max(geo.Borde(:,1)) - deltax/2;
yeta = max(geo.Borde(:,2)) - deltay/2: -deltay: min(geo.Borde(:,2)) + deltay/2;

[x_inside y_inside] = find(Inside_eta'==1); % Identifico coordenadas matriciales de puntos dentro del borde
coordeta = [xeta(x_inside)', yeta(y_inside)']; % Coordenadas espaciales de nodos \eta.
Neta = length(coordeta(:,1)); 

[m n] = size(Inside_eta);
geo = sparse([zeros(m+2,1),[zeros(1,n);Inside_eta + 0;zeros(1,n)],zeros(m+2,1)]); % Agrego filas de ceros por arriba y abajo y columnas con ceros por izquierda y derecha.
geosi = diff(geo);   % Bordes superiores e inferiores. Bordes superiores tienen valor 1 e inferiores -1
geoid = diff(geo')'; % Bordes Izquierdos y derechos. Bordes izquierdos tienen valor 1 y derechos -1

%% Identifico coordenadas de los nodos que son borde
	[BDex BDey] = find(geoid == -1); %Bordes Derechos 
	[BInx BIny] = find(geosi == -1); %Bordes Inferiores
	[BIzx BIzy] = find(geoid == 1); %Bordes Izquierdos 
	[BSux BSuy] = find(geosi == 1); %Bordes Superiores

	[xneta yneta] = find(geo == 1); % Posiciones x e y de nodos \eta.
	geoID = sparse(zeros(size(geo)));

	% Enumero nodos \eta. El extremo superior izquierdo es el primero
	% y el extremo inferior derecho es el último.
	for ienum = 1:Neta 
		geoID(xneta(ienum),yneta(ienum)) = ienum;    
	end
	geoID = geoID';

	% Calculo cuandos nodos son borde derecho, superior, izquierdo, inferior.
	nBDe = zeros(length(BDex),1);
	nBSu = zeros(length(BSux),1);
	nBIz = zeros(length(BIzx),1);
	nBIn = zeros(length(BInx),1);

	% Reconozco bordes según su número identificador (geoID)
	for iborde = 1:length(nBIz) 
		nBIz(iborde) = geoID(BIzx(iborde),BIzy(iborde)+1);
	end
	nBIz = sort(nBIz);

	for iborde = 1:length(nBIn) 
		nBIn(iborde) = geoID(BInx(iborde),BIny(iborde));
	end
	nBIn = sort(nBIn);

	for iborde = 1:length(nBDe) 
		nBDe(iborde) = geoID(BDex(iborde),BDey(iborde));
	end
	nBDe = sort(nBDe);

	for iborde = 1:length(nBSu) 
		nBSu(iborde) = geoID(BSux(iborde)+1,BSuy(iborde));
	end
	nBSu = sort(nBSu);

	New = Neta + length(BDex);
	Nns = Neta + length(BSux);



