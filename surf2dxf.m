function[]=surf2dxf(fname,X,Y,Z,C) 
%
% SURF2DXF converts a surface into a DXF file.
%
% SURF2DXF(fname,X,Y,Z) where fname is the filename (without extension)
% used to generate the dxf file and X, Y and Z are matrix arguments
% of the MATLAB surface format.
% 
% SURF2DXF(fname,X,Y,Z,C) the color scaling is determined by the range of C.
% Note that the color palete of a DXF file is not given in the RGB scale,
% the correspondent color table you can find in
% http://www.isctex.com/acadcolors.php
% 
% Example: Classical peak plots:
%
% [X,Y,Z] = peaks(3);
% surf2dxf('sd',X,Y,Z); % search the file sd.dxf at the current MATLAB path
%
%
% Author: Alexandre Carvalho Leite (alexandrecvl@hotmail.com)
%

fullname=sprintf('%s.dxf',fname);
fid=fopen(fullname,'w');
fprintf(fid,'0\nSECTION\n 2\rENTITIES\r 0\n');
minZ=abs(min(min(Z)));
maxZ=max(max(Z))+minZ;

if nargin < 5,
    C=255*((Z+minZ)/maxZ);
end

for j=1:length(X)-1,
    for i=1:length(X)-1,
      fprintf(fid,'3DFACE\n 8\n default\n');
      %create new 3DFACE element
      fprintf(fid,' 62\n %1.0f\n',C(i,j));
      %corresponding color of the autocad pallete
      fprintf(fid,'10\n %.4f\n 20\n %.4f\n 30\n %.4f\n',X(i,j),Y(i,j),Z(i,j));
      %vertex 1
      fprintf(fid,'11\n %.4f\n 21\n %.4f\n 31\n %.4f\n',X(i,j+1),Y(i,j+1),Z(i,j+1));
      %vertex 2
      fprintf(fid,'12\n %.4f\n 22\n %.4f\n 32\n %.4f\n',X(i+1,j+1),Y(i+1,j+1),Z(i+1,j+1));
      %vertex 3
      fprintf(fid,'12\n %.4f\n 22\n %.4f\n 32\n %.4f\n',X(i+1,j),Y(i+1,j),Z(i+1,j));
      %vertex 4      
      fprintf(fid,' 0\n');
    end
end
fprintf(fid,'ENDSEC\n 0\nEOF\n');
fclose(fid);