function res = get_f1_for_task( task, lambda, K, pathData, pathResults )
%GET_F1_FOR_TASK Summary of this function goes here
%   Detailed explanation goes here
params.task    = task;
params.lambda  = lambda;
params.K       = K;    
params.seed    = 1;

% variable selection
params.delta_l = 0;
params.delta_r = 30;
params.seed    = 1;

formatRes = 'res_VISION_t_%s_k_%02d_l_%5.3e_dl_%d_dr_%d_s_%d.mat';    
nameres = sprintf(formatRes, params.task, params.K, params.lambda, ...
                params.delta_l, params.delta_r, params.seed);
                                    
try 
    RES = load(fullfile(pathResults, 'VISION', nameres),'res');
catch
    altformatRes = 'cvprexp_t_%s_im_%s_k_%02d_l_%5.3e_dl_%d_dr_%d_s_%d_%s_m_%s_pp_%s_broad_%s.mat';       
    altnameres = sprintf(altformatRes, params.task, 'msa_fw', params.K, ...
                      params.lambda, params.delta_l, params.delta_r, params.seed,...
                      'proper','clean', num2str(true), num2str(true));
                  
    copyfile(fullfile('/sequoia/data1/jalayrac/CVPR2016/cameraReady_ourmethod', altnameres),...
        fullfile(pathResults, 'VISION', nameres));
    
    fprintf('You need to download the results (see README file) \n');
    res = [];
    return
end

% ==== STATISTICS ON THE DATASET ====
% get the number of videos

nVid  = numel(RES.res.clips);

% get the number of steps annotated
realK = size(RES.res.RES_VID.obj(1).perf_ccr_all,2);

% =========================================================================
%  LOAD DATA (to be able to compute F1 score)
% =========================================================================

% get number of annotations for this task
annot = load(fullfile(pathData, 'VISION',params.task,'features',...
    'full_dataset.mat'), 'Y','hw3');

% count number of unique annotations (note that we remove the
% background) :
nAnnot = sum(cellfun(@(x) sum(sum(x(:,1:end-1),1)>1), annot.Y));

% TODO: remove this check
% check if the number of videos matches the feature
if nVid~=numel(annot.Y)
    warning('Different number of videos in the feature and while running the method');
    % we need to recompute nAnnot!
    clipids = RES.res.clipids;
    nAnnot = 0;
    for c=1:numel(clipids)
        indVid = find(strcmp(clipids{c},{annot.hw3.clipid}));
        nAnnot = nAnnot + numel(unique(annot.hw3(indVid).actid));
    end        
end

% assert that we have the good number of steps
assert(realK == size(annot.Y{1},2)-1 );

% =========================================================================
%  ANALYZE RESULTS (to be able to compute F1 score)
% =========================================================================

% choose the best rounding according to objective value
iter_best_ccr = RES.res.RES_VID.crr.ccr_iter;

perf_best = mean(RES.res.RES_VID.obj(iter_best_ccr ).perf_ccr);

nCorrectPred = perf_best * nVid * realK;
nPred        = RES.res.K_predict * nVid;

precision = nCorrectPred / nPred;
recall    = nCorrectPred / nAnnot;
F1        = 2 * precision * recall / (precision+recall+0.0000001);

% ==== GET THE VARIATION ====
all_perf = zeros(numel(RES.res.RES_VID.obj),1);
for iter=iter_best_ccr:numel(RES.res.RES_VID.obj)
    all_perf(iter) = mean(RES.res.RES_VID.obj(iter).perf_ccr);
end

minNCorrectPred =  min(all_perf(iter_best_ccr:end)) * nVid * realK;
maxNCorrectPred =  max(all_perf(iter_best_ccr:end)) * nVid * realK;

minPrec = minNCorrectPred / nPred;
maxPrec = maxNCorrectPred / nPred;
minRec  = minNCorrectPred / nAnnot;
maxRec  = maxNCorrectPred / nAnnot;
minF1   = 2 * minPrec * minRec / (minPrec+minRec+0.00001);
maxF1   = 2 * maxPrec * maxRec / (maxPrec+maxRec+0.00001);

res.F1    = F1;
res.minF1 = minF1;
res.maxF1 = maxF1;     

    