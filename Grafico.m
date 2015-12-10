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

			areaMarker = 25;
			if strcmpi(class(varargin{1}), 'staggered') || strcmpi(class(varargin{1}), 'malla')
				malla = varargin{1};

			else

				malla = getMalla(varargin{:});
	
			end

			coordenadasEta = malla.coordenadasEta;	
			coordenadasU = malla.coordenadasU;	
			coordenadasV = malla.coordenadasV;
	
			graficaBorde(thisGrafico, varargin{:});
			hold on

			% GENERALIZAR ESTO PARA CUALQUIER GEOMETRIA

			% geoVieja = getGeometria(varargin{:});
			geoVieja = varargin{:};
			R = geoVieja.radioR;

			handle.scatterEta = scatter(coordenadasEta(:,1)/R, coordenadasEta(:,2)/R, areaMarker, 's', 'markeredgecolor', 'k', 'markerfacecolor', 0*[1 1 1]);
			handle.scatterU = scatter(coordenadasU(:,1)/R, coordenadasU(:,2)/R, areaMarker, '>', 'markeredgecolor', 'k', 'markerfacecolor', 0.5*[1 1 1]);
			handle.scatterV = scatter(coordenadasV(:,1)/R, coordenadasV(:,2)/R, areaMarker, '^', 'markeredgecolor', 'k', 'markerfacecolor', 1*[1 1 1]);
			hold off
			xlabel('$x [m]$', 'interpreter', 'latex')	
			ylabel('$y [m]$', 'interpreter', 'latex')	
			% asignaAxisLim(thisGrafico, varargin{:});
			axis equal			

			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'Malla';

		end %function graficaMalla

		function thisGrafico = graficaBorde(thisGrafico, objeto)
		
			% if ~strcmpi(class(objeto), 'Geometria')
				% geoVieja = getGeometria(objeto);
			% else
			geo = getGeometria(objeto);
			% end

			% R = geoVieja.radioR;
			R = geo.radioR;
			borde = getBorde(objeto);
			% handle.plot = plot(borde.coordenadasXY(:,1), borde.coordenadasXY(:,2),'k', 'linewidth', 1);
			handle.plot = plot(borde.coordenadasXY(:,1)/R, borde.coordenadasXY(:,2)/R,'k', 'linewidth', 1);
			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'Borde';

		end %function graficaBorde

		function thisGrafico = graficaModo(thisGrafico, simulacion, estructura, varargin)

			estructuraAPlot = real(estructura);			
			nEta = getNumeroNodos(simulacion);
			maxEta = max(estructuraAPlot(1:nEta));
			if isempty(varargin)
				handle.plotEta = graficaEta(Grafico(), simulacion, ... 
						 estructuraAPlot(1:nEta));
				handle.barraColor = colorbar;
			else
				maxEta = varargin{1};
				handle.plotEta = graficaEta(Grafico(), simulacion, ... 
					         estructuraAPlot(1:nEta)/maxEta);	
				handle.barraColor = colorbar;
				caxis([-1 1])
			end
			
			hold on 
			handle.plotBorde = graficaBorde(Grafico(), simulacion);
			[simulacion, estr2D] = solucion2D(simulacion, 'modo', estructuraAPlot);
			% keyboard
			handle.plotVel = graficaVelocidad(Grafico(), simulacion, estr2D.U2D, estr2D.V2D);
			hold off

			xlabel(handle.barraColor, '$\eta \eta_{max}^{-1}$', 'interpreter', 'latex')
			xlim([-1.2 1.2])
			ylim([-1.2 1.2])
			handle.ejes = gca;

			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'Modo';

		end % function graficaModo

		function thisGrafico = graficaEta(thisGrafico, simulacion, eta)

			[dx dy] = getDeltaX(simulacion);
			geoVieja = getGeometria(simulacion);
			% geoVieja.Malla = [];
			mallaNueva = Staggered(Malla(), geoVieja, 0.5*dx, 0.5*dy);
			malla = getMalla(simulacion);
			coordenadasEta = malla.coordenadasEta;
			interpEta = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(eta)); % Interpolador eta

			coordNueva = mallaNueva.coordenadasEta;
			etaInterp = interpEta(coordNueva(:,1), coordNueva(:,2));

			% val = getEtaUV(simulacion, eta);
			% x = coordenadasEta(:,1);
			% y = coordenadasEta(:,2);
			x = coordNueva(:,1);
			y = coordNueva(:,2);
			x = x';
			y = y';
			% val = eta';
			val = etaInterp';
			coordenadasX = [x-dx/2; x+dx/2; x+dx/2; x-dx/2; x-dx/2];
			coordenadasY = [y-dy/2; y-dy/2; y+dy/2; y+dy/2; y-dy/2]; 	
			coordBorde = geoVieja.Borde.coordenadasXY;
			matrizIndices = inpolygon(coordenadasX, coordenadasY, coordBorde(:,1), coordBorde(:,2)); 
			valorPatch = [val; val; val; val; val];
			valorPatch(matrizIndices == 0) = NaN;
			% handle.patch = patch(coordenadasX, coordenadasY, valorPatch);
			R = geoVieja.radioR;
			handle.patch = patch(coordenadasX/R, coordenadasY/R, valorPatch);
			shading('interp')
			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'Eta';

		end % function graficaEta

		function thisGrafico = graficaVelocidad(thisGrafico, simulacion, uMatriz, vMatriz)

			geoVieja = getGeometria(simulacion);
			R = geoVieja.radioR;
			malla = getMalla(simulacion);
			x = malla.coordenadasEta2DX;
			y = malla.coordenadasEta2DY;
			% handle.quiver = quiver(x,y,uMatriz,vMatriz, 'color', 0*[1 1 1]);
			handle.quiver = quiver(x/R,y/R,uMatriz,vMatriz, 'color', 0*[1 1 1]);
			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'Velocidad';

		end % function graficaVelocidad

		function thisGrafico = graficaPecletVertical(thisGrafico, simulacion)

			borde = getBorde(simulacion);
			trans = getTransporte(simulacion);	
			numPecletVert = pecletVertical(trans, simulacion);
			sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
			
			handle.plotEta = graficaEta(Grafico(), simulacion, numPecletVert);
			hold on 
			handle.plotVelocidad = graficaVelocidad(Grafico(), simulacion, sol2D.solucionU2D, sol2D.solucionV2D);
			geoVieja = getGeometria(simulacion);
			R = geoVieja.radioR;
			handle.plotBorde = plot(borde.coordenadasXY(:,1)/R, borde.coordenadasXY(:,2)/R,'k', 'linewidth', 1);

			hold off
			handle.barraColor = colorbar;
			caxis([min(numPecletVert) max(numPecletVert)])
			xlabel(handle.barraColor, '$Pe_{v}$', 'interpreter', 'latex')

			handle.ejes = gca;
	
			xlim([-1.2 1.2])
			ylim([-1.2 1.2])
			xlabel(handle.ejes, ['$x', 'R', '^{-1}$'], 'interpreter', 'latex')
			ylabel(handle.ejes, ['$y', 'R', '^{-1}$'], 'interpreter', 'latex')
			box(handle.ejes)
			axis square

			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'PecletVertical';

			% keyboard		
