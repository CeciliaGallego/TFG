close all; clear; clc
% Use the TrialData functions with PCA
% En este script hago PCA con todos los datos! (no es real)


% load('Chewie_CO_CS_2016-10-21.mat');
trial_data=loadTDfiles('Chewie_CO_CS_2016-10-21.mat',{@getTDidx,{'result','R'}});

% Variables
smooth = true;
bin_size = 20; % ms
pca_dims = 20; % Number of principal component
BinToPast = 5; % Including t0
idx = randperm(length(trial_data));
test_idx = idx(1:10);
train_idx = idx(11:length(trial_data));
decode_var = 'vel';
decode_mod = 'linmodel';
pol = 0; % It has to be an even number
pca = false;

% % % figure    % figure1
% % % n = 5;
% % % plot(trial_data(1).M1_spikes(trial_data(1).idx_movement_on:trial_data(1).idx_trial_end,n))
% % % hold on; plot(trial_data(1).M1_spikes(trial_data(1).idx_movement_on:trial_data(1).idx_trial_end,n))
% % % return

% Width -> kernel width (std. dev.)
if smooth
    trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));
end

% Change bin size to 20 ms
trial_data = binTD(trial_data,bin_size/10);

% Remove trials with NaN in their idx fields
trial_data = removeBadTrials(trial_data);

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, {'idx_movement_on',-0.3/(bin_size/1000)},'idx_trial_end');

% Get PCA and data to obtain the latent variables
if pca
    [trial_data,data] = dimReduce(trial_data, struct('signals','M1_spikes','num_dims',pca_dims));
    name = 'M1_pca';
else
    name = 'M1_spikes';
end

% Dup and Shift the PCA projections
trial_data = dupeAndShift(trial_data,name,-(1:BinToPast));

% getModel will build the wiener cascade. prepare the inputs
model_params = struct( ...
    'in_signals',{{[name '_shift']}}, ...
    'out_signals',{{decode_var}}, ...
    'model_type',decode_mod, ...
    'model_name',decode_var, ...
    'train_idx',train_idx, ...
    'polynomial',pol);
trial_data = getModel(trial_data,model_params);

x_vel = getSig(trial_data(test_idx),{decode_var,1});
y_vel = getSig(trial_data(test_idx),{decode_var,2});
x_vel_pred = getSig(trial_data(test_idx),{[decode_mod '_' decode_var],1});
y_vel_pred = getSig(trial_data(test_idx),{[decode_mod '_' decode_var],2});

vaf_x = compute_vaf(x_vel,x_vel_pred);
vaf_y = compute_vaf(y_vel,y_vel_pred);

% Plot the results
figure;

% Spacing
last_time = 0; last_pos = 0; spacing = 20; time = [];
for m = test_idx
    trial_length = trial_data(m).idx_trial_end;
    time = last_time+1:last_time+trial_length;
    x1 = x_vel(last_pos+1:last_pos+trial_length);
    x2 = x_vel_pred(last_pos+1:last_pos+trial_length);
    y1 = y_vel(last_pos+1:last_pos+trial_length);
    y2 = y_vel_pred(last_pos+1:last_pos+trial_length);
    last_pos = last_pos + trial_length;
    last_time = last_time+trial_length+spacing;
    subplot(2,1,1);hold on; plot(time,x1,'Color',[0, 0.4470, 0.7410],'LineWidth',2);...
        hold on; plot(time,x2,'Color',[0.8500, 0.3250, 0.0980],'LineWidth',2);
    subplot(2,1,2);hold on; plot(time,y1,'Color',[0, 0.4470, 0.7410],'LineWidth',2);...
        hold on; plot(time,y2,'Color',[0.8500, 0.3250, 0.0980],'LineWidth',2);
end
subplot(2,1,1); title(['VAF = ' num2str(vaf_x,3)]);
subplot(2,1,2); title(['VAF = ' num2str(vaf_y,3)]);

% ax(1) = subplot(2,1,1); hold all;
% plot(time,x_vel,c);
% plot(time,x_vel_pred,'LineWidth',2);
% title(['VAF = ' num2str(vaf_x,3)]);
% 
% ax(2) = subplot(2,1,2); hold all;
% plot(time,y_vel,'LineWidth',2);
% plot(time,y_vel_pred,'LineWidth',2);
% title(['VAF = ' num2str(vaf_y,3)]);

h = legend({'Actual','Predicted'},'Location','SouthEast');
set(h,'Box','off');


% % To separate trials if necessary
% td = splitTD(td,struct( ...
%     'split_idx_name','idx_trial_start', ...
%     'linked_fields',{{'result','target_direction'}}));

% % Get idices
% idx = getTDidx(trial_data,'target_direction',0);

% You can obtain the speed by normalizing the velocities
% trial_data = getNorm(trial_data,struct('signals','vel','norm_name','speed'));


%% Dudas
% Al hace PCA, tendria sentido hacer smooth a las ppal components en vez de
% a los spikes?
