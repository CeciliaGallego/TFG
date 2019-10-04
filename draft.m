close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
td = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

r_idx = randperm(286);
% % limit = min([td.idx_endTime] - [td.idx_goCueTime]);
% % 
% % for n = 1:length(td)
% %     td(n).M1_lfp = td(n).M1_lfp(td(n).idx_goCueTime:td(n).idx_goCueTime+limit-1,:);
% %     td(n).vel = td(n).vel(td(n).idx_goCueTime:td(n).idx_goCueTime+limit-1,:);
% % end
   
td = trimTD(td, {'idx_movement_on',-12},{'idx_movement_on',69});

td = dupeAndShift(td,'M1_lfp',-(1:5));


mod_params.model_type = 'linmodel';
mod_params.in_signals = 'M1_lfp_shift';
mod_params.out_signals = 'vel';
mod_params.train_idx = r_idx(1:250);

trial_data = getModel(td,mod_params);

test_idx = r_idx(251:286);

act_vel = []; est_vel = [];
for idx = test_idx
    act_vel = cat(1,act_vel,trial_data(idx).vel);
    est_vel = cat(1,est_vel,trial_data(idx).linmodel_default);
end

vaf_x = compute_vaf(act_vel(:,1),est_vel(:,1));
vaf_y = compute_vaf(act_vel(:,2),est_vel(:,2));