function [ASreg,ACreg,action] = greedy(A,T,N,epsilon)
% A: arms and their parameters (r,p)
% N: number of arm pulls
% T: number of trials
% epsilon: greedy parameter

%number of arms
NumArms = length(A);
% action value: store optimal action for each pull
action = zeros(1,N);

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
    % average reward for each arm in one trial
    AR = zeros(1,NumArms);
    % number of pulls for each arm in one trial
    NP = zeros(1,NumArms);
    
    for i = 1 : N
        [r a] = max(AR);  % choose the best average reward
        action(i) = a;
        pullReward = 0;
        if rand < epsilon      % pull the best arm           
            NP(a) = NP(a) + 1;
            pullReward = pull(A,a);
            AR(a) = (r*(NP(a)-1) + pullReward)/NP(a);
        else                   % pull one of the other arms at random
            randomPull = unidrnd(NumArms); 
            while randomPull == a
                randomPull = unidrnd(NumArms);
            end
            NP(randomPull) = NP(randomPull) + 1;
            pullReward = pull(A,randomPull);
            AR(randomPull) =  (AR(randomPull)*(NP(randomPull)-1) + pullReward)/NP(randomPull);
        end
        Sreg(i) = MER - A(a).r*A(a).p;
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