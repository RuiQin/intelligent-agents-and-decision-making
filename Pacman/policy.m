function [ agent] = policy( world,agent )

M_epi=200;%learn

p_win=zeros(3,M_epi);
p_step=zeros(3,M_epi);
p_score=zeros(3,M_epi);
p_comp=zeros(3,M_epi);

for epi=1:M_epi
    fprintf('\nsimulate episode:');
    fprintf('%d\n',epi);
    
    for p = 1:3
        [mstep(p),mscore(p),mwin(p),mcom(p)]=simulate(agent,p);
    end

    
    for p = 1 : 3
        if epi==1
            p_win(p,epi)=mwin(p);
            p_step(p,epi)=mstep(p);
            p_score(p,epi)=mscore(p);
            p_comp(p,epi)=mcom(p);
        else
            p_win(p,epi)=p_win(p,epi-1)+(mwin(p)-p_win(p,epi-1))/epi;
            p_step(p,epi)=p_step(p,epi-1)+(mstep(p)-p_step(p,epi-1))/epi;
            p_score(p,epi)=p_score(p,epi-1)+(mscore(p)-p_score(p,epi-1))/epi;
            p_comp(p,epi)=p_comp(p,epi-1)+(mcom(p)-p_comp(p,epi-1))/epi;
        end
    end
end

%--result...
X=1:M_epi;
figure(01);hold on
plot(X,p_win*100);hold on 
legend('policy 1','policy 2','policy 3');
xlabel('Allocated episode');
ylabel('Averaged Wins(%)');
hold off
figure(02);hold on
plot(X,p_step);hold on
legend('policy 1','policy 2','policy 3');
xlabel('Allocated episode')
ylabel('Averaged steps');
hold off
figure(03);hold on
plot(X,p_score);
legend('policy 1','policy 2','policy 3');
xlabel('Allocated episode');
ylabel('Averaged score');
hold off
figure(04);hold on
plot(X,p_comp*100);
legend('policy 1','policy 2','policy 3');
xlabel('Allocated episode');
ylabel('Averaged level completion(%)');
hold off
save('q-learning-rst','p_win','p_step','p_score','p_comp');
p_win
end

function [iter,score,win,complete]=simulate(agent,policy)
render=0;
Horizon=500;
win=0;
iter=1;
agent=reset_pac(agent);
world=world_init();
ghosts=ghost_agent(world);
score=0;
win=0;
complete=0;
game_over = 0;

if policy == 1
    while game_over == 0
        if iter>Horizon
            break;
        end
        
        if render
            world_rendering(world,score,agent);
            pause(0.1)
        end
        
        % find next valid direction
        valid_a=next_action(world,agent.pos,1);
        valid_a=find(valid_a~=0);
        num = length(valid_a);
        
        %find the action go to the previous position
        pro_a =[];
        for i = 1:num
            nn_p = next_pos(agent.pos,valid_a(i));
            if nn_p(1) == agent.cur_pos(1) && nn_p(2) == agent.cur_pos(2)
                prob(i) = 0;
            else
                prob(i) = 1/(num-1);
            end
            if i == 1
                pro_a(i) = prob(i);
            else
                pro_a(i) = pro_a(i-1)+prob(i);
            end
        end
        
        if num == 1
            pro_a(1) = 1;
        end
        
        x= rand();
        if(x>=0 && x < pro_a(1))
            a = valid_a(1);
        elseif (x >=pro_a(1) && x < pro_a(2))
            a = valid_a(2);
        elseif(x >= pro_a(2) && x < pro_a(3))
            a = valid_a(3);
        else
            a = valid_a(4);
        end
        
        next_p=next_pos(agent.pos,a);
        
        %-- update agent
        agent=update_agent_stat(world,agent,next_p);
        %-- update ghost; allocate new position
        ghosts=update_ghost_stat(world,ghosts,agent,next_p);
        
        [r,agent,ghosts]=eval_reward(world,agent,ghosts,1);
        %-- update1
        [world,agent,ghosts,game_over]=world_update1(world,agent,ghosts);
        %game_over = 0: not over; 1: eat all dots; -1: eaten by a ghost
        
        
        %-- update2: pac-man and ghost's position in world
        world=world_update2(world,agent,ghosts);
        score = r*100 + score;
        iter = iter + 1;
    end
    
