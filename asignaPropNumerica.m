function objeto = asignaPropNumerica(objeto, varargin)

	nInput = length(varargin);
	clasesInput = cell(nInput,1);

	for iInput = 1:nInput		
		clasesInput{iInput} = class(varargin{iInput});
		esNumero(iInput) = isnumeric(varargin{iInput});
	end 	
			
	posNumero = find(esNumero);

	if (sum(esNumero)~=0)

		try
			for iPos = 1:length(posNumero)
				% Ve si los numeros estan antecedidos por strings
				% Si lanza error de indice, es porque hay un problema
				% en sintaxis. (posNumero(iPos)-1 = 0)
							
				esString(iPos) = isa(clasesInput{posNumero(iPos)-1}, 'char');
				asignar{iPos} = varargin{posNumero(iPos)-1};
				esProp(iPos) = isprop(objeto, asignar{iPos});							
				queSeAsigna{iPos} = varargin{posNumero(iPos)};
	
			end 	

			if(sum(esNumero) ~= sum(esString))					
				error	
			end
									
		catch
			error('Error de sintaxis')
		
		end

		try
			posProp = find(esProp);
			
			if(isempty(posProp))					
				error
			end
				
			for iPos = 1:length(posProp)
				set(objeto, asignar{posProp(iPos)}, queSeAsigna{posProp(iPos)});
			end

		catch
			error(['Las propiedades especificadas no son parte del objeto. Ver properties(', class(objeto), ')'])
		end

	end				


