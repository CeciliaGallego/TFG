close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110.mat',{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
% trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});
% trial_data = trimTD(trial_data, {'idx_goCueTime'}, {'idx_goCueTime', 100});

% Get array spatial distribution
load('C:\Users\Cecilia\Documents\MATLAB\Mis scripts\Revised\Chewie_ArrayMap.mat')
guide = trial_data(1).M1_lfp_guide;

% Correlation of each channel with the rest of them for each frequency
total_corr = [];
fq = unique(trial_data(1).M1_lfp_guide(:,3));
for f = 2:9
    chan_corr = zeros(10,10);
    for ch1 = 1:96
        chan_pos = find(arr_map == ch1);
        c = [];
        disp(ch1)
        idx1 = and((guide(:,1) == ch1),(guide(:,3)==fq(f)));
        for ch2 = 1:96
            idx2 = and((guide(:,1) == ch2),(guide(:,3)==fq(f)));
            for trial = 1:length(trial_data)
                sig1 = trial_data(trial).M1_lfp(:,idx1);
                sig2 = trial_data(trial).M1_lfp(:,idx2);
                c(end+1) = corr(sig1,sig2);
            end
        end
        chan_corr(chan_pos) = mean(c); 
    end
    figure
    limit = max(abs(chan_corr(:)));
    imagesc(chan_corr); colormap 'jet'; caxis([-limit limit]); colorbar;
    title(['Higher freq = ' num2str(fq(f))])
    total_corr = cat(3,total_corr,chan_corr);
    pause(1)
end            

% % Total value of the signal in each channel
% total = zeros(1,96);
% for ch = 1:96
%     disp(ch);
%     ch_sum = 0;
%     idx = guide(:,1) == ch;
%     for trial = 1:length(trial_data)
%         sig = trial_data(trial).M1_lfp(:,idx);
%         ch_sum = ch_sum + sum(sig(:));
%     end
%     total(1,ch) = ch_sum/(length(trial_data)*9);
% end
% 
% % Total variance of the signal in each channel
% total = zeros(1,96);
% for ch = 1:96
%     disp(ch);
%     ch_var = [];
%     idx = guide(:,1) == ch;
%     for trial = 1:length(trial_data)
%         sig = trial_data(trial).M1_lfp(:,idx);
%         ch_var(end+1) = mean(var(sig));
%     end
%     total(1,ch) = mean(ch_var);
% end
% 
% 
% signal_map = zeros(10,10);
% for n = 1:96
%     idx = find(arr_map == n);
%     signal_map(idx) = total(n);
% end
% figure
% imagesc(signal_map); colormap 'jet';
% 
% result = signal_map.*total_corr;
% figure
% imagesc(result); colormap 'jet';