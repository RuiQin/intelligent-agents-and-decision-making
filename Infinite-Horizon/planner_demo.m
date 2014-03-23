function planner_demo()
%run two MDPs

disp('--------------------------------------------------------')
disp('MDP Forest:')
disp('--------------------------------------------------------')
%mdp_forest(S, discount, epsilon, p)
%S: number of states
%discount: discount factor
%epsilon : error threshold
%p: probability of burnt
mdp_forest(10, 0.7, 0.01, 0.1)
