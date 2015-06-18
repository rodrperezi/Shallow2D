clear all 
close all
% 
% Rutina para corroborar la construcción 
% de la batimetría
% 
	% 
	% Construyo borde de arbitrario de prueba
	% Este borde es el mismo utilizado en el archivo
	% TestMalla.m
	% 
	% Lo que hago ahora es crear una información de 
	% batimetría arbitraria. La idea es generar 
	% las rutinas necesarias para tomar esta información	
	% y transformarla en datos de batimetría coherentes
	% que luego puedan ser tomados y trabajados por el 	
	% modelo numérico. Pienso que lo ideal 
	% sería lograr una rutina que tome la información 
	% correspondiente al borde de una cubeta y algunos datos 
	% de batimetría, a partir de lo cual construya las
	% estructuras necesarias para ser procesadas.	
	%	
	% 
	coordenadasXY = [-250    0;
			 -260  -20;
			 -270  -50;
			 -250  -70;
			 -230  -80;
			 -200  -70;
			 -180  -50;
			 -150  -40;
			 -130  -20;
		 	 -100  -10;
		 	  -80  -30;
			  -50  -50;
			  -10  -70;
			    0  -90;
			   30  -80;
			   50  -50;
			   70  -30;
			  100  -10;
			  160    0;
			  180   30;
			  200   30;
			  230   50; 
			  250   50; 
			  230   80;
			  210   90;
			  180  100;
			  170  110;
     			  150  150;
			  100  180;
   			   50  200;
			    0  220;
     			  -30  200;
		          -50  190;
			  -80  170;
			 -100  150;
	  		 -130  130;
			 -150  120;
			 -160  120;
			 -180  150;
			 -200  140;
			 -250  130;
			 -280  120;
			 -300  100; 
			 -350   80;
			 -350  	60;
			 -340   50;
			 -300   40;
			 -280   30;
			 -260   20;
			 -250    0 ];
	bordeTest = Borde();
	bordeTest.coordenadasXY = coordenadasXY;
	bordeTest.tipoBorde = 'Prueba';
	% graficaBorde(bordeTest)
	% keyboard
%%%%%%%%%%% Lista Construcción de borde arbitrario %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%% Construcción de batimetría arbitraria %%%%%%%%%%%%%%%%%%%%%%%%

	% Algunos Comentarios:
	% 
	% La batimetría de Kranenburg tiene una característica que complica
	% la existencia. La profundidad en los bordes no es cero, es decir, 
	% existe una pared del contenedor que es vertical. Esto no debería 
	% transformarse en un problema puesto que en la naturaleza existen
	% muchos tipos de contenedores con paredes verticales. El ejemplo 
	% que tengo a mano es un vaso.
	% EL borde se entiende como la línea que separa estas zonas 
	% de profundidad distinta de cero con aquellas que no tienen 
	% profundidad puesto que no existe fluido fuera del contenedor
	% 
	% Por ende, el problema a solucionar es: que hacer con 
	% aquellos nodos (velocidad o Eta) que quedan por fuera 
	% del borde por poco. Rozas (2011) dice que los nodos
	% de velocidad que están justo en el borde, tienen la 
	% profundidad del nodo \eta al cual pertenecen
	% y evidentemente, los nodos \eta que quedan fuera
	% del borde tienen profundidad nula. 
	% 
	% O sea, si estoy en un nodo \eta que es borde, 
	% la profundidad de los nodos de velocidad que definen 
	% la pared es la misma que la profundidad del nodo \eta 
	% al cual pertenecen. Esto me parece una buena aproximación.





	geoTest = Geometria();
	geoTest.Borde = bordeTest;
	geoTest.deltaX = 0.1*(max(coordenadasXY(:,1)) - min(coordenadasXY(:,1)));
	geoTest.deltaY = geoTest.deltaX;
	geoTest.Malla = Malla(geoTest, 'staggered');
	graficaMalla(geoTest)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Conclusión: La malla está construida de manera correcta.
% Para mayor información sobre la programación, ver Malla.m

