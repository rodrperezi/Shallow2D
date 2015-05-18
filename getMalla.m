	function thisMalla = getMalla(varargin)
		if nargin == 1
			objeto = varargin{1};
			switch class(objeto)
				case 'Simulacion'				
					thisMalla = objeto.Cuerpo.Geometria.Malla;					
				case 'Cuerpo'
					thisMalla = objeto.Geometria.Malla;
				case 'Geometria'
					thisMalla = objeto.Malla;
				case 'Malla'
					thisMalla = objeto;
				otherwise 
					error(['El objeto ', class(objeto), ' no contiene una Malla'])
			end %switch
		end %if
	end %function getMalla
