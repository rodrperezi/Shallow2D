function varargout = solucionVelocidad2D(varargin, solucion)

	if nargin == 2

		objeto = varargin;
		malla = getMalla(objeto);
		matrizIndicesEta = malla.matrizIndicesEta;
		[xDentro yDentro] = find(matrizIndicesEta' == 1);
		% keyboard
		[mFilas nCol] = size(matrizIndicesEta);
		xSolucion = NaN(mFilas, nCol);
		ySolucion = xSolucion;
		solucion2DX = xSolucion;
		solucion2DY = xSolucion;
		[eta u v] = getEtaUV(objeto, solucion);
		coordenadasEta = malla.coordenadasEta;

		for iSol = 1:length(xDentro) 
			xSolucion(yDentro(iSol), xDentro(iSol)) = coordenadasEta(iSol,1);
			ySolucion(yDentro(iSol), xDentro(iSol)) = coordenadasEta(iSol,2);
			solucion2DX(yDentro(iSol), xDentro(iSol)) = u(iSol);
			solucion2DY(yDentro(iSol), xDentro(iSol)) = v(iSol);
		end
		
		varargout{1} = xSolucion;
		varargout{2} = ySolucion;
		varargout{3} = solucion2DX;
		varargout{4} = solucion2DY;

	end
end
