% Calculo de valores y vectores propios por paquetes
% Esta rutina está hecha para tratar de implementar 
% con relativa decencia el análisis modal. Esto significa
% en primera instancia, ser capaz de calcular de buena
% manera los valores y vectores propios. A lo que 
% me refieron con "buena manera" es que los valores
% y vectores cumplan las relaciones de ortogonalidad
% de los modos y que se satisfagan las relaciones entre 
% ellos. En particular, que para un problema de valores
% y vectores propios con disipación lineal, como 
% el expresado en Shimizu e Imberger (2008), los 
% modos con frecuencia de oscilación de distinto 
% signo (+r y -r) deben satisfacer que
% la estructura modal \tilde{\chi}(+r) sea igual al conjugado
% de la estructura modal con frecuencia angular negativa, 
% es decir, \tilde{\chi}(+r) = \tilde{\chi}(-r)*.
% Matlab cuenta con las funciones eig(A,B) y eigs(A,B)
% para calcular el problema de valores y vectores propios
% generalizado expresado como A*V = B*V*D, donde V es la 
% matriz de vectores propios y D es la matriz diagonal de 
% valores propios. Esto, expresado en término del problema 
% de Shimizu e Imberger (2008) es:
% 
%                  (K+C)\tilde{\chi} = (\omega + i\gamma)M\tilde{\chi}
% 
% donde:
% 	K es el operador lineal no disipativo de aguas someras
% 	C es la matriz de disipación lineal
% 	M es la matriz de peso
% 	\tilde{\chi} es la estructura modal del vector de estado \chi = (\eta, \vec{v})^T
% 	\eta es la deformación de la superficie libre del fluido
% 	\vec{v} = (u, v)^T es el vector de velocidad bidimensional
% 	\omega es la frecuencia de oscilación del modo
% 	\gamma es la tasa de disipación lineal
% 
% Como el medio fluido es continuo, la cantidad de modos de oscilación 
% que un cuerpo de fluido posee, depende de la discretización 
% numérica que se haga de él. Es decir, \deltaX y \deltaY determinan
% la cantidad de modos que posee un cuerpo de fluido. 
% Esto es porque cada nodo de la discretización, agrega un grado de libertad
% para que el medio oscile. Es decir, si se tiene una malla de discretización 
% de N elementos, entonces el medio discretizado tiene N modos de oscilación.
% En estricto rigor, en medios continuos, existen infinitos modos de oscilación, 
% pero en términos discretos, un punto del medio continuo que no tiene un 
% nodo que lo caracterice, no puede oscilar, puesto que no existe.
% Esto es válido independiente de la función conceptual que tenga el nodo
% y de como interactúen entre ellos. Por ejemplo, si de los N nodos anteriores, 
% N/4 son nodos de presión o deformación de la superficie libre, y el resto son 
% nodos de velocidad, entonces el problema de valores y vectores sigue teniendo
% N modos de oscilación y esto no implica que N/4 de esos modos sólo sean oscilaciones
% de la superficie libre. En un medio continuo, los nodos están ligados entre sí
% mediante ecuaciones que relacionan la información que estos almacenen. En
% este caso, las ecuaciones de conservación de masa y conservación de momentum
% son las que relacionan la información que tiene cada nodo.
% 
% Ahora, volviendo al problema original, es necesario entender como funcionan 
% las metodologías que posee Matlab para resolver el problema de encontrar los 
% valores y vectores propios del sistema de ecuaciones lineales descrito anteriormente.
% La función [V, D] = eig(K+C,M) calcula los valores y vectores propios y no tiene
% muchas opciones para explorar. Se puede modificar el algoritmo de cómputo 
% pero en términos prácticos no existe otra forma de aplicarla. Es decir, la
% función entrega los vectores (V) y los valores (D) aplicando un sólo
% cálculo continuo. Además la función exige que las matrices no sean de tipo
% sparse. En caso de que hayan sido definidas como tales, se debe utilizar
% la función full() para devolverlas al estado original, en tal caso, 
% el problema se debería resolver como [V, D] = eig(full(K+C), full(M))
% Por otro lado [V, D] = eigs(K+C, M) tiene algunas opciones para 
% explorar. En paticular, interesa realizar el cálculo utilizando
% la forma [V, D, FLAG] = eigs(K+C, M, K, SIGMA). FLAG es un índice
% que entrega 0 si es que los valores propios convergieron. En caso contrario
% no todos convergieron. K es un índice que permite especificar el tamaño
% del paquete de valores propios que se desea calcular (número natural).
% SIGMA es un parámetro que, puede tomar los valores 'LM', 'SM'. Estos 
% significan Largest o Smallest Magnitude respectivamente. Además
% en el caso de problemas complejos no simétricos (como corresponde al 
% sistema de ecuaciones en estudio) se pueden utilizar las opciones
% 'LR' o 'SR' y 'LI' o 'SI' que siginifican Largest o Smallest Real o Imaginary.
% Por último, en caso de que SIGMA sea un escalar real o complejo incluyendo 0, 
% entonces la función busca los K valores propios más cercanos a SIGMA.
% 
% El último antecedente a tener en cuenta y que no mencioné previamente
% es que el cálculo matemático de los valores y vectores propios tiene 
% una característica. Cuando se introducen pequeñas perturbaciones en la 
% matriz que se está resolviendo el problema, estas se traducen en 
% perturbaciones aumentadas en los valores propios. Es decir, 
% existe un factor mayor a cero que indica que cualquier modificación
% en el problema a resolver, por pequeña que sea, resultará 
% en un efecto sobre los valores propios que será bastante mayor
% a la modificación del problema original. Esta información es de 
% relevancia puesto que, por definición matemática del problema
% de aguas someras expuesto por Shimizu e Imberger (2008) la matriz
% K es compleja simétrica, o sea, Hermítica. Mientras que C es 
% una matriz compleja diagonal, o sea, anti Hermítica. He comprobado
% en el modelo numérico que existen ocasiones, en que la matriz K
% no es Hermítica pero por causa de pequeñas diferencias en ciertas
% entradas. Estas diferencias son del orden de 1e-10. 
% 
% Lo lógico sería eliminar estas pequeñas diferencias y realizar el 
% cálculo numérico con la función eig() para obtener toda la información
% en un sólo cómputo. Sin embargo, esta pequeña diferencia de precisión
% y el decimal al cual se ajuste el problema, es decir, 
% redefinir K = quant(K, PREC), para ajustar las entradas de K a la 
% precisión especificada por PREC, influyen fuertemente en el 
% resultado final. He notado también que la precisión a la cual 
% se ajusten las entradas de la matriz K, varían con la discretización
% espacial y por lo tanto con la geometría. Para eliminar
% la dependencia de la geometría, adimensionalizo la matriz K y 
% aplico un ajuste de precisión que esperaba terminara con el problema
% de dependencia de la geometría. Funciona más o menos puesto que 
% si bien la solución final es más estable, aún influye la 
% caracterización geométrica.
% 
% Es por ello, que una de las últimas opciones que resta para realizar
% el cómputo, es hacer que el computador sea menos exigido en términos
% de recursos al momento de calcular los valores y vectores propios. 
% Me da la impresión que de esta forma aumenta la precisión en el cálculo.
% La única forma de hacer esto y aún así resolver todos los valores propios
% sería resolver el problema por partes, es decir, calcular los valores
% y vectores propios por paquetes de un tamaño a determinar, pero que
% sea considerablemente más pequeño que la matriz completa. De esta forma, 
% aumentar la precisión en el cálculo, y eventualmente (por ver) cumplir
% con las propiedades matemáticas que deberían tener los modos de oscilación.
% 
% A modo de aclaración y para no dejar dudas, he corroborado innumerables 
% veces que la construcción numérica del problema es correcta, es decir, 
% Borde, Batimetría, Malla y Matrices son objetos del modelo que están 
% construidos correctamente. Por lo tanto, la única causa restante de que
% el cálculo de los valores y vectores propios sea problemático, es el 
% computador mismo y es lo que motiva este archivo.-
% 
% ¿Cómo debería llevar a cabo el cálculo por paquetes?
% 
% Alguna vez se habló con el profesor guía sobre el cálculo
% por paquetes y aquí explicaré más o menos lo conversado 
% más algunas ideas o formas que surjan de mi cerebro en función
% de los problemas que logro identificar. Me baso en la función
% [V, D] = eigs(K+C, M, K, SIGMA). Si ajustar o no la precisión 
% de la matriz K es algo que veré posteriormente. Los valores
% propios pueden ir de -\infty a +\infty dependiendo de la 
% discretización.
% 	
% Algoritmo:
% 
%	- Comenzar con SIGMA = 0 y calcular K valores propios
% 	- Calcularé primero aquellos que sean de \omega > 0
% 	- Elimino de la lista de primeros valores obtenidos
% 	  aquellos que tengan \omega < 0
% 	- Actualizo SIGMA = max(valores Propios Iteracion Previa)
% 	- Cálculo otro paquete
% 	- Si algún omega + igamma coincide con el del paquete anterior
% 	  entonces ambos paquetes se traslapan.
% 	- Elimino del segundo paquete calculado, aquellos valores traslapados
%	  y agrego los nuevos al vector que almacena el resultado acumulado
% 	- Me muevo nuevamente a SIGMA = max(valores Propios Iteracion Previa)
% 	- Repito proceso.
%	- En caso que los paquetes no se traslapen, entonces induzco el traslape
% 	  porque así me aseguro de no estoy dejando valores propios sin calcular
% 	  en el espacio entre paquetes.
% 	- Cuando termina el cálculo? Está por verse, pero me da la impresión
% 	  que debería ser cuando el max(valores Propios Iteracion Previa)
% 	  no cambie entre iteraciones, es decir, alcancé el supremo.
% 	  
%  	- A modo de comprobación y en una primera instancia, realizo el mismo 
% 	  cálculo, pero hacia menos infinito para corroborar los resultados
% 	- En caso de que la precisión de cálculo sea decente y se cumplan 
% 	  las relaciones matemáticas necesarias para los modos de +r y -r
% 	  entonces en la rutina definitiva, calcularé los modos de -r
% 	  en función de los de +r, reduciendo el tiempo de cálculo a la mitad
% 
%	Implementación
% 
	clear all 
	close all
