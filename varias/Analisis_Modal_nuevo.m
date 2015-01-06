% Rodrigo Pérez I.
% Rutina que permite correr el Análisis Modal de Shimizu.

inicioam = 1
% tic

%A = matricesAdimensionales.K + matricesAdimensionales.C;
%M = matricesAdimensionales.M;

b = matricesAdimensionales.f;


%Ap = -A*sqrt(-1);
%1
%[vr,dr]=eig(full(Ap),full(M));
vr = vectoresPropios.derechos;
dr = valoresPropios.derechos;
vl = vectoresPropios.izquierdos;
dl = valoresPropios.izquierdos;
%1
%[vl,dl]=eig(full(Ap'),full(M));

% vrp = vr;
% vlp = vl;

% drp = diag(dr);
% dlp = diag(dl);

flag = 1e-8;

drp2 = diag(dr);
dlp2 = diag(dl);

vrp2 = vr;
vlp2 = vl;

omegadr = quant(real(drp2),flag);
gammadr = quant(imag(drp2),flag);

drp2 = omegadr + sqrt(-1)*gammadr;

omegadl = quant(real(dlp2),flag);
gammadl = quant(imag(dlp2),flag);

dlp2 = omegadl - sqrt(-1)*gammadl;

fdiagcero = find(abs(drp2) <= flag);
fsincero = 1:length(drp2);
fsincero(fdiagcero) = [];

mvr = M*vrp2;
mvrc = M*conj(vrp2);
mvl = M*vlp2;
mvlc = M*conj(vlp2);

% ftilde = sparse(zeros(length(vlp2),1));
% etilde = ftilde;

% Para + r
	% for i = 1:length(vlp2)
	% 	ftilde(i) = vlp2(:,i)'*b;
	% 	etilde(i) = vlp2(:,i)'*mvr(:,i);
	% end

ftilde = dot(vlp2,repmat(b,1,length(vlp2)));
ftilde = ftilde.';
etilde = dot(vlp2,mvr);
etilde = etilde.';

iomegamenosgamma = sqrt(-1)*omegadr - gammadr;
atilde = -ftilde(fsincero)./(iomegamenosgamma(fsincero).*etilde(fsincero));
atilde2 = zeros(length(atilde)+length(fdiagcero),1);
atilde2(fsincero) = atilde;


ftilderm = ftilde;
etilderm = ftilde;

for i = 1:length(vlp2)
	ftilderm(i) = vlp2(:,i).'*b;
	etilderm(i) = vlp2(:,i).'*mvrc(:,i);
end

%ftilderm = dot(vlp2,repmat(b,1,length(vlp2)));
%ftilderm = conj(ftilderm);
%ftilderm = ftilderm.';
%etilde = dot(vlp2,mvrc);
%ftilderm = conj(ftilderm);
%etilde = etilde.';


iomegamenosgammarm = -sqrt(-1)*omegadr - gammadr;
atilderm = -ftilderm(fsincero)./(iomegamenosgammarm(fsincero).*etilderm(fsincero));
atilde2rm = zeros(length(atilderm)+length(fdiagcero),1);
atilde2rm(fsincero) = atilderm;

% Sumatoria
SOLam = zeros(length(vrp2),1);
Chivsmod = sparse(zeros(length(vrp2),length(atilde2)));
% uvsmod = sparse(zeros(Neta,length(vrp2(1,:))));
% vvsmod = sparse(zeros(Neta,length(vrp2(1,:))));


for i = 1:length(vrp2)
   	Chivsmod(:,i) = real(atilde2(i)*vrp2(:,i)); % Valores para +r y -r están todos incluidos en atilde2.
    	SOLam = SOLam + Chivsmod(:,i);
end

%mchi = M*Chivsmod;
%Etvsmod = sum(Chivsmod.*mchi)/4;
%Epvsmod = sum(Chivsmod(1:Neta,:).*mchi(1:Neta,:))/4;
%Ekvsmod = sum(Chivsmod(Neta:end,:).*mchi(Neta:end,:))/4;

clear mvr mvrc

finam = 1



