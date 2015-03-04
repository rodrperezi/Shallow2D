function matrizIntercalada = intercalaFilasNulas(matriz)
	
	[xNodos yNodos] = find(matriz' ~= 0);
	[mFilas nCol] = size(matriz);
	filaIntercalar = zeros(1,nCol);

	if(min(yNodos) == 1)
		matrizIntercalada = filaIntercalar;
	else 
		matrizIntercalada = [matriz(1:min(yNodos)-1,:); filaIntercalar];
	end

	for iFilas = min(yNodos):mFilas
		matrizIntercalada = [matrizIntercalada; matriz(iFilas,:); filaIntercalar];
	end

end


