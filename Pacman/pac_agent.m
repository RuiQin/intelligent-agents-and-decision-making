function [ agent] = pac_agent( world,agent_type )
%PAC_AGENT Summary of this function goes here
%   Detailed explanation goes here

agent.pos=world.pac_map;
if agent_type==1
    agent.n_param=9;
else
    agent.n_param=10;
end
agent.neurons=20;
w_in_hidden = (randn(agent.n_param,agent.neurons) - 0.5)/10;
w_hidden_out = (randn(1,agent.neurons) - 0.5)/10;
if agent_type~=1
    agent.param{1}=w_in_hidden;
    agent.param{2}=w_hidden_out;
else
    agent.param=rand(agent.n_param,1)./1000;
end
agent.m_mu=0;
agent.m_sigma=0;
agent.epsilon=0.05;
agent.T_max=100;
agent.decay=0.5;
agent.alpha=0.1;
agent.gamma=0.8;
agent.god_mode=0;
agent.god_time=50;
agent.timer=0;
agent.birth=world.pac_map;
agent.eat_dot=0;
agent.cur_pos=agent.pos;
agent.history=[agent.pos;agent.pos];
agent.learn_iter=1;
agent.nn=nnsetup([agent.n_param-1,agent.neurons,1],0.3);
end

function nn = nnsetup(architecture, learningRate)

    nn.size   = architecture;
    nn.n      = numel(nn.size);
    
    nn.activation_function              = 'sigm';   %  Activation functions of hidden layers: 'sigm' (sigmoid) or 'tanh_opt' (optimal tanh).
    nn.min_learnrate                    = learningRate*0.1;
    nn.max_learnrate                    = learningRate;
    nn.learningRate                     = nn.max_learnrate; %  learning rate Note: typically needs to be lower when using 'sigm' activation function and non-normalized inputs.
    nn.init_momentum                    = 0.1;
    nn.min_momentum = 0.7;
    nn.max_momentum = 0.9;
    nn.momentum                         = nn.min_momentum;          %  Momentum
    nn.scaling_learningRate             = 1;            %  Scaling factor for the learning rate (each epoch)
    nn.weightPenaltyL2                  = 0;            %  L2 regularization
    nn.nonSparsityPenalty               = 0;            %  Non sparsity penalty
    nn.sparsityTarget                   = 0.05;         %  Sparsity target
    nn.inputZeroMaskedFraction          = 0;            %  Used for Denoising AutoEncoders
    nn.dropoutFraction                  = 0;            %  Dropout level (http://www.cs.toronto.edu/~hinton/absps/dropout.pdf)
    nn.testing                          = 0;            %  Internal variable. nntest sets this to one.
    nn.output                           = 'sigm';       %  output unit 'sigm' (=logistic), 'softmax' and 'linear'
    nn.epoch=1;
    nn.last_err=0;
    nn.bk=[];
    for i = 2 : nn.n   
        % weights and weight momentum
        nn.W{i - 1} = (rand(nn.size(i), nn.size(i - 1)+1) - 0.5) * 2 * 4 * sqrt(6 / (nn.size(i) + nn.size(i - 1)));
        nn.vW{i - 1} = zeros(size(nn.W{i - 1}));
        
        % average activations (for use with sparsity)
        nn.p{i}     = zeros(1, nn.size(i));   
    end
end


