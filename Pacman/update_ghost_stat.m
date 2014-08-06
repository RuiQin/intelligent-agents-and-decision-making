function [ ghosts ] = update_ghost_stat( world,ghosts,pac,pac_nextp )
%UPDATE_GHOST_STAT Summary of this function goes here
%   Detailed explanation goes here
%-- random actions
freeze=0;
if pac.god_mode&&mod(pac.timer,2)==0
    freeze=1;
end
for ng=1:size(ghosts.pos,1)
    if ghosts.eaten(ng)% if eaten; %%if pacman god mode or not
        ghosts.eaten(ng)=0;
        ghosts.pos(ng,:)=world.gbirth(ng,:);
        continue;
    end
    gp=ghosts.pos(ng,:);
    valid_a=next_action(world,gp,0);
    valid_a=find(valid_a~=0);
    
    neighbor=0;
    for n=1:length(valid_a)
        np=next_pos(gp,valid_a(n));
        if np(1)==pac.pos(1)&&np(2)==pac.pos(2)
            neighbor=1;
            break;
        end
    end
    if neighbor
       if pac.god_mode%flee
          for n=1:length(valid_a)
              np=next_pos(gp,valid_a(n));
              if np(1)~=pac.pos(1)&&np(2)~=pac.pos(2)&&~freeze
                ghosts.pos(ng,:)=np;
                break;
              end
          end
       else % if pac flee then chase
           if pac_nextp(1)~=gp(1)||pac_nextp(2)~=gp(2)
               ghosts.pos(ng,:)=pac.pos;
           end
       end 
       
       continue;
    end
 
    if freeze
        continue;
    end
    pre_act=ghosts.pre_act(ng);

    p=rand;
    if pre_act~=0&&p<ghosts.epsilon&&ismember(pre_act,valid_a)
        np=next_pos(ghosts.pos(ng,:),pre_act);
        ghosts.pos(ng,:)=np;
        ghosts.pre_act(ng)=pre_act;
    else
        x=randi(length(valid_a),1);
        np=next_pos(ghosts.pos(ng,:),valid_a(x));
        ghosts.pos(ng,:)=np;
        ghosts.pre_act(ng)=valid_a(x);
    end
            
    
end


end

