% Rodrigo Pérez I.

clear all 
close all

set(0,'DefaultAxesFontName', 'times')
set(0,'DefaultAxesFontSize', 9)

set(0,'DefaultTextFontname', 'times')
set(0,'DefaultTextFontSize', 9)


%% Datos del Problema

g = 9.81;
rho = 1000;
uvtilde = 0.035; %de la Fuente 2013
kap = 0.41;
zo = 0.0028; %Liang 06
cfprim = inline('sqrt(ut^2 + vt^2)*(kap./(1 + log(zo./h))).^2','kap','zo','h','ut','vt'); %Liang 06
uast = 0.0066; % a partir de de la Fuente 2013
tausx = 0; % positivo hacia la derecha. Puede ser vector columna
tausy = rho*uast^2; % positivo hacia arriba. Puede ser vector columna

%% Geometría de la superficie

genera_borde

%% Discretización
 
lx = abs(max(xgeodat)-min(xgeodat));
ly = abs(max(ygeodat)-min(ygeodat));
dx = max(lx,ly)/20;
dy = dx;

%% Malla y Matrices

genera_malla
genera_bat_kranenburg
genera_matrices

Analisis_Modal_nuevo
eta = get_eta(SOLam,Neta);
u = uvsmod(:,end);
v = vvsmod(:,end);
grafica_eta(coordeta(:,1), coordeta(:,2), dx, dy, xgeodat, ygeodat, eta, u, v, Ineta)


    
    
