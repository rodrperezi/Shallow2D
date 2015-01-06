function [eta u v] = get_etauv(SOL, coordeta, coordu, coordv, nBIz, nBDe, nBSu, nBIn, IDwe, IDns)

[Neta Nu Nv] = cuenta_nodos(coordeta, coordu, coordv);

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