% 
% 
% Construyo un problema tipo Kranenburg para experimentar
% 
% Inicializo Geometria, Cuerpo y Simulacion
%
% 
	R = 800;
	H = 0.15;
	centroMasa = [0, 0];
	geo = Geometria();
	geo.deltaX = 0.1*R;
	geo.deltaY = geo.deltaX;
	geo = construyeKranenburg(geo, R, H, centroMasa);
	cuerpo = Cuerpo(Cuerpo(), geo);
	sim = Simulacion(Simulacion(), cuerpo);
% 
% Construyo forzantes, los agrego al problema y construyo matrices
% 
	viento = vientoUniforme(Forzante(), 1e-3, pi/2);
	forz = Forzantes();
	forz = addForzante(forz, viento);
	sim.Forzantes = forz;
	sim = asignaMatrices(Matrices(), sim);

% 
% Recupero matrices desde la simulacion
% 

	matrices = sim.Matrices;
	K = matrices.K;
	C = matrices.C;
	M = matrices.M;
% 
% Calculo de valores propios utilizando metodología explicada en algoritmo
% 

		% Tamaño paquete
		kPaq = 6;

		% [VPaq, DPaq, Flag] = eigs(full(K+C), full(M), kPaq, 0);
		% No puedo comenzar en cero. Arroja un error, al parecer asociado
		% a que cero es un valor propio. Pruebo con un valor cercano a cero
		% y si funciona.

		[VPaq, DPaq, Flag] = eigs(K+C, M, kPaq, 1e-10); 
		DPaq = diag(DPaq);

		% No se si 0 + 0i es necesariamente un valor propio
		% pero si en el paquete inicial calculado aparecen
		% valores negativos, me basta con saber que pase por
		% cero. Si lo incluye o no, es parte de la definición 
		% del problema supongo.
		% No olvidarse de corroborar el parámetro Flag.

		% Elimino valores con omega < 0
		borrar = find(real(DPaq) < 0);
		DPaq(borrar) = [];
		VPaq(:, borrar) = [];

		% Si es que no paso por omega < 0, entonces debería iniciar el 
		% problema con un sigma aún más pequeño (PENSAR)

		% Me doy un SIGMA a partir del cálculo inicial 
		% para comenzar a iterar. No puedo pedir 
		% max(DPaq) puesto que esto calcula el valor absoluto.
		% En ese caso puedo tomar como máximo un valor 
		% con omega < 0 (En caso de que haya alguno)

		cual = max(real(DPaq));
		donde = find(real(DPaq) == cual);

		% Cálculo nuevo problema. Me doy cuenta de que
		% sigma NO puede ser un valor propio exacto. Tomo
		% parte real. También reclama. Usé el valor absoluto y no	
		% reclamó
		
		% sigma = real(DPaq(donde)); 
		% sigma?
		sigma = abs(DPaq(donde)); 

		[VNuevo, DNuevo, FlagNuevo] = eigs(K+C, M, kPaq, sigma);
		DNuevo = diag(DNuevo);

		% Busco algún valor propio en el nuevo paquete que 
		% que esté en el paquete anterior. De ser así, hay traslape.
		% Si no, cambio sigma.
	
		% Habrá algún \omega < 0? Creo que puede ser.
		% Efectivamente hay un valor con omega < 0
		% Esto debería pasar para los primeros casos, es decir, cuando aún 
		% estamos cercanos a cero.
		% Problema, que hacer con la precisión de cálculo?
		% Imprimo motivación de pregunta
		% 
		% >> DNuevo
		% 
		% DNuevo =
		% 
		%    1.0e-03 *
		% 
		%   -0.0000 + 0.0000i
		%    0.0000 + 0.4169i
		%    0.0000 + 0.5019i
		%    0.0000 + 0.4835i
		%    0.0000 + 0.4835i
		%    0.0000 + 0.4835i
		%
		% >> DPaq
		% 
		% DPaq =
		% 
		%    1.0e-03 *
		% 
		%    0.0000 + 0.0000i
		%    0.0000 + 0.5019i
		%    0.0000 + 0.4835i
		%    0.0000 + 0.4835i
		%    0.0000 + 0.4835i
		%
		% >> DNuevo(4:6) == DPaq(3:5)
		% 
		% ans =
		% 
		%      0
		%      0
		%      0
		% 
		% >> format long e
		% >> [DNuevo(4:6), DPaq(3:5)]
		% 
		% ans =
		% 
		%   Column 1
		% 
		%       7.589415207398531e-19 + 4.834740984339032e-04i
		%       1.355252715606881e-18 + 4.835080927185185e-04i
		%       4.336808689942018e-19 + 4.835080927185195e-04i
		% 
		%   Column 2
		% 
		%       1.846763435585890e-19 + 4.835080927185196e-04i
		%       1.447677224362610e-20 + 4.834740984339033e-04i
		%       3.972976399437866e-19 + 4.835080927185207e-04i
		% 
		% >> eps
		% 
		% ans =
		% 
		%      2.220446049250313e-16
		% 
		% A mi parecer, los valores 5 y 6 en DNuevo son iguales entre sí	
		% Los valores 3 y 5 en DPaq son iguales entre sí	
		% Son todos el mismo valor. El valor 4 en DNuevo es igual al 4 en DPaq
		% Las partes reales de todos los valores mostrados son menores 
		% que la precisión de cálculo eps, por lo tanto, todos deberían ser cero.
		% De la misma forma, las partes imaginarias de los valores que
		% mencioné que eran iguales, son distintas en el decimal -16, por lo que
		% creo que también deberían ser iguales. Cualquier cosa que tenga 
		% alguna diferencia en los decimales más pequeños que -15 debería
		% ser igual entre sí. Por seguridad, corto los valores en el decimal -14 	
		% o superior.
		% Analizo que sucede con los vectores propios 5 y 6 de DNuevo:
		% 
		% >> VNuevo(:,5:6)
		% 
		% ans =
		% 
		%       1.653281785831113e-05 + 3.309049420276026e-05i     -3.542859086633632e-05 + 4.365889042525531e-06i
		%       1.660664447832633e-05 - 3.805955020018880e-05i     -2.096227035780745e-05 - 2.930046245533355e-05i
		%       1.949407245581116e-05 + 2.726212369994904e-05i     -3.936309739011250e-05 - 4.061244412367969e-07i
		%       1.654302273470071e-05 + 2.771304215703335e-05i     -3.434325273157985e-05 + 1.818266168734617e-06i
		%       1.660569130401839e-05 - 3.268348538957295e-05i     -2.206335139879727e-05 - 2.675980068557002e-05i
		%       1.955672353466368e-05 - 3.311754736523791e-05i     -2.708662333926089e-05 - 2.897621524676918e-05i
		%      -1.955672353375273e-05 + 3.311754736576343e-05i      2.708662333927372e-05 + 2.897621524663429e-05i
		%      -1.660569130324433e-05 + 3.268348539001975e-05i      2.206335139880846e-05 + 2.675980068545374e-05i
		%      -1.654302273548272e-05 - 2.771304215748121e-05i      3.434325273156631e-05 - 1.818266168620137e-06i
		%      -1.949407245672858e-05 - 2.726212370047780e-05i      3.936309739009553e-05 + 4.061244413733642e-07i
		%      -1.660664447741724e-05 + 3.805955020071599e-05i      2.096227035782243e-05 + 2.930046245519812e-05i
		%      -1.653281785922818e-05 - 3.309049420328703e-05i      3.542859086631994e-05 - 4.365889042390991e-06i
		%      -3.024303735879180e-05 + 2.914657952029599e-02i     -5.926120842314066e-03 + 1.379140377669116e-02i
		%      -1.405710192077821e-02 + 2.147915931011225e-03i      2.391164997550583e-02 + 1.059571626067271e-02i
		%       2.309088318496424e-05 - 2.225372587193813e-02i      4.524656782350967e-03 - 1.052988460693964e-02i
		%       1.405701860628311e-02 - 2.067621357985855e-03i     -2.392797557350052e-02 - 1.055772295621565e-02i
		%       1.405701860562528e-02 - 2.067621358365016e-03i     -2.392797557351118e-02 - 1.055772295611852e-02i
		%       2.309088261262358e-05 - 2.225372587226825e-02i      4.524656782341671e-03 - 1.052988460685515e-02i
		%      -1.405710192143606e-02 + 2.147915930632067e-03i      2.391164997549515e-02 + 1.059571626076986e-02i
		%      -3.024303661165101e-05 + 2.914657952072723e-02i     -5.926120842301914e-03 + 1.379140377658082e-02i
		%      -4.861015607046960e-05 + 2.561508568973808e-02i     -5.169926033317482e-03 + 1.213540867726694e-02i
		%       4.540373657289490e-06 - 2.560847770031503e-02i      5.244916175251459e-03 - 1.210224998526086e-02i
		%      -1.599713872551725e-02 + 2.398671328075494e-03i      2.722109431684665e-02 + 1.203646051652236e-02i
		%       1.221398688258174e-02 - 1.831411269192358e-03i     -2.078359728075354e-02 - 9.189966617406292e-03i
		%       1.221398688315414e-02 - 1.831411268862190e-03i     -2.078359728074422e-02 - 9.189966617490853e-03i
		%      -1.599713872626587e-02 + 2.398671327644004e-03i      2.722109431683450e-02 + 1.203646051663291e-02i
		%       4.540373000737432e-06 - 2.560847770069396e-02i      5.244916175240761e-03 - 1.210224998516389e-02i
		%      -4.861015541393663e-05 + 2.561508569011700e-02i     -5.169926033306798e-03 + 1.213540867716997e-02i
		% 
		% 
		% Como puede observarse, los vectores propios son distintos. A pesar de que el valor propio es "el mismo"
		% el vector propio no lo es. (?)
		% 
		% Al observarlo gráficamente graficaEta(sim, VNuevo(:,5)) y graficaEta(sim, VNuevo(:,6)) se aprecia que
		% efectivamente ambas estructuras son distintas.
		% 
		% En los vectores propios mostrados anteriormente, los elementos de cada vector, en general tienen signo
		% distintos, es decir, su estructura de oscilación es distinta. Si el valor propio 
		% es "el mismo" y los signos de las partes reales e imaginarias de los vectores propios son iguales, entonces
		% la estructura o forma de oscilación es la misma. Si las componentes de cada vector comparten signos
		% pero tienen distintos valores en sus entradas, comparten la forma de oscilar (estructura) pero cambia su 
		% magnitud, en función de que tan distintas sean las magnitudes de las entradas en los vectores.
		% 
		% Esto es algo a tener en consideración al momento de discriminar si es que debo quedarme con ambos vectores
		% o eliminar alguno.
		% 
		% Como debería seguir?
		%
		% Implemento el código para analizar si hay traslape o no. El concepto de traslape lo tenía pensado 
		% en base a comparar los valores propios de un paquete calculado con respecto a los valores propios 
		% acumulados en el cálculo. Pero, al notar que hay resultados que arrojan un valor propio		
		% similar o igual, pero con estructura de oscilación distinta, entonces me convenzo de que no es 
		% suficiente analizar el traslape en función de sólo el valor propio, es decir, la estructura de 
		% oscilación del vector, debe al menos ser la misma. Dudo (no lo sé aún) que tenga sentido incluir
		% como parte de los resultados dos vectores que además del mismo valor propio, tengan la misma 
		% estructura de oscilación
		% 
		% O sea, si dentro del cálculo de un paquete, aparece un vector propio igual a alguno de los que 
		% había antes, entonces analizo su estructura de oscilación. Al parecer, si un modo tiene el 
		% mismo valor propio, y su estructura modal es la misma, entonces el modo es el mismo. Tengo que terminar
		% de entender a cabalidad la función del factor de normalización. Entendido!
		% 
		% % Voy a hacer este pequeño for para normalizar los vectores propios que calculé en VNuevo.
		% 
		

		VNuevoNorm = sparse(zeros(size(VNuevo)));
		compruebaNorma = zeros(length(DNuevo),1);
		periodoModo = compruebaNorma;

		for iNorm = 1:length(DNuevo)
			
			VNuevoNorm(:,iNorm) = VNuevo(:,iNorm)/norm(VNuevo(:,iNorm));
			compruebaNorma(iNorm) = norm(VNuevoNorm(:,iNorm));

			if real(DNuevo(iNorm)) ~= 0
				periodoModo(iNorm) = 2*pi/real(DNuevo(iNorm));
			end

		end

		% CREAR EL OBJETO MODO

