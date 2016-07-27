% This script reproduces the NLP qualitative results given in the paper:
% [1] @InProceedings{Alayrac16unsupervised,
%     author      = "Alayrac, Jean-Baptiste and Bojanowski, Piotr and Agrawal, 
%     Nishant and Laptev, Ivan and Sivic, Josef and Lacoste-Julien, Simon",
%     title       = "Unsupervised learning from Narrated Instruction Videos",
%     booktitle   = "Computer Vision and Pattern Recognition (CVPR)",
%     year        = "2016"
% }

addpath('../nlp_utils/functions/');

pathResults = '../results';
pathData    = '../data';

% ========================================================================
%       CHOOSE THE TASK (changing_tire, repot, jump_car, cpr, coffee)
% ========================================================================

task = 'changing_tire';

% ========================================================================
%       OPTIONS
% ========================================================================

opts.pathData   = pathData; 
opts.maxWord    = 45;
opts.preprocSeq = true;
opts.task       = task;

% ========================================================================
%       LOAD DATA AND RESULTS
% ========================================================================

datas_nlp   = load_data_nlp( opts );
res_nlp     = load(fullfile(pathResults, 'NLP', ...
                sprintf('res_NLP_t_%s.mat', task)));
            
% ========================================================================
%       DISPLAY QUALITATIVE RESULTS
% ========================================================================            

display_qual_res(datas_nlp, res_nlp.RES.res_align);


% ========================================================================
%       OBJECTIVE VALUE (see Table 3 in Paper)
% ========================================================================    

fprintf('=============================================================\n');
fprintf('OBJECTIVE VALUE FOR FRANK-WOLFE MSA: %f\n', res_nlp.RES.res_align.f_fw); 
fprintf('=============================================================\n');