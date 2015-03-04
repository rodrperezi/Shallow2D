function [valorPatch coordenadasX coordenadasY] = puntosParaPatch(val, coord, deltax, deltay)

	dx = deltax;
	dy = deltay;
	x = coord(:,1);
	y = coord(:,2);
	x = x';
	y = y';
	val = val';
	
	coordenadasX = [x-dx/2; x+dx/2; x+dx/2; x-dx/2; x-dx/2];
	coordenadasY = [y-dy/2; y-dy/2; y+dy/2; y+dy/2; y-dy/2];
	valorPatch = [val; val; val; val; val];

end




