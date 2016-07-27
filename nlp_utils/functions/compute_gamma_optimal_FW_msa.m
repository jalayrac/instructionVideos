function gama_opt = compute_gamma_optimal_FW_msa(z, a, B)

gama_n = trace(z*B*((z-a).'));
gama_d = trace((z-a)*B*((z-a).'));

gama   = gama_n / gama_d;
gama_opt = max(min(gama,1), 0);

if gama_d<0
    gama_opt=1;
end

end