%		% Hago un pequeño for para visualizar el modo calculado
%		
%		modo = 6;
%		tFinal = 5*periodoModo(modo);
%		tiempo = 0:tFinal/100:tFinal;

%		malla = getMalla(sim);
%		Neta = malla.numeroNodosEta;

%		% cLimit = ;
%		% sol = VNuevoNorm(:,modo)*exp((DNuevo(modo))*tiempo);
%		sol = VNuevoNorm(:,modo)*exp(real(DNuevo(modo))*tiempo);
%		cLimit = max(max(real(sol(1:Neta,:))));

%		for iT = 1:length(tiempo)
%			graficaModo(sim, VNuevoNorm(:,modo)*exp(real(DNuevo(modo))*tiempo(iT)))
%			caxis([-cLimit cLimit])
%			pause(0.01)
%		end
%		

%%		%%%%%%%%%%%%%%%%%%%%%%%%%%5

%		% Automatizo el cálculo
%		
%		kPaq = 50;

%		iteraciones = 50;
%		count = 0;
%	
%		VAcum = [];
%		DAcum = [];
%		FlagAcum = [];
%		sigmasAcum = NaN(iteraciones, 1);
%		sigmasAcum = 1e10;
%		reduce = 0.5;		
%		amplifica = 4;
%		corta = 1e-10;
%		
%		for iTer = 1:iteraciones

