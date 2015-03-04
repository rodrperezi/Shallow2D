function [xSolucion2D ySolucion2D solucionX solucionY] = puntosSolucion2D(Simulacion, solucionCompleta, tipoDeGrafico)

cuerpoAnalisis = Simulacion.Cuerpo;
bordeSuperficie = cuerpoAnalisis.Geometria.bordeSuperficie;
deltaX = cuerpoAnalisis.Geometria.deltaX;
deltaY = cuerpoAnalisis.Geometria.deltaY;
Ineta = puntosDentroBorde(bordeSuperficie, deltaX, deltaY);

[aid bid] = find(Ineta'==1);
[m n] = size(Ineta);
uParaQuiver = NaN(m,n);
vParaQuiver = uParaQuiver;
xParaQuiver = uParaQuiver;
yParaQuiver = uParaQuiver;

coordeta = cuerpoAnalisis.Geometria.Malla.InformacionMalla.coordenadasEta;
x = coordeta(:,1);
y = coordeta(:,2);

[eta u v] = getEtaUV(cuerpoAnalisis, solucionCompleta);

if(strcmp(tipoDeGrafico, 'Eta'))

	for i = 1:length(aid)
		uParaQuiver(bid(i),aid(i)) = eta(i);
		vParaQuiver(bid(i),aid(i)) = eta(i);
		xParaQuiver(bid(i),aid(i)) = x(i);
		yParaQuiver(bid(i),aid(i)) = y(i);

	end

else

	for i = 1:length(aid)
		uParaQuiver(bid(i),aid(i)) = u(i);
		vParaQuiver(bid(i),aid(i)) = v(i);
		xParaQuiver(bid(i),aid(i)) = x(i);
		yParaQuiver(bid(i),aid(i)) = y(i);

	end
end

xSolucion2D = xParaQuiver;
ySolucion2D = yParaQuiver;
solucionX = uParaQuiver;
solucionY = vParaQuiver;
