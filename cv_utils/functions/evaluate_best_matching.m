function [jpc,jpc_all,mapping] = evaluate_best_matching(Z_PREDICT, clips, Z_ANNOT) 
% get a mapping between the prediction and the ground truth via the
% hungarian algorithm

% size of variables
[~, n_predict] = size(Z_PREDICT);
[~, n_annot]   = size(Z_ANNOT);

% get a score between prediction and annotation by dot product 
P_VS_A  = Z_PREDICT.'*Z_ANNOT ./ numel(clips);
mapping = assignmentoptimal_mex(1-P_VS_A);

% transform in cell format to loop over videos
Z_PREDICT    = mat2cell(Z_PREDICT, clips, n_predict); 
% same for annotations (ground truth)
Z_ANNOT      = mat2cell(Z_ANNOT, clips, n_annot);    
% jaccard per class and per video
jpc_all      = zeros(length(Z_ANNOT), n_annot);       

for j=1:length(Z_PREDICT)
    Z_annot   = Z_ANNOT{j}; 	 % the annotation
    Z_predict = Z_PREDICT{j};    % the prediction   
    for p=1:n_predict
       if mapping(p)>0
           jpc_all(j,mapping(p)) = Z_predict(:,p).' * Z_annot(:,mapping(p));
       end
    end  
end

jpc = mean(jpc_all);

end