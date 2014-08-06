function [ game_over,pred_r ] = pred_game_stat( world, agent, ghosts,agent_type  )
game_over=0;pred_r=0;
if world.dot_map(agent.pos(1),agent.pos(2))~=0
    agent.eat_dot=agent.eat_dot+1;
end
world.dot_map(agent.pos(1),agent.pos(2))=0;
      
for ng=1:ghosts.num
    if agent.pos(1)==ghosts.pos(ng,1)&&agent.pos(2)==ghosts.pos(ng,2)
        if agent.god_mode
            ghosts.eaten(ng)=1;
        else
            game_over=-1;
            break;
        end
    end
end
if game_over==-1
    pred_r=-50;
else
  
    if sum(sum(world.dot_map))==0
        game_over=1;
    end

    if game_over ==1

        if sum(sum(world.dot_map))==1
            pred_r=30+pred_r;
        end
    end
end

if agent_type~=1
    pred_r=(pred_r+50)/(73+50);
else
    pred_r=pred_r/100;
end

