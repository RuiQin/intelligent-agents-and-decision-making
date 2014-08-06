function [ agent] = reset_pac( agent )
%RESET_PAC Summary of this function goes here
%   Detailed explanation goes here
agent.pos=agent.birth;
agent.god_mode=0;
agent.god_time=50;
agent.timer=0;
agent.eat_dot=0;
end

