classdef Grafico < hgsetget

	% GRAFICO es el objeto que permite implementar cualquiera
	% de los graficos que se encuentran disponibles en el modelo

	properties 

		Handle
		Tipo
	
	end

	methods

		function thisGrafico = Grafico()
							
			if nargin == 0			
				thisGrafico;
			end			
	
		end %function Grafico

		function thisGrafico = graficaMalla(thisGrafico, varargin)

			areaMarker = 40;
			malla = getMalla(varargin{:});
			coordenadasEta = malla.coordenadasEta;	
			coordenadasU = malla.coordenadasU;	
			coordenadasV = malla.coordenadasV;
	
			graficaBorde(thisGrafico, varargin{:});
			hold on
			scatter(coordenadasEta(:,1), coordenadasEta(:,2), areaMarker, 's', 'markeredgecolor', 'k', 'markerfacecolor', 0*[1 1 1])
			scatter(coordenadasU(:,1), coordenadasU(:,2), areaMarker, '>', 'markeredgecolor', 'k', 'markerfacecolor', 0.5*[1 1 1])
			scatter(coordenadasV(:,1), coordenadasV(:,2), areaMarker, '^', 'markeredgecolor', 'k', 'markerfacecolor', 1*[1 1 1])
			hold off
		
			xlabel('x [m]', 'interpreter', 'latex')	
			ylabel('y [m]', 'interpreter', 'latex')	
			asignaAxisLim(thisGrafico, varargin{:});
			axis equal			

		end %function graficaMalla

		function thisGrafico = graficaBorde(thisGrafico, objeto)

			borde = getBorde(objeto);
			plot(borde.coordenadasXY(:,1), borde.coordenadasXY(:,2),'k', 'linewidth', 1)

		end %function graficaBorde

		function thisGrafico = graficaEta(thisGrafico, simulacion, eta)

			[dx dy] = getDeltaX(simulacion);
			malla = getMalla(simulacion);
			coordenadasEta = malla.coordenadasEta;
			% val = getEtaUV(simulacion, eta);
			x = coordenadasEta(:,1);
			y = coordenadasEta(:,2);
			x = x';
			y = y';
			val = eta';
			coordenadasX = [x-dx/2; x+dx/2; x+dx/2; x-dx/2; x-dx/2];
			coordenadasY = [y-dy/2; y-dy/2; y+dy/2; y+dy/2; y-dy/2];
			valorPatch = [val; val; val; val; val];
			patch(coordenadasX, coordenadasY, valorPatch)
			shading('interp')

		end % function graficaEta

		function thisGrafico = graficaVelocidad(thisGrafico, simulacion, uMatriz, vMatriz)

			malla = getMalla(simulacion);
			x = malla.coordenadasEta2DX;
			y = malla.coordenadasEta2DY;
			handleQuiver = quiver(x,y,uMatriz,vMatriz, 'color', 0*[1 1 1]);


		end

		function thisGrafico = graficaHidrodinamica(thisGrafico, simulacion, varargin)
			
			if isempty(simulacion.Resultados) 
				error(['La simulacion aún no tiene resuelta la Hidrodinámica'])
			else
				solHidro = getHidrodinamica(simulacion);

				if isempty(solHidro.Solucion2D)
					error('La solución no ha sido transformada a 2D. Ejecutar solucion2D(simulacion, apostrofe hidrodinamica apostrofe)')			
				end %if
				% Una vez que tengo la solución, debo 
				% ver si es permanente o impermanente. 
				% En el primer caso, entonces hago el 
				% grafico. Si es impermanente, 
				% puedo hacer el grafico de algun tiempo 
				% en particular o el grafico tipo video				
				if strcmpi(solHidro.RegimenTemporal, 'impermanente')	
		
					if strcmpi(varargin, 'permanente')
					% Si bien la solución fue calculada con el régimen 
					% impermanente, puede interesar ver el resultado del 
					% estado permanente. En ese caso, se asume que el 
					% último componente de la solución o sea solucion(:,end)									
					% es el estado permanente
						nEta = getNumeroNodos(simulacion);
						etaMax = max(max(solHidro.Solucion(1:nEta,end)));
						etaMin = min(min(solHidro.Solucion(1:nEta,end)));
						sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
						eta = getEtaUV(simulacion, solHidro.Solucion(:,end));
						graficaBorde(thisGrafico, simulacion);
						hold on
						graficaVelocidad(thisGrafico, simulacion, sol2D.solucionU2D(:,:,end), sol2D.solucionV2D(:,:,end));		
						graficaEta(thisGrafico, simulacion, eta); 
						hold off
						barraColor = colorbar;
						caxis([etaMin etaMax])
						xlabel(barraColor, '$\eta [m]$', 'interpreter', 'latex')
						asignaAxisLim(thisGrafico, simulacion);
						axis equal
						xlabel('$x [m]$', 'interpreter', 'latex')	
						ylabel('$y [m]$', 'interpreter', 'latex')

					elseif isempty(varargin)
						tiempo = solHidro.Tiempo;
						nEta = getNumeroNodos(simulacion);
						etaMax = max(max(solHidro.Solucion(1:nEta,:)));
						etaMin = min(min(solHidro.Solucion(1:nEta,:)));
						sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;					

						for iTiempo = 1:length(tiempo)
							eta = getEtaUV(simulacion, solHidro.Solucion(:,iTiempo));
							graficaBorde(thisGrafico, simulacion);
							hold on
							graficaVelocidad(thisGrafico, simulacion, sol2D.solucionU2D(:,:,iTiempo), sol2D.solucionV2D(:,:,iTiempo));		
							graficaEta(thisGrafico, simulacion, eta); 
							hold off
							barraColor = colorbar;
							caxis([etaMin etaMax])
							xlabel(barraColor, '$\eta [m]$', 'interpreter', 'latex')
							asignaAxisLim(thisGrafico, simulacion);
							axis equal
							xlabel('$x [m]$', 'interpreter', 'latex')	
							ylabel('$y [m]$', 'interpreter', 'latex')	
							pause(0.01)
						end %for

						hold off
					else
					
						error('Argumento no válido')

					end %if	

				elseif strcmpi(solHidro.RegimenTemporal, 'permanente')
					
					nEta = getNumeroNodos(simulacion);
					etaMax = max(max(solHidro.Solucion(1:nEta)));
					etaMin = min(min(solHidro.Solucion(1:nEta)));
					sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
					eta = getEtaUV(simulacion, solHidro.Solucion);
					graficaBorde(thisGrafico, simulacion);
					hold on
					graficaVelocidad(thisGrafico, simulacion, sol2D.solucionU2D, sol2D.solucionV2D);		
					graficaEta(thisGrafico, simulacion, eta); 
					hold off
					barraColor = colorbar;
					caxis([etaMin etaMax])
					xlabel(barraColor, '$\eta [m]$', 'interpreter', 'latex')
					asignaAxisLim(thisGrafico, simulacion);
					axis equal
					xlabel('$x [m]$', 'interpreter', 'latex')	
					ylabel('$y [m]$', 'interpreter', 'latex')	

				end %if
			end %if
		end %function graficaHidrodinamica

