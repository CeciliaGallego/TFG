close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});


% Plot kinematics
figure
for n = 1:length(trial_data)
    hold on; plot(trial_data(n).pos(:,1));
end
hold on; line([54,54],[-10,10]);

figure
for n = 1:length(trial_data)
    hold on; plot(trial_data(n).pos(:,2));
end
hold on; line([54,54],[-40,-20]);

figure
for n = 1:length(trial_data)
    hold on; plot(trial_data(n).vel(:,1));
end
hold on; line([54,54],[-40,40]);

figure
for n = 1:length(trial_data)
    hold on; plot(trial_data(n).vel(:,2));
end
hold on; line([54,54],[-40,40]);