function datas = load_data_nlp_for_cv( opts, opts_nlp, delta_l, delta_r )
% This function loads all necesarry variable for nlp, this function
% differs from load_data_nlp in the nlp utils folder because it needs to
% give the matrix A defined in the paper.

params.timeunit = 10; % used to get the A matrix

pathVidInfo = fullfile(opts.pathData, 'VISION', opts.task, 'videos_info');
pathNlpData = fullfile(opts.pathData, 'NLP', opts.task);

% load the similarity matrix of DOBJs
S 	        = dlmread(fullfile(pathNlpData,'sim_mat',[opts_nlp.task '_sim_mat.txt']));
D   	    = min(size(S,1),opts_nlp.maxWord); % size of the dictionnary
S           = S(1:D,1:D) ;

% dictionary of words
file_dict   = fopen(fullfile(pathNlpData,'count_files',...
    [opts_nlp.task '_lem_dobj_count']),'r');
dobjList    = textscan(file_dict, '%d %s %s');
fclose(file_dict);

count_words = dobjList{1}(1:D);
dictionnary = strcat(dobjList{2}(1:D),'_',dobjList{3}(1:D));

% individual sequences
filesTrlst  = dir(fullfile(pathNlpData, 'simple_trlst', '*.trlst'));
Y	        = cell(numel(filesTrlst),1);  % text data matrix form
y           = cell(numel(filesTrlst),1);  % text data index form
S_s         = zeros(numel(filesTrlst),1); % size of each sequence
S_orig      = zeros(numel(filesTrlst),1);
names       = cell(numel(filesTrlst), 1); % name of the different files
times       = cell(numel(filesTrlst), 1);
keep        = cell(numel(filesTrlst), 1);
A           = cell(numel(filesTrlst), 1); % A matrix in the paper

for i=1:numel(filesTrlst)	
	nameRlst           = filesTrlst(i).name;
	fRlstId            = fopen(fullfile(fullfile(pathNlpData,'simple_trlst',nameRlst)),'r');
    info_vid           = load(fullfile(pathVidInfo,[nameRlst(1:end-5) 'mat']));
	detRlst            = textscan(fRlstId, '%f %f %f');
    fclose(fRlstId);
    words_i            = detRlst{1}(:)+1;
    times_1            = detRlst{2}(:);
    times_2            = detRlst{3}(:);
    times_1(words_i>D) = [];
    times_2(words_i>D) = [];
    words_i(words_i>D) = [];
    
    
    % prepare the A matrix 
    T    = ceil(info_vid.nimgs/params.timeunit);
    A{i} = zeros(numel(words_i), T);
    for dobj=1:numel(words_i)
       r_f1 = round(times_1(dobj)*info_vid.fps/params.timeunit);
       r_f2 = round(times_2(dobj)*info_vid.fps/params.timeunit);
       if r_f1 < 1
           r_f1 = 1;
       end
       
       if r_f2<1
           r_f2 = 1;
       end
       
       if r_f1>T
           r_f1 = T;
       end
          
       if r_f2>T
           r_f2 = T;
       end       
       A{i}(dobj,r_f1:r_f2) = 1;       
    end

    A{i} = update_A_delta(A{i}, delta_l, delta_r);

   
    % if opts.preporcSeq then if the same dobj is repeated several times in the
    % sequence, we only keep the last occurence (intuision that people
    % migth introduce a concept before, but the last time they talk about
    % it will be to perform the actual step).
    if opts_nlp.preprocSeq
        keep{i}               = zeros(size(words_i));
        [~,ind_rev_uniq]      = unique(words_i(end:-1:1), 'stable');
        rev_ind               = numel(words_i):-1:1;
        ind_uniq              = rev_ind(ind_rev_uniq);
        keep{i}(ind_uniq)     = 1;
    else
        keep{i}               = ones(size(words_i)); 
    end
    
    times{i}           = [times_1 times_2];
	S_s(i)             = sum(keep{i}); % number of elements in this sequence
	S_orig(i)          = numel(words_i);
    Y{i}               = zeros(S_orig(i), D);	
    y{i}               = words_i;
    if S_s(i)>0
        Y{i}(sub2ind([S_orig(i),D],1:S_orig(i),words_i')) = 1; % transform the list of index in a matrix fashion
    end
    names{i}           = nameRlst;
end

% fill the datas
datas.keep       = keep;
datas.y          = y;
datas.times      = times;
datas.S          = S;
datas.S_s        = S_s;
datas.S_orig     = S_orig;
datas.D          = D;
datas.Y          = Y;
datas.dict       = dictionnary;
datas.c_words    = count_words;
datas.names      = names;
datas.A          = A;
end

