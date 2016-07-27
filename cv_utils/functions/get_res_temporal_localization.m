function res = get_res_temporal_localization( data_vision, lambda, params )
% this code is performing the second stage of the CVPR paper. It solves
% the DIFFRAC optimization problem under the text constraints and ordering
% contraints.

% get size of the problem
K       = size(data_vision.annot{1},2); 
[N, ~]  = size(data_vision.Z_gt);

% =========================================================================
%                       FRANK-WOLFE OPTIMIZATION
% =========================================================================

% =========================================================================
%                        1) INITIALIZATION
% =========================================================================

fprintf('Initialization...\n');
Z = get_interior_point_nlp(N, K, data_vision.clips, data_vision.constrs,...
                            data_vision.annot);
fprintf('Done.\n');
% =========================================================================
%                        2) ITERATIONS
% =========================================================================

fprintf('Launching optimization...\n');
RES_VID = frank_wolfe_optimization_stage2(data_vision.X, data_vision.Z_gt,...
    data_vision.clips, data_vision.constrs.', ...
    data_vision.annot, Z, lambda, params);
fprintf('Optimization finished...\n');
% =========================================================================
%                                 RESULTS
% =========================================================================

res.RES_VID        = RES_VID;
res.params         = params;
res.lambda         = lambda;
res.clips          = data_vision.clips;
res.clipids        = data_vision.clipids;
res.K_predict      = K;

end
