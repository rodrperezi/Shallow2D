classdef Forzantes < hgsetget

	properties

		ListaForzantes
		
	end %properties

	methods

		function thisForzantes = Forzantes()
			thisForzantes;
		end %function Forzante

		function thisForzantes = addForzante(thisForzantes, forzante)
			
			current = thisForzantes.ListaForzantes;

			if ~isempty(current) cuantos = length(fields(current));
			else cuantos = 0;
			end

			str = ['current.N',num2str(cuantos+1),'= forzante;'];
			eval(str)
			thisForzantes.ListaForzantes = current;

		end %addForzante
			
		function thisForzantes = delForzante(thisForzantes, aBorrar)

			estructuraForzantes = thisForzantes.ListaForzantes;
			num = str2num(aBorrar(2:end));
			cuantos = length(fields(estructuraForzantes));
			estructuraForzantes = rmfield(estructuraForzantes, aBorrar);

			if num ~= cuantos

				for iField = num:cuantos-1
					str = ['estructuraForzantes.N', num2str(iField),' = estructuraForzantes.N',num2str(iField+1),';'];
					eval(str)
				end		
	
				estructuraForzantes = rmfield(estructuraForzantes, ['N',num2str(cuantos)]);

			end

			thisForzantes.ListaForzantes = estructuraForzantes;
		end %delForzante
	end %methods
end %classdef

	


