clear all 
close all 


datosViento = [[1 2 3 4 5]', [2 4 6 8 10]'];
alturaMedicion = 2;
zoRugosidad = 1e-4;
serie = SerieVientoUniforme(SerieVientoUniforme(), datosViento, alturaMedicion, zoRugosidad);

R = 200;
H = 0.15;
centroMasa = [0, 0];
kranPrueba = GeoKranenburgNew(GeoKranenburgNew(),'radioR', R, 'alturaH', H, 'centroMasa', centroMasa, 'fracDeltaX', 1/10);
cuerpoPrueba = addGeometria(Cuerpo(), kranPrueba);
simCN = Simulacion(Simulacion(), cuerpoPrueba);
simCN = addForzante(simCN, serie);
simCN = addMatrices(simCN, Matrices(simCN));
simCN = addResultados(simCN, CrankNicolson(simCN));

