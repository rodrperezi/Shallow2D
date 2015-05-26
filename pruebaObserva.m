clear all 
close all 

set(0,'DefaultAxesFontName', 'times')
set(0,'DefaultAxesFontSize', 9)

set(0,'DefaultTextFontname', 'times')
set(0,'DefaultTextFontSize', 9)

% DATOS GEOMETRIA
R = 0.2;
H = 0.03;
centroMasa = [0, 0];

% CONSTRUCCION MODELO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kranPrueba = GeoKranenburg(GeoKranenburg(),'radioR', R, 'alturaH', H, 'centroMasa', centroMasa);
% keyboard
cuerpoPrueba = addGeometria(Cuerpo(), kranPrueba);
simulacionPrueba = Simulacion(Simulacion(), cuerpoPrueba);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTRUCCION FORZANTE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VIENTO UNIFORME
% vientoForzante = VientoUniforme(Forzante(), 1e-3, pi/2);
% simulacionPrueba = addForzante(simulacionPrueba, vientoForzante);

% ACELERACION OSCILATORIA TEORICA
amplitud = 0.002;
frecAngular = 113/60*2*pi;
anguloDireccion = 0;
acelForzante = AcelHoriOsci(Forzante(), amplitud, frecAngular, anguloDireccion);
simulacionPrueba = addForzante(simulacionPrueba, acelForzante);

% ACELERACION OSCILATORIA SERIE TEMPORAL
%amplitud = 0.001;
%frecAngular = 113/60*2*pi;
%anguloDireccion = 0;
%aceleracion =
%tiempo = 
%SerieAceleracion(Forzante, aceleracion, tiempo, amplitud, frecAngular, anguloDireccion)	
%simulacionPrueba = addForzante(simulacionPrueba, acelForzante);

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













