function graficaNumetrosMatriz(matriz)
% function graficaNumetrosMatriz(matriz)
% Función que grafica en una figura los números
% que contiene matriz, en el mismo formato que
% la matriz se muestra en el prompt de Matlab
	
	close all
	[filas columnas] = size(matriz);
	for iFilas = 1:filas
		for iColumnas = 1:columnas
			text(iColumnas, filas - iFilas + 1, num2str(matriz(iFilas, iColumnas)));
		end
	end
	xlim([0 columnas+1])
	ylim([0 filas+1])
	set(gca, 'visible', 'off')
	set(gcf, 'color', 'w')
end