%			thisGrafico = asignaAxisLim(thisGrafico, simulacion);
%			malla = getMalla(simulacion);
%			Lx = max(malla.coordenadasU(:,1)) - ... 	
%			     min(malla.coordenadasU(:,1));
%			Ly = max(malla.coordenadasV(:,2)) - ... 	
%			     min(malla.coordenadasV(:,2));
%			L = max([Lx Ly]);
			% thisGrafico = ejesAdimensionales(thisGrafico, simulacion, 'R', 0.5*L);

		end % graficaPecletVertical

		function thisGrafico = graficaFlujoSedimentos(thisGrafico, simulacion)

			borde = getBorde(simulacion);
			trans = getTransporte(simulacion);	
			flujoSed = flujoSedimentos(trans);
			flujoSed = abs(flujoSed);
			sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
			
			handle.plotEta = graficaEta(Grafico(), simulacion, flujoSed);
			hold on 
			handle.plotVelocidad = graficaVelocidad(Grafico(), simulacion, sol2D.solucionU2D, sol2D.solucionV2D);
			geoVieja = getGeometria(simulacion);
			R = geoVieja.radioR;
			handle.plotBorde = plot(borde.coordenadasXY(:,1)/R, borde.coordenadasXY(:,2)/R,'k', 'linewidth', 1);

			hold off
			handle.barraColor = colorbar;
			caxis([0.5*min(flujoSed) max(flujoSed)])
			xlabel(handle.barraColor, '$|F_{sed}| \left[kg m^{-2} s^{-1}\right]$', 'interpreter', 'latex')

			handle.ejes = gca;
	
			xlim([-1.2 1.2])
			ylim([-1.2 1.2])
			xlabel(handle.ejes, ['$x', 'R', '^{-1}$'], 'interpreter', 'latex')
			ylabel(handle.ejes, ['$y', 'R', '^{-1}$'], 'interpreter', 'latex')
			box(handle.ejes)
			axis square

			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'FlujoSedimentos';
			% keyboard
