function datas =  load_data_vision(params_vision)

datapath = fullfile(params_vision.pathData, 'features', params_vision.feature);

load(datapath);

Y_gt = Y;
X    = cell2mat(X);
X    = double(X);
% getting the sequence annotations
annot   = {hw3.actid};
clipids = {hw3.clipid};

y     = cell2mat(Y);
clips = cellfun(@(x) size(x, 1), Y);

% remove the background action 
Y_gt         = cell2mat(Y_gt);
Y_gt(:, end) = [];

datas.X       = X;
datas.y       = y;
datas.Z_gt    = Y_gt;
datas.clips   = clips;
datas.annot   = annot;
datas.clipids = clipids;

end