function q_val = nnpredict(nn, x)
%     x=x/norm(x);
    nn.testing = 1;
    nn = nnff(nn, x, zeros(size(x,1), nn.size(end)));
    nn.testing = 0;
    
    q_val=nn.a{nn.n};
end
