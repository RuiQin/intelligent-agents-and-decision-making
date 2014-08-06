function [ agent] = Q_learning( world,agent )

M_epi=500;%learn
M_iter=10;%eval

p_win=zeros(M_epi,1);
p_step=zeros(M_epi,1);
p_score=zeros(M_epi,1);
p_comp=zeros(M_epi,1);
for epi=1:M_epi
    fprintf('\nlearning episode:'); 
    fprintf('%d\n',epi);
    agent=qlearn(agent);
    agent.param
    for iter=1:M_iter
        n_world=world;
       [nstep,score,win,complete]=eval_agent(n_world,agent,0,1);
       if iter==1
           mstep=nstep;
           mscore=score;
           mwin=win;
           mcom=complete;
       else
           mstep=mstep+(nstep-mstep)/iter;
           mscore=mscore+(score-mscore)/iter;
           mcom=mcom+(complete-mcom)/iter;
           mwin=mwin+win;
       end   
    end
    mwin=mwin/M_iter;
    
    if epi==1
        p_win(epi)=mwin;
        p_step(epi)=mstep;
        p_score(epi)=mscore;
        p_comp(epi)=mcom;
    else
        p_win(epi)=p_win(epi-1)+(mwin-p_win(epi-1))/epi;
        p_step(epi)=p_step(epi-1)+(mstep-p_step(epi-1))/epi;
        p_score(epi)=p_score(epi-1)+(mscore-p_score(epi-1))/epi;
        p_comp(epi)=p_comp(epi-1)+(mcom-p_comp(epi-1))/epi;
    end
    fprintf('pwin:%g,pstep:%g,pscore:%g,pcomplete:%g\n',p_win(epi),p_step(epi),p_score(epi),p_comp(epi));

end

%--result...
save('q-learning(wwd)-rst','p_win','p_step','p_score','p_comp');
save(['agent-qlearning(wwd)-',num2str(M_epi),'-epo'],'agent');
% X=1:M_epi;
% figure(10);hold on
% plot(X,p_win,'Color','r');%legend('avg. winning percent');
% plot(X,p_comp,'Color','g');
% legend('averaged Wins','averaged level completion');
% xlabel('Allocated episode');
% ylabel('Averaged value(%)');
% hold off
% figure(20);hold on
% plot(X,p_step,'Color','r');
% plot(X,p_score,'Color','g');
% legend('averaged steps','averaged scores');
% xlabel('Allocated episode');
% ylabel('Average value');
% hold off

p_win
pause
end

function [agent]=qlearn(agent)
render=0;
Horizon=500;
mwin=0;
for epi=1:10
    fprintf('%d ',epi);
    iter=1;
    agent=reset_pac(agent);
    world=world_init();
    ghosts=ghost_agent(world);
    score=0;
    win=0;
    while 1
        
        if iter>Horizon 
            break;
        end
        %--
        if render
            world_rendering(world,score,agent);
            pause(0.01)
        end

        valid_a=next_action(world,agent.pos,1);
        valid_a=find(valid_a~=0);
        feat=zeros(agent.n_param,length(valid_a));
        q_val=zeros(length(valid_a),1);
        pred_step=1;
        for na=1:length(valid_a)
            feat(:,na)=ext_feat(world,agent,agent.pos,valid_a(na),pred_step,1);
            feat(1,na)=1;
            q_val(na)=feat(:,na)'*agent.param;
        end
        x=rand;
        a_indx=[];
        if x<agent.epsilon
            T=exp(-agent.decay*iter)*agent.T_max+1;
            % normalize
            norm_qv=q_val/norm(q_val);
            e=exp(norm_qv./T);
            pe=e./sum(e);
            pe=cumsum(pe,1);
            x=rand;
            if x<=pe(1)
                a_indx=1;
                a=valid_a(a_indx);
            else
                for ns=1:length(pe)-1
                    if x>pe(ns)&&x<=pe(ns+1)
                        a_indx=ns+1;
                        a=valid_a(a_indx);
                        break;
                    end
                end
             end
        else
            [r,~]=size(q_val);
            if r>1
                [~,a_indx]=max(q_val,[],1);
            else
                [~,a_indx]=max(q_val,[],2);
            end
            a=valid_a(a_indx);
        end
        next_p=next_pos(agent.pos,a);
        %-- update params
        [r,agent,ghosts]=eval_reward(world,agent,ghosts,1);
        
        %Q(s',a')
        next_v_a=next_action(world,next_p,1);
        next_v_a=find(next_v_a~=0);
        nfeat=zeros(agent.n_param,length(next_v_a));
        nq_val=zeros(length(next_v_a),1);
        pred_step=2;
        for na=1:length(next_v_a)
            nfeat(:,na)=ext_feat(world,agent,next_p,next_v_a(na),pred_step,1);
            nfeat(1,na)=1;
            nq_val(na)=nfeat(:,na)'*agent.param;
        end

        max_q=max(nq_val);
       
        %-- update1
        [world,agent,ghosts,~]=world_update1(world,agent,ghosts); 
        
        %-- update ghost; allocate new position
        ghosts=update_ghost_stat(world,ghosts,agent,next_p);
        %-- update agent
        agent=update_agent_stat(world,agent,next_p);
        %-- update2
        world=world_update2(world,agent,ghosts);
        
        [pred,pred_r]=pred_game_stat(world,agent,ghosts,1);
                
        if pred~=0
            diff=r+agent.gamma*pred_r-q_val(a_indx);
            agent.param=agent.param+agent.alpha*diff.*feat(:,a_indx);%weight decay
            if sum(agent.param.^2)>1&&1
                agent.param=agent.param-agent.alpha.*agent.param.*0.01;            
            end
           
            if pred==1
                win=1;
            else
                win=0;
            end
            
            break;
        else
            diff=r+agent.gamma*max_q-q_val(a_indx); 
            agent.param=agent.param+agent.alpha*diff.*feat(:,a_indx);
            if sum(agent.param.^2)>1&&1
                agent.param=agent.param-agent.alpha.*agent.param.*0.01;            
            end
            
            score=score+r;
        end
        
        iter=iter+1;
    end
   mwin=mwin+win;
   agent.learn_iter=agent.learn_iter+1;

end
fprintf('wp:%d\n',mwin);
end

