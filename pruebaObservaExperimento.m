clear all 
close all 

set(0,'DefaultAxesFontName', 'times')
set(0,'DefaultAxesFontSize', 9)

set(0,'DefaultTextFontname', 'times')
set(0,'DefaultTextFontSize', 9)

addpath('/home/rodrigo/Dropbox/Experimentos/MesaOscilatoria/DatosSegunExperimento/Procesador')

% DATOS GEOMETRIA
R = 0.2;
H = 0.03;
centroMasa = [0, 0];

% CONSTRUCCION MODELO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
geoPrueba = construyeKranenburg(Geometria(), R, H, centroMasa);
cuerpoPrueba = Cuerpo(Cuerpo(), geoPrueba);
simulacionPrueba = Simulacion(Simulacion(), cuerpoPrueba);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTRUCCION FORZANTE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACELERACION OSCILATORIA SERIE TEMPORAL
% Carga experimento

load 'Experimentos.mat'
% keyboard
expAnalisis = 14;
expActual = Experimentos(expAnalisis);
acelExperimento = expActual.Mediciones.Aceleracion;
velExperimento = expActual.Mediciones.VelFlujo;
velExperimento(:,2:3) = -1*velExperimento(:,2:3);

largoAcel = length(acelExperimento(:,1));
largoVel = length(velExperimento(:,1));

freqAcel = 100; %Hz
tiempoAcel = (0:largoAcel)/freqAcel;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figuras que muestran aceleraciones y velocidad 

rangoInf = 0.01;
rangoSup = 0.2;

acelInf = floor(rangoInf*largoAcel);
acelSup = floor(rangoSup*largoAcel);
velInf = floor(rangoInf*largoVel);
velSup = floor(rangoSup*largoVel);

amplitud = expActual.AmplitudOscilacion;
frecAngular = (expActual.FrecuenciaRPM)/60*2*pi;
anguloDireccion = 0;
aceleracion = acelExperimento(acelInf : acelSup,1)*9.81; %m/s^2
tiempo = tiempoAcel(acelInf : acelSup); 
acelForzante = SerieAceleracionOsci(Forzante(), aceleracion, tiempo, amplitud, frecAngular, anguloDireccion);	
simulacionPrueba = addForzante(simulacionPrueba, acelForzante);

% CONSTRUYE MATRICES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
simulacionPrueba.Matrices = Matrices(simulacionPrueba);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CORRE MODELO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ANALISIS MODAL PERMANENTE
% simulacionPrueba.AnalisisModal = AnalisisModal(simulacionPrueba,'permanente');
%save('analisisModal.mat')

% ANALISIS MODAL IMPERMANENTE
%simulacionPrueba.AnalisisModal = AnalisisModal(simulacionPrueba,'impermanente');
%save('analisisModal.mat')

% CRANKNICOLSON
simulacionPrueba.CrankNicolson = CrankNicolson(simulacionPrueba);
save('crankNicolson.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THRASH
% keyboard
% forz = addForzante(Forzantes(), vientoForzante);
% forz = addForzante(simulacionPrueba, vientoForzante);
% forz = addForzante(Forzantes(), vientoForzante1);
%omegaAceleracion = 113/60*2*pi;  % 113 rpm 
%aceleracionForzante1 = aceleracionHorizontalOscilatoria(Forzante(), 8e-3, omegaAceleracion, 0);
%forz = addForzante(Forzantes(), aceleracionForzante1);
% simulacionPrueba.Forzantes













