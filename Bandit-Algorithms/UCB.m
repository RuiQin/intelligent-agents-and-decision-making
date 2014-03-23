function [ASreg,ACreg,action] = UCB(A,T,N)
% A: arms and their parameters (r,p)
% N: number of arm pulls
% T: number of trials
% epsilon: greedy parameter

%number of arms
NumArms = length(A);

% action value: store optimal action for each pull
action = zeros(1,N);
% a very small number
delta = 0.0001;

% the simple regret for each pull
Sreg = zeros(1,N);
% the cumulative regret for each pull
Creg = zeros(1,N);
% the average simple regret for each pull
ASreg = zeros(1,N);
% the average cumulative regret for each pull
ACreg = zeros(1,N);

% maximum expected reward
MER = 0;
for i = 1 : NumArms
     MER = max(MER,A(i).r*A(i).p);
end

%record how much time does this algorithm cost
cpu_time = cputime;

for t = 1 : T
    % average reward for each arm
    AR = zeros(1,NumArms);
    % number of pulls for each arm
    NP = zeros(1,NumArms);
    for i =  1 : N
        for j = 1 : NumArms
            if NP(j) ~= 0
                E(j) = AR(j) + sqrt(2*log(i)/NP(j)); %exploration value for each arm
            else
                E(j) = AR(j) + sqrt(2*log(i)/delta);
            end
        end
        [Sr Sa] = max(AR); % best action chosen by the average reward
        
        [r a] = max(E);  % best action after explotation
        NP(a) = NP(a) + 1;
        AR(a) = (AR(a)*(NP(a)-1) + pull(A,a))/NP(a);
        action(i) = Sa;
        pullReward = pull(A,a);
     
        Sreg(i) = MER - A(Sa).r*A(Sa).p;
         if i == 1
            Creg(i) = MER - pullReward;
        else
            Creg(i) = Creg(i-1) + MER - pullReward;
        end          
        %re-calculate the average regret
        ASreg(i) = (ASreg(i)*(t-1)+Sreg(i))/t;
        ACreg(i) = (ACreg(i)*(t-1)+Creg(i))/t ; 
    end
end

cpu_time = cputime - cpu_time;
disp(['Cost cpu time: ' num2str(cpu_time)]);

%given the index of an arm, return its reward
function r = pull(A,a)
r = SBRD(A(a).r,A(a).p);