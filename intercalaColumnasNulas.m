function matrizIntercalada = intercalaColumnasNulas(matriz)
	
	[xNodos yNodos] = find(matriz' ~= 0);
	[mFilas nCol] = size(matriz);
	columnaIntercalar = zeros(mFilas,1);

	if(min(xNodos) == 1)
		matrizIntercalada = columnaIntercalar;
	else 
		matrizIntercalada = [matriz(:,1:min(xNodos)-1), columnaIntercalar];
	end

	for iColumnas = min(xNodos):nCol
		matrizIntercalada = [matrizIntercalada, matriz(:, iColumnas), columnaIntercalar];
	end
	% keyboard

end
