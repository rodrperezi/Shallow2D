function thisSimulacion = actualizaCuerpo(Simulacion, MotorDeCalculo)
		
	thisSimulacion = Simulacion;

%	if(~isempty(eval(['thisSimulacion.Resultados.',MotorDeCalculo,'.CuerpoActualizado'])))
%		stringAyuda = ['thisSimulacion.Cuerpo = thisSimulacion.Resultados.',MotorDeCalculo,'.CuerpoActualizado;'];
%		eval(stringAyuda);
%		stringAyuda = ['thisSimulacion.Resultados.',MotorDeCalculo,'.CuerpoActualizado = [];'];
%		eval(stringAyuda);
%	end


	if(~isempty(eval(['thisSimulacion.Resultados.Hidrodinamica.',MotorDeCalculo,'.CuerpoActualizado'])))
		stringAyuda = ['thisSimulacion.Cuerpo = thisSimulacion.Resultados.Hidrodinamica.',MotorDeCalculo,'.CuerpoActualizado;'];
		eval(stringAyuda);
		stringAyuda = ['thisSimulacion.Resultados.Hidrodinamica.',MotorDeCalculo,'.CuerpoActualizado = [];'];
		eval(stringAyuda);
	end
