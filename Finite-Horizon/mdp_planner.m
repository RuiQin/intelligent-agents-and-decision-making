function [V,P] = mdp_planner(T, R, discount, H, h)

% Arguments -------------------------------------------------------------
% T(SxSxA) = transition matrix 
% R(SxA) = reward matrix
% discount = discount factor
% H = time horizon
% h = terminal reward
% Evaluation -------------------------------------------------------------
% V(S,H+1)= optimal value function
%           V(:,n) = optimal value function at stage n
%           with stage in 1, ..., H
%           V(:,N+1) = value function for terminal stage 
% P(S,H)  = optimal policy
%           P(:,n) = optimal policy at stage n
%           with stage in 1, ...,H
%           P(:,N) = policy for stage H

S = size(T,1);
V = zeros(S,H+1);
V(:,H+1) = h;

for n=0:H-1
    [W,X] = mdp_bellman(T,R,discount,V(:,H-n+1));
    V(:,H-n)=W;
    P(:,H-n)=X;
end;