clear all 
close all 

set(0,'DefaultAxesFontName', 'times')
set(0,'DefaultAxesFontSize', 9)

set(0,'DefaultTextFontname', 'times')
set(0,'DefaultTextFontSize', 9)


%R = 0.2;
%H = 0.03;
R = 200;
H = 0.15;


geoPrueba = Geometria();
geoPrueba = construyeKranenburg(geoPrueba, R, H, [0, 0]);
cuerpoPrueba = Cuerpo();
cuerpoPrueba.Geometria = geoPrueba;
simulacionPrueba = Simulacion();
simulacionPrueba = Simulacion(simulacionPrueba, cuerpoPrueba);

vientoForzante1 = vientoUniforme(Forzante(), 1e-2, 0);
%vientoForzante2 = vientoUniforme(Forzante(), 2e-4, 0);
%vientoForzante3 = vientoUniforme(Forzante(), 3e-4, 0);
forz = Forzantes();
forz = addForzante(forz, vientoForzante1);
%forz = addForzante(forz, vientoForzante2);
%forz = addForzante(forz, vientoForzante3);

simulacionPrueba.Forzantes = forz;
simulacionPrueba = asignaMatrices(Matrices(), simulacionPrueba);
simulacionPrueba.AnalisisModal = AnalisisModal(simulacionPrueba,'permanente');
%solucion = simulacionPrueba.AnalisisModal.Solucion;
%graficaEta(simulacionPrueba, solucion)
% simulacionPrueba.CrankNicolson = CrankNicolson(simulacionPrueba);
% save('crankNicolson.mat')




%omegaAceleracion = 113/60*2*pi; % 113 rpm 
%aceleracionForzante1 = aceleracionHorizontalOscilatoria(Forzante(), 8e-3, omegaAceleracion, 0);

% forz = addForzante(forz, aceleracionForzante1);
%simulacionPrueba = asignaMatrices(Matrices(), simulacionPrueba);
%simulacionPrueba.AnalisisModal = AnalisisModal(simulacionPrueba,'permanente');

% save('modosPrueba.mat')


% grafica(simulacionPrueba, simulacionPrueba.AnalisisModal.Solucion, 'eta')





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%forz2 = Forzantes();
%forz2 = addForzante(forz2,aceleracionForzante1);
%simulacionPrueba.Forzantes = forz;
%simulacionPrueba = asignaMatrices(Matrices(), simulacionPrueba);





