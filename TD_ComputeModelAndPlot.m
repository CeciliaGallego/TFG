function [vaf_x, vaf_y, x_vel, x_vel_pred, y_vel, y_vel_pred] = TD_ComputeModelAndPlot(trial_data,smooth,pca,bin_size,pca_dims,BinToPast,pol)

% % Variables
% smooth = logical;
% pca = logical;
% bin_size = ms (e.g. 20)
% pca_dims = Number of principal component
% BinToPast = Including t0
decode_var = 'vel';
decode_mod = 'linmodel';
% pol = Polynomial fitting. It has to be an even number

idx = randperm(length(trial_data));
test_idx = idx(1:30);
train_idx = idx(31:length(trial_data));

% Width -> kernel width (std. dev.)
if smooth
    trial_data = smoothSignals(trial_data,struct('signals',{{'M1_spikes'}},'width',0.05));
end

% Change bin size
trial_data = binTD(trial_data,bin_size/10);

% Get PCA and data to obtain the latent variables
if pca
    [trial_data,~] = dimReduce(trial_data, struct('signals','M1_spikes','num_dims',pca_dims));
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

end