%		function thisGrafico = graficaTransporteOD(thisGrafico, simulacion, varargin)
%			% REVISA ESTA WEA PORQUE HAY QUE PEDIR LOS RESULTADOS DEL TRANSPORTEOD
%			% EN FUNCION DE COMO LOS PIDA
%			if isempty(simulacion.Resultados.TransporteOD) 
%				error(['La simulacion aún no tiene resuelta la TransporteOD'])
%			else
%				solTrans = getTransporteOD(simulacion);

%				if isempty(solTrans.Solucion2D)
%					error('La solución no ha sido transformada a 2D. Ejecutar solucion2D(simulacion, apostrofe transporteOD apostrofe)')			
%				end %if
%				% Una vez que tengo la solución, debo 
%				% ver si es permanente o impermanente. 
%				% En el primer caso, entonces hago el 
%				% grafico. Si es impermanente, 
%				% puedo hacer el grafico de algun tiempo 
%				% en particular o el grafico tipo video				
%				if strcmpi(solTrans.RegimenTemporal, 'impermanente')	
%		
%					if strcmpi(varargin, 'permanente')
%					% Si bien la solución fue calculada con el régimen 
%					% impermanente, puede interesar ver el resultado del 
%					% estado permanente. En ese caso, se asume que el 
%					% último componente de la solución o sea solucion(:,end)									
%					% es el estado permanente
%						nEta = getNumeroNodos(simulacion);
%						etaMax = max(max(solTrans.Solucion(1:nEta,end)));
%						etaMin = min(min(solTrans.Solucion(1:nEta,end)));
%						sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
%%						concentracion = AQUI HAY QUE PEDIR EL RESULTADO DE CONCENTRACION
%						graficaBorde(thisGrafico, simulacion);
%						hold on
%						graficaVelocidad(thisGrafico, simulacion, sol2D.solucionU2D(:,:,end), sol2D.solucionV2D(:,:,end));		
%						graficaEta(thisGrafico, simulacion, eta); 
%						hold off
%						barraColor = colorbar;
%						caxis([etaMin etaMax])
%						xlabel(barraColor, '$\eta [m]$', 'interpreter', 'latex')
%						asignaAxisLim(thisGrafico, simulacion);
%						axis equal
%						xlabel('$x [m]$', 'interpreter', 'latex')	
%						ylabel('$y [m]$', 'interpreter', 'latex')

