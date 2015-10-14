classdef SerieAcelExperimento < Forzante

	properties
	
		Aceleracion
		CoeficienteFriccion
		Ejes
		nRep

	end %properties

	methods

		function thisSerieAcelExperimento = SerieAcelExperimento(thisSerieAcelExperimento, experimento, ejes, nRep, varargin)
	
			if nargin == 0
				thisSerieAcelExperimento;
			else

				if ~isempty(varargin)
					if strcmpi(varargin{1}, 'ajusteSeno')
						aceleracion = ajustaSenoAcel(thisSerieAcelExperimento, experimento);
						thisSerieAcelExperimento.Tipo = 'serieAcelExperimentoSeno';
							% keyboard
					elseif strcmpi(varargin{1}, 'serieMedida')
						
						aceleracion = varargin{2}; % esta aceleracion esta en unidades de g
						thisSerieAcelExperimento.Tipo = 'serieAcelExperimento';

					else
						error('Ajuste no definido')						
					end

				else 
					medReaj = experimento.Mediciones.Reajustadas;
					aceleracion.acelX = medReaj.Aceleracion.acelX;
					aceleracion.acelY = medReaj.Aceleracion.acelY;
					thisSerieAcelExperimento.Tipo = 'serieAcelExperimento';
				end

				thisSerieAcelExperimento.Aceleracion = aceleracion;
				freqAcel = 50;
				tiempo = (0:(length(aceleracion.acelX)-1))/freqAcel; %s
				thisSerieAcelExperimento.Tiempo = tiempo;
				thisSerieAcelExperimento.Ejes = ejes;
				thisSerieAcelExperimento.CoeficienteFriccion = 1e-1;
				thisSerieAcelExperimento.nRep = nRep;
				thisSerieAcelExperimento.RegimenTemporal = 'Impermanente';

			end %if
		end %SerieAcelExperimento

		function tiempo = getTiempo(serieAcelExperimento)
			tiempo = serieAcelExperimento.Tiempo;
		end %getTiempo

		function aceleracion = getAceleracion(serieAcelExperimento)
			aceleracion = serieAcelExperimento.Aceleracion;
		end %getAceleracion


		function thisSerieAcelExperimento = adaptaForzante(thisSerieAcelExperimento, thisSimulacion);

			fluido = getFluido(thisSimulacion);
			rho = fluido.densidadRho;
			bat = getCompiladoBatimetria(thisSimulacion);
			malla = getMalla(thisSimulacion);
			Neta = malla.numeroNodosEta;
			Nns = malla.numeroNodosV;
			New = malla.numeroNodosU;
			param = getParametros(thisSimulacion);
			g = param.aceleracionGravedad;

			tiempo = getTiempo(thisSerieAcelExperimento);
			aceleracion = getAceleracion(thisSerieAcelExperimento);
			
			% construyo aceleraciones repitiendo 
			% la serie caracteristica N veces

			tiempoEstatico = linspace(0, floor(max(tiempo)*0.6), 5);			
			acelEstatica = zeros(1,length(tiempoEstatico));

			acelX = aceleracion.acelX*g;
			acelY = aceleracion.acelY*g;

			nRep = thisSerieAcelExperimento.nRep;
			% nRep = 30;
			deltaT = 1/50;

%			if nRep > 10
%				tiempoAcelX = (0:(length(acelX)-1))*deltaT;
%				% newDeltaT = 1/20;
%				newTiempo = linspace(0, max(tiempoAcelX), floor(0.4*max(tiempoAcelX)/deltaT));
%				acelX = linterp(tiempoAcelX, acelX, newTiempo);
%				acelY = linterp(tiempoAcelX, acelY, newTiempo);
%				deltaT = newTiempo(2) - newTiempo(1);
%				aceleracion.acelX = acelX/g;
%				aceleracion.acelY = acelY/g;
%				thisSerieAcelExperimento.Aceleracion = aceleracion;
%								
%			end

			acelXRep = repmat(acelX, 1, nRep);
			acelYRep = repmat(acelY, 1, nRep);


			tiempoMovil = (0:(length(acelXRep)-1))*deltaT;			
			thisSerieAcelExperimento.Tiempo = tiempoMovil;			
		
			
			% thisSerieAcelExperimento.Tiempo = [tiempoEstatico, tiempoMovil ...
			% 			  + max(tiempoEstatico)];
			
	
			batx = bat(Neta + 1: Neta + New);
			baty = bat(Neta + New + 1: New + Neta + Nns);
		
