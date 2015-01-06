function fernfaster

%FERN  MATLAB implementation of the Fractal Fern.
%   Michael Barnsley, Fractals Everywhere, Academic Press, 1993.
%   This version runs forever, or until stop is toggled.
%   See also FINITEFERN.
shg
clf reset
set(gcf,'color','white','menubar','none', ...
'numbertitle','off','name','Fractal Fern')
x = [.5; .5];
h = plot(x(1),x(2),'.');
darkgreen = [0 2/3 0];
set(h,'markersize',1,'color',darkgreen,'erasemode','none');
axis([-3 3 0 10])
axis off
stop = uicontrol('style','toggle','string','stop', ...
'background','white');
drawnow
p  = [ .85  .92  .99  1.00];
A1 = [ .85  .04; -.04  .85];  b1 = [0; 1.6];
A2 = [ .20 -.26;  .23  .22];  b2 = [0; 1.6];
A3 = [-.15  .28;  .26  .24];  b3 = [0; .44];
A4 = [  0    0 ;   0   .16];
cnt = 1;
tic
NumberPlot=2000;
y=zeros(2,NumberPlot);
y(:,1)=x;
k=2;
while ~get(stop,'value')
r = rand;
keyboard
if r &lt; p(1)
y(:,k) = A1*y(:,k-1) + b1;
elseif r &lt; p(2)
y(:,k) = A2*y(:,k-1) + b2;
elseif r &lt; p(3)
y(:,k) = A3*y(:,k-1) + b3;
else
y(:,k) = A4*y(:,k-1);
end
if k==NumberPlot
CurrentX=get(h,'xdata');
CurrentY=get(h,'ydata');
set(h,'xdata',[CurrentX y(1,2:end)],'ydata',[CurrentY y(2,2:end)]);
k=2;
y(:,1)=y(:,NumberPlot);
drawnow
else
k=k+1;
end
cnt = cnt + 1;
end
t = toc;
s = sprintf('%8.0f points in %6.3f seconds',cnt,t);
text(-1.5,-0.5,s,'fontweight','bold');
set(stop,'style','pushbutton','string','close','callback','close(gcf)')

