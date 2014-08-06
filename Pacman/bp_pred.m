function [ q_val] = bp_pred( feat,weight )

w_inp_hidden=weight{1};
w_hidden_out=weight{2};

feat = feat(2:end)';
mu_inp = mean(feat);
sigma_inp = std(feat);
feat = (feat(:,:) - mu_inp(:,1)) / sigma_inp(:,1);
feat = [feat 1];
q_val = w_hidden_out*tanh(feat*w_inp_hidden)';

end

