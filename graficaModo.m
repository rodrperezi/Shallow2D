function graficaModo(simulacion, estructura, omega)

	periodo = 2*pi/omega;
	tiempo = 0:4*periodo/100:4*periodo;
	val = getEtaUV(simulacion, estructura);
	cLimit = abs(max(val));
	% keyboard
	for iT = 1:length(tiempo)

		graficaEta(simulacion, estructura*exp(i*omega*tiempo(iT)))
		malla = getMalla(simulacion);
		x = malla.coordenadasEta2DX;
		y = malla.coordenadasEta2DY;
		[eta, u, v] = solucion2D(simulacion, estructura*exp(i*omega*tiempo(iT)));
		hold on	
		hq1 = quiver(x,y,u,v, 'color', 0*[1 1 1]);
		hold off
		caxis([-cLimit cLimit])

		minX = 1.1*min(min(x));	
		maxX = 1.1*max(max(x));
		%  keyboard
		minY = 1.1*min(min(y));	
		maxY = 1.1*max(max(y));

		xlim([minX, maxX])
		ylim([minY, maxY])
		axis equal
		pause(0.01)	

	end


end


