function mdp_parking_demo()

%define total number of spots
N = 10;

%define actions PARK = 1; DRIVE = 2; When P=T the action will become EXIT
A = 2;

%define the reward at specific spot
RA = [10:(90 - 10)/ (N - 2):90 -20];
RB = [-20 90:(10 - 90) / (N - 2):10];
parkingRewards = [RA RB];

disp('===================Weekday Parking ========================');
occupiedProA = [0.1:(0.5-0.1)/(N-2):0.5 0.6];
occupiedProB = [0.6 0.5:(0.1 - 0.5) /(N - 2):0.1];
occupiedProb = [occupiedProA occupiedProB]

% disp('===================Weekend Parking ========================');
% occupiedProA = [0.5:0.05:0.9 0.95]; 
% occupiedProB = [0.95 0.9:(-0.05):0.5];
% occupiedProb = [occupiedProA occupiedProB]

%define transition matrix T and reward R
[T R] = mdp_parking(N, occupiedProb, parkingRewards, A);

disp(' ------------------------- policy simulator----------------------------');
%probability of PARK
park_prob = 0.5;
% number of trials
trials = 1000;

for i = 1 : trials
    if(i == 1)
        % policy 1
        R1_avg(i) = policy_simulator(N, occupiedProb, R, 1, park_prob);
        % policy 2
        R2_avg(i) = policy_simulator(N, occupiedProb, R, 2, park_prob);
        % policy 3
        R3_avg(i) = policy_simulator(N, occupiedProb, R, 3, park_prob);
    else
        R1_avg(i) = (R1_avg(i-1)*(i-1) + policy_simulator(N, occupiedProb, R, 1, park_prob))/i;
        R2_avg(i) = (R2_avg(i-1)*(i-1) + policy_simulator(N, occupiedProb, R, 2, park_prob))/i;
        R3_avg(i) = (R3_avg(i-1)*(i-1) + policy_simulator(N, occupiedProb, R, 3, park_prob))/i;
    end
end

disp(['The average reward for each policy at round ' num2str(trials) ': ' num2str(R1_avg(trials)) ' ' num2str(R2_avg(trials)) ' ' num2str(R3_avg(trials))]);
drawCurve(R1_avg,R2_avg,R3_avg,trials,'Policy simulator ','Number of trials',1);

disp(' ----------------------------Q-learning-------------------------------');
iteration = 20000;
alpha1 = 0.1;
alpha2 = 0.5;
alpha3 = 0.9;

[RL_policy1 reward1] = mdp_Q_learning(T, R, alpha1, iteration, occupiedProb);
[RL_policy2 reward2] = mdp_Q_learning(T, R, alpha2, iteration, occupiedProb);
[RL_policy3 reward3] = mdp_Q_learning(T, R, alpha3, iteration, occupiedProb);

disp(['The average reward for each RL at round ' num2str(length(reward1)) ': ' num2str(reward1(length(reward1))) ' ' num2str(reward2(length(reward2))) ' ' num2str(reward3(length(reward3)))]);
drawCurve(reward1,reward2,reward3,length(reward1),'Reinforcement learning performance measure ','Number of epochs',2);

disp('-------------Compare policy 2,3 and Reinforcement learning ------------');
for i = 1 : trials
    if(i == 1)
        % policy 2
        R2_avg(i) = policy_simulator(N, occupiedProb, R, 2, park_prob);
        % policy 3
        R3_avg(i) = policy_simulator(N, occupiedProb, R, 3, park_prob);
        % Q-learning
        RL_avg(i) = RL_simulator(N, occupiedProb, R, RL_policy1);
    else
        R2_avg(i) = (R2_avg(i-1)*(i-1) + policy_simulator(N, occupiedProb, R, 2, park_prob))/i;
        R3_avg(i) = (R3_avg(i-1)*(i-1) + policy_simulator(N, occupiedProb, R, 3, park_prob))/i;
        RL_avg(i) = (RL_avg(i-1)*(i-1) + RL_simulator(N, occupiedProb, R, RL_policy1))/i;
    end
end

disp(['The average reward for each policy at round ' num2str(trials) ': ' num2str(R2_avg(trials)) ' ' num2str(R3_avg(trials)) ' ' num2str(RL_avg(trials))]);
drawCurve(R2_avg,R3_avg,RL_avg,trials,'Compare policy 2, 3 and Reinforcement learning results ','Number of trials',3);

