% function [valoresPropios, vectoresPropios] = calculaValoresVectoresPropios(matricesResolucion)
function valoresVectoresPropios = calculaValoresVectoresPropios(Cuerpo)
% calculaValoresVectoresPropios: funcion que hace lo que dice su nombre
% En la estructura valoresPropios entrega los valores del calculo por la derecha y por la izquierda
% En la estructura vectoresPropios entrega los vectores del calculo por la derecha y por la izquierda
% Para entender lo que significa el calculo por la derecha y por la izquierda se recomienda estudiar 
% Shimizu e Inberger (2008). Este calculo tiene sentido solo cuando hay disipación por esfuerzo de corte
% de fondo. Sin disipacion, entonces se puede calcular solo el problema por la derecha. 
% En este caso se asume que matricesResolucion tiene una matriz M, K, C y un forzante externo f.
% definidos acorde con Shimizu e Imberger (2008).

matricesResolucion = Cuerpo.Matrices;
A = matricesResolucion.K + matricesResolucion.C;
M = matricesResolucion.M;

[vectoresDerechos, valoresDerechos]= eig(full(A), full(M));
[vectoresIzquierdos, valoresIzquierdos]= eig(full(A'), full(M));

valoresPropios.derechos = diag(valoresDerechos);
valoresPropios.izquierdos = diag(valoresIzquierdos);
vectoresPropios.derechos = vectoresDerechos;
vectoresPropios.izquierdos = vectoresIzquierdos;

valoresVectoresPropios.valoresPropios = valoresPropios;
valoresVectoresPropios.vectoresPropios = vectoresPropios;




