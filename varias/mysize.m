function [s,varargout] = mysize(x)
nout = max(nargout,1)-1;
keyboard
s = size(x);
for k=1:nout, varargout(k) = {s(k)}; end
