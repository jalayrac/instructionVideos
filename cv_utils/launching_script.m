% If you use this code or this method, please cite the following paper:
%
% [1] @InProceedings{Alayrac16unsupervised,
%     author      = "Alayrac, Jean-Baptiste and Bojanowski, Piotr and Agrawal,
%     Nishant and Laptev, Ivan and Sivic, Josef and Lacoste-Julien, Simon",
%     title       = "Unsupervised learning from Narrated Instruction Videos",
%     booktitle   = "Computer Vision and Pattern Recognition (CVPR)",
%     year        = "2016"
% }
%
% This script launches the second stage of the method, namely the temporal
% localization of the steps in the videos (described in setion 4.2 in the
% paper).
%
% To launch the demo, you need to download the preprocessed data at this
% address:
%
% and copy them in ../data/
%
% We give mat files of results that we obtained in our paper in the folder
% ../results in order to be able to reproduce the Figure 3 of paper (see
% ploting scripts in ../display_res).
%

addpath('bin');
addpath('functions');

% =========================================================================
%               TASK (changing_tire, repot, cpr, jump_car, coffee)
% =========================================================================

opts.task = 'changing_tire';
opts.K    = 7;

% =========================================================================
%                              HYPERPARAMETERS
% =========================================================================

delta_b = 0;              % $\delta_b$ in the paper
delta_a = 30;             % $\delta_a$ in the paper, 30*10 frames ~= 10s
lambda  = 1./(30*opts.K); % $\lambda$ is set to be 1 over the number of
                          % predictions (there are 30 videos times number of
                          % cluster (=K) predictions to make.

% =========================================================================
%                       PARAMETERS OF OPTIMIZATION
% =========================================================================

params.niter   = 650;
params.verbose = true;

% =========================================================================
%                           PATHS FOR DATA
% =========================================================================

opts.pathData    = '../data';
opts.pathResults = '../results';

% =========================================================================
%                              RANDOM SEED
% =========================================================================

seed    = 1;  % random seed used in the paper
rng(seed);


% =========================================================================
%                      LOAD NLP RESULTS OF FIRST STAGE
% =========================================================================

params_nlp.broad          = true;
params_nlp.broad_tresh    = 0.9;
params_nlp.path_res_init  = sprintf(fullfile(opts.pathResults, 'NLP'),...
    opts.task);
params_nlp.format_res     = 'res_NLP_t_%s.mat';

fprintf('Loading NLP data...\n');
data_nlp                  = get_constrs_from_nlp(opts, params_nlp,...
                            delta_b, delta_a);
fprintf('Done. \n')

% =========================================================================
%                            VISION DATA
% =========================================================================

% vision parameters
params_vision.pathData    = sprintf(fullfile(opts.pathData, 'VISION',...
    '%s'), opts.task);
params_vision.feature     = 'full_dataset.mat'; % name of the vision feature

fprintf('Loading vision data...\n');
data_vision  = get_vision_data(params_vision, data_nlp);
fprintf('Done. \n')


% =========================================================================
%                         DIFFRAC OPTIMIZATION
% =========================================================================

res = get_res_temporal_localization(data_vision, lambda, params);
