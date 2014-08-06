function [  ] = world_rendering( world,score,agent)
%MAP_RENDERING Summary of this function goes here
%   Detailed explanation goes here
gs=world.grid_size;
%-pellet 
for y=1:size(world.dot_map,1)
    for x=1:size(world.dot_map,2)
        if world.dot_map(y,x)==1
            world.canvas((y-1)*gs+1:(y-1)*gs+gs,(x-1)*gs+1:(x-1)*gs+gs,:)=world.texture.dot;
        end
    end
end
%-m pellet
for i=1:size(world.mdot_map,1)
    if world.dot_map(world.mdot_map(i,1),world.mdot_map(i,2))~=0
    world.canvas((world.mdot_map(i,1)-1)*gs+1:(world.mdot_map(i,1)-1)*gs+gs,...
        (world.mdot_map(i,2)-1)*gs+1:(world.mdot_map(i,2)-1)*gs+gs,:)=world.texture.mdot;
    end
end
%-pacman
world.canvas((world.pac_map(1)-1)*gs+1:(world.pac_map(1)-1)*gs+gs,...
    (world.pac_map(2)-1)*gs+1:(world.pac_map(2)-1)*gs+gs,:)=world.texture.pac;
%-ghost
for i=1:size(world.ghost_map,1)
    world.canvas((world.ghost_map(i,1)-1)*gs+1:(world.ghost_map(i,1)-1)*gs+gs,...
        (world.ghost_map(i,2)-1)*gs+1:(world.ghost_map(i,2)-1)*gs+gs,:)=world.texture.gho(:,:,:,i);
end

figure(1);hold on 
cla
imshow(world.canvas);
if nargin>1
    title(['score:',num2str(score),';pos:(',num2str(agent.pos(1)),',',num2str(agent.pos(2)),');','god time:',num2str(agent.timer)]);
end
hold off
end

