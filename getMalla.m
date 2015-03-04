	function thisMalla = getMalla(varargin)
		if nargin == 1
			switch class(varargin{:})
				case 'Simulacion'				
					thisMalla = varargin{:}.Cuerpo.Geometria.Malla;					
				case 'Cuerpo'
					thisMalla = varargin{:}.Geometria.Malla;
				case 'Geometria'
					thisMalla = varargin{:}.Malla;
				case 'Malla'
					thisMalla = varargin{:};
				otherwise 
					error(['El objeto ', class(varargin{:}), ' no contiene una Malla'])
			end %switch
		end %if
	end %function getMalla
