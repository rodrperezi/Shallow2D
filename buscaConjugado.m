clear all 
close all 

	load 'MODOS.mat'

	% Voy a buscar vectores conjugados
	numVector = 76;
	corta = 1e-14;
	nModos = length(Vectores(1,:));
	esConj = sparse(zeros(nModos,1));
	nFilas = length(Vectores(:,1));

	% Normalizo
			
	Vectores = quant(real(Vectores),corta) + i*quant(imag(Vectores), corta);
	Valores =  quant(real(Valores),corta) + i*quant(imag(Valores), corta);
		
	for iNorm = 1:length(Valores)
	
		Vectores(:,iNorm) = Vectores(:,iNorm)/norm(Vectores(:,iNorm));
		normaVector(iNorm) = norm(Vectores(:,iNorm)); % Debería ser uno para todos
	
	end

	for iConj = 1:nModos
		% evaluaConj = find(Vectores(:,iConj) == conj(Vectores(:,numVector)));
		evaluaConj = sign(imag(Vectores(:,iConj))) == sign(imag(conj(Vectores(:,numVector))));

		if sum(evaluaConj) == nFilas
			esConj(iConj) = 1;
		end

	end
