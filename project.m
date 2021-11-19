clear all
close all
clc
profile on
% UCITAVANJE SLIKA
% LOADING IMAGES FROM FOLDER

pod = dir('C:\Users\Knez\Desktop\Obrada slike u medicini projekat\Img_1'); %put do slika

naz = cell(101,1);
for i=1:101
    naz{i,1}=pod(i).name;
end

naz = naz(3:end,1);
ref_slike=[];
slike=[];
for z=1:size(naz,1)
    temp = char(naz(z,1));
    put='C:\Users\Knez\Desktop\Obrada slike u medicini projekat\Img_1';
    temp_put = strcat(put,'\',temp);
    sl = vis_read_raw(temp_put);
    sl = double(sl);
    b = sl;
    f = ones(3,3)/9;  % formiranje maske 3x3
    sl1 = filter2(f,sl,'same'); %filtriranje NF filtrom
    sl1 = uint16(sl1);
 % KOREKCIJA DINAMICKOG OPSEGA
 % LOG COMPRESSION USING LOOKUP TABLE
    lut = vis_logLUT(65535,255,0.004); % look-up tabela za logaritam
    
    a = lut(sl1+1);
    if z==50
        c = a;
    end
    
   
%     
%     
% MULTIVELICINSKO POJACANJE STRUKTURA (LAPLASOVA PIRAMIDA)
% MULTISCALE ENHACMENT USING LAPLAS PYRAMID

lut2 = vis_sigmLUT(255,255,4); % look-up tabela sigmoid funkcije

[lpyr,res,size_vec] = vis_decomp_lappyr(a,4); % laplasova piramida (razlaganje slike na 4 nivoa)
 


im1 = ceil(lpyr{1}); % prva slika
im2 = ceil(lpyr{2}); % druga slika
im3 = ceil(lpyr{3}); % treca slika
im4 = ceil(lpyr{4}); % cetvrta slika

% 
% za prvu
% trazimo min i max slike
mini = min(im1(:));
maxi = max(im1(:));
% proveravamo sta je absolutno vece i tu vrednost koristimo da bi kreirali
% sigmoid funkciju
if abs(mini)>=maxi
    vr1 = abs(mini);
else
    vr1 = maxi;
end
% kreiranje sigmoid funkcije koriste?i prethodno dobijenu vrednost vr1
s1 = vis_sigmLUT(vr1,2,0.2);

n1 = zeros(size(im1)); % formiramo novu matricu kako bi mogli da smestimo novu sliku
for i=1:size(im1,1)
    for j=1:size(im1,1)
        tmp_sig = s1((vr1+1)+im1(i,j)); % uzimamo vrednost iz look up tabele na odgovarajucem indeksu
        n1(i,j) = im1(i,j)+10*tmp_sig; % na vrednost odgovaraju?eg piksela u staroj slici dodajemo vrednost sigmoid funkcije pomnozene sa 10
    end
end

% isti postupak radimo za preostale tri slike

% za drugu
mini = min(im2(:));
maxi = max(im2(:));
if abs(mini)>=maxi
    vr2 = abs(mini);
else
    vr2 = maxi;
end
s2 = vis_sigmLUT(vr2,2,0.2);
n2 = zeros(size(im2));
for i=1:size(im2,1)
    for j=1:size(im2,2)
        tmp_sig = s2((vr2+1)+im2(i,j));
        n2(i,j) = im2(i,j)+10*tmp_sig;
    end
end

        
% za trecu
mini = min(im3(:));
maxi = max(im3(:));
if abs(mini)>=maxi
    vr3 = abs(mini);
else
    vr3 = maxi;
end

s3 = vis_sigmLUT(vr3,2,0.2);
n3 = zeros(size(im3));
for i=1:size(im3,1)
    for j=1:size(im3,2)
        tmp_sig = s3((vr3+1)+im3(i,j));
        n3(i,j) = im3(i,j)+10*tmp_sig;
    end
end


%za cetvrtu
tmp = lpyr{4};
srv = mean2(lpyr{4});
tmp = tmp-srv;
tmp = tmp.*0.1;
tmp = tmp+srv;

im4=ceil(tmp);
mini = min(im4(:));
maxi = max(im4(:));
if abs(mini)>=maxi
    vr4 = abs(mini);
else
    vr4 = maxi;
end

s4 = vis_sigmLUT(vr4,2,0.2);
n4 = zeros(size(im4));
for i=1:size(im4,1)
    for j=1:size(im4,2)
        tmp_sig = s4((vr4+1)+im4(i,j));
        n4(i,j) = im4(i,j)+10*tmp_sig;
    end
end

% matrice gde smestamo nove slike nakon mnozenja sa sigmoid funkcijama
lpyr_nova = cell(1,4);
lpyr_nova{1,1} = n1;
lpyr_nova{1,2} = n2;
lpyr_nova{1,3} = n3;
lpyr_nova{1,4} = n4;

g = vis_recon_lappyr(lpyr_nova,res,size_vec);
ref_slike = cat(3,b,ref_slike); % referentne slike
slike=cat(3,g,slike); % smestamo nove slike u trodimenzionalnu matricu 
end   


%% RASPODELA DINAMICKOG SUMA
% ESTIMATION OF DYNAMICAL NOISE
sl_raz = [];
% za nefiltrirane
for i=81:2:89
    % za ne filtrirane slike
    sl1 = double(ref_slike(:,:,i)); % prvi kadar
    sl2 =  double(ref_slike(:,:,i+1)); % drugi kadar
    sl1 = (sl1-min(sl1(:)))/(max(sl1(:))-min(sl1(:)));
    sl2 = (sl2-min(sl2(:)))/(max(sl2(:))-min(sl2(:)));
    raz_nf = sl1-sl2; % razlika prvog i drugog
    sl_raz = cat(3,raz_nf,sl_raz);
end



% iscrtavanje za nefiltrirane slike
t = -1:0.001:1-0.001;
figure;
hold on
for i=1:5
    tmp = sl_raz(:,:,i);
    h = hist(tmp(:),2000);
    
    subplot(1,5,i)
    plot(t,h)
    xlabel('Vrednosti')
    ylabel('Kolicina')
    title('Nefiltrirana slika')
end
hold off

%% ANIZOTROPSKA DIFUZIJA
% ANISOTROPIC DIFFUSION
slike_filt = [];
lambda = 0.25;
[m,n] = size(slike(:,:,1));
red_c = [1:m];
red_gornji=[1 1:m-1];
red_donji = [2:m m];
kol_c = [1:n];
kol_levo = [1 1:n-1];
kol_desno = [2:n m]; 

for i=1:size(slike,3)
    temp = slike(:,:,i);
    for j=1:5
    
    deltaG = temp(red_gornji,kol_c)-temp(red_c,kol_c);
    deltaL = temp(red_c,kol_levo)-temp(red_c,kol_c);    
    deltaI = temp(red_donji,kol_c)-temp(red_c,kol_c);
    deltaD = temp(red_c,kol_desno)-temp(red_c,kol_c); 
    
    fluxG = deltaG.*exp(-(1/10)*abs(deltaG));
    fluxL = deltaL.*exp(-(1/10)*abs(deltaL));
    fluxI = deltaI.*exp(-(1/10)*abs(deltaI));
    fluxD = deltaD.*exp(-(1/10)*abs(deltaD));
    
    fluxGD = fluxG-fluxG(red_donji,kol_c);
    fluxLD = fluxL-fluxL(red_c,kol_desno);
    fluxDG = fluxI-fluxI(red_gornji,kol_c);
    fluxDL = fluxD-fluxD(red_c,kol_levo);
    temp = temp+lambda*(fluxGD+fluxLD+fluxDG+fluxDL);
   
    end
    slike_filt = cat(3,temp,slike_filt);

     % fluxG-fluxG(red_donji,kol_c) ---> gradijent od gore ka dole
     % fluxL-fluxL(red_c,kol_desno) ---> gradijent s leva na desno
     % fluxI-fluxI(red_gornji,kol_c) ---> gradijent od dole ka gore
     % fluxD-fluxD(red_c,kol_levo) ----> gradijent s desna na leov
    
end




%% PRONALAZENJE RAZLIKA MEDJU SLIKAMA
% FINDING DIFFERENCES BETWEEN IMAGES

raz =[];
for i=1:size(slike_filt,3)-1
    tmp = slike_filt(:,:,i);
    tmp1 = slike_filt(:,:,i+1);
    % svodimo opseg 0-255
    tmp =255*(mat2gray(tmp));
    tmp1 =255*(mat2gray(tmp1));
    tmp = ceil(tmp);
    tmp1 = ceil(tmp1);
    tmp2 = tmp~=tmp1;
    vr = sum(sum(tmp2));
    raz(i,1)=vr;
    
end
srv = mean2(raz);
raz1=[];
for i=1:size(raz,1)
    tmp = raz(i,1);
    if tmp>srv
        raz1(i,1)=1;
    else
        raz1(i,1)=0;
    end
end

raz1 = [raz1;0;0];


%% TEMPORALNO FILTRIRANJE
% TEMPORAL FILTERING ( NOT ON ALL IMAGES JUST WHERE DIFFERENCE IS SMALL)
% WHERE MOVMENT IS NOT DETECTED

clear sl
h = fspecial('gaussian',[6 1],3);
sve_filt = filter(h,1,slike_filt,[],3);
sl=[];
for i=1:size(slike_filt,3)
    tmp=raz1(i,1);
    tmp1 = raz1(i+1,1);
    
    if tmp==0 && tmp1==0
        sl = cat(3,sve_filt(:,:,i),sl);
    else
        sl = cat(3,slike_filt(:,:,i),sl);
    end
end

clear slike_filt;
slike_filt = sl; 


%% TONIRANJE
% TONE SCALING
lut3 = vis_tsLUT(255,-1,0.7,1); % lookup tabela za toniranje sigmoid funkcijom
slike_kon=[];

for i=1:size(slike_filt,3)
    tmp_sl = ceil(255*mat2gray(slike_filt(:,:,i))); % svedemo slike na opseg 0-255
    nova = zeros(size(tmp_sl));
    for j=1:size(tmp_sl,1)
        for k=1:size(tmp_sl,2)
            ind = tmp_sl(j,k)+1;
            vr = lut3(1,ind);
            nova(j,k) = vr;
        end
    end
    slike_kon = cat(3,nova,slike_kon);
end

            
%% POJACANJE KONTRASTA
% CONTRAST ENHACMENT
t_high = 98/100*255; 
t_low = 2/100*255;
slike_kon1 = [];
for i=1:size(slike_kon,3)
    tmp_sl = slike_kon(:,:,i);
    tmp = zeros(size(tmp_sl));
    for j=1:size(tmp_sl,1)
        for k=1:size(tmp_sl,2)
            if tmp_sl(j,k)<=t_low
                tmp(j,k)=0;
            elseif tmp_sl(j,k)>t_high
                tmp(j,k)=255;
            else
                tmp(j,k)=tmp_sl(j,k);
            end
        end
    end
    slike_kon1 = cat(3,tmp,slike_kon1);
end

% temp = [];
% for i=0:size(slike_kon1,3)-1
%     tmp = slike_kon1(:,:,size(slike_kon1,3)-i);
%     temp(:,:,i+1) = tmp;
% end
% clear slike_kon1 
% slike_kon1 = temp;
% clear temp
% skaliranje za video           
sl = [];
for i=1:size(slike_kon1,3)
    tmp = slike_kon1(:,:,i);
    tmp  =(tmp-min(tmp(:)))/(max(tmp(:))-min(tmp(:)));
    sl(:,:,i) = tmp;
end
%% FILTRIRANE SLIKE PRIKAZ SUMA 
% ESTIMATION NOISE OF PROCESSED IMAGES
sl_raz_f=[];
for i=81:2:89
    tmp = slike_kon1(:,:,i);
    tmp1 = slike_kon1(:,:,i+1);
    tmp = (tmp-min(tmp(:)))/(max(tmp(:))-min(tmp(:)));
    tmp1 = (tmp1-min(tmp1(:)))/(max(tmp1(:))-min(tmp1(:)));
    raz_f = tmp-tmp1;
    sl_raz_f=cat(3,raz_f,sl_raz_f);
end


figure;
hold on
for i=1:5
    tmp = sl_raz_f(:,:,i);
    h = hist(tmp(:),2000);
    
    subplot(1,5,i)
    plot(t,h)
    xlabel('Vrednosti')
    ylabel('Kolicina')
    title('Filtrirana slika')
  
end
hold off

profile viewer
profile off