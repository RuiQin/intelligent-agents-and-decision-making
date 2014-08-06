function [ world,pac,ghosts,game_over] = world_update1( world, pac,ghosts )
%WORLD_UPDATE Summary of this function goes here
%   Detailed explanation goes here
game_over=0;
if world.dot_map(pac.pos(1),pac.pos(2))~=0
    pac.eat_dot=pac.eat_dot+1;
end
world.dot_map(pac.pos(1),pac.pos(2))=0;
% world.pac_map=pac.pos;
% world.ghost_map=ghosts.pos;
      
for ng=1:ghosts.num
    if pac.pos(1)==ghosts.pos(ng,1)&&pac.pos(2)==ghosts.pos(ng,2)
        if pac.god_mode
            ghosts.eaten(ng)=1;
        else
            game_over=-1;
            break;
        end
    end
end

if sum(sum(world.dot_map))==0
    game_over=1;
end

end

