function [ feat ] = ext_feat( world,agent,agent_pos,action,pred_step,agent_type )
if nargin<6
    agent_type=1;
end
if agent.timer-pred_step<=0
    agent.god_mode=0;
end
gs=size(world.grid);
gs=gs(1)*gs(2);
pos=agent_pos;% current pos or next pos(for Q')
if action==1
    pos(1)=pos(1)-1;
end
if action==2
    pos(1)=pos(1)+1;
end
if action==3
    pos(2)=pos(2)-1;
end
if action==4
    pos(2)=pos(2)+1;
end

food_map=world.dot_map;
dist=get_dist(world.grid,pos,world.pac_forbidden,1,food_map);
dist=dist/gs;

ghost_map=zeros(size(food_map));
for ng=1:size(world.ghost_map,1)
    ghost_map(world.ghost_map(ng,1),world.ghost_map(ng,2))=1;
end
in_maze=ismember(world.ghost_map,world.gbirth,'rows');
in_maze=find(in_maze~=0);
if isempty(in_maze)
    g_dist=get_dist(world.grid,pos,world.pac_forbidden,1,ghost_map);
    if g_dist==1e5
        g_dist=gs;
    end
else
    g_dist=gs;
end
g_dist1=g_dist;
g_dist=g_dist/gs;
% powerpill
[px,py]=find(food_map==2);
pav=0;% avalable powerpill
p_dist=1;
if ~isempty(px)
    pmap=zeros(size(food_map));
    for np=1:length(px)
        pmap(px(np),py(np))=1;
    end
    p_dist=get_dist(world.grid,pos,world.pac_forbidden,1,pmap);
    p_dist=p_dist/gs;
    pav=1;
end
%- neighboring ghosts
va=next_action(world,pos,1);
va(end+1)=1;
nposes=[pos(1)-1,pos(2);pos(1)+1,pos(2);...
        pos(1),pos(2)-1;pos(1),pos(2)+1;
        pos(1),pos(2)];
ig=ismember(nposes,world.ghost_map,'rows');

nei_g=double(va)+double(ig);
nei_g=find(nei_g==2);
ng=length(nei_g);

if agent_type==1
    feat=[];
    %---------
    feat(1)=1;%bias
    %---------
    if (~ng||agent.god_mode)&&food_map(pos(1),pos(2))~=0
        feat(2)=1;
    else
        feat(2)=0;% available food can be eaten+
    end
    if agent.god_mode 
        scalar=1;
    else
        scalar=-1;
    end
    va(end)=[];
    va=find(va~=0);
    if length(va)==1
        scalar2=1;
    else
        scalar2=0;
    end
    if length(va)==2
        scalar3=1;
    else
        scalar3=0;
    end
    %---------
    feat(3)=scalar*ng;% god mode and having ghosts+
    feat(4)=scalar2*ng*scalar;%only one choice,god mode+
    feat(5)=g_dist*10;%+
    if ismember(pos,agent.history,'rows')
        wander=1;
    else
        wander=0;
    end 

    cur_feat=food_map(agent.pos(1),agent.pos(2))~=0;
    if wander&&agent.eat_dot>0&&~feat(2)&&~cur_feat&&~ng
        feat(6)=1;%-
    else
        feat(6)=0;
    end 
    %---------
    feat(7)=dist*10;% nearest food -
    if scalar==-1
        feat(8)=ng*pav*p_dist*10;% nearest ppill -
    else
        feat(8)=0;
    end
    % in the same road
    sr=1;
    for n_g=1:size(world.ghost_map,1)-1
        if ~((world.ghost_map(n_g,1)==world.ghost_map(n_g+1,1)&&...
              world.ghost_map(n_g,1)==pos(1)&&...
              g_dist1==min(abs(pos(1)-world.ghost_map(n_g,1)),abs(pos(1)-world.ghost_map(n_g+1,1))))||...
             (world.ghost_map(n_g,2)==world.ghost_map(n_g+1,2)&&...
             world.ghost_map(n_g,2)==pos(2)&&...
             g_dist1==min(abs(pos(2)-world.ghost_map(n_g,2)),abs(pos(2)-world.ghost_map(n_g+1,2)))))
            sr=0;break;
        end
    end

    feat(9)=sr*scalar;%+

    feat=feat./10;

else
    feat=[];
    %---------
    feat(1)=1;%bias
    %---------
    if (~ng||agent.god_mode)&&food_map(pos(1),pos(2))~=0
        feat(2)=1;
    else
        feat(2)=0;% available food can be eaten+
    end
    
    if agent.god_mode 
        scalar=1;
    else
        scalar=-1;
    end
    feat(3)=scalar*ng;
    va(end)=[];
    va=find(va~=0);
    if length(va)==1
        scalar2=1;
    else
        scalar2=0;
    end

    %---------
%     feat(4)=scalar*ng;% god mode and having ghosts+
    feat(4)=scalar2*scalar;%only one choice,god mode+
    feat(5)=g_dist*10;%+
    %---------
    if ismember(pos,agent.history,'rows')
        wander=1;
    else
        wander=0;
    end 

    cur_feat=food_map(agent.pos(1),agent.pos(2))~=0;

    feat(6)=wander&&agent.eat_dot>0&&~feat(2)&&~cur_feat&&~ng;
    
    %---------
    feat(7)=dist*10;% nearest food -
%     if scalar==-1
%         feat(8)=ng*pav*p_dist*10;% nearest ppill -
%     else
%         feat(8)=0;
%     end
%     feat(11)=pav;
    feat(8)=ng*pav*p_dist*10;
    % in the same road
    sr=1;
    for n_g=1:size(world.ghost_map,1)-1
        if ~((world.ghost_map(n_g,1)==world.ghost_map(n_g+1,1)&&...
              world.ghost_map(n_g,1)==pos(1)&&...
              g_dist1==min(abs(pos(1)-world.ghost_map(n_g,1)),abs(pos(1)-world.ghost_map(n_g+1,1))))||...
             (world.ghost_map(n_g,2)==world.ghost_map(n_g+1,2)&&...
             world.ghost_map(n_g,2)==pos(2)&&...
             g_dist1==min(abs(pos(2)-world.ghost_map(n_g,2)),abs(pos(2)-world.ghost_map(n_g+1,2)))))
            sr=0;break;
        end
    end

    feat(9)=sr*scalar;%+
    feat(10)=scalar;

    feat=feat./10;    
    
end
end

