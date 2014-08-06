function [ world ] = world_init()
%GUI Summary of this function goes here
%   Detailed explanation goes here
world.grid_size=20;
[world.grid,world.canvas]=gen_map(world.grid_size);
world.dot_map=world.grid;
world.mdot_map=[size(world.grid,1)-1 2; 2 size(world.grid,2)-1];
for i=1:size(world.mdot_map,1)
    world.dot_map(world.mdot_map(i,1),world.mdot_map(i,2))=2;
end

% world.ghost_map=[6 9;6 10;6 11];
world.ghost_map=[6 10; 6 11];
world.gbirth=world.ghost_map;
% world.dot_map(6,9)=0;
world.dot_map(6,10)=0;
world.dot_map(6,11)=0;
% world.dot_map(6,12)=0;
world.dot_map(5,10)=0;
world.dot_map(5,11)=0;
world.pac_map=[8,10];
world.pac_forbidden=[5 10; 5 11];

% world.dot_map(8,10)=0;
world.texture=texture_init(world);

end

function [grid,map]=gen_map(gs)

H=11;W=20;
grid=zeros(H,W);% real position
for y=1:H
    for x=1:W
        if x==1||y==1||x==W||y==H
            grid(y,x)=1;
        end
    end
end
%--
grid(2,6)=1;grid(3,6)=1;
grid(2,15)=1;grid(3,15)=1;
grid(H-1,6)=1;grid(H-2,6)=1;
grid(H-1,15)=1;grid(H-2,15)=1;
%--
% grid(3,3)=1;
grid(3,4)=1;grid(4,3)=1;grid(5,3)=1;
% grid(3,W-2)=1;
grid(3,W-3)=1;grid(4,W-2)=1;grid(5,W-2)=1;
grid(5,5)=1;grid(5,6)=1;grid(5,W+1-5)=1;grid(5,W+1-6)=1;

% grid(H+1-3,3)=1;
grid(H+1-3,4)=1;grid(H+1-4,3)=1;grid(H+1-5,3)=1;
% grid(H+1-3,W-2)=1;
grid(H+1-3,W-3)=1;grid(H+1-4,W-2)=1;grid(H+1-5,W-2)=1;
grid(H+1-5,5)=1;grid(H+1-5,6)=1;grid(H+1-5,W+1-5)=1;grid(H+1-5,W+1-6)=1;
%--
for i=8:9
    grid(3,i)=1;
    grid(H+1-3,i)=1;
end
for i=12:13
    grid(3,i)=1;
    grid(H+1-3,i)=1;
end
%--center
% grid(6,5)=1;grid(6,W+1-5)=1;
grid(5,8)=1;grid(5,9)=1;grid(5,W+1-8)=1;grid(5,W+1-9)=1;
for i=8:13
    grid(H+1-5,i)=1;
end

grid(6,9)=1;grid(6,W+1-9)=1;

grid=double(~grid);
%-- map rendering
% each grid:gs*gs
map=zeros(H*gs,W*gs,3);

for y=1:H
    for x=1:W
        if grid(y,x)==0
           map((y-1)*gs+1:(y-1)*gs+gs-1,(x-1)*gs+1:(x-1)*gs+gs-1,1)=0; 
           map((y-1)*gs+1:(y-1)*gs+gs-1,(x-1)*gs+1:(x-1)*gs+gs-1,2)=0;
           map((y-1)*gs+1:(y-1)*gs+gs-1,(x-1)*gs+1:(x-1)*gs+gs-1,3)=255;
        end
    end
end

end

function [ texture] = texture_init( map )
%TEXTURE_INIT Summary of this function goes here
%   Detailed explanation goes here
texture.pac=zeros(map.grid_size,map.grid_size,3);
texture.gho=zeros(map.grid_size,map.grid_size,3,2);
texture.dot=zeros(map.grid_size,map.grid_size,3);
texture.mdot=zeros(map.grid_size,map.grid_size,3);
for y=1:map.grid_size
    for x=1:map.grid_size
        %pac
        if sqrt((y-map.grid_size/2)^2+(x-map.grid_size/2)^2)<map.grid_size/2
            texture.pac(y,x,1)=255;
            texture.pac(y,x,2)=255;
            texture.pac(y,x,3)=0;
            
            texture.gho(y,x,1,1)=255;
            texture.gho(y,x,2,1)=0;
            texture.gho(y,x,3,1)=0;
            texture.gho(y,x,1,2)=0;
            texture.gho(y,x,2,2)=255;
            texture.gho(y,x,3,2)=0;
%             texture.gho(y,x,1,3)=0;
%             texture.gho(y,x,2,3)=255;
%             texture.gho(y,x,3,3)=255;
        end
        %dot
        if sqrt((y-map.grid_size/2)^2+(x-map.grid_size/2)^2)<map.grid_size/5
            texture.dot(y,x,1)=255;
            texture.dot(y,x,2)=255;
            texture.dot(y,x,3)=255;
        end
        %mdot
        if sqrt((y-map.grid_size/2)^2+(x-map.grid_size/2)^2)<map.grid_size/3
            texture.mdot(y,x,1)=255;
            texture.mdot(y,x,2)=255;
            texture.mdot(y,x,3)=255;
        end
    end
end



end

