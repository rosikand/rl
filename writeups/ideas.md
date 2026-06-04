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


## Environment-time/verifier-time compute/modulation 

Lots of work has been done on scaling compute (either at train or test time) but what if we scale compute spent on the environment itself or the verifier/reward model? For example, say we had a reward model. Perhaps do CoT or best-of-N on the reward model pass itself. 

The bigger picture here is whether this can lead to a "reward model scaling law" of some sorts. If we increase the compute spend on the reward model pass or in the environment, does the policy get better as a direct result? 


Another angle for environment time compute is to use it as a source of modulation/cirriculum design: for example, if the environment recognizes the policy almost got it right, then it can give less feedback/hints and amplify its difficulty on the next rollout. Somewhat like an auto-cirriculum of sorts. The key here is that this is how a student-tutor pairing works in real life: tutor might offer hints if the student is no where close and might increase problem difficulty if they are. 

An even more interesting angle is whether the policy can play student and tutor itself. And do the environment compute modulation itself. See Bailey 2026 for some inspiration. 









