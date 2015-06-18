function graficaEta(varargin, solucion)
% keyboard
	if nargin == 2
		
		objeto = varargin;
		graficaBorde(objeto);
		hold on
		
		[dx dy] = getDeltaX(objeto);

		malla = getMalla(objeto);
		coordenadasEta = malla.coordenadasEta;
		val = getEtaUV(objeto, solucion);
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
		colorbar
		

	end %if

end
