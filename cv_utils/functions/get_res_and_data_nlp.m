function [ res_nlp, data_nlp ] = get_res_and_data_nlp( opts, params_nlp, delta_b, delta_a )
% GET_RES_AND_DATA_NLP: load the results and the NLP data

% load the results
res_nlp  = load(fullfile(params_nlp.path_res_init, ...
    sprintf(params_nlp.format_res, opts.task)));
res_nlp  = res_nlp.RES;

% get back the option of the results
opts_nlp = res_nlp.opts;
data_nlp = load_data_nlp_for_cv(opts, opts_nlp, delta_b, delta_a);

end

