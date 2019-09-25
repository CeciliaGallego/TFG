close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, 'idx_goCueTime',{'idx_goCueTime',124});

% Get trials to the same target
targets = unique([trial_data.tgtDir]);
[idx,trial_data_tgt] = getTDidx(trial_data,'tgtDir',targets(8));

% for m = 1:size(trial_data(1).M1_lfp,2)
%     lfps = [];
%     for n = 1:length(trial_data_tgt)
%         lfps = cat(2,lfps,trial_data_tgt(n).M1_lfp(:,m));
%     end
%     cor = corr(lfps);
%     figure; 
%     imagesc(cor); colormap 'jet'; caxis([-1 1]); colorbar;
%     title(m); 
%     pause
% end
    

% lfps = [];
% for n = 1:length(trial_data_tgt)
%     lfps = cat(2,lfps,trial_data_tgt(n).M1_lfp);
% end
% c = corr(lfps);
% figure; 
% imagesc(c); colormap 'jet'; colorbar;




% % Find movement onset
% params.start_idx = 'idx_goCueTime';
% params.end_idx = 'idx_endTime';
% % params.which_method = 'thresh';
% % params.s_thresh = 4;
% % params.min_ds = 1;
% % params.field_idx = 2;
% td = getMoveOnsetAndPeak(trial_data,params);
% 
% 
% for n = 1:length(td)
%     if isnan(td(n).idx_movement_on)
%         td(n).idx_movement_on = idx_mov(n);
%     end
% end
% 
% % 
% %     hold off; plot(td(n).vel(td(n).idx_movement_on:td(n).idx_endTime,1));
% %     hold on; plot(td(n).vel(td(n).idx_movement_on:td(n).idx_endTime,2));
% %     title(n);
% figure
% for n = 1:length(td)
%     hold on; plot(td(n).vel(td(n).idx_goCueTime:end,1));
%     hold on; plot(td(n).vel(td(n).idx_goCueTime:end,2));
% end