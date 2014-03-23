function planner_demo()
%run two MDPs

disp('--------------------------------------------------------')
disp('MDP Forest:')
disp('--------------------------------------------------------')
%mdp_forest(S, H, p)
%S: number of states
%H: a time horizon
%p: probability of burnt
mdp_forest(20, 5, 0.1)


disp('--------------------------------------------------------')
disp('MDP Trick or Treat:')
disp('--------------------------------------------------------')
%mdp_trick_or_treat(S, H, p)
%S: number of states
%H: a time horizon
%p: probability of asking again
mdp_trick_or_treat(20, 5, 0.4)