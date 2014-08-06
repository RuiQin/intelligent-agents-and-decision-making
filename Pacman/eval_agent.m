function [ nstep,score,win,complete ] = eval_agent( world,pac,render,method )

nstep=0;
pac=reset_pac(pac);
ghosts=ghost_agent(world);
score=0;
complete=sum(sum(world.dot_map));
win=0;
if nargin < 4
    method = 1;
end
while 1
    if nstep>5000
        win=0;
        break;
    end
    if render
        world_rendering(world,score,pac);
        pause(0.01)
    end

    valid_a=next_action(world,pac.pos,1);
    valid_a=find(valid_a~=0);
    feat=zeros(pac.n_param,length(valid_a));
    q_val=zeros(length(valid_a),1);
    for na=1:length(valid_a)

        feat(:,na)=ext_feat(world,pac,pac.pos,valid_a(na),1,method);
        feat(1,na)=1;
        if method == 1% q-learning
            q_val(na)=feat(:,na)'*pac.param;
        end
        if method == -1
            q_val(na)=bp_pred(feat(:,na),pac.param);
        end
        if method == -2
%             cfeat=normalize(feat(2:end,na)',pac.m_mu,pac.m_sigma);
%             cfeat=zscore(feat(2:end,na)');
            cfeat=feat(2:end,na)';
            q_val(na)=nnpredict(pac.nn,cfeat);
        end
    end
  
    [r,~]=size(q_val);
    if r>1
        [~,a_indx]=max(q_val,[],1);
    else
        [~,a_indx]=max(q_val,[],2);
    end
    a=valid_a(a_indx);

    next_p=next_pos(pac.pos,a);
    [~,pac,ghosts,r]=eval_reward(world,pac,ghosts,method);

    %--
    score=score+r;
    %-- update1
    [world,pac,ghosts,game_over]=world_update1(world,pac,ghosts);        
    
    if game_over~=0
        if game_over==1
            win=1;
        else
            win=0;
        end
        break;
    else
        %-- update ghost; allocate new position
        ghosts=update_ghost_stat(world,ghosts,pac,next_p);
        %-- update agent
        pac=update_agent_stat(world,pac,next_p);
        %-- update2
        world=world_update2(world,pac,ghosts);
    end
    nstep=nstep+1;
    
end
complete=(complete-sum(sum(world.dot_map)))/complete;

end

