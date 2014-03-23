function mdp_parking_demo()

%define total number of spots
N = 10; total = N*2*2*2;

%define actions
A = 2;

%discount factor and error threshold
discount = 0.9; epsilon = 0.01;

%the probability that a spot is occupoed
disp('===================Weekday Parking ========================');
occupiedProA = [0.1:(0.5-0.1)/(N-2):0.5 0.2];
occupiedProB = [0.2 0.5:(0.1 - 0.5) /(N - 2):0.1];
occupiedProb = [occupiedProA occupiedProB];

% %disp('===================Weekend Parking ========================');
% occupiedProA = [0.5:0.05:0.9 0.4]; 
% occupiedProB = [0.4 0.9:(-0.05):0.5];
% occupiedProb = [occupiedProA occupiedProB];

%initialize reward matrix
R = zeros(total + 1, 1);

%define transition matrix, reward matrix, states
[T R] = mdp_parking(N, occupiedProb, discount, R, A);

%calculate the optimal value, policy, bellman error
[V,P,D] = mdp_planner(T, R, discount, epsilon)

s = size(P, 1) - 1; 
Q1 = zeros(round(s/4)+1,4);
Q2 = zeros(round(s/4)+1,4);
for i = 1 : s
     if(mod(i,4) == 1)
         Q1(ceil(i/4),1) = P(i);
         Q2(ceil(i/4),1) = V(i);
     elseif(mod(i,4) == 2)
         Q1(ceil(i/4),2) = P(i);
         Q2(ceil(i/4),2) = V(i);
     elseif(mod(i,4) == 3)
         Q1(ceil(i/4),3) = P(i);
         Q2(ceil(i/4),3) = V(i);
     else
         Q1(ceil(i/4),4) = P(i);
         Q2(ceil(i/4),4) = V(i);
     end
end
Q(:,:,1) = Q2
Q(:,:,2) = Q1
