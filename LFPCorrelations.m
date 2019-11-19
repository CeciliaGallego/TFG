close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110.mat',{@getTDidx,{'result','R'}});

% % Get only the data when the monkey is moving
trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});
% trial_data = trimTD(trial_data, {'idx_goCueTime'}, {'idx_goCueTime', 100});

% Get trials to the same target
targets = unique([trial_data.tgtDir]);
fq = unique(trial_data(1).M1_lfp_guide(:,3));



% % Correlation of each frequency band of all the channels in each trial
% for trial = 1:length(trial_data)
%     figure
%     title(num2str(trial))
%     for band = 1:length(fq)
%         isFreq = trial_data(1).M1_lfp_guide(:,3) == fq(band);
%         lfp = trial_data(trial).M1_lfp(:,isFreq);
%         c = corr(lfp);
%         subplot(2,5,band)
%         imagesc(c); colormap 'jet'; caxis([-1 1]); %colorbar;
%     end
%     pause
%     close all
% end
 



% % Correlation to eaach target of each individual band    
band = 1:size(trial_data(1).M1_lfp,2);
% If you want to see an specific band
frequency = 3;
band = band(trial_data(1).M1_lfp_guide(:,3) == fq(frequency));

for b = band
    figure
    for n = 1:8
        [~,td_tgt] = getTDidx(trial_data,'tgtDir',targets(n));
        lfps = [];
        for m = 1:length(td_tgt)
            lfps = cat(2,lfps,td_tgt(m).M1_lfp(:,b));
        end
        cor = corr(lfps);
        subplot(2,4,n)
        imagesc(cor); colormap 'jet'; caxis([-1 1]); %colorbar;
        title(round(targets(n),2));
    end
    suptitle(['band = ' num2str(trial_data(1).M1_lfp_guide(b,2)) '-' num2str(trial_data(1).M1_lfp_guide(b,3))])
    pause
    close all
end




% % Standard deviation of the correlation matrix of each band and channel to
% % the same target
% tgt = 1; result = zeros(size(trial_data(1).M1_lfp,2),8); 
% tot_cor = zeros(size(trial_data(1).M1_lfp,2),8);
% for tgt = 1:8
%     for band = 1:size(trial_data(1).M1_lfp,2)
%         [~,td_tgt] = getTDidx(trial_data,'tgtDir',targets(tgt));
%         lfps = [];
%         for trial = 1:length(td_tgt)
%             lfps = cat(2,lfps,td_tgt(trial).M1_lfp(:,band));
%         end
%         cor = corr(lfps);
%         mask = tril(true(size(cor)),-1);
%         out = cor(mask);
%         result(band,tgt) = std(out);
%         tot_cor(band,tgt) = mean(out);
%     end
% end
% result = mean(result,2);
% tot_cor = mean(tot_cor,2);
% figure
% plot(result)