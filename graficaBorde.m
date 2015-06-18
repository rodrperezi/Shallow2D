function graficaBorde(varargin)

	if nargin == 1
		objeto = varargin{1};
		borde = getBorde(objeto);
		coordenadasXY = borde.coordenadasXY;
		plot(coordenadasXY(:,1), coordenadasXY(:,2), 'k', 'linewidth', 1)
	end

end
