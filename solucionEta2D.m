function varargout = solucion2D(varargin, solucion)

	if nargin == 2

		objeto = varargin;
		malla = getMalla(objeto);
		coordenadasEta2DX = thisMalla.coordenadasEta2DX;
		[posxDentro posyDentro] = find(coordenadasEta2DX' == 1);
		[mFilas nCol] = size(matrizIndicesEta);
		solucionEta2D = NaN(mFilas, nCol);
		solucionU2D = solucionEta2D;
		solucionV2D = solucionEta2D;
		[eta u v] = getEtaUV(objeto, solucion);

		for iSol = 1:length(posxDentro) 
			solucionEta2D(yDentro(iSol), xDentro(iSol)) = eta(iSol);
			solucionU2D(yDentro(iSol), xDentro(iSol)) = u(iSol);
			solucionV2D(yDentro(iSol), xDentro(iSol)) = v(iSol);
		end
		
		varargout{1} = solucionEta2D;
		varargout{2} = solucionU2D;
		varargout{3} = solucionV2D;
	end
end
