function [im,panel_ind,prev_im,hdr,roi] = vis_read_raw(im_fname,crop_flag)

% Visaris: ucitaj raw sliku iz datoteke. Moze da vrati i preview sliku za
% odgovarajuci panel
%   [im,panel_type,prev_im,hdr] = vis_read_raw(im_fname,crop_flag)
% VP, 2007., 2008.

if ~exist(im_fname,'file'), error(['Trazena slika ne postoji! - ' im_fname]); end
% Proveri ako je velicina data kao parametar
if nargin<2, crop_flag = 0; end
hdr = [];
l = dir(im_fname);

% Utvrdi ulazni tip i
ext = data_fname_split(im_fname,'ext');
ext = ext(1:4);
L_hdr = 0;			% Zaglavlje formata
switch ext
  case {'.fxd','.FXD','.raw','.RAW'}
    % Odredi velicinu
    switch l.bytes
			case 13824000  % Pixium 3543 EZ, indeks 7
				im_size = [2880 2400];
				panel_ind = 7;
      case 16588800  % Pixium 4143 ili 4343, indeks 3
        im_size = [2880 2880];
        panel_ind = 3;
      case 19481282  % Pixium 4600, indeks 0
        im_size = [3121 3121];
        panel_ind = 0;
      case 14400000  % Pixium portable 3543, indeks 4
        im_size = [2400 3000];
        panel_ind = 4;
      case 5990400 % TRix 2430EZ, indeks 5
        im_size = [1560 1920];
        panel_ind = 5;
      case 18481152  % Toshiba 4343
        im_size = [3072 3008];        
        panel_ind = 1;
      case 14993280  % Toshiba 3543_W
        im_size = [2466 3040];
        panel_ind = 30;
      case 18874368  % Varian PaxScan4343
        im_size = [3072 3072];
        if strfind(im_fname,'Samsung') % Vrlo niskobudzetno testiranje za Samsung
          panel_ind = 2;
        else  % Inace je Varian
          panel_ind = 6; 
				end  
			case 13041664 % Careray 1500P
				im_size = [2304 2816];
				L_hdr = 65536;
				panel_ind = 9;
            case 12976128 % CareRay bez hedera
                panel_ind = 13;
                im_size = [2304 2816];
			case 15859712 % Careray 1800R
				im_size = [2816 2816];
				panel_ind = 10;
      case 30723840 % PerkinElmer XRPAD 4336
				im_size = [4320 3556];
				panel_ind = 11;
      case 18013216 % Rayence 14x17
				im_size = [2756 3268];
				panel_ind = 17;
      case 11790368  % Konica AeroDR 1717, indeks 20
        im_size = [2428 2428];
				panel_ind = 20;
      case 9690840 % Konica AeroDR 1417, indeks 21
        im_size = [2430 1994];
				panel_ind = 21;
      case 4762368  % Konica AeroDR 1012, indeks 22
        im_size = [1696 1404];
				panel_ind = 22;
        case 15212544 % Varian 4336WV4
            im_size = [3072 2476];
            panel_ind = 23;
    end
    % Ucitaj sliku odgovarajuce velicine
    f = fopen(im_fname);
		hdr = uint8(fread(f,[1 L_hdr],'uint8'));
    im = uint16(fread(f,[im_size(2) im_size(1)],'uint16'))';
  otherwise
    error('Unrecognised panel format!')
    im = []; f = []; im_size = [];
end
if ~isempty(f), fclose(f); end
if ~all(size(im)==im_size), error(['Error reading image. Should be size ' num2str(im_size) ' is ' num2str(size(im))]); end

% ===============  Neophodne korekcije slika =========================
switch panel_ind
  case 11
   im(im>16384) = 16384;      % korigujemo zasicenje na 16 bita umesto na 14 
end    


% ===============  Isecanje neaktivnog dela slika =========================
roi = [];
if crop_flag && size(im,1)>1000
  switch panel_ind
    case 0  % Trixell Pixium 4600
      im = im(61:3061,61:3061);
      roi = [61, 3061, 61, 3061];
    case 1 % Varian PaxScan4343
			if sum(sum(im(11:20,11:20)))==0
				im = im(:,33:3040);	% Toshiba 4343	
                roi = [1, size(im,1), 33, 3040];
            elseif min(size(im)) == 3008
                roi = [1, size(im, 1), 1, size(im, 2)];
			else
				im = im(11:3062,11:3062);  % Varian 4343
                roi = [11, 3062, 11, 3062];
			end
		case 3 % Trixell 4143 ili 4343
			% Odluci da li je 4143 ili 4343
			if sum(sum(im(100:150,2810:2860)))==0
				im = im(5:2876,33:2804);    % Trix 4143
                roi = [5, 2876, 33, 2804];
			else
				im = im(5:2876,33:2868);    % Trix 4343
                roi = [5, 2876, 33, 2868];
            end
        case 6 % Varian ili DRTech
            im = im(11:3062,11:3062);
            roi = [11, 3062, 11, 3062];
		case 7 % Trixell 3543 EZ
			im = im(41:2840,61:2340);
            roi = [41, 2840, 61, 2340];
		case 9	% Careray
			im = im(7:2298,7:2810);
            roi = [7, 2298, 7, 2810];
			% im = im(5:2812,5:2300);
		case 10	% Careray 1800R
			im = im(7:2810,7:2810);
            roi = [7, 2810, 7, 2810];
    case 13 % CareRay
            im = im(5:end-4, 5:end-4);
            roi = [4, size(im,1)-4, 5, size(im,2)-4];
    case 21   % Konica 1417
      im = im(1:2428,1:1992);
      roi = [1, 2428, 1, 1992];
    case 22   % Konica 1012
      im = im(1:1692,1:1404);
      roi = [1, 1692, 1, 1404];
  end
end

% Simuliranje preview slika
if nargout>2
  prev_im = [];
  switch panel_ind
    case 0  % Pixium 4600, redukujemo rezoluciju na 1/4
      % if ~libisloaded('xprp'), vis_load_dlls, end
      if size(im,1)~= 3001, prox_im = im(61:3060,61:3060); else prox_im = im(1:3000,1:3000); end
			prev_im = uint16(prox_im(1:4:3000,1:4:3000));
      % prev_im = uint16(zeros([750,750]));
      % [~,prev_im] = calllib('xprp','xprp_redukuj_rezoluciju',prox_im,int32(3000),int32(3000),2,prev_im);
    case {4,7,20,21}  % Pixium 3543, redukujemo rezoluciju na 1/4
      prev_im = imresize(im,1/4);
    otherwise % Trixell 4143, Varian, Samsung i Imix imaju sliku iste velicine
      prev_im = uint16(im);
  end
end

im = double(im);