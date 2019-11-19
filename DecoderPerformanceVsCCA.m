close all; clear all; clc;
%% Decoder performance vs CCA coefficients
filename = 'Chewie_CO_20161410_2.mat';

load(['CCA_' filename]);
load(['VAF_' filename]);
cca_coeff = mean(r_freq,2);
vaf = mean(total_vaf(1:end-1,1:2),2);
c = parula(length(cca_coeff)); 
figure
for n = 1:length(cca_coeff) 
    hold on; scatter(cca_coeff(n),vaf(n),'MarkerFaceColor',c(n,:),'MarkerEdgeColor',c(n,:)); 
end
xlabel('CCA coefficient'); ylabel('Decoder performance');
legend({'LMP','delta','theta','alpha','beta','30-50','50-100','100-200','200-400'})




%% Combine Mihili
filename = 'Mihili_CO_20140403.mat';

load(['CCA_' filename]);
load(['VAF_' filename]);
cca_coeff = mean(r_freq,2);
vaf = mean(total_vaf(1:end-1,1:2),2);
figure
for n = 1:length(cca_coeff) 
    hold on; scatter(cca_coeff(n),vaf(n),'MarkerFaceColor',c(n,:),'MarkerEdgeColor',c(n,:)); 
end
xlabel('CCA coefficient'); ylabel('Decoder performance');
legend({'LMP','delta','theta','alpha','beta','30-50','50-100','100-200','200-400'})

filename = 'Mihili_CO_20140303.mat';

load(['CCA_' filename]);
load(['VAF_' filename]);
cca_coeff = mean(r_freq,2);
vaf = mean(total_vaf(1:end-1,1:2),2);
for n = 1:length(cca_coeff) 
    hold on; scatter(cca_coeff(n),vaf(n),'MarkerFaceColor',c(n,:),'MarkerEdgeColor',c(n,:)); 
end
xlabel('CCA coefficient'); ylabel('Decoder performance');
legend({'LMP','delta','theta','alpha','beta','30-50','50-100','100-200','200-400'})

filename = 'Mihili_CO_20140603.mat';

load(['CCA_' filename]);
load(['VAF_' filename]);
cca_coeff = mean(r_freq,2);
vaf = mean(total_vaf(1:end-1,1:2),2);
c = parula(length(cca_coeff)); 
for n = 1:length(cca_coeff) 
    hold on; scatter(cca_coeff(n),vaf(n),'MarkerFaceColor',c(n,:),'MarkerEdgeColor',c(n,:)); 
end
xlabel('CCA coefficient'); ylabel('Decoder performance');
legend({'LMP','delta','theta','alpha','beta','30-50','50-100','100-200','200-400'})


%% Combine Chewie
filename = 'Chewie_CO_20162110.mat';

load(['CCA_' filename]);
load(['VAF_' filename]);
cca_coeff = mean(r_freq,2);
vaf = mean(total_vaf(1:end-1,1:2),2);
figure
for n = 1:length(cca_coeff) 
    hold on; scatter(cca_coeff(n),vaf(n),'MarkerFaceColor',c(n,:),'MarkerEdgeColor',c(n,:)); 
end
xlabel('CCA coefficient'); ylabel('Decoder performance');
legend({'LMP','delta','theta','alpha','beta','30-50','50-100','100-200','200-400'})



filename = 'Chewie_CO_20161410_1.mat';

load(['CCA_' filename]);
load(['VAF_' filename]);
cca_coeff = mean(r_freq,2);
vaf = mean(total_vaf(1:end-1,1:2),2);
for n = 1:length(cca_coeff) 
    hold on; scatter(cca_coeff(n),vaf(n),'MarkerFaceColor',c(n,:),'MarkerEdgeColor',c(n,:)); 
end
xlabel('CCA coefficient'); ylabel('Decoder performance');
legend({'LMP','delta','theta','alpha','beta','30-50','50-100','100-200','200-400'})



filename = 'Chewie_CO_20161410_2.mat';

load(['CCA_' filename]);
load(['VAF_' filename]);
cca_coeff = mean(r_freq,2);
vaf = mean(total_vaf(1:end-1,1:2),2);
for n = 1:length(cca_coeff) 
    hold on; scatter(cca_coeff(n),vaf(n),'MarkerFaceColor',c(n,:),'MarkerEdgeColor',c(n,:)); 
end
xlabel('CCA coefficient'); ylabel('Decoder performance');
legend({'LMP','delta','theta','alpha','beta','30-50','50-100','100-200','200-400'})