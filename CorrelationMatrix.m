function [corr_matrix] = CorrelationMatrix (trial_data, field, column)
% Compute the correlation matrix

% trial_data: structure containing the data to correlate
% field: string indicating the name of the field from trial_data to
% correlate
% column: the neuron or lfp chanel (and frequency band) to correlate

TimeLimit = min(cat(1,trial_data.idx_endTime)-cat(1,trial_data.idx_goCueTime))
samples = size(trial_data,2);
data = zeros (TimeLimit,samples);

for n = 1: samples
    aux = getfield(trial_data,{n},field);
    data(:,n) = aux(trial_data(n).idx_goCueTime:trial_data(n).idx_goCueTime+TimeLimit-1,column);
end

corr_matrix = corr(data);
figure
imagesc(corr_matrix); colormap 'jet'; colorbar

corr_matrix = corr_matrix(~isnan(corr_matrix));

% figure
% for n = 1:samples
%     if mean(corr_matrix(n,:))< 0.5 
%         color = 'r';
%     else
%         color = 'b';
%     end
%     hold on; plot(data(:,n),color);
% end

end

