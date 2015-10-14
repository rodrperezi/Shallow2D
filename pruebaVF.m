clear all 
close all 

set(0,'DefaultAxesFontName', 'times')
set(0,'DefaultAxesFontSize', 9)

set(0,'DefaultTextFontname', 'times')
set(0,'DefaultTextFontSize', 9)

% DATOS GEOMETRIA

R = 200;
H = 0.15;
centroMasa = [0, 0];

% CONSTRUCCION MODELO HIDRODINAMICA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kranPrueba = GeoKranenburgNew(GeoKranenburgNew(),'radioR', R, 'alturaH', H, 'centroMasa', centroMasa, 'fracDeltaX', 1/10);
cuerpoPrueba = addGeometria(Cuerpo(), kranPrueba);
simCN = Simulacion(Simulacion(), cuerpoPrueba);
simCN = addForzante(simCN, VientoUniforme(Forzante(), 'uAsterisco', 1e-3, 'anguloDireccion', pi/2));
simCN = addMatrices(simCN, Matrices(simCN));
simCN = addResultados(simCN, CrankNicolson(simCN));

%%%%%%%%%%%%%%%%%%%%%%
% AGREGAR VOLUMENES FINITOS
1
% Creo masa
OD = OxigenoDisuelto();
concIniciales = 0.2;
cSat = 8.82e-3;
nEta = getNumeroNodos(simCN);
objetoVF = VolumenesFinitos(VolumenesFinitos(), simCN,'RegimenTemporal', ...
	   'impermanente', 'Masa', OD, 'Flujos', 'adveccionVerticales', ...
 	   'ConcentracionInicial', concIniciales*cSat*ones(nEta,1));