%					elseif isempty(varargin)
%						tiempo = solHidro.Tiempo;
%						nEta = getNumeroNodos(simulacion);
%						etaMax = max(max(solHidro.Solucion(1:nEta,:)));
%						etaMin = min(min(solHidro.Solucion(1:nEta,:)));
%						sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;					

%						for iTiempo = 1:length(tiempo)
%							eta = getEtaUV(simulacion, solHidro.Solucion(:,iTiempo));
%							graficaBorde(thisGrafico, simulacion);
%							hold on
%							graficaVelocidad(thisGrafico, simulacion, sol2D.solucionU2D(:,:,iTiempo), sol2D.solucionV2D(:,:,iTiempo));		
%							graficaEta(thisGrafico, simulacion, eta); 
%							hold off
%							barraColor = colorbar;
%							caxis([etaMin etaMax])
%							xlabel(barraColor, '$\eta [m]$', 'interpreter', 'latex')
%							asignaAxisLim(thisGrafico, simulacion);
%							axis equal
%							xlabel('$x [m]$', 'interpreter', 'latex')	
%							ylabel('$y [m]$', 'interpreter', 'latex')	
%							pause(0.01)
%						end %for

%						hold off
%					else
%					
%						error('Argumento no válido')

%					end %if	

%				elseif strcmpi(solHidro.RegimenTemporal, 'permanente')
%					
%					nEta = getNumeroNodos(simulacion);
%					etaMax = max(max(solHidro.Solucion(1:nEta)));
%					etaMin = min(min(solHidro.Solucion(1:nEta)));
%					sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
%					eta = getEtaUV(simulacion, solHidro.Solucion);
%					graficaBorde(thisGrafico, simulacion);
%					hold on
%					graficaVelocidad(thisGrafico, simulacion, sol2D.solucionU2D, sol2D.solucionV2D);		
%					graficaEta(thisGrafico, simulacion, eta); 
%					hold off
%					barraColor = colorbar;
%					caxis([etaMin etaMax])
%					xlabel(barraColor, '$\eta [m]$', 'interpreter', 'latex')
%					asignaAxisLim(thisGrafico, simulacion);
%					axis equal
%					xlabel('$x [m]$', 'interpreter', 'latex')	
%					ylabel('$y [m]$', 'interpreter', 'latex')	

%				end %if
%			end %if
%		end %function graficaTransporteOD

		function thisGrafico = graficaBatimetria(thisGrafico, simulacion)

			bat = getBatimetria(simulacion);
			graficaBorde(thisGrafico, simulacion);
			hold on
			graficaEta(thisGrafico, simulacion, bat.hoNodosEta); 
			barraColor = colorbar;
			caxis([min(bat.hoNodosEta) max(bat.hoNodosEta)])
			xlabel(barraColor, '$h_o [m]$', 'interpreter', 'latex')
			asignaAxisLim(thisGrafico, simulacion);
			axis equal
			xlabel('$x [m]$', 'interpreter', 'latex')	
			ylabel('$y [m]$', 'interpreter', 'latex')	

		end %function graficaBatimetria

		function thisGrafico = asignaAxisLim(thisGrafico, objeto)
	
			malla = getMalla(objeto);
			coordenadasEta = malla.coordenadasEta;	

			deltaFraccion = 0.1;
			signoXMin = sign(min(coordenadasEta(:,1)));
			signoXMax = sign(max(coordenadasEta(:,1)));
			signoYMin = sign(min(coordenadasEta(:,2)));
			signoYMax = sign(max(coordenadasEta(:,2)));

			if signoXMin == -1; 
				facXMin = (1 + deltaFraccion);
			else
				facXMin = (1 - deltaFraccion);	
			end

			if signoXMax == -1; 
				facXMax = (1 - deltaFraccion);
			else
				facXMax = (1 + deltaFraccion);	
			end

			if signoYMin == -1; 
				facYMin = (1 + deltaFraccion);
			else
				facYMin = (1 - deltaFraccion);	
			end

			if signoYMax == -1; 
				facYMax = (1 - deltaFraccion);
			else
				facYMax = (1 + deltaFraccion);	
			end

			xlim([facXMin*min(coordenadasEta(:,1)) facXMax*max(coordenadasEta(:,1))])
			ylim([facYMin*min(coordenadasEta(:,1)) facYMax*max(coordenadasEta(:,2))])

		end % function asignaAxisLim
	end %methods
end % classdef
