function [ agent] = SARSA( world,agent,agent_type)
%state-action-reward-state-action
M_epi=500;%learn
M_iter=10;%eval

p_win=zeros(M_epi,1);
p_step=zeros(M_epi,1);
p_score=zeros(M_epi,1);
p_comp=zeros(M_epi,1);
for epi=1:M_epi
    fprintf('\nlearning episode:'); 
    fprintf('%d\n',epi);
    agent=sarsa(agent,agent_type);
    agent.param
    for iter=1:M_iter
        n_world=world;
       [nstep,score,win,complete]=eval_agent(n_world,agent,0,agent_type);
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
%--result...
if agent_type==1
    tstr='linear';
else
    tstr='NN';
end
save(['SARSA(wwd)-',tstr,'-rst-',num2str(agent.neurons),'-hid-',num2str(M_epi),'-epo'],'p_win','p_step','p_score','p_comp');
save(['SARSA(wwd)-',tstr,'-agent-',num2str(agent.neurons),'-hid-',num2str(M_epi),'-epo'],'agent');
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


pause
end

function [agent]=sarsa(agent,agent_type)
render=0;
Horizon=500;
nn_feature=[];
nn_qtarget=[];
for epi=1:10
    fprintf('%d ',epi);
    iter=1;
    agent=reset_pac(agent);
    world=world_init();
    ghosts=ghost_agent(world);
    score=0;
    
    %-- chose a from s
    valid_a=next_action(world,agent.pos,1);
    valid_a=find(valid_a~=0);
    feat=zeros(agent.n_param,length(valid_a));
    q_val_cur=zeros(length(valid_a),1);
    pred_step=1;
    for na=1:length(valid_a)
        feat(:,na)=ext_feat(world,agent,agent.pos,valid_a(na),pred_step,agent_type);
        feat(1,na)=1;
        if agent_type==1
            q_val_cur(na)=feat(:,na)'*agent.param;
        else
            cfeat=feat(2:end,na)';
            q_val_cur(na)=nnpredict(agent.nn,cfeat);
        end
    end
    x=rand;
    a_indx_cur=[];
    if x<agent.epsilon
        T=exp(-agent.decay*iter)*agent.T_max+1;
        norm_qv=q_val_cur./norm(q_val_cur);
        e=exp(norm_qv./T);
        pe=e./sum(e);
        pe=cumsum(pe,1);
        x=rand;
        if x<=pe(1)
            a_indx_cur=1;
            a_cur=valid_a(a_indx_cur);
        else
            for ns=1:length(pe)-1
                if x>pe(ns)&&x<=pe(ns+1)
                    a_indx_cur=ns+1;
                    a_cur=valid_a(a_indx_cur);
                    break;
                end
            end
        end
    else
        [r,~]=size(q_val_cur);
        if r>1
            [~,a_indx_cur]=max(q_val_cur,[],1);
        else
            [~,a_indx_cur]=max(q_val_cur,[],2);
        end
        a_cur=valid_a(a_indx_cur);
    end
    %== loop
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
        q_val_cur=zeros(length(valid_a),1);
        pred_step=1;
        for na=1:length(valid_a)
            feat(:,na)=ext_feat(world,agent,agent.pos,valid_a(na),pred_step,agent_type);
            feat(1,na)=1;
            if agent_type==1
                q_val_cur(na)=feat(:,na)'*agent.param;
            else
                cfeat=feat(2:end,na)';
                q_val_cur(na)=nnpredict(agent.nn,cfeat);
            end
        end
        next_p=next_pos(agent.pos,a_cur);
        %-- update params
        [r,agent,ghosts]=eval_reward(world,agent,ghosts,1);
        
        %Q(s',a')
        next_v_a=next_action(world,next_p,1);
        next_v_a=find(next_v_a~=0);
        nfeat=zeros(agent.n_param,length(next_v_a));
        nq_val=zeros(length(next_v_a),1);
        pred_step=2;
        for na=1:length(next_v_a)
            nfeat(:,na)=ext_feat(world,agent,next_p,next_v_a(na),pred_step,agent_type);
            nfeat(1,na)=1;
            if agent_type==1
                nq_val(na)=nfeat(:,na)'*agent.param;
            else
                cfeat=nfeat(2:end,na)';
                nq_val(na)=nnpredict(agent.nn,cfeat);
            end
        end

        x=rand;
        if x<agent.epsilon
            T=exp(-agent.decay*iter)*agent.T_max+1;
            norm_qv=nq_val./norm(nq_val);
            e=exp(norm_qv./T);
            pe=e./sum(e);
            pe=cumsum(pe,1);
            x=rand;
            if x<=pe(1)
                a_indx_nex=1;
                a_nex=next_v_a(a_indx_nex);
            else
                for ns=1:length(pe)-1
                    if x>pe(ns)&&x<=pe(ns+1)
                        a_indx_nex=ns+1;
                        a_nex=next_v_a(a_indx_nex);
                        break;
                    end
                end
            end
        else
            [r1,~]=size(nq_val);
            if r1>1
                [~,a_indx_nex]=max(nq_val,[],1);
            else
                [~,a_indx_nex]=max(nq_val,[],2);
            end
            a_nex=next_v_a(a_indx_nex);
        end

        nex_q=nq_val(a_indx_nex);
       
        %-- update1
        [world,agent,ghosts,~]=world_update1(world,agent,ghosts); 
        
        %-- update ghost; allocate new position
        ghosts=update_ghost_stat(world,ghosts,agent,next_p);
        %-- update agent
        agent=update_agent_stat(world,agent,next_p);
        %-- update2
        world=world_update2(world,agent,ghosts);
        
        [pred,pred_r]=pred_game_stat(world,agent,ghosts,agent_type);
        
        if pred~=0
            if agent_type==1
                diff=r+agent.gamma*pred_r-q_val_cur(a_indx_cur);
                agent.param=agent.param+agent.alpha*diff.*feat(:,a_indx_cur);
                if sum(agent.param.^2)>1&&1
                    agent.param=agent.param-agent.alpha.*agent.param.*0.01;            
                end
            else
                q_target=r+agent.gamma*pred_r;
                nn_feature=[nn_feature;feat(2:end,a_indx_cur)'];
                nn_qtarget=[nn_qtarget;q_target];
            end
            
            break;
        else
            if agent_type==1
                diff=r+agent.gamma*nex_q-q_val_cur(a_indx_cur);            
                agent.param=agent.param+agent.alpha*diff.*feat(:,a_indx_cur);
                if sum(agent.param.^2)>1&&1
                    agent.param=agent.param-agent.alpha.*agent.param.*0.01;            
                end
            else
                q_target=r+agent.gamma*nex_q;
                nn_feature=[nn_feature;feat(2:end,a_indx_cur)'];
                nn_qtarget=[nn_qtarget;q_target];
            end
            score=score+r;
        end
        a_cur=a_nex;
        a_indx_cur=a_indx_nex;
        iter=iter+1;
    end
end
if agent_type~=1
    nmin=0;
    nmax=1.9;
    nn_qtarget=(nn_qtarget-nmin)./(nmax-nmin);

    %--training-----
    fprintf('\noff-line training..\n');
    agent.nn=nntrain(agent.nn,nn_feature,nn_qtarget);
%     agent.nn.learningRate=agent.nn.learningRate*(0.99).^agent.learn_iter;
%     agent.nn.learningRate=agent.nn.init_learningRate*exp(-0.004*agent.learn_iter);
%     agent.nn.momentum=agent.nn.init_momentum/exp(-0.004*agent.learn_iter);
agent.nn.learningRate=...
    agent.nn.max_learnrate-...
    (agent.nn.max_learnrate-agent.nn.min_learnrate)*agent.learn_iter/500;
agent.nn.momentum=...
    agent.nn.min_momentum+...
    (agent.nn.max_momentum-agent.nn.min_momentum)*agent.learn_iter/500;

end
    agent.learn_iter=agent.learn_iter+1;

end

