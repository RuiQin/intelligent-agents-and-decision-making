function [nn, L]  = nntrain(nn, feat, delta_err)
%NNTRAIN trains a neural net
% [nn, L] = nnff(nn, x, y, opts) trains the neural network nn with input x and
% output y for opts.numepochs epochs, with minibatches of size
% opts.batchsize. Returns a neural network nn with updated activations,
% errors, weights and biases, (nn.a, nn.e, nn.W, nn.b) and L, the sum
% squared error for each training minibatch.
assert(isfloat(feat), 'train_x must be a float');
% feat=feat/norm(feat);
loss.train.e               = [];
loss.train.e_frac          = [];
loss.val.e                 = [];
loss.val.e_frac            = [];
opts.validation = 0;
% if nargin == 6
%     opts.validation = 1;
% end
% 
% fhandle = [];
% if isfield(opts,'plot') && opts.plot == 1
%     fhandle = figure();
% end

m = size(feat, 1);

loss.train.e               = [];
loss.train.e_frac          = [];
loss.val.e                 = [];
loss.val.e_frac            = [];

batchsize = 100;%opts.batchsize;
numepochs = 1e4;%opts.numepochs;

numbatches = floor(m / batchsize);

assert(rem(numbatches, 1) == 0, 'numbatches must be a integer');

n = 1;
L=zeros(numepochs,1);
for i = 1 : numepochs
    if nn.epoch>1&&i==1
        loss = nneval(nn, loss, feat, delta_err);
        epo_err = loss.train.e(end);
        if epo_err < 1e-5
            break;
        end
    end
    kk = randperm(m);
    for l=1:numbatches
        batch_x = feat(kk((l - 1) * batchsize + 1 : l * batchsize), :);

        batch_y = delta_err(kk((l - 1) * batchsize + 1 : l * batchsize), :);

        nn = nnff(nn, batch_x, batch_y);
        nn = nnbp(nn);
        nn = nnapplygrads(nn);
        L(n)=nn.L;
        n = n + 1;
    end
    loss = nneval(nn, loss, feat, delta_err);
    epo_err = loss.train.e(end);
    if epo_err < 1e-5
        break;
    end
    if i==1
        last_err=epo_err;
        bk_nn=nn;
    else
        if epo_err/last_err>1.04
            nn=bk_nn;
        else
            bk_nn=nn;
            last_err=epo_err;
        end
    end
    
    nn.learningRate = nn.learningRate * nn.scaling_learningRate;
end

nn.epoch=nn.epoch+1;
    

end

