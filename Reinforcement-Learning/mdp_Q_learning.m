function [policy reward] = mdp_Q_learning(P, R, alpha, iteration, occupiedProb)

% Find the number of states, actions and N
S = size(P,1);
A = size(P,3);
N = (S-1)/8;        % an extra state is set to be the terminal state

% Initial state choice
initial_states = [1 3 N*4+1 N*4+3];   % A[n] or B[1] 

% Initialisations for Q-function
Q = zeros(S,A);
dQ = zeros(S,A);
reward = [];

% how many trials for one epoch performance measure
episode = 100;
% how many trials to take the average reward for one performance measure
unit = 1000;
discount = 0.5;  % beta

for n=1:iteration

    stop = false;               % When choose PARK, stop the trial
    number = randint(1,1,4) + 1;
    s = initial_states(number);
    
    while (s ~= N*8 + 1)
        % greedy policy to choose action
        prob = rand();
        if (prob < (1-(1/log(n+2))))  % choose the best action
            [nil,a] = max(Q(s,:));
        else                          % randomly choose an action
            a = randint(1,1,[1,A]);
        end;
        
        if(mod(s,4) == 2 || mod(s,4) == 0)  % P=T
            s_next = N*8 + 1;
        else
            if ( a == 1)        %PARK
                s_next = s + 1;
            else                %DRIVE
                current_location = ceil(s/4);
                if (current_location == N*2)
                    current_location = 1;
                    isoccupied_prob = rand();
                    if(isoccupied_prob < occupiedProb(current_location)) % current location is occupied
                        s_next = 3;
                    else
                        s_next = 1;
                    end
                else
                    current_location = current_location + 1;
                    isoccupied_prob = rand();
                    if(isoccupied_prob < occupiedProb(current_location)) % current location is occupied
                        s_next = 4*(current_location-1) + 3;
                    else
                        s_next = 4*(current_location-1) + 1;
                    end
                end
            end
        end
        
        r = R(s);

        % Updating the value of Q
        diff = r + discount*max(Q(s_next,:)) - Q(s,a);
        dQ = alpha*diff;
        Q(s,a) = Q(s,a) + dQ;

        % Current state is updated
        s = s_next;
    end
    
    if (mod(n,episode)==0)
        [V, policy] = max(Q,[],2);
        total_reward = 0;
        for i = 1 : unit
            total_reward = total_reward + RL_simulator(N, occupiedProb, R, policy);
        end
        avg_reward = total_reward/unit;
        
        updatNo = n/episode;
        if (updatNo == 1)
            reward(updatNo) = avg_reward;
        else
            reward(updatNo) = (reward(updatNo-1)*(updatNo - 1) + avg_reward)/updatNo;
        end
 %     reward(updatNo) = avg_reward;

    end;
end
