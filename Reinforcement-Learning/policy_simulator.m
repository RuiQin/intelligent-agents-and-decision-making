function [reward] = policy_simulator(N, occupiedProb, R, policyNo, park_prob)

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

% the probability of willing to park at each spot - for policy 3
prob_willingA = [0.5:(1-0.5)/(N - 2):1 0.3];
prob_willingB = [0.3 1:(0.5 - 1) /(N - 2):0.5];
prob_willing = [prob_willingA prob_willingB];

%initialize the policy simulator
stop = false;  % whether to stop the trial
reward = 0;
current_state = initial_state;
current_location = initial_location;

if(policyNo == 1)
    while(~stop)
        if rand() < park_prob  %select PARK action with probability p
            current_state = current_state + 1;
            reward = reward + R(current_state);
            stop = true;
        else  %select DRIVE with probability 1-p
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
            reward = reward + R(current_state);            
        end
    end
    
elseif(policyNo == 2)
    while(~stop)
       if(mod(current_state,4) == 3) % O = true, take DRIVE action
           if(current_location == 2*N)
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
           reward = reward + R(current_state);
       else  % O = false, PARK with probability p, DRIVE with probability 1 - p
           if rand() < park_prob  %PARK
               current_state = current_state + 1;
               reward = reward + R(current_state);
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
               reward = reward + R(current_state);       
           end
       end
    end
else  % policy 3, similar to policy 2, but park with a flexible probability
    while(~stop)
       if(mod(current_state,4) == 3) % O = true, take DRIVE action
           if(current_location == 2*N)
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
           reward = reward + R(current_state);
       else  % O = false, PARK with probability p, DRIVE with probability 1 - p
           if rand() < prob_willing(current_location)  %PARK
               current_state = current_state + 1;
               reward = reward + R(current_state);
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
               reward = reward + R(current_state);       
           end
       end
    end
end