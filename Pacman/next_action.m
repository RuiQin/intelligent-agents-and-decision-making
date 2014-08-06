function [ valid_actions] = next_action( world,pos,is_pac )
%NEXT_ACTION Summary of this function goes here
%   Detailed explanation goes here

%==valid_actions: u/d/l/r
cw=world.grid;
valid_actions=zeros(4,1);

nposes=[pos(1)-1,pos(2);pos(1)+1,pos(2);pos(1),pos(2)-1;pos(1),pos(2)+1];
forb=ismember(nposes,world.pac_forbidden,'rows');
if cw(pos(1)-1,pos(2))==1&&~(is_pac&&forb(1)) 
    valid_actions(1)=1;
end
if cw(pos(1)+1,pos(2))==1&&~(is_pac&&forb(2)) 
    valid_actions(2)=1;
end
if cw(pos(1),pos(2)-1)==1&&~(is_pac&&forb(3)) 
    valid_actions(3)=1;
end
if cw(pos(1),pos(2)+1)==1&&~(is_pac&&forb(4)) 
    valid_actions(4)=1;
end

% for ng=1:world.ghost_map
%     if agent.pos(1)==world.ghost_map(ng,1)&&agent.pos(2)==world.ghost_map(ng,2)
%         valid_actions=[];
%         break;
%     end
% end

end

