close all; clear all; clc;

% boot = false;
% disp('File 1');
% [result{1},info{1}] = DecoderMovementOnset('Chewie_CO_20161410.mat',boot);
% disp('File 2');
% [result{2},info{2}] = DecoderMovementOnset('Chewie_CO_20162110.mat',boot);
% disp('File 3');
% [result{3},info{3}] = DecoderMovementOnset('Mihili_CO_20140303.mat',boot);
% disp('File 4');
% [result{4},info{4}] = DecoderMovementOnset('Mihili_CO_20140403.mat',boot);
% disp('File 5');
% [result{5},info{5}] = DecoderMovementOnset('Mihili_CO_20140603.mat',boot);

load('DecodeMovementOnset.mat');

boot = true;
disp('File 6');
[result{6},info{6}] = DecoderMovementOnset('Chewie_CO_20161410.mat',boot);
disp('File 7');
[result{7},info{7}] = DecoderMovementOnset('Chewie_CO_20162110.mat',boot);
disp('File 8');
[result{8},info{8}] = DecoderMovementOnset('Mihili_CO_20140303.mat',boot);
disp('File 9');
[result{9},info{9}] = DecoderMovementOnset('Mihili_CO_20140403.mat',boot);
disp('File 10');
[result{10},info{10}] = DecoderMovementOnset('Mihili_CO_20140603.mat',boot);


save('DecodeMovementOnset.mat');