%			
%			thisGrafico = asignaAxisLim(thisGrafico, simulacion);
%			malla = getMalla(simulacion);
%			Lx = max(malla.coordenadasU(:,1)) - ... 	
%			     min(malla.coordenadasU(:,1));
%			Ly = max(malla.coordenadasV(:,2)) - ... 	
%			     min(malla.coordenadasV(:,2));
%			L = max([Lx Ly]);
%			thisGrafico = ejesAdimensionales(thisGrafico, simulacion, 'R', 0.5*L);

		end % graficaFlujoSedimentos

		function thisGrafico = graficaKt(thisGrafico, simulacion)

			borde = getBorde(simulacion);
			trans = getTransporte(simulacion);	
			masa = getMasa(trans);
			kt = masa.FlujosVerticales.flujoSed.kt;
			sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
			
			handle.plotEta = graficaEta(Grafico(), simulacion, kt);
			hold on 
			handle.plotVelocidad = graficaVelocidad(Grafico(), simulacion, sol2D.solucionU2D, sol2D.solucionV2D);
			geoVieja = getGeometria(simulacion);
			R = geoVieja.radioR;
			handle.plotBorde = plot(borde.coordenadasXY(:,1)/R, borde.coordenadasXY(:,2)/R,'k', 'linewidth', 1);

			hold off
			handle.barraColor = colorbar;
			caxis([0.05*min(kt) 0.95*max(kt)])
			xlabel(handle.barraColor, '$k_t \left[m s^{-1}\right]$', 'interpreter', 'latex')

			handle.ejes = gca;
	
			xlim([-1.2 1.2])
			ylim([-1.2 1.2])
			xlabel(handle.ejes, ['$x', 'R', '^{-1}$'], 'interpreter', 'latex')
			ylabel(handle.ejes, ['$y', 'R', '^{-1}$'], 'interpreter', 'latex')
			box(handle.ejes)
			axis square

			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'Kt';

		end % graficaKt

		function thisGrafico = graficaConcentracion(thisGrafico, simulacion)

			borde = getBorde(simulacion);
			trans = getTransporte(simulacion);	
			masa = getMasa(trans);
			cSat = masa.concSaturacion;
			conc = trans.Solucion/cSat;
			sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
			
			handle.plotEta = graficaEta(Grafico(), simulacion, conc);
			hold on 
			handle.plotVelocidad = graficaVelocidad(Grafico(), simulacion, sol2D.solucionU2D, sol2D.solucionV2D);
			geoVieja = getGeometria(simulacion);
			R = geoVieja.radioR;
			handle.plotBorde = plot(borde.coordenadasXY(:,1)/R, borde.coordenadasXY(:,2)/R,'k', 'linewidth', 1);

			hold off
			handle.barraColor = colorbar;
			caxis([1.09*min(conc) 1.15*max(conc)])
			xlabel(handle.barraColor, '$CC_s^{-1}$', 'interpreter', 'latex')

			handle.ejes = gca;
	
			xlim([-1.2 1.2])
			ylim([-1.2 1.2])
			xlabel(handle.ejes, ['$x', 'R', '^{-1}$'], 'interpreter', 'latex')
			ylabel(handle.ejes, ['$y', 'R', '^{-1}$'], 'interpreter', 'latex')
			box(handle.ejes)
			axis square

			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'Concentracion';

		end % graficaKt


		function thisGrafico = graficaHidrodinamica(thisGrafico, simulacion, varargin)
			% keyboard
			if length(varargin) > 1
				error('La función recibe sólo tres argumentos')
			end

			solHidro = getHidrodinamica(simulacion);

			if isempty(solHidro) 
				error(['La simulacion aún no tiene resuelta la Hidrodinámica'])
			end

			if isempty(solHidro.Solucion2D)
				error('La solución no ha sido transformada a 2D. Ejecutar solucion2D(simulacion, apostrofe hidrodinamica apostrofe)')			
			end %if
			
			% Una vez que tengo la solución, debo 
			% ver si es permanente o impermanente. 
			% En el primer caso, entonces hago el 
			% grafico. Si es impermanente, 
			% puedo hacer el grafico de algun tiempo 
			% en particular o el grafico tipo video				

			nEta = getNumeroNodos(simulacion);

			if strcmpi(solHidro.RegimenTemporal, 'impermanente')	

				tiempo = solHidro.Tiempo;
				etaMax = max(max(solHidro.Solucion(1:nEta,:)));
				etaMin = min(min(solHidro.Solucion(1:nEta,:)));
				sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;

				if isempty(varargin)

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
						% asignaAxisLim(thisGrafico, simulacion);
						axis equal
						xlabel('$x [m]$', 'interpreter', 'latex')	
						ylabel('$y [m]$', 'interpreter', 'latex')	
						pause(0.01)
					end %for

					hold off

				elseif strcmpi(varargin{1}, 'permanente') || strcmpi(class(varargin{1}), 'double')

				% Si bien la solución fue calculada con el régimen 
				% impermanente, puede interesar ver el resultado del 
				% estado permanente. En ese caso, se asume que el 
				% último componente de la solución o sea solucion(:,end)									
				% es el estado permanente
					
					if strcmpi(class(varargin{1}), 'double')

						posTiempo = varargin{1};

						if varargin{1} > length(tiempo)
							error(['Estás intentando graficar un tiempo superior al máximo resuelto. El máximo es ', num2str(length(tiempo))])
						end
					else
						posTiempo = length(tiempo);
					end
				
