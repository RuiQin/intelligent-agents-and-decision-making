
clear;clc;close all;
%===================

world=world_init();

%========== agent_type: 1:linear; -2:neural network
%learning
%=========Q-learning-linear
p_agent=pac_agent(world,1);
p_agent=Q_learning(world,p_agent);
%========Q-learning-NN
agent_type=-2;%NN
p_agent=pac_agent(world,agent_type);
p_agent=NN(world,p_agent,agent_type);
%=========SARSA-linear/NN
agent_type=-2; %1 or -2
p_agent=pac_agent(world,agent_type);
p_agent=SARSA(world,p_agent,agent_type);
%========= policy
p_agent=pac_agent(world,1);
policy(world, agent);

% qlearn=load('/nfs/stak/students/f/fengzh/cluster/final/Q-nn-rst-5-hid-500-epo.mat');
% sarsa=load('/nfs/stak/students/f/fengzh/cluster/final/SARSA(wwd)-NN-rst-20-hid-500-epo.mat');
% qlearn.p_win=qlearn.p_win*100;
% sarsa.p_win=sarsa.p_win*100;
% qlearn.p_comp=qlearn.p_comp*100;
% sarsa.p_comp=sarsa.p_comp*100;
% X=1:500;
% h=figure(10);hold on
% plot(X,qlearn.p_win,'Color','r');%legend('avg. winning percent');
% plot(X,sarsa.p_win,'Color','g');
% legend('Q-learning (NN)','Sarsa (NN)');
% xlabel('Allocated episode');
% ylabel('Averaged Wins(%)');
% hold off
% % saveas(h,'linear_win','eps');
% 
% h=figure(20);hold on
% plot(X,qlearn.p_step,'Color','r');%legend('avg. winning percent');
% plot(X,sarsa.p_step,'Color','g');
% legend('Q-learning (NN)','Sarsa (NN)');
% xlabel('Allocated episode');
% ylabel('Averaged steps');
% hold off
% % saveas(h,'linear_steps','eps');
% 
% h=figure(30);hold on
% plot(X,qlearn.p_score,'Color','r');%legend('avg. winning percent');
% plot(X,sarsa.p_score,'Color','g');
% legend('Q-learning (NN)','Sarsa (NN)');
% xlabel('Allocated episode');
% ylabel('Averaged score');
% hold off
% % saveas(h,'linear_score','eps');
% 
% h=figure(40);hold on
% plot(X,qlearn.p_comp,'Color','r');%legend('avg. winning percent');
% plot(X,sarsa.p_comp,'Color','g');
% legend('Q-learning (NN)','Sarsa (NN)');
% xlabel('Allocated episode');
% ylabel('Averaged level completion(%)');
% hold off
% saveas(h,'linear_comp','eps');