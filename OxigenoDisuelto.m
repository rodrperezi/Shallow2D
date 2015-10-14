classdef OxigenoDisuelto < Masa

	% MASA -> OXIGENODISUELTO es la clase que caracteriza 
	% al oxigeno disuelto como parte de los tipos 
	% de masa que pueden ser transportadas

	properties

		coefDifusion
		concSaturacion
		FlujosVerticales

	end

	methods

		function thisOxigenoDisuelto = OxigenoDisuelto(thisOxigenoDisuelto, simulacion, solucion)
	
			if nargin == 0			
				thisOxigenoDisuelto;
				thisOxigenoDisuelto.coefDifusion = 1.82e-9; % [m2/s]
				thisOxigenoDisuelto.concSaturacion = 8.82e-3; % [kg/m3]
				
			else
				par = getParametros(simulacion);
				thisOxigenoDisuelto.coefDifusion = par.difusionOD; %m2/s (Steinberger 1999)
				thisOxigenoDisuelto.concSaturacion = par.saturacionOD; % kg/m3
				thisOxigenoDisuelto = asignaFlujosVerticales(thisOxigenoDisuelto, simulacion, solucion);	
			end %if

		end % OxigenoDisuelto

		function thisOxigenoDisuelto = asignaFlujosVerticales(thisOxigenoDisuelto, simulacion, solucion)

			par = getParametros(simulacion);
			forza = getForzante(simulacion);
	
			if ~strcmpi(class(forza), 'vientouniforme')

				error(['Los flujos verticales de OD están caracetrizados para un', ... 
				      ' forzante de tipo VientoUniforme'])

			end

			uAsterisco = getUAsterisco(forza);		
			difOD = thisOxigenoDisuelto.coefDifusion;
			satOD = thisOxigenoDisuelto.concSaturacion;
			kappa = par.kappaVonKarman;
			rho = par.densidadRho;
			rhoAire = par.densidadAire;
			nuAgua = par.viscosidadNu;
			phiPorosidad = 	par.porosidadPhi;
			Ds = phiPorosidad*difOD; % (Bryant 2010)

			% Necesito calcular el numero de Reynolds del flujo
			% por lo tanto necesitare especificar la solucion

			bat = getBatimetria(simulacion);
			heta = bat.hoNodosEta;
			[eta u v] = getEtaUV(simulacion, solucion);
			modV = sqrt(u.^2 + v.^2); %m/s
			numeroReynolds = modV.*(heta + eta)/nuAgua;

			uAsteriscoAire = uAsterisco*sqrt(rho/rhoAire);
			numeroSc = nuAgua/difOD;

			kt = 27.08*uAsterisco*numeroSc^(-2/3)./(numeroReynolds);
			erre = 1/86400;
			S = 2*phiPorosidad*erre*Ds; % kg/m/s

			% Ecuaciones que caracterizan flujo de OD hacia sedimentos (Nakamura & Stefan, 1994)	
			funcionFlujoSed = inline('S/2*(k.^(-1) - sqrt(k.^(-2) + 4*C/S))','S','k','C');
			dFuncionFlujosed = inline('-1./sqrt(k.^(-2) + 4.*C/S)','S','k','C');  

			%% Flujo Atmósfera
			zeo = 1e-5; % metros Ro 2006
			u10 = uAsteriscoAire*log(10/zeo)/kappa; 
			kl = (170.6*numeroSc^(-0.5)*u10^(1.81)*sqrt(rhoAire/rho))*2.78e-6; %m/s (Ro, 2007)
			% Ecuación que caracteriza flujo de OD hacia atmósfera 
			funcionFlujoAtm = inline('kl*(satOD - C)','kl', 'satOD', 'C');

			flujoSed.kt = kt;
			flujoSed.S = S;
			flujoSed.funcion = funcionFlujoSed;
			flujoSed.dFuncion = dFuncionFlujosed;

			flujoAtm.kl = kl;
			flujoAtm.satOD = satOD;
			flujoAtm.funcion = funcionFlujoAtm;

			flujosVerticales.flujoSed = flujoSed;
			flujosVerticales.flujoAtm = flujoAtm;

			thisOxigenoDisuelto.FlujosVerticales = flujosVerticales;
			% keyboard
		end % function asignaFlujosVerticales
	
		function f0VF = F0VF(thisOxigenoDisuelto, concentracion)

			fVert = thisOxigenoDisuelto.FlujosVerticales; 

			if isempty(fVert)
	
				f0VF = zeros(length(concentracion), 1);	

			else
				
				fSed = fVert.flujoSed;
				fAtm = fVert.flujoAtm;
				kl = fAtm.kl;
				satOD = fAtm.satOD;
				S = fSed.S;
				kt = fSed.kt;
				f0VF = kl*satOD*ones(length(concentracion),1) ...
				       + fSed.funcion(S, kt, concentracion) ...
				       - fSed.dFuncion(S, kt, concentracion).*concentracion;

			end

		end % function F0VF

		function f1VF = F1VF(thisOxigenoDisuelto, concentracion)

			fVert = thisOxigenoDisuelto.FlujosVerticales; 

			if isempty(fVert)
	
				f1VF = zeros(length(concentracion), 1);	

			else

				fSed = fVert.flujoSed;
				fAtm = fVert.flujoAtm;
				kl = fAtm.kl;
				S = fSed.S;
				kt = fSed.kt;
				f1VF = fSed.dFuncion(S, kt, concentracion) - kl;

			end

		end % function F1VF

		function errorVF = errorVolFinitos(thisOxigenoDisuelto, simulacion, cKMas, cK)

			fVert = thisOxigenoDisuelto.FlujosVerticales; 

			if isempty(fVert)
	
				errorVF = sqrt(sum(abs(cKMas - cK).^2));

			else
				
				nEta = getNumeroNodos(simulacion);
				[dx dy] = getDeltaX(simulacion);
				fSed = fVert.flujoSed;
				fAtm = fVert.flujoAtm;
				
				flujoSed = sum(fSed.funcion(fSed.S, fSed.kt, cKMas)*dx*dy)/(nEta*dx*dy);
				flujoAtm = sum(fAtm.funcion(fAtm.kl, fAtm.satOD, cKMas)*dx*dy)/(nEta*dx*dy);
				errorVF = abs(flujoSed +  flujoAtm);

			end

		end % function errorVolFinitos
		
		function cTilde = cMezclaCompleta(masa)

			cSat = masa.concSaturacion;
			cPos = 0:cSat/100:cSat;

			fSed = masa.FlujosVerticales.flujoSed;
			fAtm = masa.FlujosVerticales.flujoAtm;
			S = fSed.S;
			kt = fSed.kt;
			kl = fAtm.kl;

			for iC = 1:length(cPos)
				flujoPos(iC) = fSed.funcion(S,mean(kt), cPos(iC)) +  ... 
					       fAtm.funcion(kl, cSat, cPos(iC));	
			end

			cTilde = linterp(-flujoPos, cPos, 0);

		end % cMezclaCompleta

		function coefDifusion = getCoefDifusion(thisOxigenoDisuelto)

			coefDifusion = thisOxigenoDisuelto.coefDifusion;

		end % getCoefDifusion

		function csat = getSaturacion(thisOxigenoDisuelto)

			csat = thisOxigenoDisuelto.concSaturacion;

		end % getSaturacion
		
		function flujosVert = getFlujosVerticales(thisOxigenoDisuelto)

			flujosVert = thisOxigenoDisuelto.FlujosVerticales;

		end % getFlujosVerticales






	end %methods
end %classdef



%%%%%%%%%%%%%%%% THRASH

	

%			%% Datos hidrodinámicos
%			% Esfuerzo de corte promedio (uniforme)
%			tauprom = sqrt(tausy^2 + tausx^2); %VER TEMA DE SIGNO

%%			%% Flujo Sedimentos
%%			rho = 1000; %kg/m3
%%			rho_a = 1.2; %kg/m3
%%			kap = 0.41;
%%			nu = 1.15e-6; %m2/s
%% 			phi = 0.9;  % (Bryant 2010)

%			
%			% erre = 2/86400; % kg/m3/s  %r entre 0.1 y 1 kg/m3/dia
%			CSat = 8.82*0.001; % kg/m3

