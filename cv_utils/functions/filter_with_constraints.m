function C_aft = filter_with_constraints( C, cstr )
%FILTER_WITH_CONSTRAINTS Summary of this function goes here
%   Detailed explanation goes here

INF = 10000;

nEvents = size(cstr,2);
T       = size(cstr,1);

C_aft = C;

for e=1:nEvents
   i_s = find(cstr(:,e),1,'first');
   i_e = find(cstr(:,e),1,'last');

   if i_e+1<T
        C_aft(1:e, min(i_e+1,T):T) = INF;
   end
   if i_s-1>=1
    	C_aft(e:end, 1:max(i_s-1,1)) = INF;
   end
end


end

