function graficaModo(simulacion, estructura)

	graficaEta(simulacion, estructura)
	malla = getMalla(simulacion);
	x = malla.coordenadasEta2DX;
	y = malla.coordenadasEta2DY;
	[eta, u, v] = solucion2D(simulacion, estructura);
	hold on	
	hq1 = quiver(x,y,u,v, 'color', 0*[1 1 1]);
	hold off

	% minX = 1.1*sign(min(min(x)))*abs(min(min(x)));	
	% maxX = 1.1*sign(max(max(x)))*abs(max(max(x)));
	
	minX = 1.1*min(min(x));	
	maxX = 1.1*max(max(x));
	%  keyboard
	minY = 1.1*min(min(y));	
	maxY = 1.1*max(max(y));

	xlim([minX, maxX])
	ylim([minY, maxY])
	axis equal

end


