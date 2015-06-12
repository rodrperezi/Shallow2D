classdef VolumenesFinitos < TransporteOD

	properties

		tiempoComputo	

	end %properties

	methods
		
		function thisVolumenesFinitos = VolumenesFinitos(simulacion)

			if nargin == 0
				thisVolumenesFinitos;
			else 
			
				if isempty(simulacion.Resultados) 
				% if isempty(simulacion.Resultados) || isempty(simulacion.Resultados.Hidrodinamica)
						
					error(['La simulacion aún no tiene resuelta la Hidrodinámica'])
				
				else
					tic
					%%%% Aqui se aplica la resolucion
					solHidro = getHidrodinamica(simulacion);
			
					% Veo el regimenTemporal de la solucion
					% si es permanente, entonces resuelvo
					% el transporte de OD permanente. Si es
					% impermanente, resuelvo el transporte
					% impermanente.					

					if strcmpi(solHidro.RegimenTemporal, 'permanente')
						% resuelve VF permanente
						% Los volumenes finitos para el transporte de OD	
						% con flujos verticales entre agua y sedimentos 
						% solo pueden ser resueltos para el caso en que 
						% el forzante es un viento uniforme, puesto que 
						% la parametrizacion de los flujos utiliza el 
						% parametro uAsterisco. 

					elseif strcmpi(solHidro.RegimenTemporal, 'impermanente')
						% resuelve VF impermanente
						% ARREGLAR LO DEL UASTERISCO EN LOS 
						% COEFICIENTES DE DISPERSION

					else
						error(['Regimen temporal ', solHidro.RegimenTemporal ,' no definido'])
					end
					%%%%
					thisVolumenesFinitos.tiempoComputo = toc;
				end %if
			end %if
		end %VolumenesFinitos

%		function 

		%	
			%%% Parametros para el transporte de OD

			%	parametros = cuerpo.Parametros;
			%	rho = parametros.densidadRho;
			%	rho_a = parametros.densidadAire;
			%	kap = parametros.kappaVonKarman;
			%	nu = parametros.viscosidadNu;
			%	D = parametros.difusionOD;
			%	phi = parametros.porosidadPhi;
			%	CSat = parametros.saturacionOD;
			%	zeo = 0.01; % m
			%	Ds = phi*D; % (Bryant 2010)
			%	erre = 2/86400; % kg/m3/s  %r entre 0.1 y 1 kg/m3/dia

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			%	u = soluciones.solucionU;
			%	v = soluciones.solucionV;
			%	modV = sqrt(u.^2 + v.^2); %m/s
			%	
			%	% ucwater = sqrt(tauprom/rho); %m/s
			%	ucwater = uAsterisco; %m/s  
			%	ucair = ucwater*sqrt(rho/rho_a);
			%	Sc = nu/D;

			%	% Ecuaciones que caracterizan flujo de OD hacia sedimentos (Nakamura & Stefan, 1994)	
			%	S = 2*phi*erre*Ds; % kg/m/s

			%	heta = cuerpo.Geometria.batimetriaKranenburg.hoEta;
			%	eta = soluciones.solucionEta;
			%	% keyboard
			%	numeroReynolds = modV.*(heta + eta)/nu;
			%	kt = ucwater*min(27.08*Sc^(-2/3)./numeroReynolds,1/20); % m/s de la Fuente et al. 2014
			%	% keyboard
			%	Fsed = inline('S/2*(k.^(-1) - sqrt(k.^(-2) + 4*C/S))','S','k','C'); % C es el 
			%	dFsed = inline('-1./sqrt(k.^(-2) + 4.*C/S)','S','k','C');  

			%%% Flujo Atmósfera
			%	u10 = ucair*log(10/zeo)/kap; %Si uast es vector, entonces U10 debería ser vector. (variabilidad espacial de esfuerzo de corte)
			%	kl = (170.6*Sc^-0.5*u10^1.81*sqrt(rho_a/rho))*2.78e-6; %m/s (Ro, 2007)

			%	% Ecuación que caracteriza flujo de OD hacia atmósfera 
			%	Fatm = inline('kl*(CSat - C)','kl','CSat','C');

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			%%% Coeficientes de Dispersion (Holly, 1984). Interpolaciones para eta.
			%	mallaStaggered = getMalla(cuerpo);
			%	mallaStaggered = mallaStaggered.InformacionMalla;	
			%	
			%	Neta = length(mallaStaggered.coordenadasEta);
			%	Nns = length(mallaStaggered.coordenadasU);
			%	New = length(mallaStaggered.coordenadasV);
			%	IDwe = mallaStaggered.IDwe;
			%	IDns = mallaStaggered.IDns;	
			%	IDetaC = mallaStaggered.IDC;	
			%	howe =  cuerpo.Geometria.batimetriaKranenburg.hoU;     
			%	hons =  cuerpo.Geometria.batimetriaKranenburg.hoV;	

			%	dx = cuerpo.Geometria.deltaX;
			%	dy = cuerpo.Geometria.deltaY;

			%	nBIz = mallaStaggered.numeroBordesIzquierdo;
			%	nBDe = mallaStaggered.numeroBordesDerecho;
			%	nBSu = mallaStaggered.numeroBordesSuperior;
			%	nBIn = mallaStaggered.numeroBordesInferior;
			%	
			%	SOL = soluciones.solucionCompleta;
			%	
			%	coeficientesDispersion

			%	if(strcmpi(dispersion, 'sinDispersion'))
			%		kxxwe = kxxwe*0;
			%		kyyns = kyyns*0;
			%	end

			%%% Métodos de resolución
			%	esquemaLeyDePotencia
			%	volumenesFinitos.concentracionEta = C_VF;
			%	volumenesFinitos.numeroPeclet = numeroPeclet;