%					etaMax = max(max(solHidro.Solucion(1:nEta,end)));
%					etaMin = min(min(solHidro.Solucion(1:nEta,end)));
%					sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
					eta = getEtaUV(simulacion, solHidro.Solucion(:,posTiempo));
					graficaBorde(thisGrafico, simulacion);
					hold on
					graficaVelocidad(thisGrafico, simulacion, sol2D.solucionU2D(:,:,posTiempo), sol2D.solucionV2D(:,:,posTiempo));		
					graficaEta(thisGrafico, simulacion, eta); 
					hold off
					barraColor = colorbar;
					caxis([etaMin etaMax])
					xlabel(barraColor, '$\eta [m]$', 'interpreter', 'latex')
					asignaAxisLim(thisGrafico, simulacion);
					axis equal
					xlabel('$x [m]$', 'interpreter', 'latex')	
					ylabel('$y [m]$', 'interpreter', 'latex')

				elseif strcmpi(varargin{1}, 'impermanente')

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
		
				if isempty(varargin)

					etaMax = max(max(solHidro.Solucion(1:nEta)));
					etaMin = min(min(solHidro.Solucion(1:nEta)));
					sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
					eta = getEtaUV(simulacion, solHidro.Solucion);
					handle.plotEta = graficaEta(Grafico(), simulacion, eta/etaMax); 
					hold on
					borde = getBorde(simulacion);
					geoVieja = getGeometria(simulacion);
					R = geoVieja.radioR;
					handle.plotBorde = plot(borde.coordenadasXY(:,1)/R, ...
					borde.coordenadasXY(:,2)/R,'k', 'linewidth', 1);
					handle.plotVelocidad = graficaVelocidad(Grafico(), simulacion, sol2D.solucionU2D, sol2D.solucionV2D);		

					hold off
					handle.barraColor = colorbar;
					caxis([-1 1])
					xlabel(handle.barraColor, '$\eta \eta_{max}^{-1}$', 'interpreter', 'latex')
					% asignaAxisLim(thisGrafico, simulacion);
					% axis equal
					handle.ejes = gca;
					xlim([-1.2 1.2])
					ylim([-1.2 1.2])

					xlabel(handle.ejes, ['$x', 'R', '^{-1}$'], 'interpreter', 'latex')
					ylabel(handle.ejes, ['$y', 'R', '^{-1}$'], 'interpreter', 'latex')
					box(handle.ejes)
					axis square

					thisGrafico.Handle = handle;
					thisGrafico.Tipo = 'Hidrodinamica';

				elseif strcmpi(varargin{1}, 'impermanente')

					error('El régimen temporal de la solución es permanente. No puedes visualizar el régimen impermanente')

				elseif strcmpi(varargin{1}, 'velocidad')

					sol2D = simulacion.Resultados.Hidrodinamica.Solucion2D;
					[eta u v]= getEtaUV(simulacion, solHidro.Solucion);
					vel = sqrt(u.^2 + v.^2);
					velMax = max(vel);
					velMin = min(vel);
					velAd = abs(vel)/velMax;
					handle.plotEta = graficaEta(Grafico(), simulacion, velAd); 
					hold on
					geoVieja = getGeometria(simulacion);
					R = geoVieja.radioR;
					borde= getBorde(simulacion);
					handle.plotBorde = plot(borde.coordenadasXY(:,1)/R, ...
					borde.coordenadasXY(:,2)/R,'k', 'linewidth', 1);
					handle.plotVelocidad = graficaVelocidad(Grafico(), simulacion, sol2D.solucionU2D, sol2D.solucionV2D);		
					hold off
					handle.barraColor = colorbar;
					caxis([min(velAd) max(velAd)])
					xlabel(handle.barraColor, '$|\mathrm{\textbf v}| |\mathrm{\textbf v}|_{max}^{-1}$', 'interpreter', 'latex')
					handle.ejes = gca;
					xlim([-1.2 1.2])
					ylim([-1.2 1.2])

					xlabel(handle.ejes, ['$x', 'R', '^{-1}$'], 'interpreter', 'latex')
					ylabel(handle.ejes, ['$y', 'R', '^{-1}$'], 'interpreter', 'latex')
					box(handle.ejes)
					axis square

					thisGrafico.Handle = handle;
					thisGrafico.Tipo = 'HidrodinamicaVel';
				end

			end %if
		end %function graficaHidrodinamica

		function thisGrafico = graficaPerfilEta(thisGrafico, simulacion, direccion, fraccionPosicion, varargin)

			nEta = getNumeroNodos(simulacion);
			solHidro = getHidrodinamica(simulacion);
			malla = getMalla(simulacion);

			if strcmpi(direccion, 'x') 

				buscaPosPerfil = malla.coordenadasEta2DY;
				minPosPerfil = min(min(buscaPosPerfil));
				posPerfil = minPosPerfil + fraccionPosicion*abs(max(max(buscaPosPerfil)) - minPosPerfil); 
				[fila col] = find(buscaPosPerfil <= posPerfil);
				entradaPosterior = min(fila);				
				entradaAnterior = entradaPosterior - 1;
				largoCoordenadas = length(malla.coordenadasEta2DX(:, 1));
				coordenadasPerfil = [malla.coordenadasEta2DX(entradaAnterior,:)', posPerfil*ones(largoCoordenadas,1)];
				labelXPlot = '$x [m]$';
				coordXPlot = 1;

			elseif strcmpi(direccion, 'y') 

				buscaPosPerfil = malla.coordenadasEta2DX;
				minPosPerfil = min(min(buscaPosPerfil));
				posPerfil = minPosPerfil + fraccionPosicion*abs(max(max(buscaPosPerfil)) - minPosPerfil); 
				[fila col] = find(buscaPosPerfil <= posPerfil);
				entradaAnterior = max(col);
				entradaPosterior = entradaAnterior + 1;	
				largoCoordenadas = length(malla.coordenadasEta2DY(:, 1));
				coordenadasPerfil = [posPerfil*ones(largoCoordenadas,1), malla.coordenadasEta2DY(:, entradaAnterior)];
				labelXPlot = '$yR^{-1}$';
				coordXPlot = 2;

			else 
				error('Direccion especificada debe ser x o y')
			end

			if isempty(varargin)
				eta = getEtaUV(simulacion, solHidro.Solucion(:,end));
			else
				eta = varargin{1};
			end
			coordenadasEta = malla.coordenadasEta;
			interpEta = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(eta)); % Interpolador eta
			etaInterp = interpEta(coordenadasPerfil(:,1), coordenadasPerfil(:,2));

			% Grafico perfil eta
			geo = getGeometria(simulacion);
			alturaH = geo.alturaH;
			radioR = geo.radioR;

			if isempty(varargin)
				handle.scatter = scatter(coordenadasPerfil(:,coordXPlot)/radioR, etaInterp/alturaH);
				ylabel('$\eta H^{-1}$', 'interpreter', 'latex')
			else
				handle.scatter = scatter(coordenadasPerfil(:,coordXPlot)/radioR, etaInterp/varargin{2});
				ylabel('$\eta \eta^{-1}_{max}$', 'interpreter', 'latex')
			end
				
			xlabel(labelXPlot, 'interpreter', 'latex')	
			xlim([-1.2 1.2])

			thisGrafico.Handle = handle;
			thisGrafico.Tipo =  'PerfilTransversalEta';

		end


		function thisGrafico = graficaPerfilTransversal(thisGrafico, simulacion, direccion, fraccionPosicion, varargin)
			
			% La idea es visualizar el perfil transversal 
			% de eta y de velocidad, ya sea en el regimen 
			% permanente o impermanente, según sea especificado
			% en regTemporal

			% Construyo el espacio para graficar. En principio
			% incluyo en el grafico todas las variables que resuelve 
			% el programa. Luego veo si es que es necesario eliminar alguna

			cuadroSubPlot(1) = subplot(3,2,[1,3,5]); % Panel para hidrodinamica
			cuadroSubPlot(2) = subplot(3,2,2); 	 % Panel para eta
			cuadroSubPlot(3) = subplot(3,2,4); 	 % Panel para U
			cuadroSubPlot(4) = subplot(3,2,6); 	 % Panel para V

			% Graficar linea que muestra la seccion. Para ello 
			% debo encontrar las coordenadas que caracterizan la linea.
			% Por ejemplo, si quiero graficar un perfil en la direccion	
			% 'x', entonces debo definir en que coordenada 'y' estará 
			% ubicado el perfil. La coordenada 'y' en este caso es 
			% definida por el parametro fraccionPosicion, el cual 
			% determina en que fraccion del largo total en la 
			% direccion 'y' se encontrara el perfil. El perfil 
			% estara ubicado en la coordenada min(y) + fraccionPosicion*largo(y)

		
			malla = getMalla(simulacion);

			if strcmpi(direccion, 'x') 

				buscaPosPerfil = malla.coordenadasEta2DY;
				minPosPerfil = min(min(buscaPosPerfil));
				posPerfil = minPosPerfil + fraccionPosicion*abs(max(max(buscaPosPerfil)) - minPosPerfil); 
				[fila col] = find(buscaPosPerfil <= posPerfil);
				entradaPosterior = min(fila);				
				entradaAnterior = entradaPosterior - 1;
				largoCoordenadas = length(malla.coordenadasEta2DX(:, 1));
				coordenadasPerfil = [malla.coordenadasEta2DX(entradaAnterior,:)', posPerfil*ones(largoCoordenadas,1)];
				labelXPlot = '$x [m]$';
				coordXPlot = 1;

			elseif strcmpi(direccion, 'y') 

				buscaPosPerfil = malla.coordenadasEta2DX;
				minPosPerfil = min(min(buscaPosPerfil));
				posPerfil = minPosPerfil + fraccionPosicion*abs(max(max(buscaPosPerfil)) - minPosPerfil); 
				[fila col] = find(buscaPosPerfil <= posPerfil);
				entradaAnterior = max(col);
				entradaPosterior = entradaAnterior + 1;	
				largoCoordenadas = length(malla.coordenadasEta2DY(:, 1));
				coordenadasPerfil = [posPerfil*ones(largoCoordenadas,1), malla.coordenadasEta2DY(:, entradaAnterior)];
				labelXPlot = '$y [m]$';
				coordXPlot = 2;

			else 
				error('Direccion especificada debe ser x o y')
			end

			% En esta seccion implemento la visualizacion 
			% permanente e impermanente

			nEta = getNumeroNodos(simulacion);
			solHidro = getHidrodinamica(simulacion);

			if strcmpi(solHidro.RegimenTemporal, 'impermanente') 

				tiempo = solHidro.Tiempo;
				etaMax = max(max(solHidro.Solucion(1:nEta,:)));
				etaMin = min(min(solHidro.Solucion(1:nEta,:)));

				if isempty(varargin)

					% No se porque, pero en el Samsung negro
					% los casos en que el loop es 
					% automatico, no corre normalmente. 
					% Sin embargo, si el loop 
					% lo corro por fuera de la funcion, 
					% entonces si funciona pero utilizando pause
					% y no pause(0.01). Al parecer no 
					% se alcanza a actualizar la imagen. 
					% Revisar

					for iTiempo = 1:length(tiempo)
						iTiempo
						subplot(cuadroSubPlot(1));
						graficaHidrodinamica(thisGrafico, simulacion, iTiempo);
						% drawnow
						hold on
						plot(coordenadasPerfil(:,1), coordenadasPerfil(:,2), 'k', 'linewidth', 1.0)			
						hold off

						[eta u v] = getEtaUV(simulacion, solHidro.Solucion(:,iTiempo));
						coordenadasEta = malla.coordenadasEta;
						interpEta = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(eta)); % Interpolador eta
						interpU = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(u)); % Interpolador u
						interpV = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(v)); % Interpolador v
						etaInterp = interpEta(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
						uInterp = interpU(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
						vInterp = interpV(coordenadasPerfil(:,1), coordenadasPerfil(:,2));

						% Grafico perfil eta
						subplot(cuadroSubPlot(2));
						scatter(coordenadasPerfil(:,coordXPlot), etaInterp)
						xlabel(labelXPlot, 'interpreter', 'latex')	
						ylabel('$\eta [m]$', 'interpreter', 'latex')

						% Grafico perfil u
						subplot(cuadroSubPlot(3));
						scatter(coordenadasPerfil(:,coordXPlot), uInterp)
						xlabel(labelXPlot, 'interpreter', 'latex')	
						ylabel('$U [m/s]$', 'interpreter', 'latex')

						% Grafico perfil v
						subplot(cuadroSubPlot(4));
						scatter(coordenadasPerfil(:,coordXPlot), vInterp)
						xlabel(labelXPlot, 'interpreter', 'latex')	
						ylabel('$V [m/s]$', 'interpreter', 'latex')						
						
						pause(0.01)

					end

				elseif strcmpi(varargin{1}, 'permanente') || strcmpi(class(varargin{1}), 'double')

					if strcmpi(class(varargin{1}), 'double')

						posTiempo = varargin{1};

						if varargin{1} > length(tiempo)
							error(['Estás intentando graficar un tiempo superior al máximo resuelto. El máximo es ', num2str(length(tiempo))])
						end
					else
						posTiempo = length(tiempo);
					end

					subplot(cuadroSubPlot(1));
					graficaHidrodinamica(thisGrafico, simulacion, posTiempo);
					hold on
					plot(coordenadasPerfil(:,1), coordenadasPerfil(:,2), 'k', 'linewidth', 1.0)			
					hold off
					[eta u v] = getEtaUV(simulacion, solHidro.Solucion(:,posTiempo));
					coordenadasEta = malla.coordenadasEta;
					interpEta = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(eta)); % Interpolador eta
					interpU = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(u)); % Interpolador u
					interpV = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(v)); % Interpolador v
					etaInterp = interpEta(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
					uInterp = interpU(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
					vInterp = interpV(coordenadasPerfil(:,1), coordenadasPerfil(:,2));

					% Grafico perfil eta
					subplot(cuadroSubPlot(2));
					scatter(coordenadasPerfil(:,coordXPlot), etaInterp)
					xlabel(labelXPlot, 'interpreter', 'latex')	
					ylabel('$\eta [m]$', 'interpreter', 'latex')

					% Grafico perfil u
					subplot(cuadroSubPlot(3));
					scatter(coordenadasPerfil(:,coordXPlot), uInterp)
					xlabel(labelXPlot, 'interpreter', 'latex')	
					ylabel('$U [m/s]$', 'interpreter', 'latex')

					% Grafico perfil v
					subplot(cuadroSubPlot(4));
					scatter(coordenadasPerfil(:,coordXPlot), vInterp)
					xlabel(labelXPlot, 'interpreter', 'latex')	
					ylabel('$V [m/s]$', 'interpreter', 'latex')	

				elseif strcmpi(varargin{1}, 'impermanente')

					for iTiempo = 1:length(tiempo)

						subplot(cuadroSubPlot(1));
						graficaHidrodinamica(thisGrafico, simulacion, iTiempo);
						hold on
						plot(coordenadasPerfil(:,1), coordenadasPerfil(:,2), 'k', 'linewidth', 1.0)			
						hold off

						[eta u v] = getEtaUV(simulacion, solHidro.Solucion(:,iTiempo));
						coordenadasEta = malla.coordenadasEta;
						interpEta = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(eta)); % Interpolador eta
						interpU = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(u)); % Interpolador u
						interpV = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(v)); % Interpolador v
						etaInterp = interpEta(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
						uInterp = interpU(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
						vInterp = interpV(coordenadasPerfil(:,1), coordenadasPerfil(:,2));

						% Grafico perfil eta
						subplot(cuadroSubPlot(2));
						scatter(coordenadasPerfil(:,coordXPlot), etaInterp)
						xlabel(labelXPlot, 'interpreter', 'latex')	
						ylabel('$\eta [m]$', 'interpreter', 'latex')

						% Grafico perfil u
						subplot(cuadroSubPlot(3));
						scatter(coordenadasPerfil(:,coordXPlot), uInterp)
						xlabel(labelXPlot, 'interpreter', 'latex')	
						ylabel('$U [m/s]$', 'interpreter', 'latex')

						% Grafico perfil v
						subplot(cuadroSubPlot(4));
						scatter(coordenadasPerfil(:,coordXPlot), vInterp)
						xlabel(labelXPlot, 'interpreter', 'latex')	
						ylabel('$V [m/s]$', 'interpreter', 'latex')						
						
						pause(0.01)

					end
				end
				
			elseif strcmpi(solHidro.RegimenTemporal, 'permanente')

				if isempty(varargin)

				elseif strcmpi(varargin{1}, 'permanente')

				elseif ~strcmpi(varargin{1}, 'permanente')
					error('El único régimen temporal que puedes visualizar es el permanente puesto que la solución es permanente')
				end

				subplot(cuadroSubPlot(1));
				graficaHidrodinamica(thisGrafico, simulacion, 'permanente');
				hold on
				plot(coordenadasPerfil(:,1), coordenadasPerfil(:,2), 'k', 'linewidth', 1.0)			
				hold off
				[eta u v] = getEtaUV(simulacion, solHidro.Solucion(:,end));
				coordenadasEta = malla.coordenadasEta;
				interpEta = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(eta)); % Interpolador eta
				interpU = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(u)); % Interpolador u
				interpV = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(v)); % Interpolador v
				etaInterp = interpEta(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				uInterp = interpU(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				vInterp = interpV(coordenadasPerfil(:,1), coordenadasPerfil(:,2));

				% Grafico perfil eta
				subplot(cuadroSubPlot(2));
				scatter(coordenadasPerfil(:,coordXPlot), etaInterp)
				xlabel(labelXPlot, 'interpreter', 'latex')	
				ylabel('$\eta [m]$', 'interpreter', 'latex')

				% Grafico perfil u
				subplot(cuadroSubPlot(3));
				scatter(coordenadasPerfil(:,coordXPlot), uInterp)
				xlabel(labelXPlot, 'interpreter', 'latex')	
				ylabel('$U [m/s]$', 'interpreter', 'latex')

				% Grafico perfil v
				subplot(cuadroSubPlot(4));
				scatter(coordenadasPerfil(:,coordXPlot), vInterp)
				xlabel(labelXPlot, 'interpreter', 'latex')	
				ylabel('$V [m/s]$', 'interpreter', 'latex')
	
			end
			
		end

		function thisGrafico = graficaValidacionKranenburg(thisGrafico, simulacion, direccion)

			if ~strcmpi(class(simulacion.ListaForzantes{1}), 'vientouniforme')
				error('La distribución de velocidad de Kranenburg es sólo válida para un forzante de clase VientoUniforme')
			end

			if ~strcmpi(class(simulacion.Cuerpo.Geometria), 'geokranenburg')
				error('La distribución de velocidad de Kranenburg es sólo válida para una geometria de clase GeoKranenburg')
			end

			malla = getMalla(simulacion);
			geo = getGeometria(simulacion);
			alturaH = geo.alturaH;
			radioR = geo.radioR;
			centro = geo.centroMasa;
			parametros = getParametros(simulacion);
			zo = parametros.zoAsperezaAgua;
			kappaVonKarman = parametros.kappaVonKarman;
			lnZ = log(alturaH/zo);
			viento = simulacion.ListaForzantes{1};
			uAsterisco = viento.uAsterisco;
			velAdKran = inline('-0.5 + sqrt(0.5 - 0.5*(sqrt((coord - centro).^2))/R)', 'coord', 'centro', 'R');

			solHidro = getHidrodinamica(simulacion);

			[eta u v] = getEtaUV(simulacion, solHidro.Solucion(:,end)); % Se asume que si la solucion es impermanente, el ultimo tiempo es el Regimen Permanente

			coordenadasEta = malla.coordenadasEta;
			interpU = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(u)); % Interpolador u
			interpV = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), full(v)); % Interpolador v

			if strcmpi(direccion, 'x') 

				if quant(cos(viento.anguloDireccion),1e-15) ~= 0
					error('La direccion del viento debe ser perpendicular al perfil a graficar')
				end	

				buscaPosPerfil = malla.coordenadasEta2DY;
				minPosPerfil = min(min(buscaPosPerfil));
				fraccionPosicion = 0.5;
				posPerfil = minPosPerfil + fraccionPosicion*abs(max(max(buscaPosPerfil)) - minPosPerfil); 
				[fila col] = find(buscaPosPerfil <= posPerfil);
				entradaPosterior = min(fila);				
				entradaAnterior = entradaPosterior - 1;
				largoCoordenadas = length(malla.coordenadasEta2DX(:, 1));
				coordenadasPerfil = [malla.coordenadasEta2DX(entradaAnterior,:)', posPerfil*ones(largoCoordenadas,1)]; % Falta ver bien como se obtienen las coordenadas
				labelXPlot = '$x [m]$';
				coordXPlot = 1;
				uInterp = interpU(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				vInterp = interpV(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				velInterpAdim = -kappaVonKarman*sqrt(uInterp.^2 + vInterp.^2)/(lnZ*uAsterisco);
				velInterpAdim = velInterpAdim.*sign(vInterp);

			elseif strcmpi(direccion, 'y') 

				if quant(sin(viento.anguloDireccion),1e-15) ~= 0 
					error('La direccion del viento debe ser perpendicular al perfil a graficar')
				end

				buscaPosPerfil = malla.coordenadasEta2DX;
				minPosPerfil = min(min(buscaPosPerfil));
				fraccionPosicion = 0.5;
				posPerfil = minPosPerfil + fraccionPosicion*abs(max(max(buscaPosPerfil)) - minPosPerfil); 
				[fila col] = find(buscaPosPerfil <= posPerfil);
				entradaAnterior = max(col);
				entradaPosterior = entradaAnterior + 1;	
				largoCoordenadas = length(malla.coordenadasEta2DY(:, 1));
				coordenadasPerfil = [posPerfil*ones(largoCoordenadas,1), malla.coordenadasEta2DY(:, entradaAnterior)];
				labelXPlot = '$y [m]$';
				coordXPlot = 2;
				uInterp = interpU(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				vInterp = interpV(coordenadasPerfil(:,1), coordenadasPerfil(:,2));
				velInterpAdim = -kappaVonKarman*sqrt(uInterp.^2 + vInterp.^2)/(lnZ*uAsterisco);
				velInterpAdim = velInterpAdim.*sign(uInterp);

			else 
				error('Direccion especificada debe ser x o y')
			end

			coordPerfilKran = min(coordenadasPerfil(:,coordXPlot)):(max(coordenadasPerfil(:,coordXPlot)) - min(coordenadasPerfil(:,coordXPlot)))/100:max(coordenadasPerfil(:,coordXPlot));
			plot(coordPerfilKran, velAdKran(coordPerfilKran, centro(coordXPlot), radioR), 'k','linewidth', 1.5)
			hold on 
			scatter(coordenadasPerfil(:,coordXPlot), velInterpAdim)
			hold off
			xlabel(labelXPlot, 'interpreter', 'latex')	
			ylabel('$\frac{U_o \kappa}{u_* \ln{Z}}$', 'interpreter', 'latex')

			difVel = abs(velAdKran(coordenadasPerfil(:,coordXPlot), centro(coordXPlot), radioR) - velInterpAdim);
			fNan = find(~isnan(difVel));
			difVel = difVel(fNan);
			errorAjuste = sqrt(sum(difVel.^2))
			% keyboard

		end

		function thisGrafico = graficaEnergiaTiempo(thisGrafico, simulacion)

			solHidro = getHidrodinamica(simulacion);
		
			if ~strcmpi(solHidro.RegimenTemporal, 'impermanente')
				error('Este grafico requiere que el régimen temporal sea impermanente')
			end

			[nEta nU nV] = getNumeroNodos(simulacion);
			[deltaX deltaY] = getDeltaX(simulacion);
			[M K C]= getMatrices(simulacion);

			tiempo = solHidro.Tiempo;
			areaTotal = nEta*deltaX*deltaY;
			solucionTiempo = solHidro.Solucion;
			MsolucionTiempo = M*solucionTiempo;
			energiaTiempo = sparse(1,length(tiempo));

			energiaTotal = 0.5*areaTotal*dot(solucionTiempo, MsolucionTiempo);
			energiaPotencial = 0.5*areaTotal*dot(solucionTiempo(1:nEta,:), MsolucionTiempo(1:nEta,:));
			energiaCinetica = 0.5*areaTotal*dot(solucionTiempo(nEta+1:end,:), MsolucionTiempo(nEta+1:end,:));

			% panelSp(1) = subplot(1,2,1);

			plot(tiempo, energiaTotal, 'r')
			xlabel('t [s]', 'interpreter', 'latex')
			ylabel('E [J]', 'interpreter', 'latex')
%			hold on
%			plot(tiempo, energiaPotencial, 'k')
%			plot(tiempo, energiaCinetica)
%			plot(tiempo, energiaCinetica + energiaPotencial, 'g')

%			panelSp(2) = subplot(1,2,2)

%			plot(tiempo, energiaCinetica./energiaTotal)
%			hold on 
%			plot(tiempo, energiaPotencial./energiaTotal,'r')

			hold off
		end

		function thisGrafico = graficaBatimetria(thisGrafico, varargin)

			bat = getBatimetria(varargin{:});
			graficaBorde(thisGrafico, varargin{:});
			hold on
			graficaEta(thisGrafico, varargin{:}, bat.hoNodosEta); 
			% barraColor = colorbar;
			% caxis([min(bat.hoNodosEta) max(bat.hoNodosEta)])
			% xlabel(barraColor, '$h_o [m]$', 'interpreter', 'latex')
			% asignaAxisLim(thisGrafico, varargin{:});
			axis equal
			xlabel('$x [m]$', 'interpreter', 'latex')	
			ylabel('$y [m]$', 'interpreter', 'latex')	

		end %function graficaBatimetria

		function thisGrafico = graficaBatimetriaAdim(thisGrafico, varargin)

			bat = getBatimetria(varargin{:});
			handle.plotBorde = graficaBorde(thisGrafico, varargin{:});
			hold on
			geo = getGeometria(varargin{:});
			H = geo.alturaH;
			handle.plotEta = graficaEta(thisGrafico, varargin{:}, bat.hoNodosEta/H); 
			handle.ejes = gca;
			% barraColor = colorbar;
			% caxis([min(bat.hoNodosEta) max(bat.hoNodosEta)])
			% xlabel(barraColor, '$h_o [m]$', 'interpreter', 'latex')
			% asignaAxisLim(thisGrafico, varargin{:});
			axis square

			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'BatimetriaAdim';

			xlabel('$x [m]$', 'interpreter', 'latex')	
			ylabel('$y [m]$', 'interpreter', 'latex')	

		end %function graficaBatimetria

		function graficaPerfilBatimetria(thisGrafico, varargin)

			geo = getGeometria(varargin{:});
			centro = geo.centroMasa;
			Ro = geo.radioR;
			xbat = linspace(-Ro, Ro, 100);
			ybat = zeros(1, length(xbat));
			hH = 0.5+sqrt(0.5-0.5*sqrt((xbat - centro(1)).^2 + (ybat - centro(2)).^2)/Ro);

			handle.plotBat = plot(xbat/Ro, hH);

			thisGrafico.Handle = handle;
			thisGrafico.Tipo = 'PerfilBatimetria';

		end
	

		function thisGrafico = asignaAxisLim(thisGrafico, objeto)
	
			malla = getMalla(objeto);
			coordenadasEta = malla.coordenadasEta;	

%			deltaFraccion = 0.2;
%			signoXMin = sign(min(coordenadasEta(:,1)));
%			signoXMax = sign(max(coordenadasEta(:,1)));
%			signoYMin = sign(min(coordenadasEta(:,2)));
%			signoYMax = sign(max(coordenadasEta(:,2)));

%			if signoXMin == -1; 
%				facXMin = (1 + deltaFraccion);
%			else
%				facXMin = (1 - deltaFraccion);	
%			end

%			if signoXMax == -1; 
%				facXMax = (1 - deltaFraccion);
%			else
%				facXMax = (1 + deltaFraccion);	
%			end

%			if signoYMin == -1; 
%				facYMin = (1 + deltaFraccion);
%			else
%				facYMin = (1 - deltaFraccion);	
%			end

%			if signoYMax == -1; 
%				facYMax = (1 - deltaFraccion);
%			else
%				facYMax = (1 + deltaFraccion);	
%			end

			% malla = getMalla(simulacion);
			% Lx = max(malla.coordenadasU(:,1)) - ... 	
			%     min(malla.coordenadasU(:,1));
			% Ly = max(malla.coordenadasV(:,2)) - ... 	
			%      min(malla.coordenadasV(:,2));
			% L = max([Lx Ly]);

			ejes = thisGrafico.Handle.ejes;

			% xlim(ejes, [floor(facXMin*min(coordenadasEta(:,1))) ceil(facXMax*max(coordenadasEta(:,1)))])
			% ylim(ejes, [floor(facYMin*min(coordenadasEta(:,2))) ceil(facYMax*max(coordenadasEta(:,2)))])
			box(ejes)
			axis square
			% keyboard

		end % function asignaAxisLim

		function thisGrafico = ejesAdimensionales(thisGrafico, objeto, stringLCar, valorLCar)
		
			ejes = thisGrafico.Handle.ejes;
			xlabel(ejes, ['$x', stringLCar, '^{-1}$'], 'interpreter', 'latex')
			ylabel(ejes, ['$y', stringLCar, '^{-1}$'], 'interpreter', 'latex')

%			numTicksX = 8;
%			xlimi = get(ejes,'xlim');
%			set(ejes,'xtick',linspace(xlimi(1), xlimi(2), numTicksX))

			xticks = str2num(get(gca, 'xticklabel'));
			xticks = num2str(xticks/valorLCar);

%			numTicksY = 6;
%			ylimi = get(ejes,'ylim');
%			set(ejes,'ytick',linspace(ylimi(1), ylimi(2), numTicksY))


%yticks = str2num(get(gca, 'yticklabel'));
%rad = max(yticks);
%yticks = num2str(yticks/rad);
			% set(gca, 'xticklabel', xticks)
% set(gca, 'yticklabel', yticks)

		end % function ejesAdimensionales

	end %methods
end % classdef


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THRASH


