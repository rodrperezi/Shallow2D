	function [solucionEta varargout] = getEtaUV(varargin, solucionCompleta)
		if nargin == 2
			objeto = varargin;
			malla = getMalla(objeto);
			[numeroNodosEta numeroNodosU numeroNodosV]= getNumeroNodos(objeto);
			
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
			
			eta = SOL(1:Neta);
			
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
