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

% CONSTRUCCION MODELO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% kranPrueba = GeoKranenburg(GeoKranenburg(),'radioR', R, 'alturaH', H, 'centroMasa', centroMasa);
kranPrueba = GeoKranenburgNew(GeoKranenburgNew(),'radioR', R, 'alturaH', H, 'centroMasa', centroMasa, 'fracDeltaX', 1/20);
cuerpoPrueba = addGeometria(Cuerpo(), kranPrueba);

simAM = Simulacion(Simulacion(), cuerpoPrueba);
simAM = addForzante(simAM, VientoUniforme(Forzante(), 'uAsterisco', 1e-3, 'anguloDireccion', pi/2));
simAM = addMatrices(simAM, Matrices(simAM));
simAM = addResultados(simAM, AnalisisModal(simAM, 'permanente'));

[M, K, C] = getMatrices(simAM);

solAM = simAM.Resultados.Hidrodinamica.Solucion;
enAM = 0.5*dot(solAM, M*solAM)*areaSuperficial(simAM);

simCN = Simulacion(Simulacion(), cuerpoPrueba);
simCN = addForzante(simCN, VientoUniforme(Forzante(), 'uAsterisco', 1e-3, 'anguloDireccion', pi/2));
simCN = addMatrices(simCN, Matrices(simCN));
simCN = addResultados(simCN, CrankNicolson(simCN));

solCN = simCN.Resultados.Hidrodinamica.Solucion(:,end);
enCN = 0.5*dot(solCN, M*solCN)*areaSuperficial(simCN);

save('sim20.mat', 'simAM', 'simCN', 'enAM','enCN')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55



% sim = solucion2D(sim, 'hidrodinamica');
%[M K C] = getMatrices(sim);
%[kmascLI1 id1] = licols(full([K+C]), 1e-10);
%[kmascLI2 id2] = licols(full([K+C].'), 1e-10);
%di1 = diff(id1);
%di2 = diff(id2);
%fi1 = find(di1 ~= 1);
%fi2 = find(di2 ~= 1);

%col1 = fi1 + 1
%col2 = fi2 + 1

%[Neta Nu Nv] = getNumeroNodos(sim)
%graficaMalla(Grafico(), sim)

%keyboard


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTRUCCION FORZANTE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VIENTO UNIFORME
% vientoForzante = VientoUniforme(Forzante(), 1e-3, pi/2);
% simulacionPrueba = addForzante(simulacionPrueba, vientoForzante);

% ACELERACION OSCILATORIA TEORICA
%amplitud = 0.002;
%frecAngular = 113/60*2*pi;
%anguloDireccion = 0;
%acelForzante = AcelHoriOsci(Forzante(), amplitud, frecAngular, anguloDireccion);
%simulacionPrueba = addForzante(simulacionPrueba, acelForzante);




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
%simulacionPrueba.Matrices = Matrices(simulacionPrueba);
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
%simulacionPrueba.CrankNicolson = CrankNicolson(simulacionPrueba);
%save('crankNicolson.mat')
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













