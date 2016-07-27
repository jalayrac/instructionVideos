function res = optimize_msa_fw( datas, params )
% OPTIMIZE_MSA_FW: Optimize the MSA cost using the quadratic program reformulation
% and the FW algorithm. This reformulation is given in appendix B of paper
% [1].

% Size of the concatenated variable (U in the paper)
S_T = sum(datas.S_s);
% optimization variables
U	= cell(1,numel(datas.Y)); % latent variables in cell format
for i=1:numel(datas.Y)
	U{i} = zeros(params.L,datas.S_s(i));
end
u = cell2mat(U); % concatenated variable

% initialization of the U variable (generate random constraints)
c_m = rand(size(u));
c   = mat2cell(c_m, params.L, datas.S_s);
U   = optimize_a_msa(c);

% get the data matrix (Y in the paper)
Y           = cell2mat(datas.Y);
% remove the deleted dobj (in case of preprocessing)
Y           = Y(cell2mat(datas.keep)==1,:);
u           = cell2mat(U);

% Get the cost function as a matrix (C_o in the paper)
C_o                             = datas.S; % initial similar matrix of wordnet
C_o(datas.S<params.sim_thresh)  = params.cost_dissimilar;
C_o(datas.S>=params.sim_thresh) = params.cost_similar;

% Get the B matrix which encode the similarity at the token level (see
% Appendix B of the paper).
B                               = Y*C_o*(Y.');

clear Y C_o; 

% Variables to get track of the optimization
obj       = struct('f', [], 'd', [], 'f_fw_r', [], 'f_l2_r', []);
best_fw_r = zeros(size(u));
best_a_l2 = zeros(size(u));
best_f_l2 = 1000000;
best_f_fw = 1000000;

for i = 1:params.niter    
    % ======================================================
    % GRADIENT-COMPUTATION
    % ======================================================
        
    grad      = 2*u*B/S_T;
    
    % ======================================================
    % FW-ORACLE: getting the direction for the next iterate
    % ======================================================
    
    % cutting the gradient into the different sequences for the Dynamic
    % programming
    l = mat2cell(grad, params.L, datas.S_s);
    % performing dynamic programming (linear oracle of FW)
    fw_corner = optimize_a_msa(l);
    fw_corner = cell2mat(fw_corner);
    % compute the FW duality gap
    d = trace(grad*(u-fw_corner).');

    % ===================
    %  STEP-SIZE
    % ===================
    
    % getting the optimal step size, in this non-convex case two things are
    % possible for the step size
    % - Convex quadratic in the direction: like classic case.
    % - Concave quadratic in the direction: go fully towards the corner.
    gama = compute_gamma_optimal_FW_msa(u,fw_corner,B);
    
    % ===================
    %  FW-update
    % ===================
    
    u    = (1-gama)*u + gama*fw_corner;
     
    % =====================================================================
    % ROUNDINGS: get integer solution from the relaxed iterate (we use the 
    % one of lowest objective at the end)
    % =====================================================================

    % L2 rounding
    U    = mat2cell(-u, params.L, datas.S_s);
    a_l2 = optimize_a_msa(U);
    a_l2 = cell2mat(a_l2);
    f_l2 = trace(a_l2*B*(a_l2.'))/S_T; % L2-rounding objective

    % keep the track of the lowest objective
    if f_l2 <= best_f_l2
        best_f_l2 = f_l2;
        best_a_l2    = a_l2;
    end

    % ===========
    % OBJECTIVES
    % ===========
    
    f    = trace(u*B*(u.'))/S_T; % relaxed objective
    f_fwr  = trace(fw_corner*B*(fw_corner.'))/S_T; % FW-rounding objective

    % keep the lowest objective for the frank-wolfe rounding
    if f_fwr <= best_f_fw
        best_f_fw = f_fwr;
        best_fw_r    = fw_corner;
    end
    % keeping track of the objective
    obj(i).f       = f;
    obj(i).d       = d;
    obj(i).f_fw_r  = f_fwr;

    if params.verbose
        fprintf('iteration %d out of %d : f=%2.2e, d=%2.2e, f_fwr=%2.2e \n',i,params.niter,f,d,f_fwr);
    end
end

% =====================================================================
% Transform the results in an easier form for analysis
% =====================================================================

% Analyse results for the FW rounding
A  = mat2cell(best_fw_r, params.L, datas.S_s);

% cG is a matrix of size "number of sequences" x L, and contains the index
% of the dobj which have been aligned together (a column correspond to
% aligned dobj). This matrix is direclyt interpretable and is used
% afterwards to get qualitative results.
cG = zeros(numel(datas.S_s), params.L);

for i=1:numel(datas.S_s)
    [pos_l, ~] = ind2sub(size(A{i}),find(A{i}));
    words      = datas.y{i}(datas.keep{i}==1);
    cG(i,pos_l) = words;
end

A  = mat2cell(best_a_l2, params.L, datas.S_s);
cG_l2 = zeros(numel(datas.S_s), params.L);

for i=1:numel(datas.S_s)
    [pos_l, ~] = ind2sub(size(A{i}),find(A{i}));
    words      = datas.y{i}(datas.keep{i}==1);
    cG_l2(i,pos_l) = words;
end

res.obj     = obj;
if best_f_fw < best_f_l2
    res.cG      = cG;
else
    res.cG      = cG_l2;
end
res.cG_fw_r = cG;
res.cG_l2_r = cG_l2;
res.Z_l2_r  = mat2cell(best_a_l2, params.L, datas.S_s);
res.Z_fw_r  = mat2cell(best_fw_r, params.L, datas.S_s);
res.f_fw    = best_f_fw;
res.f_l2    = best_f_l2;

end
