classdef Batimetria < hgsetget

	% BATIMETRIA es el objeto que contiene las coordenadas 
	% de la malla y su correspondiente valor de batimetria

	properties

		tipoBatimetria
		hoNodosEta
		hoNodosU
		hoNodosV
       
	end
    
	methods

		function thisBatimetria = Batimetria()
		% function thisBatimetria = Batimetria()    
		% Constructor del objeto batimetria
			thisBatimetria;
	        end %function Batimetria

		function thisBatimetria = batimetriaKranenburg(thisBatimetria, geometria)

			thisBatimetria = generaBatimetriaKranenburg(thisBatimetria, geometria);
			thisBatimetria.tipoBatimetria = 'Kranenburg';
		
		end %function batimetriaKranenburg

		function thisBatimetria = generaBatimetriaKranenburg(thisBatimetria, geometria)
		% generaBatimetriaKranenburg: Construye una estructura batimetria que contiene
		% los valores de la profundidad de la hoya en el estado no perturbado
		
			malla = geometria.Malla;
			centroMasa = geometria.centroMasa;
			radio = geometria.radioR;
			hKran = geometria.alturaH;	
			borde = geometria.Borde.coordenadasXY;
			coordenadasEta = malla.coordenadasEta;
			coordenadasU = malla.coordenadasU;
			coordenadasV = malla.coordenadasV;

			centro = centroMasa;
			Ro = radio;
			N = 1000; 
			xk = -Ro + 2*Ro.*rand(N,1) + centro(1);
			yk = (sqrt(Ro^2-(xk-centro(1)).^2)).*rand(N,1);
			sk = rand(N,1);
			fk = find(sk <= 0.5);
			gk = find(sk > 0.5);
			sk(fk) = sk(fk)./(-sk(fk));
			sk(gk) = sk(gk)./(sk(gk));
			yk = yk.*sk + centro(2);

			xgeodat = borde(:,1);
			ygeodat = borde(:,2);

			xbat = [xk;xgeodat];
			ybat = [yk;ygeodat];

			hH = 0.5+sqrt(0.5-0.5*sqrt((xbat - centro(1)).^2 + (ybat - centro(2)).^2)/Ro);
			hH = real(hH);

			% Construct the interpolant
			F = TriScatteredInterp(xbat,ybat,hH);
			howe = F(coordenadasU(:,1),coordenadasU(:,2));
			hons = F(coordenadasV(:,1),coordenadasV(:,2));
			heta = F(coordenadasEta(:,1),coordenadasEta(:,2));

			% heta = [heta; zeros(size(xgeodat))];
			% coordbat = [xbat,ybat];

			% keyboard

			IDwe = malla.matrizIDwe;
			IDns = malla.matrizIDns;

			fk = find(isnan(howe)==1);
			for i = 1:length(fk)
			    gk = find(IDwe(:,1) == fk(i));
			    hk = find(IDwe(:,2) == fk(i));
			    if(isempty(gk)); gk = 0; end
			    if(isempty(hk)); hk = 0; end
			    fink = max(gk,hk);
			    howe(fk(i)) = heta(fink);
			end

			fk = find(isnan(hons)==1);
			for i = 1:length(fk)
			    gk = find(IDns(:,1) == fk(i));
			    hk = find(IDns(:,2) == fk(i));
			    if(isempty(gk)); gk = 0; end
			    if(isempty(hk)); hk = 0; end
			    fink = max(gk,hk);
			    hons(fk(i)) = heta(fink);
			end

			hoNodosU = howe;
			hoNodosV = hons;
			hoNodosEta = heta;

			thisBatimetria.hoNodosU = hoNodosU*hKran;
			thisBatimetria.hoNodosV = hoNodosV*hKran;
			thisBatimetria.hoNodosEta = hoNodosEta*hKran;

		end %generaBatimetriaKranenburg
	end %methods
end %classdef

%%%%%%%%%%%%%%%%%%%% THRASH

%		function thisBatimetria = generaBatimetriaKranenburg(thisBatimetria, Geometria)

%			malla = Geometria.Malla;
%			centroMasa = Geometria.centroMasa;
%			radio = Geometria.parametrosGeometria.Radio;
%			hKran = Geometria.parametrosGeometria.Altura;	
%			borde = Geometria.Borde.coordenadasXY;

%			kranenburg = inline('0.5 + sqrt(0.5 - 0.5*sqrt((x-centroMasa(1)).^2 + (y-centroMasa(2)).^2)/radio)', 'x', 'y', 'centroMasa', 'radio');
%			coordenadasEta = malla.coordenadasEta;
%			coordenadasU = malla.coordenadasU;
%			coordenadasV = malla.coordenadasV;

%			hoNodosEta = kranenburg(coordenadasEta(:,1), coordenadasEta(:,2), centroMasa, radio);			
%			hoNodosU = kranenburg(coordenadasU(:,1), coordenadasU(:,2), centroMasa, radio);	
%			hoNodosV = kranenburg(coordenadasV(:,1), coordenadasV(:,2), centroMasa, radio);

%			% Los nodos que tengan ho complejo, significa que están 
%			% levemente por fuera de la circunferencia del borde. 
%			% En este caso, la parte real (0.5) es el valor que 
%			% se adopta puesto que es la profundidad en el borde.			
%	
%			hoNodosEta = real(hoNodosEta);				
%			hoNodosU = real(hoNodosU);
%			hoNodosV = real(hoNodosV);
%			
%%			interpolador = TriScatteredInterp(coordenadasEta(:,1), coordenadasEta(:,2), hoNodosEta);
%%			hoNodosU = interpolador(coordenadasU(:,1), coordenadasU(:,2));		
%%			hoNodosV = interpolador(coordenadasV(:,1), coordenadasV(:,2));


%			thisBatimetria.hoNodosU = hoNodosU*hKran;
%			thisBatimetria.hoNodosV = hoNodosV*hKran;
%			thisBatimetria.hoNodosEta = hoNodosEta*hKran;
%% 			thisBatimetria.hoNodosU = ones(length(hoNodosU),1)*hKran;
%% 			thisBatimetria.hoNodosV = ones(length(hoNodosV),1)*hKran;
%% 			thisBatimetria.hoNodosEta = ones(length(hoNodosEta),1)*hKran;

%		end % generaBatimetriaKranenburg