%			count = count + 1

%					[VPaq, DPaq, Flag] = eigs(K+C, M, kPaq, sigmasAcum(count)); 	
%					DPaq = diag(DPaq);
%					borrar = find(real(DPaq) < 0);
%					DPaq(borrar) = [];
%					VPaq(:, borrar) = [];	
%					% DPaq 
%					% pause
%	

%					candidato = max(abs(DPaq));
%					% donde = find(abs(DPaq) == candidato);
%					% sigmasAcum(count+1) = quant(reduce*abs(DPaq(donde)), corta);
%					sigmasAcum(count+1) = quant(reduce*abs(candidato), corta);


%				% if(sum(find(sigmasAcum(count+1) == sigmasAcum))~= 0)
%					% keyboard
%					% sigmasAcum(count+1) = quant(amplifica*abs(DPaq(donde)), corta)
%				% 	sigmasAcum(count+1) = quant(amplifica*abs(candidato), corta);

%				% end

%				VAcum = [VAcum, VPaq];
%				DAcum = [DAcum; DPaq]
%				FlagAcum = [FlagAcum, Flag]; 
%		end

		% Como avanzo en "sigma" para buscar los valores y vectores propios adecuadamente?
		% El primer paso parece estar bien, busco en torno a un valor cercano a cero.
		% La pregunta es como avanzo a la siguiente adivinanza y calculo un paquete
		% acorde
			
		%% Corroboro resultados del analisis modal aplicando normalizaciones
	
