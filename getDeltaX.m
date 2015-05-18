	function [deltaX varargout]= getDeltaX(varargin)
		if nargin == 1
			objeto = varargin{1};
			geometria = getGeometria(objeto);
			deltaX = geometria.deltaX;
			deltaY = geometria.deltaY;

			argoutExtra = max(nargout,1)-1;
			argoutAux = deltaY;		
			for k = 1:argoutExtra, varargout(k) = {argoutAux(k)}; end

		end %if
	end %function getDeltaX
