function [ agent] = NN( world,agent,agent_type )

M_epi=500;%learn
M_iter=10;%eval

p_win=zeros(M_epi,1);
p_step=zeros(M_epi,1);
p_score=zeros(M_epi,1);
p_comp=zeros(M_epi,1);
for epi=1:M_epi
    fprintf('\nlearning episode:'); 
    fprintf('%d\n',epi);
%     agent=train_nn_online(agent,agent_type);
    agent=train_nn_offline(agent,agent_type);
    render=0;
    fprintf('\ntest:\n');
    for iter=1:M_iter
        fprintf('%d ',iter); 
        n_world=world;
       [nstep,score,win,complete]=eval_agent(n_world,agent,render,agent_type);
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
    fprintf('mstep:%g,mscore:%g,mcomp:%g,mwin:%g\n',mstep,mscore,mcom,mwin);
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
end

%--result...
X=1:M_epi;
save(['Q-nn-rst-',num2str(agent.neurons),'-hid-',num2str(M_epi),'-epo'],'p_win','p_step','p_score','p_comp');
save(['Q-agent-nn-',num2str(agent.neurons),'-hid-',num2str(M_epi),'-epo'],'agent');
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

function [agent]=train_nn_online(agent,agent_type)
render=0;
Horizon=1000;
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
            feat(:,na)=ext_feat(world,agent,agent.pos,valid_a(na),pred_step,agent_type);
            if agent_type==-1
                q_val(na)=bp_pred(feat(:,na),agent.param);%feat(:,na)'*agent.param;
            else
                q_val(na)=nnpredict(agent.nn,feat(2:end,na)');
            end
         end
        x=rand;
        a_indx=[];
        if x<agent.epsilon
            T=exp(-agent.decay*iter)*agent.T_max+1;
            % normalize
            norm_qv=q_val./norm(q_val);
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
        [r,agent,ghosts]=eval_reward(world,agent,ghosts,-1);
        
        %Q(s',a')
        next_v_a=next_action(world,next_p,1);
        next_v_a=find(next_v_a~=0);
        nfeat=zeros(agent.n_param,length(next_v_a));
        nq_val=zeros(length(next_v_a),1);
        pred_step=2;
        for na=1:length(next_v_a)
            nfeat(:,na)=ext_feat(world,agent,next_p,next_v_a(na),pred_step,agent_type);
%             nq_val(na)=nfeat(:,na)'*agent.param;
            if agent_type==-1
              nq_val(na)=bp_pred(nfeat(:,na),agent.param);
            else
              nq_val(na)=nnpredict(agent.nn,nfeat(2:end,na)');
            end
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
        
        [pred,pred_r]=pred_game_stat(world,agent,ghosts,agent_type);
        
        if pred~=0
            q_target=r+agent.gamma*pred_r;
            if agent_type==-2
            agent.nn=nntrain(agent.nn,feat(2:end,a_indx)',q_target);
            else
            agent.param = bp_train(feat(:,a_indx),q_target,agent.param,agent.alpha);
            end
            if pred==1
                win=1;
            else
                win=0;
            end
            break;
        else
            q_target=r+agent.gamma*max_q;
            if agent_type==-2
            agent.nn=nntrain(agent.nn,feat(2:end,a_indx)',q_target);
            else
            agent.param = bp_train(feat(:,a_indx),q_target,agent.param,agent.alpha);
            end
            score=score+r;
        end
        
        iter=iter+1;
    end
   mwin=mwin+win;
    
end
fprintf('wp:%d\n',mwin);
end

function [agent]=train_nn_offline(agent,agent_type)
render=0;
Horizon=1000;
 
nn_feature=[];
nn_qtarget=[];
%-- collect data
for epi=1:10
    fprintf('%d ',epi);
    iter=1;
    agent=reset_pac(agent);
    world=world_init();
    ghosts=ghost_agent(world);
    score=0;
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
            feat(:,na)=ext_feat(world,agent,agent.pos,valid_a(na),pred_step,agent_type);
            if agent_type==-1
                q_val(na)=bp_pred(feat(:,na),agent.param);%feat(:,na)'*agent.param;
            else
%                 [cfeat,~,~]=zscore(feat(2:end,na)');
                cfeat=feat(2:end,na)';
                q_val(na)=nnpredict(agent.nn,cfeat);
            end
        end
        %-- current
        x=rand;
        a_indx=[];
        T=exp(-0.1*agent.learn_iter);
        if x<T
            a_indx=randi(length(valid_a),1);
            a=valid_a(a_indx);
            
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
        [r,agent,ghosts]=eval_reward(world,agent,ghosts,-1);
        
        %Q(s',a')
        next_v_a=next_action(world,next_p,1);
        next_v_a=find(next_v_a~=0);
        nfeat=zeros(agent.n_param,length(next_v_a));
        nq_val=zeros(length(next_v_a),1);
        pred_step=2;
        for na=1:length(next_v_a)
            nfeat(:,na)=ext_feat(world,agent,next_p,next_v_a(na),pred_step,agent_type);
%             nq_val(na)=nfeat(:,na)'*agent.param;
            if agent_type==-1
              nq_val(na)=bp_pred(nfeat(:,na),agent.param);
            else
%               [cfeat,~,~]=zscore(nfeat(2:end,na)');
              cfeat=nfeat(2:end,na)';
              nq_val(na)=nnpredict(agent.nn,cfeat);
            end
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
        
        [pred,pred_r]=pred_game_stat(world,agent,ghosts,agent_type);
        
        if pred~=0
            q_target=r+agent.gamma*pred_r;
            nn_feature=[nn_feature;feat(2:end,a_indx)'];
            nn_qtarget=[nn_qtarget;q_target];

            if pred==1
                win=1;
            else
                win=0;
            end
            break;
        else
            q_target=r+agent.gamma*max_q;
            nn_feature=[nn_feature;feat(2:end,a_indx)'];
            nn_qtarget=[nn_qtarget;q_target];
            score=score+r;
        end
        iter=iter+1;
    end
    
end
% normalize data
% [nn_feature, mu, sigma] = zscore(nn_feature);
% if agent.learn_iter==1
%     agent.m_mu=mu;agent.m_sigma=sigma;
% else
%     agent.m_mu=agent.m_mu+(mu-agent.m_mu)./agent.learn_iter;
%     agent.m_sigma=agent.m_sigma+(sigma-agent.m_sigma)./agent.learn_iter;
% end
nmin=0;
nmax=1.9;
nn_qtarget=(nn_qtarget-nmin)./(nmax-nmin);

%--training-----
fprintf('\noff-line training..\n');
agent.nn=nntrain(agent.nn,nn_feature,nn_qtarget);
% agent.nn.learningRate=agent.nn.learningRate*(0.99).^agent.learn_iter;

agent.nn.learningRate=...
    agent.nn.max_learnrate-...
    (agent.nn.max_learnrate-agent.nn.min_learnrate)*agent.learn_iter/500;
agent.nn.momentum=...
    agent.nn.min_momentum+...
    (agent.nn.max_momentum-agent.nn.min_momentum)*agent.learn_iter/500;
% agent.nn.momentum=agent.nn.init_momentum/exp(-0.004*agent.learn_iter);

agent.learn_iter=agent.learn_iter+1;
end
