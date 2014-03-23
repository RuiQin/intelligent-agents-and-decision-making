%this function has a probability pro return reward r, otherwise return 0
function reward = SBRD(r,pro)
generated_pro = rand;
if(generated_pro <= pro)
    reward = r;
else
    reward = 0;
end