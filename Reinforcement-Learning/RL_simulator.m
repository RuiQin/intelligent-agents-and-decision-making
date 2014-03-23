function [reward] = RL_simulator(N, occupiedProb, R, policy)

% choose the initial state according to the following statements
% when a parking trial begins the agent is randomly placed at either B[1] or A[n] 
prob = rand();
if prob < 0.5    %A[n]
    initial_location = 1;
    prob1 = rand();
    if prob1 < occupiedProb(initial_location)
        initial_state = 3;
    else
        initial_state = 1;
    end
else             %B[1]
    initial_location = N+1;
    prob2 = rand();
    if prob2 < occupiedProb(initial_location)
        initial_state = 4*N+3;
    else
        initial_state = 4*N+1;
    end
end

%initialize the policy simulator
stop = false;  % whether to stop the trial
reward = 0;
current_state = initial_state;
current_location = initial_location;


while(~stop)
    if(policy(current_state) == 1)   % PARK = 1
        if(mod(current_state,4) == 1 || mod(current_state,4) == 3)
            current_state = current_state + 1;
            reward = reward + R(current_state);
        end
        stop = true;
    else                             % DRIVE = 2;
        if(mod(current_state,4) == 2 || mod(current_state,4) == 0)     %(O=F,P=T) or (O=T,P=T)
            stop = true;
        else
            if(current_location == 2*N)  %current location is B[n]
                current_location = 1;
                isoccupied_prob = rand();
                if(isoccupied_prob < occupiedProb(current_location)) % current location is occupied
                    current_state = 3;
                else
                    current_state = 1;
                end
            else
                current_location = current_location + 1;
                isoccupied_prob = rand();
                if(isoccupied_prob < occupiedProb(current_location)) % current location is occupied
                    current_state = 4*(current_location-1) + 3;
                else
                    current_state = 4*(current_location-1) + 1;
                end
            end
        end
        reward = reward + R(current_state);
    end
end