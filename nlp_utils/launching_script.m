% If you use this code or this method, please cite the following paper:
% [1] @InProceedings{Alayrac16unsupervised,
%     author      = "Alayrac, Jean-Baptiste and Bojanowski, Piotr and Agrawal, 
%     Nishant and Laptev, Ivan and Sivic, Josef and Lacoste-Julien, Simon",
%     title       = "Unsupervised learning from Narrated Instruction Videos",
%     booktitle   = "Computer Vision and Pattern Recognition (CVPR)",
%     year        = "2016"
% }
%
% This script launches the Multiple Sequence Alignment (MSA) for the text
% sequences described in Section 4.1 of the paper.
%
% To launch the demo, you need to download the preprocessed data. 
% (see README for instructions) and copy them in ../data/.
%
% NOTE: for better results, one can launch several random initialization of
% the program and keep the solution that leads to the lowest objective. We
% give mat files of results that we obtained in our paper in the folder
% ../results.
%
% Run compile.m before launching this script.

% =========================================================================
%                             ADDING UTILS PATH
% =========================================================================

addpath('functions/');
addpath('bin/');

% =========================================================================
%                                DATA PATH 
% =========================================================================

pathData    = '../data';
 
% =========================================================================
%                                   SEED 
% =========================================================================

seed = 3;
rng(seed);

% =========================================================================
%               TASK (changing_tire, repot, cpr, jump_car, coffee)
% =========================================================================

task   = 'changing_tire';


% =========================================================================
%                               PARAMETERS
% =========================================================================

params_msa_fw.L               = 120;   % size of the global common template (see paper [1], Appendix B)
params_msa_fw.cost_similar    = -1;   % cost c if similar (see Section 5 of the paper)
params_msa_fw.cost_dissimilar = 100;  % cost c if dissimilat (see Section 5 of the paper)
params_msa_fw.sim_thresh      = 1;    % threshold in the wordnet distance to be similar
params_msa_fw.niter           = 200; % number of iterations in the procedure
params_msa_fw.verbose         = true; % verbose mode displays information during optimization

% OPTIONS 
opts.pathData   = pathData; 
opts.maxWord    = 45;
opts.preprocSeq = true;
opts.task       = task;

% =========================================================================
%                     MULTIPLE SEQUENCE ALIGNMENT
% =========================================================================

% load the data
datas       = load_data_nlp(opts);
% launch optimization (and display qualitative results)
RES         = get_res_msa_fw(datas, params_msa_fw);
RES.opts    = opts;
