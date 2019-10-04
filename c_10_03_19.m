close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
trial_data = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

% Get only the data when the monkey is moving
trial_data = trimTD(trial_data, {'idx_movement_on',-12},{'idx_movement_on',42});

% Get array spatial distribution
load('C:\Users\Cecilia\Documents\MATLAB\Mis scripts\ArrayMap.mat')

for ch = 1:96
    c_ch = zeros(size(arr_map));
    for ch2 = 1:96
        idx = find(arr_map == ch2);
        c = [];
        for f = 7
            for trial = 1:length(trial_data)
                sig1 = trial_data(trial).M1_lfp(:,(ch-1)*7+f);
                sig2 = trial_data(trial).M1_lfp(:,(ch2-1)*7+f);
                c(end+1) = corr(sig1,sig2);
            end
        end
        c_ch(idx) = mean(c);
    end
    close all;
    figure
    disp(ch)
    imagesc(c_ch); colormap 'jet'; caxis([-1 1]); colorbar;
    pause (0.1)
end
            

