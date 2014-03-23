function drawCurve(r1,r2,r3, pull, title_name, xTitle, No)
% regret: regret value for each pull
% pull: total number of pulls
% bandit: number of bandit I use: 1,2,3
% Reg: cumulative regret, simple regret
% No: figure No.

figure(No);
pulls = 1:(pull/length(r1)):pull;
plot(pulls,r1,'r')
hold on
plot(pulls,r2,'b')
hold on
plot(pulls,r3,'g')
xlabel(xTitle)
ylabel('Average reward')
if(No == 1)
    legend('Policy 1','Policy 2','Policy 3')
elseif(No ==2)
    legend('alpha = 0.1','alpha = 0.5','alpha = 0.9')
else
    legend('Policy 2','Policy 3','Reinforcement Learning')
end
title(title_name)

