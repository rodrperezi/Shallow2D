	function [numeroNodosEta varargout] = getNumeroNodos(varargin)
		if nargin == 1
			objeto = varargin{1};
			malla = getMalla(objeto);
			numeroNodosEta = malla.numeroNodosEta;
			numeroNodosU = malla.numeroNodosU;
			numeroNodosV = malla.numeroNodosV;
	
			argoutExtra = max(nargout,1)-1;
			argoutAux = [numeroNodosU, numeroNodosV];		
			for k = 1:argoutExtra, varargout(k) = {argoutAux(k)}; end
		end
	end
