function malla = getMalla(varargin)

	switch class(varargin{1})
		case 'Cuerpo'
			malla = varargin{1}.Geometria.Malla;
		case 'Geometria'
			malla = varargin{1}.Malla;
		case 'Simulacion'
			malla = varargin{1}.Cuerpo.Geometria.Malla;
	end
end

