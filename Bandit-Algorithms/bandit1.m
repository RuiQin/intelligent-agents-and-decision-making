function bandit1()

%NumArms: number of arms
% N: number of arm pulls
% T: number of trials
NumArms = 10;
N = 2000;
T = 1000;
epsilon = 0.5;

%initialize the bandit1, the first nine arms have (0.05,1), the last arm
%has (1,0.1)
A = struct('r',{},'p',{});
for i = 1 : NumArms - 1
    A(i).r = 0.05;
    A(i).p = 1;
end
A(NumArms).r = 1;
A(NumArms).p = 0.1;

disp('=====================Bandit 1=========================')

disp('-----------------incremental uniform-------------')
[ASreg1,ACreg1,action] = incremental_uniform(A,T,N);
drawActionBar(action, 'bandit1: ', 'Incremental Uniform',1)

disp('-----------------------UCB-----------------------')
[ASreg2,ACreg2,action] = UCB(A,T,N);
drawActionBar(action, 'bandit1: ', 'UCB',2)

disp('---------------------greedy----------------------')
[ASreg3,ACreg3,action] = greedy(A,T,N,epsilon);
drawActionBar(action, 'bandit1: ', 'Greedy',3)

drawCurve(ASreg1,ASreg2,ASreg3,N,'bandit1: ','Simple Regret',4)
drawCurve(ACreg1,ACreg2,ACreg3,N,'bandit1: ','Cumulative Regret',5)
