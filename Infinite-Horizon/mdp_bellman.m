
function [V,P] = mdp_bellman(T, R, discount, Vprev)

% mdp_bellman Applies the Bellman operator on the value function Vprev
%                      Returns a new value function and a Vprev-improving policy
% Arguments ---------------------------------------------------------------
% Let S = number of states, A = number of actions
%   T(SxSxA) = transition matrix
%   R(SxA) = reward matrix
%   discount = discount rate, in ]0, 1]
%   Vprev(S) = value function
% Evaluation --------------------------------------------------------------
%   V(S)   = new value function
%   P(S)  = Vprev-improving policy

A = size(T,3);
s = size(R,2);
for a = 1:A
    if s ~= 1
        Q(:,a) = R(:,a) + discount*T(:,:,a)*Vprev;
    else
        Q(:,a) = R + discount*T(:,:,a)*Vprev;
    end
end
[V,P] = max(Q,[],2);