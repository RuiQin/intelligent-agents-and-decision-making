function mdp_forest(S, H, p)

% Definition of Transition matrix T(:,:,1) associated to action Wait (action 1) and
% T(:,:,2) associated to action Cut (action 2)
%             | p 1-p 0.......0  |                  | 1 0..........0 |
%             | .  0 1-p 0....0  |                  | . .          . |
%  T(:,:,1) = | .  .  0  .       |  and T(:,:,2) =  | . .          . |
%             | .  .        .    |                  | . .          . |
%             | .  .         1-p |                  | . .          . |
%             | p  0  0....0 1-p |                  | 1 0..........0 |
%             
% T(:,:,1) = [ 0.5 0.5;   0.8 0.2 ];
% T(:,:,2) = [ 0 1;   0.1 0.9 ];
% 
% %reward matrix
% R = [ 5 10; -1 2 ];
% 
% %terminal reward
% h = [0;0];

%define T(:,:,1)
T1 = zeros(S,S)+(1-p)*diag(ones(S-1,1),1);
T1(:,1) = p;
T1(S,S) = 1-p;

%define T(:,:,2)
T2 = zeros(S,S);
T2(:,1) = 1;

%define Transition matrix T
T = cat(3,T1,T2);

% Definition of Reward matrix R1 associated to action Wait and 
% R2 associated to action Cut
%           | 0  |                   | 0  |
%           | .  |                   | 1  |
%  R(:,1) = | .  |  and     R(:,2) = | .  |	
%           | .  |                   | .  |
%           | 0  |                   | 1  |                   
%           | r1 |                   | r2 |

%r1: reward when forest is in the oldest state and action Wait is performed
r1 = 4;
%r2: reward when forest is in the oldest state and action Cut is performed
r2 = 2;

%define Reward matrix R
R1=zeros(S,1);
R1(S)=r1;
R2=ones(S,1);
R2(1)=0;
R2(S)=r2;
R=[R1 R2];

h = zeros(S,1);

[V, P] = mdp_planner(T, R, 1, H, h)