function A_up = update_A_delta( A, delta_b, delta_a )
%UPDATE_A_DELTA: given the parameters delta, update the A matrix (alignment
%between the frames and the captions).

T = size(A,2);

if -delta_b<=delta_a
    dl     = min(delta_b,T-1);
    dr     = min(delta_a,T-1);
    M_all  = spdiags(ones(T,dl+dr+1),-dl:dr,T,T);
    
    A_up   = A*M_all>=1;
else
   fprintf('Invalid delta configuration. A will remain the same \n');
   A_up = A;
end

end

