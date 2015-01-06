function analisisModal = AnalisisModal(Cuerpo)
	
		analisisModal.CuerpoActualizado = [];

		if(~isempty(Cuerpo.Forzante) && ~isempty(Cuerpo.Geometria) && isempty(Cuerpo.Matrices))
			Cuerpo.Matrices = generaMatrices(Cuerpo);
			Cuerpo.valoresVectoresPropios = calculaValoresVectoresPropios(Cuerpo);
			analisisModal.CuerpoActualizado = Cuerpo;
		elseif(~isempty(Cuerpo.Matrices) && isempty(Cuerpo.valoresVectoresPropios))
			Cuerpo.valoresVectoresPropios = calculaValoresVectoresPropios(Cuerpo);
			analisisModal.CuerpoActualizado = Cuerpo;
		end

		analisisModal.solucionCompleta = amplitudesModales(Cuerpo);
		[analisisModal.solucionEta analisisModal.solucionU analisisModal.solucionV]= getEtaUV(Cuerpo, analisisModal.solucionCompleta);

end