%		[Vam, Dam] = eig(full(K+C), full(M));
%		Dam = diag(Dam);
%		VamNorm = sparse(zeros(size(Vam)));
%		compruebaNorma = zeros(length(Dam),1);
%		periodoModo = compruebaNorma;

%%		for iNorm = 1:length(Dam)
%%			
%%			VamNorm(:,iNorm) = Vam(:,iNorm)/norm(Vam(:,iNorm));
%%			compruebaNorma(iNorm) = norm(VamNorm(:,iNorm));

%%			if real(Dam(iNorm)) ~= 0
%%				periodoModo(iNorm) = abs(2*pi/real(Dam(iNorm)));
%%			end

%%		end


%		% Automatizo el cálculo
%		
%		kPaq = 50;

%		iteraciones = 50;
%		count = 0;
%	
%		VAcum = [];
%		DAcum = [];
%		FlagAcum = [];
%		sigmasAcum = NaN(iteraciones, 1);
%		sigmasAcum = 1e10;
%		reduce = 0.5;		
%		amplifica = 4;
%		corta = 1e-15;
%		
%		for iTer = 1:iteraciones

%			count = count + 1

%					[VPaq, DPaq, Flag] = eigs(K+C, M, kPaq, sigmasAcum(count)); 	
%					DPaq = diag(DPaq);
%					borrar = find(real(DPaq) < 0);
%					DPaq(borrar) = [];
%					VPaq(:, borrar) = [];	
%		
%					% Normalizo
%					
%					for iNorm = 1:length(DPaq)
%	
%						VPaq(:,iNorm) = VPaq(:,iNorm)/norm(VPaq(:,iNorm));
%						normaVector(iNorm) = norm(VPaq(:,iNorm)); % Debería ser uno para todos
%	
%					end


