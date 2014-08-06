function [ next_p] = next_pos( cur_p,action )
%NEXT_POS Summary of this function goes here
%   Detailed explanation goes here
next_p=cur_p;

if action==1
    next_p(1)=next_p(1)-1;
end
if action==2
    next_p(1)=next_p(1)+1;
end
if action==3
    next_p(2)=next_p(2)-1;
end
if action==4
    next_p(2)=next_p(2)+1;
end

end

