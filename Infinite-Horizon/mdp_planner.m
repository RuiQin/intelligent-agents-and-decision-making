function [V,P,D] = mdp_planner(T, R, discount, epsilon)

% Arguments -------------------------------------------------------------
% T(SxSxA) = transition matrix 
% R(SxA) = reward matrix
% discount = discount factor
% epsilon  
% H = time horizon
% V0(S) = starting value function (default : zeros(S,1))
% Evaluation -------------------------------------------------------------
% V(S,H+1)= optimal value function
%           V(:,n) = optimal value function at stage n
%           with stage in 1, ..., H
%           V(:,N+1) = value function for terminal stage 
% P(S,H)  = optimal policy
%           P(:,n) = optimal policy at stage n
%           with stage in 1, ...,H
%           P(:,N) = policy for stage H
% D(H,1) = bellman error

S = size(T,1);
VO = zeros(S,1);
V = VO;

% if discount ~= 1
%     thresh = epsilon * (1-discount)/discount;
% else
%     thresh = epsilon;
% end;

finished = false;
iter = 0;

while ~finished
    iter = iter + 1;
%    disp(['Iteration:',num2str(iter)]) 
    Vprev = V;
    [V, P] = mdp_bellman(T,R,discount,V);
    diff = max(abs(V-Vprev));
    D(:,iter) = diff;
    if diff < epsilon
        finished = true;
        disp(['Iteration:',num2str(iter)]); 
    end;
end;
    