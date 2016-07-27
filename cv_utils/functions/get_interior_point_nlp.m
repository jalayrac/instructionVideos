function z = get_interior_point_nlp(N, K, clips, constrs, annot)
%This function aims at finding an interior point to start the FW
%optimization by looking at the constraints coming from NLP.

% for the initialization do the convex combination of n_trials points
ntrials = 10;
z = zeros(N, K);
for i = 1:ntrials
    zTA = rand(K, N);
    l = mat2cell(zTA, K, clips);
    corner = linear_oracle_algnAndConstraints(l, K, constrs, annot);
    corner = cell2mat(corner);
    z = z + corner;
end
z = z / ntrials;

end