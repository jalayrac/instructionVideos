function RES = get_res_msa_fw( datas, params)
% This function gives results from Multiple Sequence Alignment with Frank Wolfe for a given
% task :
% INPUT:
% - datas  : NLP data obtained from the processing of the NLP features.
% - params : parameters for the optimization (see launching script for
% details)

% launch optimization procedure 
res_align      = optimize_msa_fw(datas, params);
% get understandable results
display_qual_res(datas, res_align);

% format the results
RES.res_align  = res_align;
RES.params     = params;

end