%			newAcelX = [acelEstatica, acelXRep];
%			newAcelY = [acelEstatica, acelYRep];
			newAcelX = acelXRep;
			newAcelY = acelYRep;
		
			ejes = thisSerieAcelExperimento.Ejes;

			if strcmpi(ejes, 'xy')
				thisSerieAcelExperimento.DireccionX = -rho*batx*newAcelX;
				thisSerieAcelExperimento.DireccionY = -rho*batx*newAcelY;
			elseif strcmpi(ejes, 'x')
				thisSerieAcelExperimento.DireccionX = -rho*batx*newAcelX;
				% thisSerieAcelExperimento.DireccionY = -rho*batx*newAcelY*0;
				thisSerieAcelExperimento.DireccionY = -rho*batx*newAcelX*0;
			elseif strcmpi(ejes, 'y')
				% thisSerieAcelExperimento.DireccionX = -rho*batx*newAcelX*0;
				thisSerieAcelExperimento.DireccionX = -rho*batx*newAcelY*0;
				thisSerieAcelExperimento.DireccionY = -rho*batx*newAcelY;
			end

		end %adaptaForzante 


		function acelAjustada = ajustaSenoAcel(thisSerieAcelExperimento, exp)

			% series = cell(1,1);	
			% series{1} = 'acelX';
			series = cell(2,1);	
			series{1} = 'acelX';
			series{2} = 'acelY';
			g = 9.81;

			acelAjustada = [];

			for iS = 1:length(series)

				acelX = eval(['exp.Mediciones.Reajustadas.Aceleracion.', series{iS}]);
				acelX = acelX*g;

