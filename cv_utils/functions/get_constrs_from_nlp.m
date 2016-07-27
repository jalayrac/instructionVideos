function data_nlp = get_constrs_from_nlp( opts, params_nlp, delta_b, delta_a )
%GET_CONSTRS_FROM_NLP 

% Load results and data from 1st stage Multiple Sequence Alignment
[ res, data_nlp ]  = get_res_and_data_nlp( opts, params_nlp, delta_b, delta_a);

R = cell(1,numel(data_nlp.names)); % R matrix defined in the paper 
                                   % (assignment matrix of dobj)
     
cG = res.res_align.cG;

% ========================================================================
%   SELECT THE STEP THAT ARE KEPT (TIE BREAKING desribed in the paper)
% ========================================================================

fG = cG>0;
nEventsPerLine = sum(fG);
nLeftEvent = zeros(30,1);
for n_filter=1:30
    nLeftEvent(n_filter) = sum(nEventsPerLine>=n_filter); 
end

tab_max  = 1:30;
N_FILTER = tab_max(nLeftEvent<=opts.K);
N_FILTER = N_FILTER(1); 
% find the filter that keeps at most K event (minimum number of
% dobj aligned together to be kept in the filtering)

filterGraph = (nEventsPerLine>=N_FILTER); 
% tells which column of the assignement matrix is kept after the filtering
labelGraph  = zeros(size(filterGraph));
labelGraph(filterGraph) = 1:sum(filterGraph);

K_after = max(labelGraph);
% K_after <= params.K

% get the dobj representant of each cluster
dobj_per_event = cell(1,K_after);
for e=1:K_after
    ind_graph_e       = find(labelGraph==e);
    dobj_per_event{e} = cG( cG(:,ind_graph_e)>0 , ind_graph_e);
end

for f=1:numel(data_nlp.names)
    seq_f       = cG(f,:)>0;
    % find for the sequence f which elements are assigned to an event
    keep_online = labelGraph(seq_f); 
    % this gives the label of each dobj of the sequence
    real_keep_online                      = zeros(1, numel(data_nlp.keep{f}));
    real_keep_online(data_nlp.keep{f}==1) = keep_online;
    
    R{f} = zeros(numel(real_keep_online), K_after);

    dobj_labeled = find(real_keep_online>0);
    % tells which dobj where labeled
    val_label    = real_keep_online(real_keep_online>0);
    % tells to which event they were labeled
    R{f}(sub2ind(size(R{f}), dobj_labeled, val_label)) = 1;  % fills the R matrix

    % if params_nlp.broad, we authorize to regroup dobj to the same cluster
    % , this allows to get more broader constraints, but still respects the
    % ordering constraints.
    if params_nlp.broad
       for e=1:K_after
          ind_triggered = find(R{f}(:,e)==1,1,'first');
          if isempty(ind_triggered) || ind_triggered==1
              continue
          end
          % compute distance to each cluster before ind_trigered
          for i=1:ind_triggered-1
             score = mean(data_nlp.S(data_nlp.y{f}(i), dobj_per_event{e})); 
             if score > params_nlp.broad_tresh || ismember(data_nlp.y{f}(i), dobj_per_event{e})
                 if sum(R{f}(i,:))==0
                    R{f}(i,e) = 1; 
                 end
             end                       
          end                                   
       end
    end
end       

data_nlp.R              = R;
data_nlp.dobj_per_event = dobj_per_event;
        
end

