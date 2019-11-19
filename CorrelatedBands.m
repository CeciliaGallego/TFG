close all; clear; clc;

freq = 9;
filename = 'Chewie_CO_20162110.mat';
varname = 'M1_lfp';
kinename = 'vel';
toSave = false;
use = 15; 
same_channels = false;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles(filename,{@getTDidx,{'result','R'}});

var = []; kine = [];
for trial = 1:length(trial_data)
    var = cat(1,var,trial_data(trial).(varname));
    kine = cat(1,kine,trial_data(trial).(kinename));
end
c = corr(var,kine);
c = mean(abs(c),2);


if same_channels
    use;
    new_c = zeros(1,96);
    for ch = 1:96
        idx = trial_data(1).M1_lfp_guide(:,1) == ch;
        new_c(ch) = mean(c(idx));
    end
    [~,idx] =  sort(new_c,'descend');
    for trial = 1:length(trial_data)
        trial_data(trial).corr_bands = idx(1:use);
        trial_data(trial).mod_lfp = trial_data(trial).(varname)(:,ismember(trial_data(1).M1_lfp_guide(:,1),idx(1:use)));
        trial_data(trial).mod_lfp_guide = trial_data(trial).([varname '_guide'])(ismember(trial_data(1).M1_lfp_guide(:,1),idx(1:use)),:);  
    end
else
    [~,idx] = sort(c,'descend');
    data = zeros(96,freq);
    bands = unique(trial_data(1).M1_lfp_guide(:,3));
    f = trial_data(1).M1_lfp_guide(idx,3);
    for b = 1:length(bands)
        band_idx = f == bands(b);
        aux = idx(band_idx);
        data(:,b) = aux;
    end
    for trial = 1:length(trial_data)
        aux = data(1:use,:);
        trial_data(trial).corr_bands = aux(:);
        trial_data(trial).mod_lfp = trial_data(trial).(varname)(:,aux(:));
        trial_data(trial).mod_lfp_guide = trial_data(trial).([varname '_guide'])(aux(:),:);
    end
end

figure
subplot(1,2,1)
histogram(trial_data(1).mod_lfp_guide(:,1),max(trial_data(1).mod_lfp_guide(:,1))); title('Channels');
subplot(1,2,2)
histogram(trial_data(1).mod_lfp_guide(:,3),100); title('Frequencies');

if toSave
    save(filename,'trial_data');
end 