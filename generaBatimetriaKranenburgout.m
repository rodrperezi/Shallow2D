function thisBatimetria = generaBatimetriaKranenburg(thisBatimetria, Geometria)
% generaBatimetriaKranenburg: Construye una estructura batimetria que contiene
% los valores de la profundidad de la hoya en el estado no perturbado

malla = Geometria.Malla;
centro = Geometria.centroMasa;
Ro = Geometria.parametrosGeometria.Radio;
H = Geometria.parametrosGeometria.Altura;
borde = Geometria.Borde.coordenadasXY;

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
howe = F(malla.coordenadasU(:,1),malla.coordenadasU(:,2));
hons = F(malla.coordenadasV(:,1),malla.coordenadasV(:,2));
heta = F(malla.coordenadasEta(:,1),malla.coordenadasEta(:,2));

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

thisBatimetria.hoNodosU = howe*H;
thisBatimetria.hoNodosV = hons*H;
thisBatimetria.hoNodosEta = heta*H;


