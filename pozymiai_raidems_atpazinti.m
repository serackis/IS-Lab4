function pozymiai = pozymiai_raidems_atpazinti(pavadinimas, pvz_eiluciu_sk)
%%  pozymiai = pozymiai_raidems_atpazinti(pavadinimas, pvz_eiluciu_sk)
% taikymo pavyzdys:
% pozymiai = pozymiai_raidems_atpazinti('test_data.png', 8) 
%
%%
% Vaizdo su pavyzdþiais nuskaitymas
V = imread(pavadinimas);
figure(12), imshow(V)
%% Raidþiø iðkirpimas ir sudëliojimas á kintamojo 'objektai' celes
V_pustonis = rgb2gray(V);
% vaizdo keitimo dvejetainiu slenkstinës reikðmës paieðka
slenkstis = graythresh(V_pustonis);
% pustonio vaizdo keitimas dvejetainiu
V_dvejetainis = im2bw(V_pustonis,slenkstis);
% rezultato atvaizdavimas
figure(1), imshow(V_dvejetainis)
% vaizde esanèiø objektø kontûrø paieðka
V_konturais = edge(uint8(V_dvejetainis));
% rezultato atvaizdavimas
figure(2),imshow(V_konturais)
% objektø kontûrø uþpildymas 
se = strel('square',7); % struktûrinis elementas uþpildymui
V_uzpildyti = imdilate(V_konturais, se); 
% rezultato atvaizdavimas
figure(3),imshow(V_uzpildyti)
% tuðtumø objetø viduje uþpildymas
V_vientisi= imfill(V_uzpildyti,'holes');
% rezultato atvaizdavimas
figure(4),imshow(V_vientisi)
% vientisø objektø dvejetainiame vaizde numeravimas
[O_suzymeti Skaicius] = bwlabel(V_vientisi);
% apskaièiuojami objektø dvejetainiame vaizde poþymiai
O_pozymiai = regionprops(O_suzymeti);
% nuskaitomos poþymiø - objektø ribø koordinaèiø - reikðmës
O_ribos = [O_pozymiai.BoundingBox];
% kadangi ribà nusako 4 koordinatës, pergrupuojame reikðmes
O_ribos = reshape(O_ribos,[4 Skaicius]); % Skaicius - objektø skaièius
% nuskaitomos poþymiø - objektø masës centro koordinaèiø - reikðmës
O_centras = [O_pozymiai.Centroid];
% kadangi centrà nusako 2 koordinatës, pergrupuojame reikðmes
O_centras = reshape(O_centras,[2 Skaicius]);
O_centras = O_centras';
% pridedamas kiekvienam objektui vaize numeris (treèias stulpelis ðalia koordinaèiø)
O_centras(:,3) = 1:Skaicius;
% surûðiojami objektai pagal x koordinatæ - stulpelá
O_centras = sortrows(O_centras,2);
% rûðiojama atsiþvelgiant á pavyzdþiø eiluèiø ir raidþiø skaièiø
raidziu_sk = Skaicius/pvz_eiluciu_sk;
for k = 1:pvz_eiluciu_sk
    O_centras((k-1)*raidziu_sk+1:k*raidziu_sk,:) = ...
        sortrows(O_centras((k-1)*raidziu_sk+1:k*raidziu_sk,:),3);
end
% ið dvejetainio vaizdo pagal objektø ribas iðkerpami vaizdo fragmentai
for k = 1:Skaicius
    objektai{k} = imcrop(V_dvejetainis,O_ribos(:,O_centras(k,3)));
end
% vieno ið vaizdo fragmentø atvaizdavimas
figure(5),
for k = 1:Skaicius
   subplot(pvz_eiluciu_sk,raidziu_sk,k), imshow(objektai{k})
end
% vaizdo fragmentai apkerpami, panaikinant fonà ið kraðtø (pagal staèiakampá)

for k = 1:Skaicius % Skaicius = 88, jei yra 88 raidës
    V_fragmentas = objektai{k};
    % nustatomas kiekvieno vaizdo fragmento dydis
    [aukstis, plotis] = size(V_fragmentas);
    
    % 1. Baltø stulpeliø naikinimas
    % apskaièiuokime kiekvieno stulpelio sumà
    stulpeliu_sumos = sum(V_fragmentas,1);
    % naikiname tuos stulpelius, kur suma lygi aukðèiui
    V_fragmentas(:,stulpeliu_sumos == aukstis) = [];
    % perskaièiuojamas objekto dydis
    [aukstis, plotis] = size(V_fragmentas);
    % 2. Baltø eiluèiø naikinimas
    % apskaièiuokime kiekvienos seilutës sumà
    eiluciu_sumos = sum(V_fragmentas,2);
    % naikiname tas eilutes, kur suma lygi ploèiui
    V_fragmentas(eiluciu_sumos == plotis,:) = [];
    objektai{k}=V_fragmentas;% áraðome vietoje neapkarpyto
end
% vieno ið vaizdo fragmentø atvaizdavimas
figure(6),
for k = 1:Skaicius
   subplot(pvz_eiluciu_sk,raidziu_sk,k), imshow(objektai{k})
end
%%
%% Suvienodiname vaizdo fragmentø dydþius iki 70x50
for k=1:Skaicius
    V_fragmentas=objektai{k};
    V_fragmentas_7050=imresize(V_fragmentas,[70,50]);
    % padalinkime vaizdo fragmentà á 10x10 dydþio dalis
    for m=1:7
        for n=1:5
            % apskaièiuokime kiekvienos dalies vidutiná ðviesumà 
            Vid_sviesumas_eilutese=sum(V_fragmentas_7050((m*10-9:m*10),(n*10-9:n*10)));
            Vid_sviesumas((m-1)*5+n)=sum(Vid_sviesumas_eilutese);
        end
    end
    % 10x10 dydþio dalyje maksimali ðviesumo galima reikðmë yra 100
    % normuokime ðviesumo reikðmes intervale [0, 1]
    Vid_sviesumas = ((100-Vid_sviesumas)/100);
    % rezultatà (poþmius) neuronø tinklui patogiau pateikti stulpeliu
    Vid_sviesumas = Vid_sviesumas(:);
    % iðsaugome apskaièiuotus poþymius á bendrà kintamàjá
    pozymiai{k} = Vid_sviesumas;
end