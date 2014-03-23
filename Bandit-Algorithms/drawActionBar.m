function drawActionBar(action, bandit, algorithm, No)
% action: best arm choosen in each round, it's a N-dimensional vector
% bandit: number of bandit I use: 1,2,3
% algorithm: algorithm I use: uniform, greedy, UCB
% No: figure No.

figure(No);
A = unique(action)  % numbers appear in action at least once
n = histc(action,A)    % how many times it appears
BAR(A,n);
xlabel('arm index');
ylabel('times as the best arm');
title(strcat(bandit,algorithm));