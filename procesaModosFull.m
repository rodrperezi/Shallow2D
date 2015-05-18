clear all 
close all 

% Rutina para procesar modos

load MODOS.mat

% Normaliza modos para que tengan norma unitaria

% Los vectores propios se ordenan de la forma [v1, ..., vn], en donde, vi es un vector columna
% de n elementos (dim(vi) = nx1). Actualmente, la rutina que normaliza la matriz que tiene los 
% vectores incluye un for que la recorre por columnas (rutina comentada a continuación):
 
%for iNorm = 1:length(ValoresDerecha)
%	VectoresDerecha(:,iNorm) = VectoresDerecha(:,iNorm)/norm(VectoresDerecha(:,iNorm));
%	VectoresIzquierda(:,iNorm) = VectoresIzquierda(:,iNorm)/norm(VectoresIzquierda(:,iNorm));
%	compruebaNorm(iNorm) = norm(VectoresIzquierda(:,iNorm)) + norm(VectoresDerecha(:,iNorm));	
%end

% En el fondo, se recorre la información vector a vector y en cada loop se hacen tres cálculos y asignaciones.
% Otra forma de hacer esto mismo.

% normaDerecha = sqrt(sum(VectoresDerecha.^2)); % vector de 1xn
% normaDerecha = repmat(normaDerecha, length(ValoresDerecha), 1); % matriz de nxn
% VectoresDerecha = VectoresDerecha./normaDerecha; % Normalización, matriz de nxn

% normaIzquierda = sqrt(sum(VectoresIzquierda.^2)); % vector de 1xn
% normaIzquierda = repmat(normaIzquierda, length(ValoresIzquierda), 1); % matriz de nxn
% VectoresIzquierda = VectoresIzquierda./normaIzquierda; % Normalización, matriz de nxn

% Resumido en una línea

VectoresDerecha = VectoresDerecha./(repmat(sqrt(sum(VectoresDerecha.^2)), length(ValoresDerecha), 1));
VectoresIzquierda = VectoresIzquierda./(repmat(sqrt(sum(VectoresIzquierda.^2)), length(ValoresIzquierda), 1));

% Corto decimales que sean menores que (del orden de) la precisión eps

corta = 1e-13;

ValoresDerecha = quant(real(ValoresDerecha), corta) + i*quant(imag(ValoresDerecha), corta);
ValoresIzquierda = quant(real(ValoresIzquierda), corta) + i*quant(imag(ValoresIzquierda), corta);

VectoresDerecha = quant(real(VectoresDerecha), corta) + i*quant(imag(VectoresDerecha), corta);
VectoresIzquierda = quant(real(VectoresIzquierda), corta) + i*quant(imag(VectoresIzquierda), corta);

% Busco (algún) valor propio 0.

fNuloDer = find(abs(ValoresDerecha)==0);
fNuloIzq = find(abs(ValoresIzquierda)==0);
ValoresDerechaNulo = ValoresDerecha(fNuloDer);
ValoresIzquierdaNulo = ValoresIzquierda(fNuloIzq);
VectoresDerechaNulo = VectoresDerecha(:,fNuloDer);
VectoresIzquierdaNulo = VectoresIzquierda(:,fNuloIzq);

% Busco y ordeno vectores con omega positivo.

fDerecha = find(real(ValoresDerecha)>0);
fIzquierda = find(real(ValoresIzquierda)>0);
ValoresDerechaPositivos = ValoresDerecha(fDerecha);
ValoresIzquierdaPositivos = ValoresIzquierda(fIzquierda);
VectoresDerechaPositivos = VectoresDerecha(:,fDerecha);
VectoresIzquierdaPositivos = VectoresIzquierda(:,fIzquierda);

