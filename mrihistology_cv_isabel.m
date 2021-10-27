clear
close all
datadir = 'C:\Users\justoh\Data\Isabel';
[num,txt,raw] = xlsread(fullfile(datadir,'spss_dataset_histo_MRI_epilep_ms.xlsx'));
% leave one animal out
animal_id = raw(2:69,2);
diffusion = num(:,1:7);
histol = num(:,8:10);
region_id = raw(2:69,1);
animals = unique(animal_id);
regions = unique(region_id);
% leave one out of the histological parameters
fold_animal = zeros(size(num,1),1);
for f = 1:length(animals)
   idx = strcmp(animals{f},animal_id);
   fold_animal(idx) = f;
end
for f = 1:length(regions)
    idx = strcmp(regions{f},region_id);
    fold_region(idx) = f;
end
hat_histol_animal =zeros(size(histol));
hat_histol_region =zeros(size(histol));
for f = 1:length(animals)  % for histol params
    which = strcmp(animals{f},animal_id); 
    Xtrain = [diffusion(~which,:),ones(sum(~which),1)];
    Xtest = [diffusion(which,:),ones(sum(which),1)];
    for i = 1:3
        y = histol(~which,i);
        b = regress(y,Xtrain);
        yhat = Xtest*b;
        hat_histol_animal(which,i) = yhat;
    end
end

for f = 1:length(regions)  % for histol params
    which = strcmp(regions{f},region_id); 
    Xtrain = [diffusion(~which,:),ones(sum(~which),1)];
    Xtest = [diffusion(which,:),ones(sum(which),1)];
    for i = 1:3
        y = histol(~which,i);
        b = regress(y,Xtrain);
        yhat = Xtest*b;
        hat_histol_region(which,i) = yhat;
    end
end

for i = 1:3
    res(1,i) = corr(hat_histol_animal(:,i),histol(:,i));
    res2(1,i) = corr(hat_histol_region(:,i),histol(:,i));
    %res(2,i) = mean(abs(hat_histol_animal(:,i) - histol(:,i)));
    % res2(2,i)    = mean(abs(hat_histol_region(:,i) - histol(:,i)));
    res(2,i) = 1 - sum(abs(hat_histol_animal(:,i) - histol(:,i)).^2)/sum(abs(histol(:,i) - mean(histol(:,i))).^2);
    res2(2,i) = 1 - sum(abs(hat_histol_region(:,i) - histol(:,i)).^2)/sum(abs(histol(:,i) - mean(histol(:,i))).^2);    
end
