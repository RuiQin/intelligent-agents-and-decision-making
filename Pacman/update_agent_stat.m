function [ agent] = update_agent_stat( world,agent,next_p )
%UPDATE_AGENT Summary of this function goes here
%   Detailed explanation goes here
if world.dot_map(next_p(1),next_p(2))==2
    agent.god_mode=1;
    agent.timer=agent.timer+agent.god_time;
else
    if agent.god_mode
        agent.timer=agent.timer-1;
    end
end
if agent.timer==0
    agent.god_mode=0;
end
agent.history(1,:)=[];
agent.history(end+1,:)=agent.pos;

agent.cur_pos=agent.pos;
agent.pos=next_p;

%== if meet pause once
% if ~ismember(next_p,ghosts.pos,'rows')
%     agent.pos=next_p;
% end

end

