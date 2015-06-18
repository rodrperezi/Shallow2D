classdef Staggered < Malla

	% STAGGERED es el objeto que genera la malla staggered

	properties 

		numeroNodosEta
		numeroNodosU
		numeroNodosV
		coordenadasEta
		coordenadasU
		coordenadasV
		matrizID
		matrizIDeta
		matrizIDwe
		matrizIDns
		numeroBordesIzquierdo
		numeroBordesDerecho
		numeroBordesSuperior
		numeroBordesInferior
		matrizIndicesEta
		coordenadasEta2DX
		coordenadasEta2DY
		deltaX 
		deltaY


	end

	methods

		function thisMalla = Staggered(thisMalla, geometria, deltaX, deltaY)
			% La malla se construye trabajando con los nodos Eta.
			% Los nodos de velocidad se construyen en función de los 
			% nodos Eta que queden contenidos en el borde. Se asume como 
			% convención que la enumeración de los nodos Eta comienza desde 
			% el extremo superior izquierdo.
			% A modo de ejemplo, explico la construcción de una malla
			% para una figura irregular arbitraria contenida en el archivo 
			% TestMalla.m
			% 
			% 
			borde = geometria.Borde;
			extremosX = [min(borde.coordenadasXY(:,1)), max(borde.coordenadasXY(:,1))];
			extremosY = [min(borde.coordenadasXY(:,2)), max(borde.coordenadasXY(:,2))];

			% [deltaX, deltaY] = getDeltaX(geometria);
			% 
			% Los nodos Eta deben quedar alejados del borde, para que los nodos de 
			% de velocidad queden justo en el borde. Por eso agrando el dominion en 0.5 deltaX
			% de esa forma me aseguro que todo el borde está dentro del dominio
			% y que los nodos Eta que queden dentro del borde, queden alejados
			% del borde (hacia el interior) una distancia de 0.5 dx. El vector
			% del dominioEtaY está invertido solo por un tema de visualización.
			dominioEtaX = extremosX(1)-0.5*deltaX:deltaX:extremosX(2)+0.5*deltaX;
			dominioEtaY = extremosY(2)+0.5*deltaY:-deltaY:extremosY(1)-0.5*deltaY; 
			% keyboard
			% >> dominioEtaX
			%
			% dominioEtaX =
			% 
			%   -380  -320  -260  -200  -140   -80   -20    40   100   160   220   280
			% >> dominioEtaY
			% 
			% dominioEtaY =
			% 
			%    250   190   130    70    10   -50  -110
			% 
			% keyboard 
			% Busco que puntos de Eta están contenidos en el borde					
			matrizIndicesEta = puntosDentroBorde(borde, dominioEtaX, dominioEtaY);
			% 
			% 
			% La función puntosDentroBorde hace lo siguiente:
			% 
			% function matrizIndices = puntosDentroBorde(borde, espacioX, espacioY)
			% 	coordenadasXY = borde.coordenadasXY;
			% 	[meshX meshY] = meshgrid(espacioX, espacioY); % Construyo meshgrid de dominio
			%  	matrizIndices = inpolygon(meshX, meshY, coordenadasXY(:,1), coordenadasXY(:,2)); 
			% 	keyboard
			% end % function puntosDentroBorde			
			% 
			% Estas son las matrices con las que trabaja la función:
			% 
			% >> meshX 
			%
			% meshX =
			% 
			%   -380  -320  -260  -200  -140   -80   -20    40   100   160   220   280
			%   -380  -320  -260  -200  -140   -80   -20    40   100   160   220   280
			%   -380  -320  -260  -200  -140   -80   -20    40   100   160   220   280
			%   -380  -320  -260  -200  -140   -80   -20    40   100   160   220   280
			%   -380  -320  -260  -200  -140   -80   -20    40   100   160   220   280
			%   -380  -320  -260  -200  -140   -80   -20    40   100   160   220   280
			%   -380  -320  -260  -200  -140   -80   -20    40   100   160   220   280
			% 
			% >> meshY
			% 
			% meshY =
			% 
			%    250   250   250   250   250   250   250   250   250   250   250   250
			%    190   190   190   190   190   190   190   190   190   190   190   190
			%    130   130   130   130   130   130   130   130   130   130   130   130
			%     70    70    70    70    70    70    70    70    70    70    70    70
			%     10    10    10    10    10    10    10    10    10    10    10    10
			%    -50   -50   -50   -50   -50   -50   -50   -50   -50   -50   -50   -50
			%   -110  -110  -110  -110  -110  -110  -110  -110  -110  -110  -110  -110
			% 
			% >> matrizIndices
			% 
			% matrizIndices =
			% 
			%      0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     1     1     0     0     0     0
			%      0     0     0     1     0     1     1     1     1     1     0     0
			%      0     1     1     1     1     1     1     1     1     1     1     0
			%      0     0     0     1     1     1     1     1     1     1     0     0
			%      0     0     1     1     0     0     1     1     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0
			% 
			% La función puntosDentroBorde asigna matrizIndices (variable interior)
			% a matrizIndicesEta (variable exterior)
			% 
			% Ahora pretendo conocer las posiciones en que los nodos 
			% están dentro del borde.
			% 
			[etaDentroBordeX, etaDentroBordeY] = find(matrizIndicesEta' == 1); 
			% keyboard
			% 			
			% La notación de numeración de nodos adoptada es que el primer nodo 
			% es aquel que está en el borde superior izquierdo y recorriendo
			% la fila, el nodo aumenta de numeración. Por eso se calcula
			% [etaDentroBordeX, etaDentroBordeY] = find(matrizIndicesEta' == 1); 
			% (con el transpuesto) porque entrega: (muestro los primeros 10 datos)
			% 
			% >> [etaDentroBordeX(1:10), etaDentroBordeY(1:10)]
			% 
			% ans =
			% 
			%      7     2
			%      8     2
			%      4     3
			%      6     3
			%      7     3
			%      8     3
			%      9     3
			%     10     3
			%      2     4
			%      3     4
			% 
			% La función [I, J] = find() entrega en el vector I las posiciones
			% correspondientes a las filas y en J entrega las columnas. 
			% Si es que no uso el transpuesto se obtiene: 
			% [etaDentroBordeX, etaDentroBordeY] = find(matrizIndicesEta == 1); 
			% 
			% 
			% >> [etaDentroBordeX(1:10), etaDentroBordeY(1:10)] 
			% 
			% ans =
			% 
			%      4     2
			%      4     3
			%      6     3
			%      3     4
			%      4     4
			%      5     4
			%      6     4
			%      4     5
			%      5     5
			%      3     6
			% 
			% 
			% 
			% Es decir, el recorrido de la matriz no es la convención de recorrido 
			% adoptada. En el caso que se hace el cálculo con el transpuesto de la matriz
			% de índices sí corresponde con la convención. 
			% No es algo vital de hacer, pero es sólo por organización que puede 
			% tener mayor utilidad en el caso de figuras no simétricas.			
			% 
			% Cálculo de las coordenadasEta
			% 
			% Usando los resultados obtenidos de calcular la posición de los nodos Eta 
			% con la matriz de índices transpuesta, las coordenadasEta son:
			% 
			coordenadasEta = [dominioEtaX(etaDentroBordeX)', dominioEtaY(etaDentroBordeY)']; 
			numeroNodosEta = length(coordenadasEta(:,1)); 
			% keyboard
			% 
			% >> coordenadasEta(1:10,:)
			% 
			% ans =
			% 
			%    -20   190
			%     40   190
			%   -200   130
			%    -80   130
			%    -20   130
			%     40   130
			%    100   130
			%    160   130
			%   -320    70
			%   -260    70
			%
			% 
			% Como se puede ver, el primer valor de las coordenadas corresponde 
			% al nodo superior izquierdo.
			% 
			%  
			% Esta seccion es para reconocer e identificar los nodos que son borde
			% 
			% Agrego ceros a la matrizIndicesEta por todos sus bordes en lo que 
			% llamo la matriz geo. Es una matriz de referencia de la geometria
			% que me permite encontrar con facilidad los bordes de la geometria 
			% la función usando diff(). La función diff() aplicada a una matriz
			% hace la resta de la fila N menos la fila N-1, es decir, 
			% la matriz pierde un valor en la dimensión vertical. (La primera fila
			% se reemplaza por la resta entre la segunda y la primera)
			%
			[m n] = size(matrizIndicesEta);
			geo = sparse([zeros(m+2,1),[zeros(1,n); matrizIndicesEta + 0;zeros(1,n)],zeros(m+2,1)]); 
			geoSupInf = diff(geo);   % Bordes superiores e inferiores. Bordes superiores tienen valor 1 e inferiores -1
			geoIzqDer = diff(geo')'; % Bordes Izquierdos y derechos. Bordes izquierdos tienen valor 1 y derechos -1
			% keyboard 
			% 
			% Muestro lo que es cada matriz anterior:			
			% 
			% >> full(geoSupInf)
			% 
			% ans =
			%			
			%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     0     1     1     0     0     0     0     0
			%      0     0     0     0     1     0     1     1     1     1     1     0     0     0
			%      0     0     1     1     1     1     1     1     1     1     1     1     0     0
			%      0     0     0     0     1     1     1     1     1     1     1     0     0     0
			%      0     0     0     1     1     0     0     1     1     0     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
			% 
			% >> full(geoSupInf)
			% 
			% ans =
			% 
			%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     0     1     1     0     0     0     0     0
			%      0     0     0     0     1     0     1     0     0     1     1     0     0     0
			%      0     0     1     1     0     1     0     0     0     0     0     1     0     0
			%      0     0    -1    -1     0     0     0     0     0     0     0    -1     0     0
			%      0     0     0     1     0    -1    -1     0     0    -1    -1     0     0     0
			%      0     0     0    -1    -1     0     0    -1    -1     0     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
			% 
			% >> full(geoIzqDer)
			% 
			% ans =
			%
			%      0     0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     1     0    -1     0     0     0     0
			%      0     0     0     1    -1     1     0     0     0     0    -1     0     0
			%      0     1     0     0     0     0     0     0     0     0     0    -1     0
			%      0     0     0     1     0     0     0     0     0     0    -1     0     0
			%      0     0     1     0    -1     0     1     0    -1     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0     0
			% 
			% En resumen, la matriz geoSupInf tiene en su primera fila, la
			% cantidad de bordes superiores (1's) que tiene la geometría en su 
			% parte superior (segunda fila de la matriz geo). 
			% La matriz geoIzqDer tiene en su primera columna, la cantidad de bordes
			% izquierdos (1's) que tiene la geometría en su borde izquierdo.
			% (segunda columna matriz geo). Puede darse el caso en que
			% un nodo sea tanto borde en el eje SupInf y en el eje IzqDer.
			% 
			% Posiciones (numero) x e y de nodos \eta en la matriz geo
			% 
			[xNumeroNodosEta yNumeroNodosEta] = find(geo' == 1); 
			[mFilas nCol] = size(geo');
			geoEnume = sparse(mFilas, nCol);
			coordenadasEta2DX = NaN(mFilas, nCol);
			coordenadasEta2DY = coordenadasEta2DX;
			% puntosDentro = geoEnume';
			% 		
			% Enumero nodos \eta. El extremo superior izquierdo es el primero
			% y el extremo inferior derecho es el último. Nodos eta crecen de izquierda a derecha. 
			% Verificar con imagesc(geoEnume). Las transposiciones en este caso 
			% están argumentadas bajo el mismo concepto de conservar 
			% la notación de enumeración
			% 
			for iEnum = 1:numeroNodosEta 
				geoEnume(xNumeroNodosEta(iEnum),yNumeroNodosEta(iEnum)) = iEnum;
				coordenadasEta2DX(xNumeroNodosEta(iEnum),yNumeroNodosEta(iEnum)) = coordenadasEta(iEnum,1);
				coordenadasEta2DY(xNumeroNodosEta(iEnum),yNumeroNodosEta(iEnum)) = coordenadasEta(iEnum,2);
			end
			geoEnume = geoEnume';
			coordenadasEta2DX = coordenadasEta2DX';
			coordenadasEta2DY = coordenadasEta2DY';
			% graficaNumerosMatriz(geoEnume)
			% keyboard
			% >> full(geoEnume)
			% 
			% ans =
			% 
			%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     0     1     2     0     0     0     0     0
			%      0     0     0     0     3     0     4     5     6     7     8     0     0     0
			%      0     0     9    10    11    12    13    14    15    16    17    18     0     0
			%      0     0     0     0    19    20    21    22    23    24    25     0     0     0
			%      0     0     0    26    27     0     0    28    29     0     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
			%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
			% Identifico coordenadas de los nodos que son borde en las matrices	
			% que contienen los bordes
			% 
			[bordeDerechoX bordeDerechoY] = find(geoIzqDer' == -1); %Bordes Derechos 
			[bordeInferiorX bordeInferiorY] = find(geoSupInf' == -1); %Bordes Inferiores
			[bordeIzquierdoX bordeIzquierdoY] = find(geoIzqDer' == 1); %Bordes Izquierdos 
			[bordeSuperiorX bordeSuperiorY] = find(geoSupInf' == 1); %Bordes Superiores
			% keyboard
			% Calculo cuantos nodos son borde derecho, superior, izquierdo, inferior.
			numeroBordesDerecho = zeros(length(bordeDerechoX),1);
			numeroBordesSuperior = zeros(length(bordeSuperiorX),1);
			numeroBordesIzquierdo = zeros(length(bordeIzquierdoX),1);
			numeroBordesInferior = zeros(length(bordeInferiorX),1);
		
			% Reconozco (identifico) bordes según su número identificador contenido en geoEnume. 
			% Accedo a la matriz geoEnume con los indices 'cambiados' de posicion. Es decir, 
			% el indice x está en la posición y y viceversa. Esto es para evitar 
			% más transposiciones. El uno que aparece sumando/restando en algunos 
			% de los índices, es para acomodar el dato obtenido 
			% de las matrices geoSupInf y geoIzqDer con la matriz geoEnum, 
			% que tiene una dimensión más producto de que no ha sido sometida 
			% a la función diff().
			% 
			for iBorde = 1:length(numeroBordesIzquierdo) 
				numeroBordesIzquierdo(iBorde) = geoEnume(bordeIzquierdoY(iBorde), bordeIzquierdoX(iBorde)+1);
			end % La posición de los bordes izquierdos en geoEnume está desplazada una unidad con respecto a 
			    % geoIzqDer	
			numeroBordesIzquierdo = sort(numeroBordesIzquierdo);
		
			for iBorde = 1:length(numeroBordesInferior) 
				numeroBordesInferior(iBorde) = geoEnume(bordeInferiorY(iBorde), bordeInferiorX(iBorde));
			end % La posición de los bordes inferiores, es la misma en geoEnume que en geoSupInf
			numeroBordesInferior = sort(numeroBordesInferior);
		
			for iBorde = 1:length(numeroBordesDerecho) 
				numeroBordesDerecho(iBorde) = geoEnume(bordeDerechoY(iBorde),bordeDerechoX(iBorde));
			end % La posición de los bordes derechos, es la misma en geoEnume que en geoIzqDer
			numeroBordesDerecho = sort(numeroBordesDerecho);
		
			for iBorde = 1:length(numeroBordesSuperior) 
				numeroBordesSuperior(iBorde) = geoEnume(bordeSuperiorY(iBorde)+1,bordeSuperiorX(iBorde));
			end % La posición de los bordes superiores en geoEnume está desplazada en una unidad con respecto 
			    % a geoSupInf
			numeroBordesSuperior = sort(numeroBordesSuperior);
			% keyboard
			% El 1 que aparece en los for anteriores es para adecuar la informacion guardada en borde(..) 
			% al tamaño de la matriz geoEnume. Esto porque como de puede ver más arriba, el calculo 
			% de las posiciones de los bordes se hace con respecto a matrices de otro tamaño (Ej geoInfSup)
			% 
			% Independiente de lo anterior, se puede ver que el calculo es correcto al comparar
			% los números de nodo que son borde con su enumeracion en geoEnume. Muestro los resultados
			% 
			% 
			% >> [numeroBordesIzquierdo, numeroBordesDerecho]
			% 
			% ans =
			% 
			%      1     2	
			%      3     3
			%      4     8
			%      9    18
			%     19    25
			%     26    27
			%     28    29
			% 
			% >> [numeroBordesInferior, numeroBordesSuperior]
			% 
			% ans =
			% 
			%      9     1
			%     10     2
			%     18     3
			%     20     4
			%     21     7
			%     24     8
			%     25     9
			%     26    10
			%     27    12
			%     28    18
			%     29    26
			% 
			% Como los nodos de velocidad están por fuera de los nodos
			% eta, se tiene que la cantidad de nodos de velocidad
			% en una fila, es la cantidad de nodos eta
			% mas un nodo extra por cada nodo que sea borde derecho (o izquierdo)
			% Aplica lo mismo para la dirección SupInf.			
			numeroNodosU = numeroNodosEta + length(bordeDerechoX);
			numeroNodosV = numeroNodosEta + length(bordeSuperiorX);
			coordenadasU = zeros(numeroNodosU,2);
			coordenadasV = zeros(numeroNodosV,2);
			%
			% Ahora opero de manera similar a la anterior, pero para 
			% los nodos de velocidad. La idea es construir una matriz
			% que me permita generar un vector de identificación.	
			% La matriz se construye a partir de geoEnum.
			% La lógica de construcción de la matriz de identificación	
			% se explica a continuación.
			% 
			% Tomo la matriz geoEnume y agrego filas y columnas
			% vacías entre los nodos enumerados utilizando las funciones 
			% intercalaFilasNulas e intercalaColumnasNulas. De esta manera
			% creo el espacio físico para albergar los nodos de velocidad.
			% 
			% geoEnume = Staggered.intercalaFilasNulas(geoEnume);
			% geoEnume = Staggered.intercalaColumnasNulas(geoEnume);
			geoEnume = intercalaFilasNulas(thisMalla, geoEnume);
			geoEnume = intercalaColumnasNulas(thisMalla, geoEnume);
			% graficaNumerosMatriz(geoEnume)
			% keyboard
			% 
			% La matriz geoEnume la muestro a continuación pero no en su forma full()
			% pues es muy grande. Se puede visualizar con la función 
			% graficaNumerosMatriz(geoEnume) Se aprecia que aparecen 
			% varias filas y columnas con ceros, puesto que geoEnume
			% tiene previamente filas y columnas con ceros
			% a las cuales también se les intercalan filas/columnas vacías.
			% Esto no es de importancia en el cálculo puesto que geoEnume es sparse.
			% 
			% 
			% >> geoEnume =
			% 
			%    (8,4)        9
			%    (8,6)       10
			%   (12,6)       26
			%    (6,8)        3
			%    (8,8)       11
			%   (10,8)       19
			%   (12,8)       27
			%    (8,10)      12
			%   (10,10)      20
			%    (6,12)       4
			%    (8,12)      13
			%   (10,12)      21
			%    (4,14)       1
			%    (6,14)       5
			%    (8,14)      14
			%   (10,14)      22
			%   (12,14)      28
			%    (4,16)       2
			%    (6,16)       6
			%    (8,16)      15
			%   (10,16)      23
			%   (12,16)      29
			%    (6,18)       7
			%    (8,18)      16
			%   (10,18)      24
			%    (6,20)       8
			%    (8,20)      17
			%   (10,20)      25
			%    (8,22)      18
			% 
			% Ahora busco la nueva ubicación de los nodos Eta en la matriz geoEnume
			% Al igual que antes, busco la ubicación en geoEnume transpuesta para 
			% conservar la convención de enumeración.	
			[xNuevosNodosEta yNuevosNodosEta] = find(geoEnume' ~=0);
			% 
			% A la izquierda y derecha de los nodos Eta, agrego el valor -1 a geoEnume
			% el cual servirá para identificar a los nodos U. Similarmente, 
			% arriba y abajo de los nodos Eta agrego el valor -2 para identificar 
			% a los nodos V.
			% 
			for iNodo = 1:length(xNuevosNodosEta)
				geoEnume(yNuevosNodosEta(iNodo), xNuevosNodosEta(iNodo)+1) = -1;
				geoEnume(yNuevosNodosEta(iNodo), xNuevosNodosEta(iNodo)-1) = -1;
				geoEnume(yNuevosNodosEta(iNodo)+1, xNuevosNodosEta(iNodo)) = -2;
				geoEnume(yNuevosNodosEta(iNodo)-1, xNuevosNodosEta(iNodo)) = -2;
			end
			% 
			% Finalmente enumero tanto los nodos U como los nodos V
			% 
			[xNodosU yNodosU] = find(geoEnume' == -1);
			[xNodosV yNodosV] = find(geoEnume' == -2);
	
			for iEnum = 1:length(xNodosU) 
				geoEnume(yNodosU(iEnum), xNodosU(iEnum)) = iEnum + numeroNodosEta;    
			end

			for iEnum = 1:length(xNodosV) 
				geoEnume(yNodosV(iEnum), xNodosV(iEnum)) = iEnum + numeroNodosEta + numeroNodosU;    
			end

			% graficaNumerosMatriz(geoEnume);	
			% keyboard
			% 
			% Con esto ya estamos listos para construir el vector ID.
			% Lo único que resta por hacerse es recorrer la matriz
			% geoEnume con los vectores xNuevosNodosEta e yNuevosNodosEta
			% Se recorre la matriz para asignar el vector ID, y a la vez
			% asignar las coordenadas de los nodos de velocidad.
			% 
			ID = zeros(numeroNodosEta,4); % Nodos de velocidad w,e,n,s
			IDeta = zeros(numeroNodosEta,2); % Nodos eta: E, N
			nEta = numeroNodosEta;
			nResV = nEta + numeroNodosU;
			% 
			for iID=1:numeroNodosEta
				% keyboard
				% Observación: Si me quiero mover al nodo norde (en la matriz), debo restar, para el sur sumar
				ID(iID, 1) = geoEnume(yNuevosNodosEta(iID), xNuevosNodosEta(iID)-1); % nodo w
				ID(iID, 2) = geoEnume(yNuevosNodosEta(iID), xNuevosNodosEta(iID)+1); % nodo e
				ID(iID, 3) = geoEnume(yNuevosNodosEta(iID)-1, xNuevosNodosEta(iID)); % nodo n
				ID(iID, 4) = geoEnume(yNuevosNodosEta(iID)+1, xNuevosNodosEta(iID)); % nodo s

				IDeta(iID, 1) = geoEnume(yNuevosNodosEta(iID), xNuevosNodosEta(iID)+2); % nodo E
				IDeta(iID, 2) = geoEnume(yNuevosNodosEta(iID)-2, xNuevosNodosEta(iID)); % nodo N
		
				% Nodos eta: W, E, S, N
				IDetaC(iID, 1) = geoEnume(yNuevosNodosEta(iID), xNuevosNodosEta(iID)-2); % nodo W
				IDetaC(iID, 2) = geoEnume(yNuevosNodosEta(iID), xNuevosNodosEta(iID)+2); % nodo E
				IDetaC(iID, 3) = geoEnume(yNuevosNodosEta(iID)+2, xNuevosNodosEta(iID)); % nodo S
				IDetaC(iID, 4) = geoEnume(yNuevosNodosEta(iID)-2, xNuevosNodosEta(iID)); % nodo N
	
				coordenadasU(ID(iID,1)-nEta,1) = coordenadasEta(iID,1) - 0.5*deltaX; %coordenadaX de nodo w
				coordenadasU(ID(iID,1)-nEta,2) = coordenadasEta(iID,2); %coordenadaY de nodo w
				coordenadasU(ID(iID,2)-nEta,1) = coordenadasEta(iID,1) + 0.5*deltaX; %coordenadaX de nodo e
				coordenadasU(ID(iID,2)-nEta,2) = coordenadasEta(iID,2); %coordenadaY de nodo e
				coordenadasV(ID(iID,3)-nResV,1) = coordenadasEta(iID,1); %coordenadaX de nodo n
				coordenadasV(ID(iID,3)-nResV,2) = coordenadasEta(iID,2) + 0.5*deltaY; %coordenadaY de nodo n
				coordenadasV(ID(iID,4)-nResV,1) = coordenadasEta(iID,1); %coordenadaX de nodo s
				coordenadasV(ID(iID,4)-nResV,2) = coordenadasEta(iID,2) - 0.5*deltaY; %coordenadaY de nodo s
			end
	
			% graficaNumerosMatriz(geoEnume)
			% keyboard

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
			thisMalla.matrizIDetaC = IDetaC;
			thisMalla.matrizIDwe = IDwe;
			thisMalla.matrizIDns = IDns;
			thisMalla.numeroBordesIzquierdo = numeroBordesIzquierdo;
			thisMalla.numeroBordesDerecho = numeroBordesDerecho;
			thisMalla.numeroBordesSuperior = numeroBordesSuperior;
			thisMalla.numeroBordesInferior = numeroBordesInferior;
			thisMalla.matrizIndicesEta = matrizIndicesEta;
			thisMalla.coordenadasEta2DX = coordenadasEta2DX;
			thisMalla.coordenadasEta2DY = coordenadasEta2DY;
			thisMalla.deltaX = deltaX;
			thisMalla.deltaY = deltaY;
			thisMalla.TipoDeMalla = 'Staggered';
		end % function construyeMallaStaggered

		function matrizIntercalada = intercalaColumnasNulas(thisMalla, matriz)
	
			[xNodos yNodos] = find(matriz' ~= 0);
			[mFilas nCol] = size(matriz);
			columnaIntercalar = zeros(mFilas,1);

			if(min(xNodos) == 1)
				matrizIntercalada = columnaIntercalar;
			else 
				matrizIntercalada = [matriz(:,1:min(xNodos)-1), columnaIntercalar];
			end

			for iColumnas = min(xNodos):nCol
				matrizIntercalada = [matrizIntercalada, matriz(:, iColumnas), columnaIntercalar];
			end
		end % function intercalaColumnasNulas

		function matrizIntercalada = intercalaFilasNulas(thisMalla, matriz)
	
			[xNodos yNodos] = find(matriz' ~= 0);
			[mFilas nCol] = size(matriz);
			filaIntercalar = zeros(1,nCol);

			if(min(yNodos) == 1)
				matrizIntercalada = filaIntercalar;
			else 
				matrizIntercalada = [matriz(1:min(yNodos)-1,:); filaIntercalar];
			end

			for iFilas = min(yNodos):mFilas
				matrizIntercalada = [matrizIntercalada; matriz(iFilas,:); filaIntercalar];
			end
		end % function intercalaFilasNulas
	end %methods
end % classdef


