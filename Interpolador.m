function [valorInterpolado coordenadasInterpoladas] = Interpolador(Simulacion, solucionCompleta, tipoDeGrafico, nuevoDeltaX, nuevoDeltaY)

cuerpoAnalisis = Simulacion.Cuerpo;

bordeSuperficie = cuerpoAnalisis.Geometria.bordeSuperficie;
mallaInterpolada = generaMallaStaggered(bordeSuperficie, nuevoDeltaX, nuevoDeltaY);
% keyboard


switch tipoDeGrafico
	case 'Peclet'	
		% stringAyuda = ['concentracion = Simulacion.Resultados.Transporte.',motorDeCalculo];		
		% eval(stringAyuda)
		peclet = getEtaUV(cuerpoAnalisis, solucionCompleta);
		coordenadasSinInterpolar = cuerpoAnalisis.Geometria.Malla.InformacionMalla.coordenadasEta;
		coordenadasInterpoladas = mallaInterpolada.coordenadasEta;
		funcionInterpoladorEta = TriScatteredInterp(coordenadasSinInterpolar(:,1), coordenadasSinInterpolar(:,2), full(peclet));
		valorInterpolado = funcionInterpoladorEta(coordenadasInterpoladas(:,1), coordenadasInterpoladas(:,2));

	case 'Concentracion'	
		% stringAyuda = ['concentracion = Simulacion.Resultados.Transporte.',motorDeCalculo];		
		% eval(stringAyuda)
		concentracion = getEtaUV(cuerpoAnalisis, solucionCompleta);
		coordenadasSinInterpolar = cuerpoAnalisis.Geometria.Malla.InformacionMalla.coordenadasEta;
		coordenadasInterpoladas = mallaInterpolada.coordenadasEta;
		funcionInterpoladorEta = TriScatteredInterp(coordenadasSinInterpolar(:,1), coordenadasSinInterpolar(:,2), full(concentracion));
		valorInterpolado = funcionInterpoladorEta(coordenadasInterpoladas(:,1), coordenadasInterpoladas(:,2));
	case 'Eta'
		eta = getEtaUV(cuerpoAnalisis, solucionCompleta);
		coordenadasSinInterpolar = cuerpoAnalisis.Geometria.Malla.InformacionMalla.coordenadasEta;
		coordenadasInterpoladas = mallaInterpolada.coordenadasEta;
		funcionInterpoladorEta = TriScatteredInterp(coordenadasSinInterpolar(:,1), coordenadasSinInterpolar(:,2), full(eta));
		valorInterpolado = funcionInterpoladorEta(coordenadasInterpoladas(:,1), coordenadasInterpoladas(:,2));
	case 'Velocidad'
		[eta u v] = getEtaUV(cuerpoAnalisis, solucionCompleta);
		% coordenadasSinInterpolarU = cuerpoAnalisis.Geometria.Malla.InformacionMalla.coordenadasU;
		coordenadasSinInterpolarU = cuerpoAnalisis.Geometria.Malla.InformacionMalla.coordenadasEta;
		% coordenadasInterpoladasU = mallaInterpolada.coordenadasU;
		coordenadasInterpoladasU = mallaInterpolada.coordenadasEta;
		% keyboard
		% funcionInterpoladorU = TriScatteredInterp(coordenadasSinInterpolarU(:,1), coordenadasSinInterpolarU(:,2), u);
		funcionInterpoladorU = TriScatteredInterp(coordenadasSinInterpolarU(:,1), coordenadasSinInterpolarU(:,2), full(u));
		valorInterpoladoU = funcionInterpoladorU(coordenadasInterpoladasU(:,1), coordenadasInterpoladasU(:,2));
		% coordenadasSinInterpolarV = cuerpoAnalisis.Geometria.Malla.InformacionMalla.coordenadasV;
		coordenadasSinInterpolarV = cuerpoAnalisis.Geometria.Malla.InformacionMalla.coordenadasEta;
		% coordenadasInterpoladasV = mallaInterpolada.coordenadasV;
		coordenadasInterpoladasV = mallaInterpolada.coordenadasEta;
		% funcionInterpoladorV = TriScatteredInterp(coordenadasSinInterpolarV(:,1), coordenadasSinInterpolarV(:,2), v);
		funcionInterpoladorV = TriScatteredInterp(coordenadasSinInterpolarV(:,1), coordenadasSinInterpolarV(:,2), full(v));
		valorInterpoladoV = funcionInterpoladorV(coordenadasInterpoladasV(:,1), coordenadasInterpoladasV(:,2));
		coordenadasInterpoladas = mallaInterpolada.coordenadasEta;
		valorInterpolado = sqrt(valorInterpoladoU.^2 + valorInterpoladoV.^2);
	otherwise
		error('myapp:chk', 'Aún no existe ese tipo de gráfico')
end



