% Rodrigo Pérez I. 
% Volúmenes Finitos (con esquema ley de potencia) para resolver transporte de OD.
% Los términos fuente están linealizados.

%% Coeficientes

	etawe = etawe*0;
	etans = etans*0;

	% m3/s
	De = [howe(IDwe(:,2)) + etawe(IDwe(:,2))].*kxxwe(IDwe(:,2))*dy/(0.5*dx);
	Dw = [howe(IDwe(:,1)) + etawe(IDwe(:,1))].*kxxwe(IDwe(:,1))*dy/(0.5*dx);
	Ds = [hons(IDns(:,2)) + etans(IDns(:,2))].*kyyns(IDns(:,2))*dx/(0.5*dy);
	Dn = [hons(IDns(:,1)) + etans(IDns(:,1))].*kyyns(IDns(:,1))*dx/(0.5*dy);

	%m3/s
	Fe = [howe(IDwe(:,2)) + etawe(IDwe(:,2))].*uaux(IDwe(:,2))*dy; 
	Fw = [howe(IDwe(:,1)) + etawe(IDwe(:,1))].*uaux(IDwe(:,1))*dy;
	Fs = [hons(IDns(:,2)) + etans(IDns(:,2))].*vaux(IDns(:,2))*dx;
	Fn = [hons(IDns(:,1)) + etans(IDns(:,1))].*vaux(IDns(:,1))*dx;

	aE = De.*max(0,(1-0.1*abs(Fe./De)).^5) + max(0,-Fe);
	aW = Dw.*max(0,(1-0.1*abs(Fw./Dw)).^5) + max(0,Fw);
	aN = Dn.*max(0,(1-0.1*abs(Fn./Dn)).^5) + max(0,-Fn);
	aS = Ds.*max(0,(1-0.1*abs(Fs./Ds)).^5) + max(0,Fs);

	IDetaCaux = IDetaC; % Nodos eta: W, E, E+1, S, N, N+1

	% Condiciones de Borde
	aE(nBDe) = 0; IDetaCaux(nBDe,2) = 1;
	aW(nBIz) = 0; IDetaCaux(nBIz,1) = 1;
	aN(nBSu) = 0; IDetaCaux(nBSu,5) = 1;
	aS(nBIn) = 0; IDetaCaux(nBIn,4) = 1;

	% Adivinanza Inicial (concentración uniforme e igual a Saturación)

	Ci = ones(Neta,1)*CSat;
	C_VF = Ci;
	Ck = 10*Ci;
	kvf = 1;

	Fsedprom = 0;
	Fatmprom = 10;

	% Iteraciones hasta convergencia

	while abs(Fsedprom + Fatmprom) > eps
		Ck = C_VF;
		% pause	
		% keyboard
		Fo = kl*CSat*ones(Neta,1) + Fsed(S,kt,Ck) - dFsed(S,kt,Ck).*Ck; %kg/m2/s
		F1 = dFsed(S,kt,Ck) - kl; %m/s
		bvf = Fo*dx*dy; %kg/s
		aP = aE + aW + aN + aS - F1*dx*dy + Fe - Fw + Fn - Fs;
		generaMatricesVolumenesFinitos
		% keyboard
		C_VF = G\bvf;
		fcm = find(C_VF<=0);
		C_VF(fcm) = 0;
		kvf = kvf + 1;
		Fsedprom = sum(Fsed(S,kt,C_VF)*dx*dy)/(Neta*dx*dy);
		Fatmprom = sum(Fatm(kl,CSat,C_VF)*dx*dy)/(Neta*dx*dy);
		% pause
		
	end 

% Calculo de Ctilde
concentracionesPosibles = 0:CSat/100:CSat;

for iC = 1:length(concentracionesPosibles)
	Fanapos(iC) = Fsed(S,mean(kt), concentracionesPosibles(iC)) + Fatm(kl,CSat,concentracionesPosibles(iC));	
end

concentracionTilde = linterp(-Fanapos, concentracionesPosibles, 0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R = cuerpo.Geometria.radioKranenburg;
% keyboard
numeroPeclet = modV.*(heta + eta)/(2*R*abs(dFsed(S,mean(kt),concentracionTilde) - kl));

% full(modV.*(heta + eta)/(2*R*abs(dFsed(S,mean(kt),Canalitico) - kl)))

% t_VF = toc;

% Fsedprom = sum(Fsed(S,kt,C_VF)*dx*dy)/(Neta*dx*dy);
% Fatmprom = sum(Fatm(kl,CSat,C_VF)*dx*dy)/(Neta*dx*dy);
% C_prom = mean(C_VF);




