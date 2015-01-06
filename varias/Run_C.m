% Rodrigo Pérez I. 
% Módulo de resolución del problema de transporte de OD en 2D 
% mediante la utilización de volúmenes finitos y del algoritmo de 
% Newton Rapson. 

%% Datos hidrodinámicos
	% Esfuerzo de corte promedio (uniforme)
	tauprom = sqrt(tausy^2 + tausx^2); %VER TEMA DE SIGNO

%% Flujo Sedimentos
	rho = 1000; %kg/m3
	rho_a = 1.2; %kg/m3
	kap = 0.41;
	nu = 1.15e-6; %m2/s
	D = 1.82E-9; %m2/s (Steinberger 1999)
	phi = 0.9;  % (Bryant 2010)
	Ds = phi*D; % (Bryant 2010)
	erre = 2/86400; % kg/m3/s  %r entre 0.1 y 1 kg/m3/dia
	CSat = 8.82*0.001; % kg/m3
	modV = sqrt(u.^2 + v.^2); %m/s
	ucwater = sqrt(tauprom/rho); %m/s   %VER TEMA DE SIGNO
	ucair = ucwater*sqrt(rho/rho_a);
	Sc = nu/D;
 	% kt = ucwater*0.047*(modV.*heta/nu).^(-0.7); % m/s % (Ordonez et al.)
%   	kt = (0.05*ucwater*Sc^(-2/3))*ones(length(heta),1);
	kt = ucwater*min(2.84*(modV.*(heta + eta)/nu).^(-2/3)*Sc^(-2/3),1/20); % m/s % (Ordonez et al.)
	S = 2*phi*erre*Ds; % kg/m/s

	% Ecuaciones que caracterizan flujo de OD hacia sedimentos (Nakamura & Stefan, 1994)	
	Fsed = inline('S/2*(k.^(-1) - sqrt(k.^(-2) + 4*C/S))','S','k','C'); % C es el 
	dFsed = inline('-1./sqrt(k.^(-2) + 4.*C/S)','S','k','C');  

%% Flujo Atmósfera
	zeo = 0.01; % m
	u10 = ucair*log(10/zeo)/kap; %Si uast es vector, entonces U10 debería ser vector. (variabilidad espacial de esfuerzo de corte)
	kl = (170.6*Sc^-0.5*u10^1.81*sqrt(rho_a/rho))*2.78e-6; %m/s (Ro, 2007)

	% Ecuación que caracteriza flujo de OD hacia atmósfera 
	Fatm = inline('kl*(CSat - C)','kl','CSat','C');

%% Coeficientes de Dispersion (Holly, 1984). Interpolaciones para eta.
	k_coef_disp

%% Métodos de resolución

	VFesqleypotencia_invC
% 	grafica_C(coordeta(:,1), coordeta(:,2), dx, dy, xgeodat, ygeodat, C_VF, u, v, Ineta)
% 	Fs2 = Fsedprom;
% 	Fa2 = Fatmprom;
% 	Delta2 = abs(Fs2 + Fa2);
% 	Cp2 = C_prom;
% 	tres2 = t_VF;
	C_max2 = max(C_VF);
	C_min2 = min(C_VF);

	% Cinv = C_VF;

 	% Res2 = [Fs2;Fa2;Delta2;Cp2;tres2;C_max2;C_min2];

	% grafica_C(coordeta(:,1), coordeta(:,2), dx, dy, xgeodat, ygeodat, C_VF, u, v, Ineta)

%	figure	

%	grafica_C(coordeta(:,1), coordeta(:,2), dx, dy, xgeodat, ygeodat, Fsed(S,kt,C_VF), u, v, Ineta)

	% figure

	% grafica_C(coordeta(:,1), coordeta(:,2), dx, dy, xgeodat, ygeodat, Fatm(kl,CSat,C_VF) + Fsed(S,kt,C_VF), u, v, Ineta)

	% Res = [Res1,Res2]


