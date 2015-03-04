%% construyeSimulacion
% 
% Rutina para estandarizar el proceso de construcción de una 
% simulación. La idea es detallar los pasos empleados, descripción
% que posteriormente puede ser utilizada a modo de manual/ejemplo.

clear all 
close all 
addpath('../')
% El objeto Simulacion: Dentro del diseño de Shallow2D, este es el 
% objeto de mayor jerarquía. Tiene como propiedades un objeto de clase
% Cuerpo, uno de clase Forzante y otro de clase Resultados.
% Se entiende que un Cuerpo influenciado por un Forzante son los
% componentes básicos para llevar a cabo una Simulacion.

% Construir un objeto Simulacion: El constructor se invoca de la
% forma Simulacion(varargin), en donde varargin puede ser objetos 
% de clase Cuerpo, Forzante o Resultados.
%  
% Para Ejecutar una simulación: Dentro de los métodos de la clase
% Simulación, se incluye la función Run(Simulacion, Motor), la cual
% resuelve la Simulacion utilizando el Motor especificado. La
% funcion retorna un objeto de clase Simulación cuya propiedad
% Resultados corresponde al cálculo del problema definido por 
% el Cuerpo y el Forzante de la Simulación.
%  
% 
% 	>> Simulacion
% 	
% 	ans = 
% 
% 	Simulacion
% 
% 	Properties: 
%             Cuerpo: []
%           Forzante: []
%         Resultados: [] 
% 
 
sim = Simulacion;





     

