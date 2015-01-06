function [solucionEta solucionU solucionV] = getEtaUV(Cuerpo, solucionCompleta)

malla = getMalla(Cuerpo);
[numeroNodosEta numeroNodosU numeroNodosV]= getNumeroNodos(malla);

SOL = solucionCompleta;
Neta = numeroNodosEta;
Nu = numeroNodosU;
Nv = numeroNodosV;

IDwe = malla.InformacionMalla.IDwe;
IDns = malla.InformacionMalla.IDns;
nBIz = malla.InformacionMalla.numeroBordesIzquierdo;
nBDe = malla.InformacionMalla.numeroBordesDerecho;
nBSu = malla.InformacionMalla.numeroBordesSuperior;
nBIn = malla.InformacionMalla.numeroBordesInferior;

eta = SOL(1:Neta,end);

uaux = sparse(zeros(Nu,1));
vaux = sparse(zeros(Nv,1));

ku = 1;
kv = 1;

for j = 1:Nu
    if(sum(j == [IDwe(nBIz,1);IDwe(nBDe,2)])==0);
       	uaux(j) = SOL(Neta + ku); 
       	ku = ku+1;
    end
end
    
for j = 1:Nv
    if(sum(j == [IDns(nBSu,1);IDns(nBIn,2)])==0);
       	vaux(j) = SOL(Neta + kv + Nu - length([IDwe(nBIz,1);IDwe(nBDe,2)]));
       	kv= kv+1;
    end    
end
        
for j = 1:Neta
    u(j,1) = mean(uaux(IDwe(j,:)));
    v(j,1) = mean(vaux(IDns(j,:)));
end

solucionEta = eta;
solucionU = u;
solucionV = v;



