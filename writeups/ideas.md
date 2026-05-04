[← back](../index.html){.back}

# Laundry list of ideas 

Here is an annotated laundry list of ideas I have in my backlog for developing RL algorithms and running experiments. 

... 


## Post-training under infinite compute 

Parallel to the pre-training under infinite compute paper. 


What can the base model, in principle, reach with infinite compute. Is the ceiling is still set by the base model's prior? And how does true search and exploration tie into this? 


## AlphaZero-style search 

How can we enable true search and exploration (RLVR is just reinforcing sampling from a base model) in LLM's. 

The deeper issue is that the action space is enormous (vocab size, ~150K for modern tokenizers) and the horizon is long (hundreds to thousands of tokens), so the combinatorial trajectory space is astronomical. Classical exploration methods that work in gridworlds or even Atari don't transfer cleanly: you can't do count-based bonuses over trajectories because you'll never see the same trajectory twice, and per-token UCB is noisy and probably misaligned with what you actually want (which is diversity at the level of reasoning structure, not token choice). 

the tree expansion is decoupled from the sampling distribution. 

need way to find solutions the base model wouldn't sample greedily. 

In LLM-land, "true search" would mean something analogous: a procedure that explores trajectory space in a way not directly sampled from π_θ, evaluates the results, and uses that signal to update the policy.


Note to self: good experiment testbed here is using the Countdown dataset (action space is smaller) and a small llm (perhaps nanochat RL'd?). 

Policy methods are good at moving the model’s distribution toward trajectories that worked.
Value/search methods are good at deciding which partial trajectories are worth expanding.
The frontier for LLM reasoning is probably thus hybrid: 

> policy generates, verifier scores, value estimates guide partial search, and RL distills successful search back into the policy.