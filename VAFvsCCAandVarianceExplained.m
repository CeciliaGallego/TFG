% close all; clear all; clc;

%% Decoder performance vs CCA coefficients
filename = 'Chewie_CO_20162110.mat';
monkey = 'Chewie';

load(['dPCA_' filename]);
load(['fullVAF_' filename]);


vaf = mean(total_vaf(1:end-1,1:2),2);
time_var = explained(1,:);

bands = 1:9; 
figure
yyaxis left; b = bar(bands,time_var); yyaxis right; p = plot(bands,vaf);
title(monkey); xlabel('Frequecy bands'); yyaxis left; ylabel('% Variance (time)'); yyaxis right; ylabel('Decoder performance (VAF)')

name = {'LMP','0.5-4','4-8','8-12','12-25','25-50','50-100','100-200','200-400'};
set(gca, 'XTick', 1:9, 'XTickLabel',name);