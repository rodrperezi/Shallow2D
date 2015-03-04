% Funciones getPropiedad(objeto)
% La programacion orientada a objetos de Matlab permite acceder
% a la propiedad de un objeto solo si el argumento de la 
% es un objeto de la clase donde está definida la función.
% A mi parecer es más práctico tener la facilidad de 
% acceder a una propiedad desde cualquier parte, por 
% eso este archivo pretende juntar las funciones getPropiedad
% que sean de mayor utilidad durante la programación

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function thisBatimetria = getBatimetria(varargin)	
		if nargin == 1
			switch class(varargin{:})
				case 'Simulacion'				
					thisBatimetria = varargin{:}.Cuerpo.Geometria.Batimetria;					
				case 'Cuerpo'
					thisBatimetria = varargin{:}.Geometria.Batimetria;
				case 'Geometria'
					thisBatimetria = varargin{:}.Batimetria;
				case 'Batimetria'
					thisBatimetria = varargin{:};
				otherwise 
					error(['El objeto ', class(varargin{:}), ' no contiene una Batimetria'])
				end %switch	
		end %if
	end %getBatimetria
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function thisGeometria = getGeometria(varargin)	
		if nargin == 1
			switch class(varargin{:})
				case 'Simulacion'				
					thisGeometria = varargin{:}.Cuerpo.Geometria;					
				case 'Cuerpo'
					thisGeometria = varargin{:}.Geometria;
				case 'Geometria'
					thisGeometria = varargin{:};
				otherwise 
					error(['El objeto ', class(varargin{:}), ' no contiene una Geometria'])
			end %switch	
		end %if
	end %getGeometria
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function thisBorde = getBorde(varargin)	
		if nargin == 1
			switch class(varargin{:})
				case 'Simulacion'				
					thisBorde = varargin{:}.Cuerpo.Geometria.Borde;					
				case 'Cuerpo'
					thisBorde = varargin{:}.Geometria.Borde;
				case 'Geometria'
					thisBorde = varargin{:}.Borde;
				case 'Borde'
					thisBorde = varargin{:};
				otherwise 
					error(['El objeto ', class(varargin{:}), ' no contiene un Borde'])
			end %switch	
		end %if
	end %getBorde
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function thisCuerpo = getCuerpo(varargin)	
		if nargin == 1
			switch class(varargin{:})
				case 'Simulacion'				
					thisCuerpo = varargin{:}.Cuerpo;					
				case 'Cuerpo'
					thisCuerpo = varargin{:};
				otherwise 
					error(['El objeto ', class(varargin{:}), ' no contiene un Cuerpo'])
			end %switch	
		end %if
	end %getCuerpo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function [numeroNodosEta varargout] = getNumeroNodos(varargin)
		if nargin == 1
			malla = getMalla(varargin{:});
			numeroNodosEta = malla.numeroNodosEta;
			numeroNodosU = malla.numeroNodosU;
			numeroNodosV = malla.numeroNodosV;
	
			argoutExtra = max(nargout,1)-1;
			argoutAux = [numeroNodosU, numeroNodosV];		
			for k = 1:argoutExtra, varargout(k) = {argoutAux(k)}; end
		end
	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function [solucionEta varargout] = getEtaUV(varargin, solucionCompleta)
% 	function [solucionEta solucionU solucionV] = getEtaUV(Cuerpo, solucionCompleta)
		if length(varargin) == 1
			malla = getMalla(varargin);
			[numeroNodosEta numeroNodosU numeroNodosV]= getNumeroNodos(varargin{:});
			
			SOL = solucionCompleta;
			Neta = numeroNodosEta;
			Nu = numeroNodosU;
			Nv = numeroNodosV;
			
			IDwe = malla.matrizIDwe;
			IDns = malla.matrizIDns;
			nBIz = malla.numeroBordesIzquierdo;
			nBDe = malla.numeroBordesDerecho;
			nBSu = malla.numeroBordesSuperior;
			nBIn = malla.numeroBordesInferior;
			
			eta = SOL(1:Neta,end);
			
			uaux = sparse(zeros(Nu,1));
			vaux = sparse(zeros(Nv,1));
			
			ku = 1;
			kv = 1;
			
			for iNodosU = 1:Nu
			    if(sum(iNodosU == [IDwe(nBIz,1);IDwe(nBDe,2)])==0);
				% Como los bordes son eliminados en la generacion 	
				% de matrices producto de la asignación de la 
				% condición de borde de velocidad nula, debo
				% saltarme los nodos que son borde.
			       	uaux(iNodosU) = SOL(Neta + ku); 
			       	ku = ku+1;
			    end
			end
			    
			for iNodosV = 1:Nv
			    if(sum(iNodosV == [IDns(nBSu,1);IDns(nBIn,2)])==0);
			       	vaux(iNodosV) = SOL(Neta + kv + Nu - length([IDwe(nBIz,1);IDwe(nBDe,2)]));
			       	kv= kv+1;
			    end    
			end
        	
			for iNodosEta = 1:Neta
				% Promedio los valores de u y v para las posiciones
				% de los nodos Eta
			    u(iNodosEta,1) = mean(uaux(IDwe(iNodosEta,:)));
			    v(iNodosEta,1) = mean(vaux(IDns(iNodosEta,:)));
			end
	
			solucionEta = eta;
			solucionU = u;
			solucionV = v;
	
			argoutExtra = max(nargout,1)-1;
			argoutAux = {solucionU, solucionV};		
			for k = 1:argoutExtra, varargout(k) = {argoutAux{k}}; end
		end	
	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55

