function graficaMalla(varargin)

	if nargin == 1

		set(0,'DefaultAxesFontName', 'times')
		set(0,'DefaultAxesFontSize', 9)
	
		set(0,'DefaultTextFontname', 'times')
		set(0,'DefaultTextFontSize', 9)
	
		areaMarker = 40;
		
		malla = getMalla(varargin{:});
		coordenadasEta = malla.coordenadasEta;	
		coordenadasU = malla.coordenadasU;	
		coordenadasV = malla.coordenadasV;
	
		graficaBorde(varargin{:})
		hold on
		scatter(coordenadasEta(:,1), coordenadasEta(:,2), areaMarker, 's', 'markeredgecolor', 'k', 'markerfacecolor', 0*[1 1 1])
		scatter(coordenadasU(:,1), coordenadasU(:,2), areaMarker, '>', 'markeredgecolor', 'k', 'markerfacecolor', 0.5*[1 1 1])
		scatter(coordenadasV(:,1), coordenadasV(:,2), areaMarker, '^', 'markeredgecolor', 'k', 'markerfacecolor', 1*[1 1 1])
		hold off
		
		axis equal
	
		xlabel('x [m]', 'interpreter', 'latex')	
		ylabel('y [m]', 'interpreter', 'latex')	
	end %if
	
end
