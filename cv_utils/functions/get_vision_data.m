function data_vision = get_vision_data( params_vision, data_nlp )
% data_vision will get the necessary variables from vision along with the
% induced constraints from nlp in a single structure.

datas          = load_data_vision(params_vision);
X_temp         = datas.X;
Z_gt_temp      = datas.Z_gt;
clips_temp     = datas.clips;
clipids_temp   = datas.clipids;

video_with_srt = data_nlp.names;

% define the new variables 
corr_clips  = [0; cumsum(clips_temp)];
X           = [];
Z_gt        = [];
constrs     = cell(1, numel(video_with_srt));
annot       = cell(1, numel(video_with_srt));
clipids     = cell(1, numel(video_with_srt));
clips       = [];

K           = size(data_nlp.R{1},2); 

for f=1:numel(video_with_srt)
   [~, name_clip] = fileparts(video_with_srt{f});   
   ind_clip  = find(ismember(clipids_temp, name_clip));
   constrs{f}                = data_nlp.A{f}.'*data_nlp.R{f}; %precompute to win time
   constrs{f}(constrs{f}>=1) = 1;
   %  update variable
   X          = [X; X_temp(corr_clips(ind_clip)+1:corr_clips(ind_clip+1),:)];
   Z_gt       = [Z_gt; Z_gt_temp(corr_clips(ind_clip)+1:corr_clips(ind_clip+1),:)];
   annot{f}   = 1:K; % same for all clips (because of the nlp assumed structure)
   clips      = [clips; clips_temp(ind_clip)];
   clipids{f} = name_clip;   
end

data_vision.clips   = clips;
data_vision.constrs = constrs;
data_vision.clipids = clipids;
data_vision.annot   = annot;
data_vision.X       = X;
data_vision.Z_gt    = Z_gt;

end

