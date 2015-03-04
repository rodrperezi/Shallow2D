function graficaBorde(varargin)
	
	if nargin == 1
		borde = getBorde(varargin{:});
		coordenadasXY = borde.coordenadasXY;
		plot(coordenadasXY(:,1), coordenadasXY(:,2), 'k', 'linewidth', 1)
	end

end
