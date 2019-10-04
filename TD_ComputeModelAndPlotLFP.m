function [vaf_x, vaf_y, x_vel, x_vel_pred, y_vel, y_vel_pred] = TD_ComputeModelAndPlotLFP(trial_data,BinToPast,name)

idx = randperm(length(trial_data));

test_idx = idx(1:30);
train_idx = idx(31:length(trial_data));

% train_idx = idx;

% Dup and Shift the PCA projections
trial_data = dupeAndShift(trial_data,name,-(1:BinToPast));

% getModel will build the wiener cascade. prepare the inputs
mod_params.model_type = 'linmodel';
mod_params.in_signals = [name '_shift'];
mod_params.out_signals = 'vel';
mod_params.train_idx = train_idx;

trial_data = getModel(trial_data,mod_params);

% actual_vel = cat(1,trial_data(test_idx).vel);
% pred_vel = cat(1,trial_data(test_idx).linmodel_default);
x_vel = getSig(trial_data(test_idx),{'vel',1});
y_vel = getSig(trial_data(test_idx),{'vel',2});
x_vel_pred = getSig(trial_data(test_idx),{'linmodel_default',1});
y_vel_pred = getSig(trial_data(test_idx),{'linmodel_default',2});
% x_vel = getSig(trial_data,{'vel',1});
% y_vel = getSig(trial_data,{'vel',2});
% x_vel_pred = getSig(trial_data,{'linmodel_default',1});
% y_vel_pred = getSig(trial_data,{'linmodel_default',2});

vaf_x = compute_vaf(x_vel,x_vel_pred);
vaf_y = compute_vaf(y_vel,y_vel_pred);

end