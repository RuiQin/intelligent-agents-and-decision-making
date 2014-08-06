function [ r,agent,ghosts,r_real] = eval_reward( world,agent,ghosts,agent_type )
    
if world.dot_map(agent.pos(1),agent.pos(2))~=0
    r=3;
    if sum(sum(world.dot_map))==1
        r=30+r;
    end
else
    r=-1;
end

r1=0;
for ng=1:ghosts.num
    if agent.pos(1)==ghosts.pos(ng,1)&&agent.pos(2)==ghosts.pos(ng,2)
        b=1;
        if agent.god_mode
            r1=r1+20;
        else
            r=-50;
            break;
        end
    end
end
r=r+r1;
r_real=r;
if agent_type~=1
%     r=r/500;
    r=(r+50)/(73+50);

else
    r=r/100;
end

end

