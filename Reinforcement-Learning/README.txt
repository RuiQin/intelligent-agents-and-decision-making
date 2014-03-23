The main entrance file is mdp_parking_demo.m, it has two sets of parameters: the weekday and weekend, with different spot occupied probability, mdp_parking.m is to generate the transition matrix and reward vector. demo will run three experiment:

1. Simulate the agent using the three policies: 
   policy_simulator.m
   
2. Use Q-learning to get a policy:  
   mdp_Q_learning

3. Compare policy 2, 3 and policy got from reinforcement learning: 
   policy_simulator.m, RL_simulator.m