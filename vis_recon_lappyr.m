function im = vis_recon_lappyr(LPyr, Res, size_vec)

% Rekonstruise laplasovu piramidu
%   im = vis_recon_lappyr(LPyr, Res)
% VP, Sept 07

N = length(LPyr);

% define filter 
w = [1 4 6 4 1] / 16;

% loop over decomposition depth -> synthesis
for i1 = N:-1:1
  % undecimate and interpolate 
  M1T = conv2(conv2(es2(undec2(Res), 2), 2*w, 'valid'), 2*w', 'valid');
  % add coefficients
  Res = M1T + LPyr{i1};
end

% copy image
im = Res(1:size_vec(1),1:size_vec(2));