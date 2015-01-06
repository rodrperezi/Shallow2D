function volumenesFinitos = VolumenesFinitos(cuerpo, soluciones, dispersion)

%% Datos hidrodinámicos
% keyboard
	if(strcmpi(cuerpo.Forzante.tipoForzante, 'vientoUniforme'))
		
		if(strcmpi(cuerpo.Forzante.parametroCaracteristico1,'uasterisco'))		
			uAsterisco = cuerpo.Forzante.valorParametroCaracteristico1;
			anguloViento = cuerpo.Forzante.valorParametroCaracteristico2;
		elseif(strcmpi(cuerpo.Forzante.parametroCaracteristico1,'anguloViento'))		
			uAsterisco = cuerpo.Forzante.valorParametroCaracteristico2;
			anguloViento = cuerpo.Forzante.valorParametroCaracteristico1;
		else
			error('myapp:Chk','Algun error en los nombres de los parametros')
		end
	else
		error('myapp:chk', 'Falta programar este forzante para volumenes finitos')
	end


	
%% Parametros para el transporte de OD

	parametros = cuerpo.Parametros;
	rho = parametros.densidadRho;
	rho_a = parametros.densidadAire;
	kap = parametros.kappaVonKarman;
	nu = parametros.viscosidadNu;
	D = parametros.difusionOD;
	phi = parametros.porosidadPhi;
	CSat = parametros.saturacionOD;
	zeo = 0.01; % m
	Ds = phi*D; % (Bryant 2010)
	erre = 2/86400; % kg/m3/s  %r entre 0.1 y 1 kg/m3/dia

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	u = soluciones.solucionU;
	v = soluciones.solucionV;
	modV = sqrt(u.^2 + v.^2); %m/s
	
	% ucwater = sqrt(tauprom/rho); %m/s
	ucwater = uAsterisco; %m/s  
	ucair = ucwater*sqrt(rho/rho_a);
	Sc = nu/D;

	% Ecuaciones que caracterizan flujo de OD hacia sedimentos (Nakamura & Stefan, 1994)	
	S = 2*phi*erre*Ds; % kg/m/s

	heta = cuerpo.Geometria.batimetriaKranenburg.hoEta;
	eta = soluciones.solucionEta;
	% keyboard
	numeroReynolds = modV.*(heta + eta)/nu;
	kt = ucwater*min(27.08*Sc^(-2/3)./numeroReynolds,1/20); % m/s de la Fuente et al. 2014
	% keyboard
	Fsed = inline('S/2*(k.^(-1) - sqrt(k.^(-2) + 4*C/S))','S','k','C'); % C es el 
	dFsed = inline('-1./sqrt(k.^(-2) + 4.*C/S)','S','k','C');  

%% Flujo Atmósfera
	u10 = ucair*log(10/zeo)/kap; %Si uast es vector, entonces U10 debería ser vector. (variabilidad espacial de esfuerzo de corte)
	kl = (170.6*Sc^-0.5*u10^1.81*sqrt(rho_a/rho))*2.78e-6; %m/s (Ro, 2007)

	% Ecuación que caracteriza flujo de OD hacia atmósfera 
	Fatm = inline('kl*(CSat - C)','kl','CSat','C');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Coeficientes de Dispersion (Holly, 1984). Interpolaciones para eta.
	mallaStaggered = getMalla(cuerpo);
	mallaStaggered = mallaStaggered.InformacionMalla;	
	
	Neta = length(mallaStaggered.coordenadasEta);
	Nns = length(mallaStaggered.coordenadasU);
	New = length(mallaStaggered.coordenadasV);
	IDwe = mallaStaggered.IDwe;
	IDns = mallaStaggered.IDns;	
	IDetaC = mallaStaggered.IDC;	
	howe =  cuerpo.Geometria.batimetriaKranenburg.hoU;     
	hons =  cuerpo.Geometria.batimetriaKranenburg.hoV;	

	dx = cuerpo.Geometria.deltaX;
	dy = cuerpo.Geometria.deltaY;

	nBIz = mallaStaggered.numeroBordesIzquierdo;
	nBDe = mallaStaggered.numeroBordesDerecho;
	nBSu = mallaStaggered.numeroBordesSuperior;
	nBIn = mallaStaggered.numeroBordesInferior;
	
	SOL = soluciones.solucionCompleta;
	
	coeficientesDispersion

	if(strcmpi(dispersion, 'sinDispersion'))
		kxxwe = kxxwe*0;
		kyyns = kyyns*0;
	end

%% Métodos de resolución
	esquemaLeyDePotencia
	volumenesFinitos.concentracionEta = C_VF;
	volumenesFinitos.numeroPeclet = numeroPeclet;

