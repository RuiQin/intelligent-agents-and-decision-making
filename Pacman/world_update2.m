function [ world] = world_update2( world, pac,ghosts )
%WORLD_UPDATE Summary of this function goes here
%   Detailed explanation goes here
world.pac_map=pac.pos;
world.ghost_map=ghosts.pos;
end



