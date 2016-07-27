function display_qual_res( datas, res)
%PRECISION_RECALL_FOR_K Summary of this function goes here
%   Detailed explanation goes here
fG = res.cG>0;
nEventsPerLine = sum(fG);

nLeftEvent = zeros(20,1);
max_filter = 20;

for n_filter=1:max_filter
    nLeftEvent(n_filter) = sum(nEventsPerLine>=n_filter);
end

% Getting the results for different K (here from 1 to 15)
Ks = 1:15;

for i=1:numel(Ks)
    k   = Ks(i);

    fprintf('=============\n');
    fprintf('     K=%d   \n', k);
    fprintf('=============\n');

    
    n_k = find(nLeftEvent<=k,1,'first');
    if isempty(n_k); continue; end

    ind_kept    = nEventsPerLine >= n_k;
    res_matrix  = res.cG(:,ind_kept);
    seq_predict = zeros(size(res_matrix,2),1);

    for e=1:size(res_matrix,2)
        n_elements = sum(res_matrix(:,e)>0);      
        ind_words  = unique(res_matrix(res_matrix(:,e)>0,e));
        fprintf('%d)',e);
        for w=ind_words'
            fprintf('%s, ',strrep(datas.dict{w},'_',' '));
        end
        if seq_predict(e) ~=0
            fprintf('(%d aligned) \n',n_elements); 
        else
            fprintf('(%d aligned) \n',n_elements); 
        end
    end    
end


end

