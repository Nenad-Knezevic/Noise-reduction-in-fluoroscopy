function lut = vis_logLUT(ip_opseg, op_opseg, tol, a, b)

% Vraca log lut tabelu za zeljeni opseg sa zeljenom tolerancijom i nagibom
% definisanim sa b. Prvi deo do tol (npr. 0.04) je linearan a posle log lut
% Parametri su od -1 do 1 a 0 je standardna vrednost
%    lut = vis_logLUT(opseg, tol, b)
% VP, Mar 2008.

% Parametri
if nargin==2, tol = 0.04; end   % Standardna tolerancija 4%
if nargin==1, op_opseg = 256; end
if nargin<4, a = 0; end
if nargin<5, b = 0; end
% Mapiramo parametare, nominalno izmedju -1 i 1
% if tol>=0
%   tol = 0.04+0.06*tol;
% else 
%   tol = 0.04*(1+tol);
% end
a = 1-0.5*abs(a);
if b>0
  b = (exp(b^3)-1)/(exp(1)-1)*ip_opseg*10;
else 
  b = (1-(exp(-(-1-b).^3)-1)/(exp(1)-1))*(-tol*ip_opseg+0.01);
end
% disp(['Parametri su a=' num2str(a) ' b=' num2str(b) ' i Tol= ' num2str(tol)])

% disp(['Ulazno b=' num2str(bu) ' izlazno b=' num2str(b)]);
lin_op_opseg = ceil(tol*op_opseg);
lin_ip_opseg = ceil(tol*a*ip_opseg);
log_lim = log(b+lin_ip_opseg+1);
log_max = log(b+a*ip_opseg+1);
% disp(num2str([lin_op_opseg lin_ip_opseg log_lim log_max]))
% Pravimo krivu
lut = zeros(1,ip_opseg);
lut(1:lin_ip_opseg) = 0:(lin_op_opseg-1)/(lin_ip_opseg-1):lin_op_opseg-1;
k = (op_opseg-lin_op_opseg)/(log_max-log_lim);
lut(lin_ip_opseg+1:round(a*ip_opseg)) = lin_op_opseg + k * (log(b+(lin_ip_opseg+1:round(a*ip_opseg)))-log_lim);
lut(round(ip_opseg*a):ip_opseg) = op_opseg;
