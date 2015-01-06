function [numeroNodosEta varargout] = getNumeroNodos(varargin)
% keyboard
		switch class(varargin{1})
			case 'Cuerpo'
				% keyboard
				numeroNodosEta = varargin{1}.Geometria.Malla.InformacionMalla.numeroNodosEta;
				numeroNodosU = varargin{1}.Geometria.Malla.InformacionMalla.numeroNodosU;
				numeroNodosV = varargin{1}.Geometria.Malla.InformacionMalla.numeroNodosV;
			case 'Geometria'
				numeroNodosEta = varargin{1}.Malla.InformacionMalla.numeroNodosEta;
				numeroNodosU = varargin{1}.Malla.InformacionMalla.numeroNodosU;
				numeroNodosV = varargin{1}.Malla.InformacionMalla.numeroNodosV;
			case 'Malla'
				numeroNodosEta = varargin{1}.InformacionMalla.numeroNodosEta;
				numeroNodosU = varargin{1}.InformacionMalla.numeroNodosU;
				numeroNodosV = varargin{1}.InformacionMalla.numeroNodosV;
		end

		argoutExtra = max(nargout,1)-1;
		argoutAux = [numeroNodosU, numeroNodosV];		
		for k = 1:argoutExtra, varargout(k) = {argoutAux(k)}; end
end
