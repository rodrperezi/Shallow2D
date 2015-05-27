classdef Transporte
	% TRANSPORTE es un objeto que contiene los resultados
	% del transporte escalar para los motores de calculo utilizados.
	properties

		 AnalisisModal
		 CrankNicolson

	end

	methods
%				% Esta condicion la pondré en la clase Transporte
%				if strcmpi(superclase, 'TransporteOD') 
%				% Si es que quiero asignar resultados de 
%				% transporte, necesito que existan los de 
%				% hidrodinamica					
%					if ~isempty(res.Hidrodinamica)					
%					% Si es que no está vacío, entonces
%					% asigna
%					

%					end

%				end %end


		function thisTransporte = Transporte(Cuerpo, Hidrodinamica, dispersion)

			if(~isempty(Hidrodinamica))
				% keyboard %TAMOS EN ESTO
				if(~isempty(Hidrodinamica.AnalisisModal))
					thisTransporte.AnalisisModal = VolumenesFinitos(Cuerpo, Hidrodinamica.AnalisisModal, dispersion);
					% keyboard
				end

				% if()
				% end
			
			else		
				error('myapp:chk', 'Para resolver el transporte escalar primero necesitas resolver la hidrodinamica.');
			
			end

		end % Transporte
	end % methods
end % classdef



%%%%%%%%% THRASH

			
%			if nargin == 2

%				switch MotorDeCalculo
%					case 'AnalisisModal'
%						thisTransporte.AnalisisModal = VOLUMENESFINITOS(Cuerpo);
%					case 'CrankNicolson'
%						thisTransporte.CrankNicolson = VOLUMENESFINITOS(Cuerpo);	
%				end

% 			end		



