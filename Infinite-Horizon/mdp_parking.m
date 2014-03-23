function [T, R] = mdp_parking(N, occupiedProb, discount, R, A)

%define the number of action
PARK = 1; DRIVE = 2; EXIT = 3;

%define the number of states (L,O,P)
L = N * 2; O = 2; P = 2;
totalState = L*O*P;

%define the reward at specific spot
RA = [10:(90 - 10)/ (N - 2):90 -20];
RB = [-20 90:(10 - 90) / (N - 2):10];
parkingRewards = [RA RB];

%define the cost
collision = -1000; driving = -0.5;

% instantiate the state space
S = struct('L', {}, 'O', {}, 'P', {});
% 0 is false; 1 is true
Status = [0 1];

T = zeros(totalState,totalState + 1, A);  % the last state is termianl state
T(totalState + 1, totalState + 1, 1) = 1.0;
T(totalState + 1, totalState + 1, 2) = 1.0;

i = 1;
for j = 1:L
    for m = 1:length(Status)
        for n = 1:length(Status)
            S(i).L = j;
            S(i).O = Status(m);
            S(i).P = Status(n);
            i = i + 1;
        end
    end
end

%define the transition matrix
    
for i = 1:totalState
    
    curSpot = S(i).L;
    isParked = S(i).P;
    isOccupied = S(i).O;
    
    %Reward for PARK 
    if isParked == 1
        if isOccupied == 1
            R(i,1) = collision;
        else
            R(i,1) = parkingRewards(curSpot);
        end
    else
        %Reward for DRIVE
        R(i,1) = driving;
    end 
   
    
    % Table
    if isParked == 0
        
        %park
        T(i, i + 1, 1) = 1.0;
        
        % DRIVE = 2
        if curSpot == N * 2
            T(i,1,2) = 1 - occupiedProb(1);  %{L=20,O,P=F}->{L=1,O,P=F}
            T(i,3,2) = occupiedProb(1); %{L=20,O,P=F}->{L=1,O,P=F}
        else    % L = 1,2,...,19
            if isOccupied == 1
                T(i,i+4,2) = occupiedProb(curSpot+1);  %{L=i,O=T,P=F}->{L=i+1,O=T,P=F}
                T(i,i+2,2) = 1 - occupiedProb(curSpot+1); %{L=i,O=T,P=F}->{L=i+1,O=F,P=F}
            else
                T(i,i+4,2) = 1 - occupiedProb(curSpot+1);  %{L=i,O=F,P=F}->{L=i+1,O=F,P=F}
                T(i,i+6,2) = occupiedProb(curSpot+1); %{L=i,O=F,P=F}->{L=i+1,O=T,P=F}
            end
        end
        
    else
        T(i, totalState + 1, 1) = 1.0;
        T(i, totalState + 1, 2) = 1.0;
    end   
    
end

