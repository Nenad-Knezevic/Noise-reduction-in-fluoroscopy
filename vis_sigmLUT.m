function lut = vis_sigmLUT(ip_range, op_range, k)

k1 = op_range;
k2 = 4*k/k1;

x = [-ip_range:ip_range];

lut = k1*(1./(1+exp(-k2.*x))-0.5);