[ValoresDerechaPositivos indDerPos] = sort(ValoresDerechaPositivos);
[ValoresIzquierdaPositivos indIzqPos] = sort(ValoresIzquierdaPositivos);
VectoresDerechaPositivos = VectoresDerechaPositivos(:,indDerPos);
VectoresIzquierdaPositivos = VectoresIzquierdaPositivos(:,indIzqPos);

% Busco y ordeno vectores con omega negativo.

fDerecha = find(real(ValoresDerecha)<0);
fIzquierda = find(real(ValoresIzquierda)<0);
ValoresDerechaNegativos = ValoresDerecha(fDerecha);
ValoresIzquierdaNegativos = ValoresIzquierda(fIzquierda);
VectoresDerechaNegativos = VectoresDerecha(:,fDerecha);
VectoresIzquierdaNegativos = VectoresIzquierda(:,fIzquierda);

[ValoresDerechaNegativos indDerNeg] = sort(ValoresDerechaNegativos);
[ValoresIzquierdaNegativos indIzqNeg] = sort(ValoresIzquierdaNegativos);
VectoresDerechaNegativos = VectoresDerechaNegativos(:,indDerNeg);
VectoresIzquierdaNegativos = VectoresIzquierdaNegativos(:,indIzqNeg);

% Busco vectores con omega cero.

fDerechaCero = find(real(ValoresDerecha)==0);
fIzquierdaCero = find(real(ValoresIzquierda)==0);
ValoresDerechaCero = ValoresDerecha(fDerechaCero);
ValoresIzquierdaCero = ValoresIzquierda(fIzquierdaCero);
VectoresDerechaCero = VectoresDerecha(:,fDerechaCero);
VectoresIzquierdaCero = VectoresIzquierda(:,fIzquierdaCero);

% Ordena las partes imaginarias de los valores con omega cero. De menor a mayor

[ValoresDerechaCero indDerechaCero]= sort(ValoresDerechaCero);
[ValoresIzquierdaCero indIzquierdaCero]= sort(ValoresIzquierdaCero);
VectoresDerechaCero = VectoresDerechaCero(:,indDerechaCero);
VectoresIzquierdaCero = VectoresIzquierdaCero(:,indIzquierdaCero);

% Dime cuantas veces aparece cada valor propio con omega = 0 en la lista

cuantasDerecha = zeros(length(ValoresDerechaCero),1);
cuantasIzquierda = cuantasDerecha;

for iCuantas = 1:length(ValoresDerechaCero)

	cuantasDerecha(iCuantas) = length(find(ValoresDerechaCero(iCuantas)==ValoresDerechaCero));
	cuantasIzquierda(iCuantas) = length(find(ValoresIzquierdaCero(iCuantas)==ValoresIzquierdaCero));

end

% Algunos aparecen dos veces otros una.
% Los que aparecen una sola vez, los aislo para ver si pueden salir del problema.

fDerechaUna = find(cuantasDerecha == 1);
fIzquierdaUna = find(cuantasIzquierda == 1);
ValoresDerechaCeroUna = ValoresDerechaCero(fDerechaUna);
ValoresIzquierdaCeroUna = ValoresIzquierdaCero(fIzquierdaUna);
VectoresDerechaCeroUna = VectoresDerechaCero(:,fDerechaUna);
VectoresIzquierdaCeroUna = VectoresIzquierdaCero(:,fIzquierdaUna);

% Aislo los que aparecen dos veces. 

fDerechaDos = find(cuantasDerecha == 2);
fIzquierdaDos = find(cuantasIzquierda == 2);
ValoresDerechaCeroDos = ValoresDerechaCero(fDerechaDos);
ValoresIzquierdaCeroDos = ValoresIzquierdaCero(fIzquierdaDos);
VectoresDerechaCeroDos = VectoresDerechaCero(:,fDerechaDos);
VectoresIzquierdaCeroDos = VectoresIzquierdaCero(:,fIzquierdaDos);

% For para mostrar par de modos con omega = 0 y que aparecen dos veces

