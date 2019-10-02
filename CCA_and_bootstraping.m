close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, 'idx_goCueTime',{'idx_goCueTime',124});

% Smooth spikes
trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));

% Do PCA
[trial_data,params_pca] = dimReduce(trial_data, struct('signals','M1_spikes','num_dims',10));

% Get trials to the same target
targets = unique([trial_data.tgtDir]);


fq = trial_data(1).M1_lfp_guide(1:7,3);
bands = {'d','a','b','g1','g2','g3','g4'};

% Separate in frequency bands
for band = 1:7
    for trial = 1: length(trial_data)
        isFreq = trial_data(trial).M1_lfp_guide(:,3) == fq(band); % Maximum frequency == 5
        trial_data(trial).(bands{band}) = trial_data(trial).M1_lfp(:,isFreq);
    end
end

% Generate matrices for CCA
pca = []; r = [];
for band = 1:7
    lfp = [];
    for trial = 1:length(trial_data)
        if band == 1
            pca = cat(1,pca,trial_data(trial).M1_pca);  
        end
        lfp = cat(1,lfp,trial_data(trial).(bands{band}));
    end  
    [~,~,aux] = canoncorr(lfp,pca);
    r = cat(1,r,aux);
end

r_boot = [];
for iter = 1:1000
    rand_idx = randperm(length(trial_data));
    disp(iter)
    for band = 1:7
        r_lfp = [];
        for trial = 1:length(trial_data)
            r_lfp = cat(1,r_lfp,trial_data(rand_idx(trial)).(bands{band}));
        end  
        [~,~,aux] = canoncorr(r_lfp,pca);
        r_boot = cat(1,r_boot,aux);
    end
end

new_r_boot = mean(r_boot);

% Plot result
c = parula(7);
figure
for band = 1:7
    hold on; plot(r(band,:),'color',c(band,:));   
%     hold on; plot(r_boot(band,:),'color',c(band,:));   
end
hold on; plot(new_r_boot,'k','linewidth',2);





% lfp = []; pca = [];
% for n = 1: length(trial_data)
%     lfp = cat(1,lfp,trial_data(n).M1_lfp);
%     pca = cat(1,pca,trial_data(n).M1_pca);
% end
% [~,~,aux] = canoncorr(lfp,pca);
% r = cat(1,r,aux);
% hold on; plot(r(8,:),'color',c(8,:));
% legend(bands)

% % Get one target
% targets = unique(cat(1,trial_data.tgtDir));
% [~, data_target] = getTDidx(trial_data,'tgtDir',targets(5));

% c = CorrelationMatrix(data_target,'SingleFreq',1);
