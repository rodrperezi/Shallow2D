function crankNicolson = CrankNicolson(Cuerpo)
	
		crankNicolson.CuerpoActualizado = [];

		if(~isempty(Cuerpo.Forzante) && ~isempty(Cuerpo.Geometria) && isempty(Cuerpo.Matrices))
				Cuerpo.Matrices = generaMatrices(Cuerpo);
				crankNicolson.CuerpoActualizado = Cuerpo;
		end
	
		% tiempoFinal = 100000; %s
		tiempoFinal = 10000; %s
		deltaT = 0.5; %s
		tiempoCalculo = 0:deltaT:tiempoFinal;
		matricesResolucion = Cuerpo.Matrices;
		b = matricesResolucion.f;
		M = matricesResolucion.M;
		A = sqrt(-1)*(matricesResolucion.K + matricesResolucion.C);

		SOLri = sparse(zeros(length(b),2));

		h=waitbar(0,'Please wait..');

		nTiempoCalculo = length(tiempoCalculo);
		for iTiempoCalculo = 2:nTiempoCalculo
			waitbar(iTiempoCalculo/nTiempoCalculo)
			SOLri(:,2) = (M/deltaT - 0.5*A)\((0.5*A + M/deltaT)*SOLri(:,1) + b); 
			% OPTIMIZAR
			error(iTiempoCalculo) = norm(SOLri(:,1) - SOLri(:,2))/norm(SOLri(:,1));
			SOLri(:,1) = SOLri(:,2);
		
		end
		close(h)
		crankNicolson.solucionCompleta = SOLri(:,2);
		% analisisModal.solucionCompleta = amplitudesModales(Cuerpo);
		[crankNicolson.solucionEta crankNicolson.solucionU crankNicolson.solucionV]= getEtaUV(Cuerpo, crankNicolson.solucionCompleta);


