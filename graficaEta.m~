function graficaEta(varargin, solucion)

	if length(varargin) == 1
		
		graficaBorde(varargin);
		hold on
		
		[dx dy] = getDeltaX(varargin);

		malla = getMalla(varargin);
		coordenadasEta = malla.coordenadasEta;
		val = getEtaUV(varargin, solucion);
		x = coordenadasEta(:,1);
		y = coordenadasEta(:,2);
		x = x';
		y = y';
		val = val';
	
		coordenadasX = [x-dx/2; x+dx/2; x+dx/2; x-dx/2; x-dx/2];
		coordenadasY = [y-dy/2; y-dy/2; y+dy/2; y+dy/2; y-dy/2];
		valorPatch = [val; val; val; val; val];

		patch(coordenadasX, coordenadasY, valorPatch)
		shading('interp')
		hold off

	end %if

end
