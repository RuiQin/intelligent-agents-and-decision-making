function drawCurve(regret1,regret2,regret3, pull, bandit, Reg, No)
% regret: regret value for each pull
% pull: total number of pulls
% bandit: number of bandit I use: 1,2,3
% Reg: cumulative regret, simple regret
% No: figure No.

figure(No);
pulls = 1:(pull/length(regret1)):pull;
plot(pulls,regret1,'r')
hold on
plot(pulls,regret2,'b')
hold on
plot(pulls,regret3,'g')
xlabel('Number of pulls')
ylabel(Reg)
legend('Incremental Uniform','UCB','0.5-Greedy')
title(strcat(bandit,Reg))

