classdef Masa < hgsetget

	% MASA es la clase padre de los tipo de masa que pueden
	% ser transportadas en fluidos

	properties

		Tipo

	end

	methods

		function thisMasa = Masa()
	
			if nargin == 0			
				thisMasa;
			end %if

		end % Masa
	end %methods
end %classdef

