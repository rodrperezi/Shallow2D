function varargout = solucion2D(varargin, solucion)

	if nargin == 2

		evolTemporal = length(solucion(1,:));
		objeto = varargin;
		malla = getMalla(objeto);
		coordenadasEta2DX = malla.coordenadasEta2DX;
		[xDentro yDentro] = find(~isnan(coordenadasEta2DX'));
		[mFilas nCol] = size(coordenadasEta2DX);

		if evolTemporal ~= 1

			solucionEta2D = NaN(mFilas, nCol, evolTemporal);
			solucionU2D = solucionEta2D;
			solucionV2D = solucionEta2D;
			
			for iTiempo = 1:evolTemporal

				[eta u v] = getEtaUV(objeto, solucion(:,iTiempo));

				for iSol = 1:length(xDentro) 
					solucionEta2D(yDentro(iSol), xDentro(iSol), iTiempo) = eta(iSol);
					solucionU2D(yDentro(iSol), xDentro(iSol), iTiempo) = u(iSol);
					solucionV2D(yDentro(iSol), xDentro(iSol), iTiempo) = v(iSol);
				end
			end

		else
			solucionEta2D = NaN(mFilas, nCol);
			solucionU2D = solucionEta2D;
			solucionV2D = solucionEta2D;

			[eta u v] = getEtaUV(objeto, solucion);

			for iSol = 1:length(xDentro) 
				solucionEta2D(yDentro(iSol), xDentro(iSol)) = eta(iSol);
				solucionU2D(yDentro(iSol), xDentro(iSol)) = u(iSol);
				solucionV2D(yDentro(iSol), xDentro(iSol)) = v(iSol);
			end
			
		end

		varargout{1} = solucionEta2D;
		varargout{2} = solucionU2D;
		varargout{3} = solucionV2D;
	end
end


