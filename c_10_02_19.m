close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});

% Get trials to the same target
targets = unique([trial_data.tgtDir]);

% % Standard deviation of each band and channel
% result = zeros(96,8);
% for tgt = 1:8
%     [~,td_tgt] = getTDidx(trial_data,'tgtDir',targets(tgt));
%     for ch = 1:96
%         ch_std = [];
%         for freq = 1:7
%             idx = freq + (ch-1)*7;
%             lfp = [];
%             for trial = 1:length(td_tgt)
%                 lfp = cat(2,lfp,td_tgt(trial).M1_lfp(:,idx));
%             end
%             cor = corr(lfp);
%             mask = tril(true(size(cor)),-1);
%             out = cor(mask);
%             ch_std(end+1) = std(out);
%         end
%         result(ch,tgt) = mean(ch_std);
%     end
% end
% result = mean(result,2);
% 
% figure
% plot(result)
% 
% load('C:\Users\Cecilia\Documents\MATLAB\Mis scripts\mod_channelAndBand.mat')
% modulated = [];
% for n = 1:7:672
%     mod = sum(mask(n:n+6));
%     if mod > 5
%         modulated(end+1) = ceil(n/7);
%     end
% end
% hold on; scatter(modulated, result(modulated));



% Standard deviation of each band and channel
result = zeros(672,8); tot_cor = zeros(672,8);
for tgt = 1:8
    for band = 1:size(trial_data(1).M1_lfp,2)
        [~,td_tgt] = getTDidx(trial_data,'tgtDir',targets(tgt));
        lfps = [];
        for m = 1:length(td_tgt)
            lfps = cat(2,lfps,td_tgt(m).M1_lfp(:,band));
        end
        cor = corr(lfps);
        mask = tril(true(size(cor)),-1);
        out = cor(mask);
        result(band,tgt) = std(out);
        tot_cor(band,tgt) = mean(out);
    end
end
result = mean(result,2);
tot_cor = mean(tot_cor,2);

figure 
plot(result)
load('C:\Users\Cecilia\Documents\MATLAB\Mis scripts\mod_channelAndBand.mat')
idx = (1:672).*mask; idx (idx == 0) = [];
hold on; scatter(idx,result(idx));
hold on; plot(idx,result(idx));

load('C:\Users\Cecilia\Documents\MATLAB\Mis scripts\ArrayMap.mat')
mask = zeros (10);
mask (arr_map >= 28 & arr_map <= 68) = 1;
figure; 
imagesc(mask)