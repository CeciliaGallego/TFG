close all; clear; clc;

% Open TD ('Chewie_CO_20162110.mat'   'Chewie_CO_CS_2016-10-21.mat')
td = loadTDfiles('Chewie_CO_20162110_ceci.mat',{@getTDidx,{'result','R'}});

td = FindMovementOn(td);
% td = trimTD(td, 'idx_goCueTime',{'idx_goCueTime',124});

targets = unique([td.tgtDir]);

for n = 1:8
    figure
    [~,td_tgt] = getTDidx(td,'tgtDir',targets(n));
    plot(diff([td_tgt.pos]))    
end

pos = [];
for n = 1:length(td_tgt)
    pos = cat(2,pos,td_tgt(n).pos(:,2));
end
mean(pos);

figure
for n = 1:length(td)
    hold on; plot(td(n).pos(td(n).idx_movement_on:end,1));
end

figure
for n = 1:length(td)
    hold on; plot(td(n).pos(td(n).idx_movement_on:end,2));
end