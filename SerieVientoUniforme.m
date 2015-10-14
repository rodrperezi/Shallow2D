classdef SerieVientoUniforme < Forzante


	properties

		uAsterisco
		anguloDireccion
		CoeficienteFriccion

	end


	methods

		function thisSerieViento = SerieVientoUniforme(thisSerieViento, datosViento, alturaMedicion, zoRugosidad)

			% - datosViento: es el vector que espoecifica la magnitud de la velocidad 
			% del viento en el tiempo. La primera columna es el tiempo, la segunda es el viento. Las unidades son m/s
			% El uasterisco se calcula con un perfil logaritmico y se expresa desde
			% el punto de vista del agua.
			% - alturaMedicion: Se espcifica en m.
			% - zoRugosidad = se especifica en m.


			if nargin == 0

				thisSerieViento;				

			else

				% Asigno datos viento 
				thisSerieViento.anguloDireccion = pi/2;
				thisSerieViento.CoeficienteFriccion = 1e-3; % actualizar por kranenburg
				par = Parametros();
				kappa = par.kappaVonKarman;
				rhoAire = par.densidadAire;
				rhoAgua = par.densidadRho;
				uAsteriscoViento = datosViento(:,2)*kappa/log(alturaMedicion/zoRugosidad);
				thisSerieViento.uAsterisco = uAsteriscoViento*sqrt(rhoAire/rhoAgua);
				thisSerieViento.Tipo = 'serieVientoUniforme';

				tiempo = datosViento(:,1)*86400; %para dejarlo en segundos 
				thisSerieViento.Tiempo = tiempo;
				thisSerieViento.RegimenTemporal = 'Impermanente';
			end	
		end

		function uAsterisco = getUAsterisco(thisSerieViento)

			uAsterisco = thisSerieViento.uAsterisco;

		end
	

		function thisSerieViento = adaptaForzante(thisSerieViento, thisSimulacion);

			fluido = getFluido(thisSimulacion);
			rho = fluido.densidadRho;
			malla = getMalla(thisSimulacion);
			Nns = malla.numeroNodosV;
			New = malla.numeroNodosU;
			uAsterisco = getUAsterisco(thisSerieViento);
			uAsterisco = uAsterisco';
			anguloDireccion = thisSerieViento.anguloDireccion;
			thisSerieViento.DireccionX = repmat(rho*uAsterisco.^2*cos(anguloDireccion), New, 1);
			thisSerieViento.DireccionY = repmat(rho*uAsterisco.^2*sin(anguloDireccion), Nns, 1);
		
%			if isempty(thisVientoUniforme.coeficienteFriccion)
%		
%				parametros = getParametros(thisSimulacion);
%				g = parametros.aceleracionGravedad;
%				hom = profundidadMedia(thisSimulacion);
%				malla = getMalla(thisSimulacion);
%				Lx = max(malla.coordenadasU(:,1)) - ... 	
%				     min(malla.coordenadasU(:,1));
%				Ly = max(malla.coordenadasV(:,2)) - ... 	
%				     min(malla.coordenadasV(:,2));
%				L = max([Lx Ly]);

%				wed = g*hom^2/(uAsterisco^2*L);
%				relAsp = L/hom;
%				alpha = 0.0188;
%				beta = -0.4765;
%				gamma = -0.3804;
%				coefEstimado = alpha*(wed^beta)*(relAsp^gamma);
%				thisVientoUniforme.coeficienteFriccion = coefEstimado*sqrt(g*hom); 			

%			end


		end %adaptaForzante 





	end

end %classdef

%%%%% THRASH