%					% Corto decimales que son menores que la precision de calculo
%					
%					DPaq = quant(real(DPaq), corta) + i*quant(imag(DPaq), corta);	
%					VPaq = quant(real(VPaq), corta) + i*quant(imag(VPaq), corta);
%	
%					% Tengo que conservar sólo pares valor/vector propio que no 
%					% estén en la lista.

%					% Busco si alguno de los valores propios calculados está 
%					% en los valores acumulados

%					for iBusca = 1:length(DPaq)

%						donde = find(DPaq(iBusca) == DAcum);

%						if(~isempty(donde))
%							% Si es que encontre el valor propio 
%							% en la lista de acumulados, entonces
%							% comparo sus vectores normalizados
%	
%							for iDonde = 1:length(donde)	
%								esIgual(iDonde) = sum(VPaq(:,iBusca) == VAcum(:,donde(iDonde)));
%							end	

%							% Si son exactamente iguales, entonces no tengo que agregarlo.
%							seBorran = find(length(VPaq(:,1)) == esIgual)
%							DPaq(seBorran) = [];
%							VPaq(:,seBorran) = [];	
%						end		
%					end

%					candidato = max(abs(DPaq));
%					sigmasAcum(count+1) = quant(reduce*abs(candidato), corta);

%				VAcum = [VAcum, VPaq];
%				DAcum = [DAcum; DPaq]
%				FlagAcum = [FlagAcum, Flag]; 
%		end

		% No está funcionando este asunto. 

		[VectoresDerecha, ValoresDerecha] = eig(full(K+C), full(M)); 
		ValoresDerecha = diag(ValoresDerecha);
		[VectoresIzquierda, ValoresIzquierda] = eig(full(K+C)', full(M)); 
		ValoresIzquierda = diag(ValoresIzquierda);

		save('MODOS.mat')

%		% Voy a buscar vectores conjugados

%		numVector = 1;
%		nModos = length(Vectores(1,:));
%		esConj = sparse(zeros(nModos,1));
%		nFilas = length(Vectores(:,1));

%		for iConj = 1:nModos
% 
%			evaluaConj = find(Vectores(:,iConj) == conj(Vectores(:,numVector)));

%			if sum(evaluaConj) == nFilas
%				esConj(iConj) = 1;
%			end

%		end

		% RESOLVER EL PROBLEMA Y VISUALIZAR MODOS PARA EL CASO EN QUE RESUELVO SOLO 
		% OMEGA POSITIVO






























