function img = niak_vol2img(hdr,vol,coord,method)
% Generate an image file with a brain sagital, coronal and axial slices. 
%
% [] = NIAK_VOL2IMG( VOL , HDR , COORD , INTERP )
%
% HDR.SOURCE (structure) the header of the volume
% HDR.TARGET (structure) the header of a volume defining the sampling space
% VOL        (3D array) brain volume, in stereotaxic space.
% COORD      (vector 1x3) defines which slices to display (X,Y,Z).
% METHOD     (string, default 'spline') the spatial interpolation 
%            method. See METHOD in INTERP2.
% 
% Copyright (c) Pierre Bellec 
% Centre de recherche de l'Institut universitaire de gériatrie de Montréal, 2012.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : visualization

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
 
%% Default options
if nargin < 3
    error('Please specify VOl, HDR, and COORD') 
end
if nargin < 4
    method = 'spline';
end

%% get coordinates in voxel space
coord_w = coord(1:3);
coord_w = coord_w(:)';
coord_vs = round(niak_coord_world2vox(coord_w,hdr.source.info.mat));
coord_vt = round(niak_coord_world2vox(coord_w,hdr.target.info.mat));

%% sized of the target space 
dim_s = hdr.source.info.dimensions(1:3);
dim_t = hdr.target.info.dimensions(1:3);

%% Extract coordinates in 3D source space
[xx_vs,yy_vs,zz_vs] = ndgrid(1:dim_s(1),1:dim_s(2),1:dim_s(3));  
slice_ws = niak_coord_vox2world([xx_vs(:) yy_vs(:) zz_vs(:)],hdr.source.info.mat);
xx_ws = reshape(slice_ws(:,1),size(xx_vs));
yy_ws = reshape(slice_ws(:,2),size(yy_vs));
zz_ws = reshape(slice_ws(:,3),size(zz_vs));

%% resample the three slices 
img = cell(3,1);
for dd = 1:3 % loop over dimensions x, y, z
    % generate the source image 
    % and the coordinates of pixels in source and target 
    switch dd 
        case 1 
            [xx_vt,yy_vt,zz_vt] = ndgrid(coord_vt(1),1:dim_t(2),1:dim_t(3));         
        case 2  
            [xx_vt,yy_vt,zz_vt] = ndgrid(1:dim_t(1),coord_vt(2),1:dim_t(3));
        case 3
            [xx_vt,yy_vt,zz_vt] = ndgrid(1:dim_t(1),1:dim_t(2),coord_vt(3));
    end
        
    % Build world coordinates for voxels in the slice of source space
    slice_wt = niak_coord_vox2world([xx_vt(:) yy_vt(:) zz_vt(:)],hdr.target.info.mat);
    xx_wt = reshape(slice_wt(:,1),size(xx_vt));
    yy_wt = reshape(slice_wt(:,2),size(yy_vt));
    zz_wt = reshape(slice_wt(:,3),size(zz_vt));

    %% resample
    img{dd} = squeeze(interpn(xx_ws,yy_ws,zz_ws,vol,xx_wt,yy_wt,zz_wt));
end