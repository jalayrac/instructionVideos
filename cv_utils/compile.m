src_path = fullfile('functions', 'mex');
src_files = {'assignmentoptimal_mex.c','warping_jump_mex.c'};
output_path = 'bin';

mexcmd = ['mex -O ', '-outdir ', output_path];
for i_file = 1 : length(src_files)
    eval([mexcmd,  ' ', fullfile(src_path, src_files{i_file})]);
end