%				if isemtpy(acelX)
%					continue
%				end

				tiempoAcel = (0:(length(acelX)-1))/50;
				amplitud = exp.AmplitudOscilacion;
				freq = exp.FrecuenciaRPM*(2*pi/60); %rad/s
				tiempoSeno = (0:(2*length(acelX)-1))/50;
				% keyboard
				nCiclosAprox = ceil(tiempoAcel(end)/(2*pi/freq));



				% Busco frecuencia que maximiza la correlacion 
				% entre series

				posFreq = linspace(0.5*freq, 1.5*freq, 15);
				largoVentana = length(acelX);
				nCor = length(tiempoSeno) - largoVentana;
				errorProm = zeros(length(posFreq),1);
				ampFija = max([max(acelX) - min(acelX)]);
	
				for iF = 1:length(posFreq)

					freqTest = posFreq(iF);
					serieTeo = ampFija*sin(freqTest*tiempoSeno);
					corr = zeros(nCor,1);
	
					for iC = 1:nCor

						corr(iC) = sum(acelX.* ...
								serieTeo(iC : iC + largoVentana - 1));
					end

					[locMax, posMax] = lmax(corr);
					fMax = posMax(locMax == max(locMax));
		
					if length(fMax) > 1 
						fMax = fMax(1);
					end
	
					serieTeoAjus = serieTeo(fMax : fMax +  ...
								  largoVentana - 1);

					errorProm(iF) = sqrt(sum(abs(acelX - serieTeoAjus).^2));

					% figure
					% plot(acelX)
					% hold on 
					% plot(serieTeoAjus, 'r')
					% hold off
					% iF

				end %for iF

				% Del for anterior, se obtiene la frecuencia que ajusta la serie. 
				% La mejor frecuencia es aquella que minimiza el error. 

				fMinErr = find(errorProm == min(errorProm));
				mejorFreq = posFreq(fMinErr); % rad/s

				% Ahora debo ajustar la amplitud

				ampEst = ampFija/(mejorFreq^2);
				posAmp = linspace(0.5*ampEst, 1.5*ampEst, 15);
				freqTest = mejorFreq;

				for iA = 1:length(posAmp)

					serieTeo = posAmp(iA)*freqTest^2*sin(freqTest*tiempoSeno);
					corr = zeros(nCor,1);
	
					for iC = 1:nCor

						corr(iC) = sum(acelX.* ...
								serieTeo(iC : iC + largoVentana - 1));
					end

					[locMax, posMax] = lmax(corr);
					fMax = posMax(locMax == max(locMax));
		
					if length(fMax) > 1 
						fMax = fMax(1);
					end
	
					serieTeoAjus = serieTeo(fMax : fMax +  ...
								  largoVentana - 1);

					errorPromAmp(iA) = sqrt(sum(abs(acelX - serieTeoAjus).^2));

					% plot(acelX)
					% hold on 
					% plot(serieTeoAjus, 'r')
					% hold off
					% iA
					% pause
					% keyboard

				end %for iA
	
				fAmp = find(errorPromAmp == min(errorPromAmp));
				mejorAmp = posAmp(fAmp);

				serieTeo = mejorAmp*freqTest^2*sin(freqTest*tiempoSeno);
				corr = zeros(nCor,1);
	
				for iC = 1:nCor

					corr(iC) = sum(acelX.* ...
						serieTeo(iC : iC + largoVentana - 1));
				end

				[locMax, posMax] = lmax(corr);
				fMax = posMax(locMax == max(locMax));
		
				if length(fMax) > 1 
					fMax = fMax(1);
				end
	
				serieFinal = serieTeo(fMax : fMax + largoVentana - 1);
				errorAjuste = sqrt(sum(abs(acelX - serieFinal).^2));

				% keyboard	

				% Fijo una cantidad de ciclos para la serie
				% teórica ajsutada

				nCiclos = floor(0.8*ceil(tiempoAcel(end)/(2*pi/freqTest)));
				
				% Construyo una nueva serie teórica y ajusto las mediciones 
				% a esta serie. La serie teórica comienza en cero 
				% y termina en cero. La idea es que las mediciones
				% se acerquen a eso.

				periodoCiclo = 2*pi/freqTest; %s
				tFinal = periodoCiclo*nCiclos;
				tiempoNCiclos = (0:floor(tFinal*50))/50;				
				serieNCiclos = mejorAmp*freqTest^2*sin(freqTest*tiempoNCiclos);
							
				% Hasta aquí la serie comienza y termina un poco 
				% antes de cero. La idea es utilizar esta
				% serie para correlacionarla con las mediciones 
				% y encontrar el nuevo vector de datos medidos

				largoVentana = length(serieNCiclos);
				nCor = length(acelX) - largoVentana;
				corr = zeros(nCor,1);
	
				for iC = 1:nCor

					corr(iC) = sum(serieNCiclos.* ...
						acelX(iC : iC + largoVentana - 1));
				end

				[locMax, posMax] = lmax(corr);
				fMax = posMax(locMax == max(locMax));
		
				if length(fMax) > 1 
					fMax = fMax(1);
				end
				% keyboard
				mediFinal = acelX(fMax : fMax + largoVentana - 1);

				if strcmpi(series{iS}, 'acelY') && length(mediFinal) ~= length(serieNCiclos)
					errorAjuste = NaN;
				elseif length(mediFinal) ~= length(serieNCiclos)
					errorAjuste = NaN;
				else
					errorAjuste = sqrt(sum(abs(mediFinal - serieNCiclos).^2));
				end

				parametrosAjuste.FrecuenciaRPM = freqTest/(2*pi)*60;
				parametrosAjuste.AmplitudOscilacion = mejorAmp;
				parametrosAjuste.errorAjuste = errorAjuste;

				eval(['acelAjustada.', series{iS}, ' = serieNCiclos/g;'])
				eval(['acelAjustada.ajuste', series{iS}, ' = parametrosAjuste;'])
				eval(['exp.Mediciones.Reajustadas.Aceleracion.', series{iS}, ' = mediFinal/g;']);

				% plot(mediFinal)
				% hold on 
				% plot(serieNCiclos, 'r')
				% hold off
				% keyboard
				
			end % for iS
			% keyboard
			% figure
			% acelX = exp.Mediciones.Reajustadas.Aceleracion.acelX*g;
			% plot(acelX)
			% hold on 
			% plot(acelAjustada.acelX*g, 'r')
			% hold off
			% keyboard
		end % function ajustaSenoAcel
	end %methods
end %classdef


%%%%%% THRASH


