function [vaf, actual, predicted] = TD_ComputeModelLFPtoLatVar(trial_data,BinToPast,name)

idx = randperm(length(trial_data));

test_idx = idx(1:round(length(trial_data)*0.1));
train_idx = idx(round(length(trial_data)*0.1)+1:length(trial_data));

% train_idx = idx;

% Dup and Shift the PCA projections
trial_data = dupeAndShift(trial_data,name,-(1:BinToPast));

% getModel will build the wiener cascade. prepare the inputs
mod_params.model_type = 'linmodel';
mod_params.in_signals = [name '_shift'];
mod_params.out_signals = 'M1_pca';
mod_params.train_idx = train_idx;
mod_params.polynomial = 3;

trial_data = getModel(trial_data,mod_params);
 
actual = getSig(trial_data(test_idx),'M1_pca');
predicted = getSig(trial_data(test_idx),'linmodel_default');


vaf = compute_vaf(actual,predicted);

end