elseif policy ==2
    while game_over == 0
        if iter>Horizon
            break;
        end
        
        if render
            world_rendering(world,score,agent);
            pause(0.1)
        end
        
        % find next valid direction
        valid_a=next_action(world,agent.pos,1);
        no_ghost_a = valid_a;
        has_ghost_a = [];
        valid_a=find(valid_a~=0);
        num = length(valid_a);
        
        %find whether there is a ghost nearby
        for i = 1:num
            nn_p = next_pos(agent.pos,valid_a(i));
            for ng=1:ghosts.num
               
                %if there is a ghost nearby
                food_map=world.dot_map;                
                ghost_map=zeros(size(food_map));
                
                for ng=1:size(world.ghost_map,1)
                    ghost_map(world.ghost_map(ng,1),world.ghost_map(ng,2))=1;
                end
                in_maze=ismember(world.ghost_map,world.gbirth,'rows');
                in_maze=find(in_maze~=0);
                if isempty(in_maze)
                    g_dist=get_dist(world.grid,nn_p,world.pac_forbidden,1,ghost_map);
                    if g_dist==1e5
                        g_dist=size(world.grid);
                    end
                else
                    g_dist=size(world.grid);
                end
                
                if g_dist <= 1
                    if ~agent.god_mode
                        %there is a ghost
                        no_ghost_a(valid_a(i)) = 0;
                    else
                        has_ghost_a(end+1)=valid_a(i);
                    end
                end
            end
        end
        
        no_ghost_a = find(no_ghost_a~=0);
        if ~isempty(has_ghost_a)
            a = has_ghost_a(ceil(rand()*length(has_ghost_a)));
            %can't find a way that no ghost
        elseif isempty(no_ghost_a)
            a = valid_a(ceil(rand()*length(valid_a)));
        elseif length(no_ghost_a) == 1 %only one choice
            a = no_ghost_a(1);
        else     % length(no_ghost_a) >= 2          
            %find the action go to the previous position
            pro_a =[];
            for i = 1:length(no_ghost_a)
                nn_p = next_pos(agent.pos,no_ghost_a(i));
                if nn_p(1) == agent.cur_pos(1) && nn_p(2) == agent.cur_pos(2)
                    prob(i) = 0; 
                else
                    prob(i) = 1/(length(no_ghost_a)-1);
                end
                if i == 1
                    pro_a(i) = prob(i);
                else
                    pro_a(i) = pro_a(i-1)+prob(i);
                end
            end
            
            x= rand();            
            for i = 1: length(no_ghost_a)
                if (x>=0 && x < pro_a(1))
                    a = no_ghost_a(1);
                    break;
                elseif i ~= 1 && (x >= pro_a(i-1) && x < pro_a(i))
                    a = no_ghost_a(i);
                    break;
                end
            end
            
        end
        
        next_p=next_pos(agent.pos,a);
        
        %-- update agent
        agent=update_agent_stat(world,agent,next_p);
        %-- update ghost; allocate new position
        ghosts=update_ghost_stat(world,ghosts,agent,next_p);
        
        [r,agent,ghosts]=eval_reward(world,agent,ghosts,1);
        %-- update1
        [world,agent,ghosts,game_over]=world_update1(world,agent,ghosts);
        %game_over = 0: not over; 1: eat all dots; -1: eaten by a ghost
        
        %-- update2: pac-man and ghost's position in world
        world=world_update2(world,agent,ghosts);
        score = r*100 + score;
        iter = iter + 1;
    end
    
elseif policy == 3
    while game_over == 0
        if iter>Horizon
            break;
        end
        
        if render
            world_rendering(world,score,agent);
            pause(0.1)
        end
        
        % find next valid direction
        valid_a=next_action(world,agent.pos,1);
        no_ghost_a = valid_a;
        has_ghost_a = [];
        valid_a=find(valid_a~=0);
        num = length(valid_a);

        
        %find whether there is a ghost nearby
        for i = 1:num
            nn_p = next_pos(agent.pos,valid_a(i));
            for ng=1:ghosts.num
                
                %if there is a ghost nearby
                food_map=world.dot_map;
                ghost_map=zeros(size(food_map));
                
                for ng=1:size(world.ghost_map,1)
                    ghost_map(world.ghost_map(ng,1),world.ghost_map(ng,2))=1;
                end
                in_maze=ismember(world.ghost_map,world.gbirth,'rows');
                in_maze=find(in_maze~=0);
                if isempty(in_maze)
                    g_dist=get_dist(world.grid,nn_p,world.pac_forbidden,1,ghost_map);
                    if g_dist==1e5
                        g_dist=size(world.grid);
                    end
                else
                    g_dist=size(world.grid);
                end
                
                if g_dist <= 1
                    if ~agent.god_mode
                        %there is a ghost
                        no_ghost_a(valid_a(i)) = 0;
                    else
                        has_ghost_a(end+1)=valid_a(i);
                    end
                end
            end
        end
        
        no_ghost_a = find(no_ghost_a~=0);
        if ~isempty(has_ghost_a)
            a = has_ghost_a(ceil(rand()*length(has_ghost_a)));
        %can't find a way that no ghost
        elseif isempty(no_ghost_a)
            a = valid_a(ceil(rand()*length(valid_a)));
        elseif length(no_ghost_a) == 1 %only one choice
            a = no_ghost_a(1);
        else     % length(no_ghost_a) >= 2
            dot_a = [];
            %find all actions lead to the directions has dot
            for i = 1 : length(no_ghost_a)
                np =  next_pos(agent.pos,no_ghost_a(i));
                if world.dot_map(np(1),np(2)) ~= 0
                    dot_a(end+1) = no_ghost_a(i);
                end
            end
            
            %if all has dot, randomly choose one;
            if length(no_ghost_a) == length(dot_a)
                a = dot_a(ceil(rand()*length(dot_a)));
            elseif length(dot_a) == 0
                %find the action go to the nearest dot
                dist = [];
                for i = 1:length(no_ghost_a)
                    nn_p = next_pos(agent.pos,no_ghost_a(i));
                    dist(i)=get_dist(world.grid,nn_p,world.pac_forbidden,1,food_map);
                end
                [~,index] = min(dist);
                a = no_ghost_a(index);

            else
                %choose a way has dot
                a = dot_a(ceil(rand()*length(dot_a)));
            end
            
        end
        
        next_p=next_pos(agent.pos,a);
        
        %-- update agent
        agent=update_agent_stat(world,agent,next_p);
        %-- update ghost; allocate new position
        ghosts=update_ghost_stat(world,ghosts,agent,next_p);
        
        [r,agent,ghosts]=eval_reward(world,agent,ghosts,1);
        %-- update1
        [world,agent,ghosts,game_over]=world_update1(world,agent,ghosts);
        %game_over = 0: not over; 1: eat all dots; -1: eaten by a ghost
        
        %-- update2: pac-man and ghost's position in world
        world=world_update2(world,agent,ghosts);
        score = r*100 + score;
        iter = iter + 1;
    end
end

complete=agent.eat_dot/110;

if game_over == 1
    win = 1;
end

end