%		end



%		function leyDePotencia

			%% Rodrigo Pérez I. 
			%% Volúmenes Finitos (con esquema ley de potencia) para resolver transporte de OD.
			%% Los términos fuente están linealizados.

			%%% Coeficientes

			%	etawe = etawe*0;
			%	etans = etans*0;

			%	% m3/s
			%	De = [howe(IDwe(:,2)) + etawe(IDwe(:,2))].*kxxwe(IDwe(:,2))*dy/(0.5*dx);
			%	Dw = [howe(IDwe(:,1)) + etawe(IDwe(:,1))].*kxxwe(IDwe(:,1))*dy/(0.5*dx);
			%	Ds = [hons(IDns(:,2)) + etans(IDns(:,2))].*kyyns(IDns(:,2))*dx/(0.5*dy);
			%	Dn = [hons(IDns(:,1)) + etans(IDns(:,1))].*kyyns(IDns(:,1))*dx/(0.5*dy);

			%	%m3/s
			%	Fe = [howe(IDwe(:,2)) + etawe(IDwe(:,2))].*uaux(IDwe(:,2))*dy; 
			%	Fw = [howe(IDwe(:,1)) + etawe(IDwe(:,1))].*uaux(IDwe(:,1))*dy;
			%	Fs = [hons(IDns(:,2)) + etans(IDns(:,2))].*vaux(IDns(:,2))*dx;
			%	Fn = [hons(IDns(:,1)) + etans(IDns(:,1))].*vaux(IDns(:,1))*dx;

			%	aE = De.*max(0,(1-0.1*abs(Fe./De)).^5) + max(0,-Fe);
			%	aW = Dw.*max(0,(1-0.1*abs(Fw./Dw)).^5) + max(0,Fw);
			%	aN = Dn.*max(0,(1-0.1*abs(Fn./Dn)).^5) + max(0,-Fn);
			%	aS = Ds.*max(0,(1-0.1*abs(Fs./Ds)).^5) + max(0,Fs);

			%	IDetaCaux = IDetaC; % Nodos eta: W, E, E+1, S, N, N+1

			%	% Condiciones de Borde
			%	aE(nBDe) = 0; IDetaCaux(nBDe,2) = 1;
			%	aW(nBIz) = 0; IDetaCaux(nBIz,1) = 1;
			%	aN(nBSu) = 0; IDetaCaux(nBSu,5) = 1;
			%	aS(nBIn) = 0; IDetaCaux(nBIn,4) = 1;

			%	% Adivinanza Inicial (concentración uniforme e igual a Saturación)

			%	Ci = ones(Neta,1)*CSat;
			%	C_VF = Ci;
			%	Ck = 10*Ci;
			%	kvf = 1;

			%	Fsedprom = 0;
			%	Fatmprom = 10;

			%	% Iteraciones hasta convergencia

			%	while abs(Fsedprom + Fatmprom) > eps
			%		Ck = C_VF;
			%		% pause	
			%		% keyboard
			%		Fo = kl*CSat*ones(Neta,1) + Fsed(S,kt,Ck) - dFsed(S,kt,Ck).*Ck; %kg/m2/s
			%		F1 = dFsed(S,kt,Ck) - kl; %m/s
			%		bvf = Fo*dx*dy; %kg/s
			%		aP = aE + aW + aN + aS- F1*dx*dy + Fe - Fw + Fn - Fs;
			%		generaMatricesVolumenesFinitos
			%		% keyboard
			%		C_VF = G\bvf;
			%		fcm = find(C_VF<=0);
			%		C_VF(fcm) = 0;
			%		kvf = kvf + 1;
			%		Fsedprom = sum(Fsed(S,kt,C_VF)*dx*dy)/(Neta*dx*dy);
			%		Fatmprom = sum(Fatm(kl,CSat,C_VF)*dx*dy)/(Neta*dx*dy);
			%		% pause
			%		
			%	end 

			%% Calculo de Ctilde
			%concentracionesPosibles = 0:CSat/100:CSat;

			%for iC = 1:length(concentracionesPosibles)
			%	Fanapos(iC) = Fsed(S,mean(kt), concentracionesPosibles(iC)) + Fatm(kl,CSat,concentracionesPosibles(iC));	
			%end

			%concentracionTilde = linterp(-Fanapos, concentracionesPosibles, 0);
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%R = cuerpo.Geometria.radioKranenburg;
			%% keyboard
			%numeroPeclet = modV.*(heta + eta)/(2*R*abs(dFsed(S,mean(kt),concentracionTilde) - kl));

			%% full(modV.*(heta + eta)/(2*R*abs(dFsed(S,mean(kt),Canalitico) - kl)))

			%% t_VF = toc;

			%% Fsedprom = sum(Fsed(S,kt,C_VF)*dx*dy)/(Neta*dx*dy);
			%% Fatmprom = sum(Fatm(kl,CSat,C_VF)*dx*dy)/(Neta*dx*dy);
			%% C_prom = mean(C_VF);


%		end 
		
		%% function

			%% Rodrigo Pérez I. 
			%% Rutina que genera matrices para el problema de volúmenes finitos
			%% El problema se plantea de la forma G*C = b
			%% IDetaC = zeros(Neta,6); % Nodos eta: W, E, E+1, S, N, N+1

			%fila = (1:Neta)';
			%G = sparse([fila;fila;fila;fila;fila],[fila; IDetaCaux(:,1); IDetaCaux(:,2); IDetaCaux(:,5); IDetaCaux(:,4)], [aP;-aW;-aE;-aN;-aS]);
		%% end

	
	end %methods
end %classdef
