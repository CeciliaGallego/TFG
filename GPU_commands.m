% GPU details
gpu = gpuDevice;

% Move a variable from the workspace to the GPU
GPU_name = gpuArray(workspace_name);

% Move back the variable from the GPU to the workspace
workspace_name = gather(GPU_name);
