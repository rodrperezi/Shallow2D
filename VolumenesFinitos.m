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


						% For que itera sonbre el tiempo
	
						tiempo = solHidro.Tiempo;

						for iT = 1: length(tiempo)
							% actualizar coeficientes de dispersion
							thisVolumenesFinitos = coeficientesDispersion(thisVolumenesFinitos, simulacion, solHidro.Solucion(:,iT));
							% actualizar numero de Peclet o resolver esquema ley de potencia
							thisVolumenesFinitos = leyDePotencia(thisVolumenesFinitos, simulacion, solHidro.Solucion(:,iT));
							% itera los volumenes finitos
							% thisVolumenesFinitos = iteraVolFinitos();

						end %for

					else
						error(['Regimen temporal ', solHidro.RegimenTemporal ,' no definido'])
					end
					%%%%
					thisVolumenesFinitos.tiempoComputo = toc;
				end %if
			end %if
		end %VolumenesFinitos

		function thisVolumenesFinitos = coeficientesDispersion(thisVolumenesFinitos, simulacion, solucion)
			% falta definir el uasterisco
			% Extraigo parametros para calculo de los coeficientes
			parametros = getParametros(simulacion);
			malla = getMalla(simulacion);	
			bat = getBatimetria(simulacion);
		
			howe = bat.hoNodosU;
			hons = bat.hoNodosV;

			eL = parametros.coefLong;
			eT = parametros.coefTrans;

			[eta, u, v] = getEtaUV(simulacion, solucion);
			[Neta Nu Nv] = getNumeroNodos(simulacion);

			IDwe = malla.matrizIDwe;
			IDns = malla.matrizIDns;
			IDuwe = zeros(nU,2);
			IDvns = zeros(nV,2);

			nBDe = malla.numeroBordesDerecho;
			nBIz = malla.numeroBordesIzquierdo;
			nBSu = malla.numeroBordesSuperior;
			nBIn = malla.numeroBordesInferior;

			% Velocidades auxiliares para cálculo de ángulo de linea
			% de corriente. El ángulo de la linea de corriente 
			% con respecto al eje de coordenadas fijo (x,y)
			% se calcula como el arcotangente entre las 
			% componentes de la velocidad en cada nodo. Como 
			% necesito conocer el ángulo en los nodos de velocidad
			% entonces hay que promediar las velocidades "v" para 
			% nodos "u" y lo mismo para los nodos "v" pero promediando
			% las velocidades en los nodos "u".

			% Vectores para almacenar velocidades promedio
			% También necesito promediar las deformaciones de la 
			% superficie libre hacia los nodos de velocidad
			% para calcular los coeficientes de dispersion

			Vuaux = zeros(Nu,1);
			Uvaux = zeros(Nv,1);
			etawe = Vuaux;
			etans = Uvaux;
			uaux = sparse(zeros(Nu,1));
			vaux = sparse(zeros(Nv,1));

			ku = 1;
			kv = 1;

			% for para promediar velocidades v para los nodos u
			for iNU = 1:Nu

				% busca el nodo en la matriz de oeste este
				[filaid colid] = find(iNU == IDwe);
				filaid = sort(filaid);
	
				if(sum(iNU == IDwe(nBIz,1)) ~= 0);	
					% Si el nodo es borde izquierdo
					IDuwe(iNU,2) = filaid;
				elseif(sum(iNU == IDwe(nBDe,2)) ~= 0);	
					% Si el nodo es borde derecho
					IDuwe(iNU,1) = filaid;
				else
					% Si el nodo no es borde
					IDuwe(iNU,:) = filaid'; %Nodo eta W, E
					% velocidad "v" promedio en nodo "u" es 
					% el promedio entre las velocidades "v"
					% que han sido promediadas a lso nodos eta
					% almacenadas en el vector "v"
					Vuaux(iNU) = mean(v(IDuwe(iNU,:)));
					etawe(iNU) = mean(eta(IDuwe(iNU,:)));
				end %if

				% almaceno velocidades u de los nodos
				if(sum(iNU == [IDwe(nBIz,1);IDwe(nBDe,2)])==0);
				       	uaux(iNU) = solucion(Neta + ku); 
				       	ku = ku+1;
				end %if
			end %for

			% for para promediar velocidades u para los nodos v
			for iNV = 1:Nv

				[filaid colid] = find(iNV == IDns);
				filaid = sort(filaid);
	
				if(sum(iNV == IDns(nBSu,1))~=0);	
					IDvns(iNV,2) = filaid;
				elseif(sum(iNV == IDns(nBIn,2))~=0);	
					IDvns(iNV,1) = filaid;
				else
					IDvns(iNV,:) = filaid'; %Nodo eta N, S
					Uvaux(iNV) = mean(u(IDvns(iNV,:)));
					etans(iNV) = mean(eta(IDvns(iNV,:)));
				end %if

				if(sum(iNV == [IDns(nBSu,1);IDns(nBIn,2)])==0);
					vaux(iNV) = solucion(Neta + kv + Nu - length([IDwe(nBIz,1);IDwe(nBDe,2)]));
				       	kv= kv+1;
				end %if
		      
			end %for

			thetawe = atan2(Vuaux, uaux);
			f1 = find(thetawe <= 0);
			thetawe(f1) = thetawe(f1) + 2*pi;

			thetans = atan2(vaux, Uvaux);
			f2 = find(thetans <= 0);
			thetans(f2) = thetans(f2) + 2*pi;

			coefDispersion.kxxwe = uast.*[howe + etawe].*(eL*cos(thetawe).^2 + eT*sin(thetawe).^2);
			coefDispersion.kyyns = uast.*[hons + etans].*(eL*sin(thetans).^2 + eT*cos(thetans).^2);
			velocidades.velU = uaux;
			velocidades.velV = vaux;
			thisVolumenesFinitos.coefDispersion = coefDispersion;
			thisVolumenesFinitos.velocidades = velocidades;

		end % function coeficientesDispersion

		function thisVolumenesFinitos = leyDePotencia(thisVolumenesFinitos, simulacion, solucion)
			% no he definido uaux vaux
			malla = getMalla(simulacion);
			bat = getBatimetria(simulacion);
			howe = bat.hoNodosU;
			hons = bat.hoNodosV;

			nBDe = malla.numeroBordesDerecho;
			nBIz = malla.numeroBordesIzquierdo;
			nBSu = malla.numeroBordesSuperior;
			nBIn = malla.numeroBordesInferior;

			kxxwe = thisVolumenesFinitos.coefDipersion.kxxwe;
			kyyns = thisVolumenesFinitos.coefDipersion.kyyns;
			uaux = thisVolumenesFinitos.velocidades.velU;
			vaux = thisVolumenesFinitos.velocidades.velV;

			[dx dy] = getDeltaX(simulacion);

			% m3/s
			De = [howe(IDwe(:,2))].*kxxwe(IDwe(:,2))*dy/dx;
			Dw = [howe(IDwe(:,1))].*kxxwe(IDwe(:,1))*dy/dx;
			Ds = [hons(IDns(:,2))].*kyyns(IDns(:,2))*dx/dy;
			Dn = [hons(IDns(:,1))].*kyyns(IDns(:,1))*dx/dy;

			%m3/s
			Fe = [howe(IDwe(:,2))].*uaux(IDwe(:,2))*dy; 
			Fw = [howe(IDwe(:,1))].*uaux(IDwe(:,1))*dy;
			Fs = [hons(IDns(:,2))].*vaux(IDns(:,2))*dx;
			Fn = [hons(IDns(:,1))].*vaux(IDns(:,1))*dx;

			aE = De.*max(0,(1-0.1*abs(Fe./De)).^5) + max(0,-Fe);
			aW = Dw.*max(0,(1-0.1*abs(Fw./Dw)).^5) + max(0,Fw);
			aN = Dn.*max(0,(1-0.1*abs(Fn./Dn)).^5) + max(0,-Fn);
			aS = Ds.*max(0,(1-0.1*abs(Fs./Ds)).^5) + max(0,Fs);
			IDetaC = malla.matrizIDetaC; % Nodos eta: W, E, S, N

			% Condiciones de Borde
			aE(nBDe) = 0; IDetaC(nBDe,2) = 1;
			aW(nBIz) = 0; IDetaC(nBIz,1) = 1;
			aN(nBSu) = 0; IDetaC(nBSu,4) = 1;
			aS(nBIn) = 0; IDetaC(nBIn,3) = 1;

			coefTransporte.aE = aE;
			coefTransporte.aW = aW;
			coefTransporte.aN = aN;
			coefTransporte.aS = aS;
			thisVolumenesFinitos.coefTransporte = coefTransporte;	
			thisVolumenesFinitos.IDetaC = IDetaC;

		end % function leyDePotencia

%		function 

%		end
		


	end %methods
end %classdef

%%%%%%%%%%%%%%%%%%%%%%%%% THRASH


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

