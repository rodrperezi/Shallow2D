function matrizIndices = puntosDentroBorde(borde, espacioX, espacioY)
	
	coordenadasXY = borde.coordenadasXY;
	[meshX meshY] = meshgrid(espacioX, espacioY); % Construyo meshgrid de dominio
	matrizIndices = inpolygon(meshX, meshY, coordenadasXY(:,1), coordenadasXY(:,2)); 
	% keyboard
end % function puntosDentroBorde
