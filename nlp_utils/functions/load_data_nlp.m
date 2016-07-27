function datas = load_data_nlp( opts )
% This function loads all necesarry variable for nlp from the NLP features.
pathNlpData = fullfile(opts.pathData, 'NLP', opts.task);

% load the similarity matrix of DOBJs
S 	        = dlmread(fullfile(pathNlpData,'sim_mat',[opts.task '_sim_mat.txt']));
% we keep only the first opts.maxWord words in the dictionnary
D   	    = min(size(S,1),opts.maxWord); 
S           = S(1:D,1:D) ;

% load the dictionary of DOBJs
file_dict   = fopen(fullfile(pathNlpData,'count_files',...
    [opts.task '_lem_dobj_count']),'r');
dobjList    = textscan(file_dict, '%d %s %s');
fclose(file_dict);
count_words = dobjList{1}(1:D);
dictionnary = strcat(dobjList{2}(1:D),'_',dobjList{3}(1:D));

% load the individual sequences
filesTrlst  = dir(fullfile(pathNlpData, 'simple_trlst', '*.trlst'));
Y	        = cell(numel(filesTrlst),1);  % text data matrix form
y           = cell(numel(filesTrlst),1);  % text data index form
S_s         = zeros(numel(filesTrlst),1); % size of each sequence
S_orig      = zeros(numel(filesTrlst),1); 
names       = cell(numel(filesTrlst), 1); % name of the different files
times       = cell(numel(filesTrlst), 1); % time stamp of each words
keep        = cell(numel(filesTrlst), 1); % matrix to eliminate some words

for i=1:numel(filesTrlst)	
	nameRlst           = filesTrlst(i).name;
	fRlstId            = fopen(fullfile(fullfile(pathNlpData,'simple_trlst',nameRlst)),'r');
	detRlst            = textscan(fRlstId, '%f %f %f');
    fclose(fRlstId);
    words_i            = detRlst{1}(:)+1;
    times_1            = detRlst{2}(:);
    times_2            = detRlst{3}(:);
    times_1(words_i>D) = [];
    times_2(words_i>D) = [];
    words_i(words_i>D) = [];
        
    % if opts.preporcSeq then if the same dobj is repeated several times in the
    % sequence, we only keep the last occurence (intuision that people
    % migth introduce a concept before, but the last time they talk about
    % it will be to perform the actual step).
    if opts.preprocSeq
        keep{i}               = zeros(size(words_i));
        [~,ind_rev_uniq]      = unique(words_i(end:-1:1), 'stable');
        rev_ind               = numel(words_i):-1:1;
        ind_uniq              = rev_ind(ind_rev_uniq);
        keep{i}(ind_uniq)     = 1;
    else
        keep{i}               = ones(size(words_i)); 
    end
    
    times{i}      = [times_1 times_2];
	S_s(i)        = sum(keep{i}); %number of elements in this sequence
	S_orig(i)     = numel(words_i);
    Y{i}          = zeros(S_orig(i), D);	
    y{i}          = words_i;
    
    if S_s(i)>0
        Y{i}(sub2ind([S_orig(i),D],1:S_orig(i),words_i')) = 1; % transform the list of index in a matrix fashion
    end
    names{i}           = nameRlst;
end

% fill the datas
datas.keep    = keep;
datas.y       = y;
datas.times   = times;
datas.S       = S;
datas.S_s     = S_s;
datas.S_orig  = S_orig;
datas.D       = D;
datas.Y       = Y;
datas.dict    = dictionnary;
datas.c_words = count_words;
datas.names   = names;
end

