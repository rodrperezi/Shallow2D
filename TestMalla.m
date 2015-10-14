clear all 
close all
% 
% Rutina para corroborar que la construcción de la malla 
% es correcta.
% 
	% Esta rutina pretende generar una serie de pruebas
	% para entender y respaldar que la construcción
	% de la malla numérica staggered implementada
	% en el modelo numérico es correcta.
	% Esto surge producto de algunas observaciones
	% en el procesamiento de los datos, que hacen 
	% pensar que pueda existir un error. En particular
	% al resolver el problema de valores y vectores 
	% propìos, (ver Shimizu e Imberger, 2008) para el 
	% sistema de ecuaciones linealizadas de momentum
	% observé que al ordenar los vectores propios 
	% según el signo de su frecuencia angular, es decir, 
	% separar la construcción según +r y -r, no se cumple
	% la relación para los vectores propios \chi(+r) = \chi(-r)*.
	% Esto puede ser un problema de cómputo o algún error
	% en la programación. Por lo tanto, realizo un análisis
	% exhaustivo de la conformación del modelo numérico 
	% para encontrar la causa del problema.
	% 
	% Construyo borde de arbitrario de prueba
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
%	graficaBorde(bordeTest)
%	keyboard
%%%%%%%%%%% Lista Construcción de borde arbitrario %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	R = 1000;
	H = 10;
	centroMasa = [0 0];
	
	kranPrueba = GeoKranenburgNew(GeoKranenburgNew(),'radioR', R, 'alturaH', H, 'centroMasa', centroMasa, 'fracDeltaX', 1/5);
	% geoTest = Geometria();
	% geoTest.Borde = bordeTest;
	% deltaX = 0.1*(max(coordenadasXY(:,1)) - min(coordenadasXY(:,1)));
	% deltaY = deltaX;
	% geoTest.Malla = Malla(geoTest, 'staggered');
	% geoTest.Malla = Staggered(Malla(), geoTest, deltaX, deltaY);
	graficaMalla(Grafico(), kranPrueba)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Conclusión: La malla está construida de manera correcta.
% Para mayor información sobre la programación, ver Malla.m

