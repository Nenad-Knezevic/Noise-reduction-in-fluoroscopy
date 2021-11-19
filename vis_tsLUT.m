function lut = vis_tsLUT(op_range,sirina,dubina,tip)

% Tone Scale je sigmoidalni lut za suzavanje/sirenje dinamickog opsega, gde
% je ref_ip tacka pivotiranja (-1 do 1), op_range je ulazni (i indeksni) 
% opseg luta a sirina je faktor pojacanja odnosno smanjenja.
%   lut = vis_tsLUT(op_range,sirina,dubina,tip)
% VP, Aug 2008.

if dubina>1, dubina = 1; end
if dubina<-1, dubina = -1; end
if sirina<0, sirina = 0; end
if sirina>1, sirina = 1; end

% Mapiramo parametre
dubina = sign(dubina)*dubina^2;
sirina = 1+(sirina^2)*3;

ip_x = 0:op_range;
switch tip
  case {0,'linearni'}
    % Linearni lut
    disp(['Dubina ' num2str(dubina) ' Sirina: ' num2str(sirina)])
    R = op_range/2;
    lut = R*(1 + sirina * (1 + dubina)) - sirina * ip_x; 
    lut = max(0,lut);
    lut = min(op_range,lut);
  case {1,'sigmoid'}
    % Sigmoidalni lut
    disp(['Dubina ' num2str(dubina) ' Sirina: ' num2str(sirina)])
    h_ipr = (1 + dubina) * op_range/2;
    k2 = sirina * 4/op_range;
    max_Norm = op_range-op_range*1./(1+exp(-k2*(0-h_ipr)));
    min_Norm = op_range-op_range*1./(1+exp(-k2*(op_range-h_ipr)));
    f_Norm = op_range/(max_Norm-min_Norm);
    lut = (op_range - op_range*(1./(1+exp(-k2*(ip_x-h_ipr))))-min_Norm )*f_Norm;
end

