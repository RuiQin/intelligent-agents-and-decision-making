function bandit3()

%NumArms: number of arms
% N: number of arm pulls
NumArms = 10;
N = 200;
T = 1000;
epsilon = 0.5;

%initialize the bandit1, i'th arm has(i/20,0.1)
A = struct('r',{},'p',{});
for i = 1 : NumArms
    A(i).r = i/NumArms;
    A(i).p = i/NumArms;
end

disp('=====================Bandit 3=========================')

disp('-----------------incremental uniform-------------')
[ASreg1,ACreg1,action] = incremental_uniform(A,T,N);
drawActionBar(action, 'bandit3: ', 'Incremental Uniform',1)

disp('-----------------------UCB-----------------------')
[ASreg2,ACreg2,action] = UCB(A,T,N);
drawActionBar(action, 'bandit3: ', 'UCB',2)

disp('---------------------greedy----------------------')
[ASreg3,ACreg3,action] = greedy(A,T,N,epsilon);
drawActionBar(action, 'bandit3: ', 'Greedy',3)

drawCurve(ASreg1,ASreg2,ASreg3,N,'bandit3: ','Simple Regret',4)
drawCurve(ACreg1,ACreg2,ACreg3,N,'bandit3: ','Cumulative Regret',5)