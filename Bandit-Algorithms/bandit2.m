function bandit2()

%NumArms: number of arms
% N: number of arm pulls
NumArms = 20;
N = 2000;
T = 1000;
epsilon = 0.5;

%initialize the bandit1, i'th arm has(i/20,0.1)
A = struct('r',{},'p',{});
for i = 1 : NumArms
    A(i).r = i/20;
    A(i).p = 0.1;
end

disp('=====================Bandit 2=========================')

disp('-----------------incremental uniform-------------')
[ASreg1,ACreg1,action] = incremental_uniform(A,T,N);
drawActionBar(action, 'bandit2: ', 'Incremental Uniform',1)

disp('-----------------------UCB-----------------------')
[ASreg2,ACreg2,action] = UCB(A,T,N);
drawActionBar(action, 'bandit2: ', 'UCB',2)

disp('---------------------greedy----------------------')
[ASreg3,ACreg3,action] = greedy(A,T,N,epsilon);
drawActionBar(action, 'bandit2: ', 'Greedy',3)

drawCurve(ASreg1,ASreg2,ASreg3,N,'bandit2: ','Simple Regret',4)
drawCurve(ACreg1,ACreg2,ACreg3,N,'bandit2: ','Cumulative Regret',5)