%for iMuestra = 1:length(ValoresDerechaCeroDos)-2
%	
%	sPlot(1) = subplot(2,2,1);
%	graficaModo(sim, VectoresDerechaCeroDos(:,(iMuestra-1)*2+1))
%	sPlot(2) = subplot(2,2,2);
%	graficaModo(sim, VectoresDerechaCeroDos(:,(iMuestra-1)*2+2))

%	sPlot(3) = subplot(2,2,3);
%	graficaModo(sim, conj(VectoresDerechaCeroDos(:,(iMuestra-1)*2+1)))
%	sPlot(4) = subplot(2,2,4);
%	graficaModo(sim, conj(VectoresDerechaCeroDos(:,(iMuestra-1)*2+2)))

%	keyboard

%end

% Observo que la estructura espacial de los modos es la misma pero no tienen el mismo ángulo de origen
% Con esto me refiero a que, si bien tienen la misma forma, uno se encuentra con una rotación 
% distinta a su par.


% For para mostrar modos con omega = 0 y que aparecen una vez

%for iMuestra = 1:length(ValoresDerechaCeroUna)
%	
%	sPlot(1) = subplot(1,2,1);
%	graficaModo(sim, VectoresDerechaCeroUna(:,iMuestra))
%	sPlot(2) = subplot(1,2,2);
%	graficaModo(sim, conj(VectoresDerechaCeroUna(:,iMuestra)))

%	keyboard

%end

% Observo que los modos conjugados se ven iguales que los modos originales. Al parecer
% las partes imaginarias de las estructuras, son cero, al menos hasta el cuarto decimal
% La suma de las partes imaginarias de cada componente de las estructuras es del orden de eps


% For para mostrar modos con omega != 0. Comparo estructuras

%for iMuestra = 1:length(ValoresDerechaPositivos)
%	
%	sPlot(1) = subplot(2,2,1);
%	graficaModo(sim, VectoresDerechaPositivos(:,iMuestra))
%	sPlot(2) = subplot(2,2,2);
%	graficaModo(sim, VectoresDerechaNegativos(:,iMuestra))
%	sPlot(3) = subplot(2,2,3);
%	graficaModo(sim, conj(VectoresDerechaPositivos(:,iMuestra)))
%	sPlot(4) = subplot(2,2,4);
%	graficaModo(sim, conj(VectoresDerechaNegativos(:,iMuestra)))

%	keyboard

%end

% Debo corroborar que el orden de los valores es el correcto
% Corroboro

corroboraOrden = ValoresDerechaPositivos == -real(ValoresDerechaNegativos) + i*imag(ValoresDerechaNegativos);
length(ValoresDerechaPositivos)
sum(corroboraOrden)

% Hasta aqui veo que el largo del vector de Valores Propios es 315 y la suma de corroboraOrden es 266
% Esto indica que hay un problema de orden en los valores propios

% Busco cuales estan pareados incorrectamente. Al parecer las diferencias son pequeñas y se deben 
% a decimales en la posicion 1e-15. Voy a probar cortando los valores en un decimal un poco mayor
% 1e-14. Con 1e-14 mejora el resultado ahora la relacion es Valores Propios es 315 y la suma de corroboraOrden 311. 
% Pruebo con 1e-13. Calzan los resultados Valores Propios es 315 y la suma de corroboraOrden 315. 
% Independiente del decimal en el cual se cortan los valores, esto me dice que están ordenados correctamente. 
% Es decir, valores y vectores de omegas positivos y negaivos están correctamente pareados.
% Problema: Aquellos valores propios que difieren en un decimal menor que 1e-13 ahora pasan a ser iguales
% 

% Ahora debería realizar el cálculo de una solución del problema modal utilizando distintas metodologías. 
% Algunas de las que debo probar son: Utilizar todos los modos, forzar simetría a partir de modos 
% con omega > 0, evaluar utilización de modos con omega = 0, etc. 




