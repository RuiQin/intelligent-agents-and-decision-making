function [ ghost_agent] = ghost_agent( world )
%GHOST_AGENT Summary of this function goes here
%   Detailed explanation goes here
%-- init using position;

ghost_agent.pos=world.ghost_map;
ghost_agent.num=size(world.ghost_map,1);
ghost_agent.eaten=zeros(size(ghost_agent.pos,1),1);
ghost_agent.pre_act=zeros(ghost_agent.num,1);
ghost_agent.epsilon=0.75;

end

