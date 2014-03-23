function mdp_trick_or_treat(S, H, p)

% Definition of Transition matrix T(:,:,1) associated to Get (action 1) and
% T(:,:,2) associated to action Not Get and go away (action 2)
% T(:,:,3) associated to action Not Get and trick people (action 2)
%             | p 1-p 0.......0  |                  | 0 1..........0 |
%             | .  p 1-p 0....0  |                  | . 0          . |
%  T(:,:,1) = | .  .  p  .       |  and T(:,:,2/3)= | . .          . |
%             | .  .        .    |                  | . .          . |
%             | .  .         1-p |                  | . .          1 |
%             | 1-p  0  0....0 p |                  | 1 0..........0 |
%             

%define T(:,:,1)
T1 = zeros(S,S)+p*diag(ones(S,1),0)+(1-p)*diag(ones(S-1,1),1);
T1(S,1) = 1-p;

%define T(:,:,2)
T2 = zeros(S,S)+diag(ones(S-1,1),1);
T2(S,1) = 1;

T3 = zeros(S,S)+diag(ones(S-1,1),1);
T3(S,1) = 1;

%define Transition matrix T
T = cat(3,T1,T2,T3);

% Definition of Reward matrix R1 associated to action Wait and 
% R2 associated to action Cut
%           | 2  |                   | -1 |                | 0  |
%           | .  |                   | 1  |                | 1  |
%  R(:,1) = | -1 |  and     R(:,2) = | .  |     R(:,3)  =  | .  |
%           | .  |                   | .  |                | .  |
%           | 2  |                   | -1 |                | 0  |          
%           | 2  |                   | 1  |                | 1  |

%define Reward matrix R
% R1
R1=2*ones(S,1);
for n = 1:3:round(S/4)
    R1(n) = -1;
end

for n = round(3*S/4):S
    R1(n) = 2.5;
end
%R2
R2=(-1)*ones(S,1);
for n = 1:2:round(S/3)
    R2(n) = 1;
end
%R3
R3=zeros(S,1);
for n = 2:3:round(S/4)
    R2(n) = 1;
end

R=[R1 R2 R3];

h = zeros(S,1);

[V, P] = mdp_planner(T, R, 1, H, h)