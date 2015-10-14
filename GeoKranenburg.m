classdef GeoKranenburg < Geometria

	% GEOMETRIA -> GEOKRANENBURG es el objeto que caracteriza la 
	% batimetría de Kranenburg (1992) dada por la ecuación 
	% 
	% h(x,y)/H = 0.5 + sqrt(0.5 - 0.5*sqrt((x-centroMasa(1)).^2 + ...
	% 	     (y-centroMasa(2)).^2)/R)
	% 
	% siendo H una altura característica de la batimetría y R el radio de 
	% la circunferencia que describe el borde. centroMasa = [x_cm y_cm] 
	% es el vector que contiene las coordenadas [x_cm y_cm] del centro de 
	% masa de la hoya.
	% 
	% El objeto se construye como: 
	% 		
	% thisGeoKranenburg = 
	% GeoKranenburg(thisGeoKranenburg, 'prop1', valor1, 'prop2', valor2...);
	% 	
	% de manera de conservar el estilo de Matlab. Las propiedades
	% del objeto son 
	% 
	% >> properties(GeoKranenburg)
	% 
	% 	Properties for class GeoKranenburg:
	% 
	% 	    radioR
	% 	    alturaH
	% 	    centroMasa
	%  	    Borde
	%  	    Malla
	% 	    Batimetria	
	% 
	% Aquellas propiedades que comienzan con minúscula son valores 
	% númericos a partir de los cuales se construyen los demás 
	% objetos. Por lo tanto, solo basta ASIGNAR 
	% 	    
	% 	    radioR
	% 	    alturaH
	% 	    centroMasa
	%
	% para que se construya el objeto. En este caso particular, 
	% el objeto tiene tres propiedades y por lo tanto el argumento
	% tiene un largo máximo de 7 elementos, siendo las posiciones 
	% pares strings que contienen el nombre de la propiedad a asignar 
	% entre comillas ('ejemplo') y las posiciones impares 
	% (excepto la primera) contienen el valor 
	% de la respectiva propiedad que les antecede en los argumentos. 
	% Las posiciones pares deben ser por definición strings
	% que definan alguna propiedad del objeto. Por lo tanto, 
	% no puede haber una asignación de propiedades mayor 
	% a la cantidad de propiedades del objeto y la propiedad
	% a asignar tiene que existir dentro del objeto.


	properties

		radioR
		alturaH


	end
    
	methods

		function thisGeoKranenburg = GeoKranenburg(thisGeoKranenburg, varargin)
			
			if nargin == 0
				thisGeoKranenburg;		
			else
				thisGeoKranenburg = asignaPropNumerica(thisGeoKranenburg, varargin{:});
				radio = thisGeoKranenburg.radioR;
				altura = thisGeoKranenburg.alturaH;
				centro = thisGeoKranenburg.centroMasa;

				if(~isempty(radio) && ~isempty(altura) && ~isempty(centro))
					% Revisa si variables fundamentales están definidas
					% o sea se puede construir el objeto.
					
					thisGeoKranenburg.Borde = generaBordeCircular(Borde(), radio, centro);
					dx = 0.1*radio;
					dy = dx;
					thisGeoKranenburg.Malla = Staggered(Malla(), thisGeoKranenburg, dx, dy);
					thisGeoKranenburg.Batimetria = batimetriaKranenburg(Batimetria(), thisGeoKranenburg);
				end %if
			end %if
		end %function GeoKranenburg

		function bat = getBatimetria(geoKran)

			bat = geoKran.Batimetria;

		end %getBatimetria

		function malla = getMalla(geoKran)

			malla = geoKran.Malla;

		end %getMalla

		function rel = relacionAspecto(geoKran)

			malla = getMalla(geoKran);
			Lx = max(malla.coordenadasU(:,1)) - ... 	
			     min(malla.coordenadasU(:,1));
			Ly = max(malla.coordenadasV(:,2)) - ... 	
			     min(malla.coordenadasV(:,2));
			L = max([Lx Ly]);
			bat = getBatimetria(geoKran);
			hom = mean(bat.hoNodosEta);

			rel = L/hom;

		end % function relacionAspecto

		function hom = profundidadMedia(geoKran)

			bat = getBatimetria(geoKran);
			hom = mean(bat.hoNodosEta);

		end % function profundidadMedia

	end %methods
end %classdef



%%%%%%%%%%%%%%%%%%% THRASH


%		function thisGeometria = construyeKranenburg(thisGeometria, radio, altura, centroMasa)
%			% Función que construye la geometría de Kranenburg (1992)

%			thisGeometria.tipoGeometria = 'Kranenburg';		
%			parametrosGeometria.Radio = radio;
%			parametrosGeometria.Altura = altura;
%			thisGeometria.parametrosGeometria = parametrosGeometria;
%			thisGeometria.centroMasa = centroMasa;
%			thisGeometria.Borde = generaBordeCircular(Borde(), radio, centroMasa);
%			if isempty(thisGeometria.deltaX)		
%				thisGeometria.deltaX = 0.1*radio;
%				thisGeometria.deltaY = thisGeometria.deltaX;
%			end
%			thisGeometria.Malla = Malla(thisGeometria, 'staggered');
%			thisGeometria.Batimetria = batimetriaKranenburg(Batimetria(), thisGeometria);

%		end %function construyeKranenburg


%	        function thisCuerpo = Cuerpo(thisCuerpo, varargin)

%			if nargin == 0

%				thisCuerpo;
%	
%			else
%				keyboard
%				thisCuerpo.Parametros = Parametros();			
%				thisCuerpo.Fluido = Fluido('Agua', thisCuerpo.Parametros.densidadRho, thisCuerpo.Parametros.viscosidadNu);

%				for iVariable = 1:length(varargin)
%					switch class(varargin{iVariable})
%						case 'Geometria' 
%							thisCuerpo.Geometria = varargin{iVariable};
%						case 'Parametros'
%							thisCuerpo.Parametros = varargin{iVariable};
%						case 'Fluido'
%							thisCuerpo.Fluido = varargin{iVariable};
%						otherwise 
%							error(['Clase cuerpo no trabaja con ', class(varargin{iVariable})])
%					end %switch 
%				end %for
%			end %if
%	       	end % function Cuerpo

%		function thisGeometria = Geometria(varargin)
%		% function thisGeometria = Geometria()    
%		% Constructor del objeto Geometria
%	
%			if nargin == 0

%				thisGeometria;
%	
%			else
				
%				for iVariable = 1:nargin
%					switch class(varargin{iVariable})
%						case 'Borde' 
%							thisGeometria.Borde = varargin{iVariable};
%						case 'Malla'
%							thisGeometria.Malla = varargin{iVariable};
%						case 'Batimetria'
%							thisGeometria.Batimetria = varargin{iVariable};
% 						case 'char'
														


%						otherwise 
%							error(['Wrong input argument: Clase Geometria no trabaja con ', class(varargin{iVariable})])
%					end %switch 
%				end %for
%			end %if
%        	 end %function Geometria
%	

