function [LPyr, Res, size_vec, GPyr] = vis_decomp_lappyr(im, N)

% Konstruise Laplasovu piramidu
%   LPyr = vis_decomp_lappyr(im, N)
% originalno (Oliver Rockinger 16.08.99)

if ischar(im), im=double(imread(im)); else im = double(im); end

% Pripremi sliku 
red_faktor = 2^N;
add_size = fliplr(ceil(size(im)/red_faktor)*red_faktor - size(im));
size_vec = size(im);
im = improc_extend_back(im,add_size);

% define filter
w = [1 4 6 4 1] / 16;

% cells for selected images
LPyr = cell(1,N);
GPyr = cell(1,N);

% loop over decomposition depth -> analysis
for i1 = 1:N 
  
  if nargout>3
    GPyr(i1) = {im};
  end
  
  % perform filtering 
  G1 = conv2(conv2(es2(im,2), w, 'valid'),w', 'valid');
 
  % decimate, undecimate and interpolate 
  M1T = conv2(conv2(es2(undec2(dec2(G1)), 2), 2*w, 'valid'),2*w', 'valid');
 
  % select coefficients and store them
  LPyr(i1) = {im-M1T};
  
  % decimate 
  im = dec2(G1);
end
Res = im;
