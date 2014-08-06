%---------------------------------------------------------
% MATLAB feed forward neural network backprop code
% by Phil Brierley
% www.philbrierley.com
% 29 March 2006
%--------------------------------------------------------
function [weight]=bp_train(feat,delta_r,weight,alpha)
% feat: n-by-1 up/down/left/right
% delta_r: for back propagation 
% weight: learned weight

%user specified values
epochs = 10000;
epsilon = 1e-3;

% ------- load in the data -------

% train_inp = [1 1; 1 0; 0 1; 0 0];
% train_out = [1; 0; 0; 1];
train_inp = feat(2:end)';
train_out = delta_r;
% train_inp=feat;
% train_out=delta_r;
% check same number of patterns in each
if size(train_inp,1) ~= size(train_out,1)
    disp('ERROR: data mismatch')
   return 
end    

%standardise the data to mean=0 and standard deviation=1
%inputs
mu_inp = mean(train_inp);
sigma_inp = std(train_inp);
train_inp = (train_inp(:,:) - mu_inp(:,1)) / sigma_inp(:,1);

% %outputs
% train_out = train_out';
% mu_out = mean(train_out);
% sigma_out = std(train_out);
% train_out = (train_out(:,:) - mu_out(:,1)) / sigma_out(:,1);
% train_out = train_out';

%read how many patterns (# of training dataset)
num_train = size(train_inp,1);

%add a bias as an input
bias = ones(num_train,1);
train_inp = [train_inp bias];

%---------- data loaded ------------

% ---------- set weights -----------------
weight_input_hidden = weight{1};
weight_hidden_output = weight{2};


%do a number of epochs
for iter = 1:epochs
    
    %get the learning rate from the slider
%     alr = get(hlr,'value');
    alr = alpha;
    blr = alr / 10;
    
    %loop through the training data, selecting randomly
    for j = 1:num_train
        
        %select a random 
        patnum = round((rand * num_train) + 0.5);
        if patnum > num_train
            patnum = num_train;
        elseif patnum < 1
            patnum = 1;    
        end
       
        %set the current pattern
        this_pat = train_inp(patnum,:);
        act = train_out(patnum,1);
        
        %calculate the current error for this pattern
        hval = (tanh(this_pat*weight_input_hidden))';
        pred = hval'*weight_hidden_output';
        error = pred - act;

        % adjust weight hidden - output
        delta_HO = error.*blr .*hval;

        weight_hidden_output = weight_hidden_output - delta_HO';

        % adjust the weights input - hidden
        delta_IH= alr.*error.*weight_hidden_output'.*(1-(hval.^2))*this_pat;
        
        weight_input_hidden = weight_input_hidden - delta_IH';
    end
    
    %plot overall network error at end of each epoch
    pred = weight_hidden_output*tanh(train_inp*weight_input_hidden)';
    error = pred' - train_out;
    delta_err=(sum(error.^2))^0.5;
    
    if delta_err < epsilon
        break;
    end
       
end  

weight{1}=weight_input_hidden ;
weight{2}=weight_hidden_output;


end