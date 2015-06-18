% Rodrigo Perez I. 
% Rutina que calcula los coeficientes kxx, kxy, kyy segun la fÓrmula de elder para cada nodo u y v.
% Se utiliza la descomposición de Holly (1984) para el cálculo de los coeficientes efectivos, la cual incluye el ángulo entre un eje que sigue la línea de corriente (chi, eta) y el plano cartesiano (x,y).

eL = 5.93;
eT = 0.23;

velu = u;
velv = v;

IDuwe = zeros(New,2);
IDvns = zeros(Nns,2);

Vuaux = zeros(New,1);
Uvaux = zeros(Nns,1);
etawe = Vuaux;
etans = Uvaux;

for j = 1:New

	[filaid colid] = find(j == IDwe);
	filaid = sort(filaid);
	
	if(sum(j == IDwe(nBIz,1))~=0);	
		IDuwe(j,2) = filaid;
	elseif(sum(j == IDwe(nBDe,2))~=0);	
		IDuwe(j,1) = filaid;
	else
		IDuwe(j,:) = filaid'; %Nodo eta W, E
		Vuaux(j) = mean(velv(IDuwe(j,:)));
		etawe(j) = mean(eta(IDuwe(j,:)));
	end
	
end

for j = 1:Nns

	[filaid colid] = find(j == IDns);
	filaid = sort(filaid);
	
	if(sum(j == IDns(nBSu,1))~=0);	
		IDvns(j,2) = filaid;
	elseif(sum(j == IDns(nBIn,2))~=0);	
		IDvns(j,1) = filaid;
	else
		IDvns(j,:) = filaid'; %Nodo eta N, S
		Uvaux(j) = mean(velu(IDvns(j,:)));
		etans(j) = mean(eta(IDvns(j,:)));
	end
	      
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uast = uAsterisco;

Nu = New;
Nv = Nns;

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


theta1 = atan2(Vuaux, uaux);
f1 = find(theta1 <= 0);
theta1(f1) = theta1(f1) + 2*pi;

theta2 = atan2(vaux, Uvaux);
f2 = find(theta2 <= 0);
theta2(f2) = theta2(f2) + 2*pi;

kxxwe = uast.*[howe + etawe].*(eL*cos(theta1).^2 + eT*sin(theta1).^2);
kyyns = uast.*[hons + etans].*(eL*sin(theta2).^2 + eT*cos(theta2).^2);
% kxywe = (eL - eT)*uast.*[howe + etawe].*sin(theta1).*cos(theta1);
% kxyns = (eL - eT)*uast.*[hons + etans].*sin(theta2).*cos(theta2);

