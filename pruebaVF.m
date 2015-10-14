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
kranPrueba = GeoKranenburgNew(GeoKranenburgNew(),'radioR', R, 'alturaH', H, 'centroMasa', centroMasa, 'fracDeltaX', 1/20);
cuerpoPrueba = addGeometria(Cuerpo(), kranPrueba);
simCN = Simulacion(Simulacion(), cuerpoPrueba);
simCN = addForzante(simAM, VientoUniforme(Forzante(), 'uAsterisco', 1e-3, 'anguloDireccion', pi/2));
simCN = addMatrices(simAM, Matrices(simAM));
simCN = addResultados(simAM, AnalisisModal(simAM, 'permanente'));

