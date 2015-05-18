function graficaBatimetria(varargin)

	if nargin == 1
		objeto = varargin{1};
		graficaBorde(objeto);
		hold on
		
		[dx dy] = getDeltaX(objeto);

		batimetria = getBatimetria(objeto);
		malla = getMalla(objeto);
		coordenadasEta = malla.coordenadasEta;
		val = batimetria.hoNodosEta;
		x = coordenadasEta(:,1);
		y = coordenadasEta(:,2);
		x = x';
		y = y';
		val = val';
	
		coordenadasX = [x-dx/2; x+dx/2; x+dx/2; x-dx/2; x-dx/2];
		coordenadasY = [y-dy/2; y-dy/2; y+dy/2; y+dy/2; y-dy/2];
		valorPatch = [val; val; val; val; val];

		handlePatch = patch(coordenadasX, coordenadasY, valorPatch);
		shading('interp')
		colormap('gray')
		c = colorbar;
		xlabel(c, '$h_o$ [m]', 'interpreter', 'latex')
		xlabel('$x$ [m]', 'interpreter', 'latex')
		ylabel('$y$ [m]', 'interpreter', 'latex')
		hold off

	end %if

end
