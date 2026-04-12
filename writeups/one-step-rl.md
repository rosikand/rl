[← back](../index.html){.back}

# Idea: One-Step RLVR: What If Reinforcement Learning Only Needed One Gradient Step?

::: {.date}
April 12, 2026
:::

Note: see research proposal [slide deck](../images/onesteprl.pdf)

* Reinforcement learning with verifiable rewards, or **RLVR**, has become a key ingredient in post-training language models.

* It works especially well in domains like:

  * math
  * code
  * other settings where outputs can be automatically checked by a verifier

* But RLVR is expensive.

* Standard pipelines often require:

  * thousands of optimization steps
  * repeated rollout generation
  * long training runs over large clusters

* The default assumption is that this long iterative process is necessary.

* The core question of this proposal is:

  * **what if it is not?**

## Core idea

* **One-Shot RLVR** is based on a simple hypothesis:

  * if the update direction is already clear from the base model
  * and the target expert solution is nearby in parameter space
  * then most of RLVR’s many gradient steps may be unnecessary
* In that regime, RLVR may not be doing extended search.
* It may just be:

  * finding a direction early
  * then repeatedly walking along that same direction

## Key observations motivating the idea

* Recent work suggests RLVR training is often surprisingly linear.

* Across algorithms and model sizes:

  * weights move roughly along a straight path
  * log-probabilities follow a similar trend

* This suggests the optimization direction may not change much over training.

* Other work suggests pretrained models are surrounded by many nearby task-expert solutions in parameter space.

* These solutions appear to be:

  * dense
  * nearby
  * increasingly available at larger scales

* They are specialists rather than generalists, but they may still be close enough to reach with minimal movement.

* Put together, these observations suggest:

  * the destination may already be close
  * the direction may already be available from the start

* That leads to the main question:

  * **if the direction does not change and the expert is close, why take 1,000 steps when one may suffice?**

## The proposed shift

* Standard RLVR allocates compute to **depth**:

  * small rollout batches
  * many sequential gradient updates

* One-Shot RLVR allocates compute to **breadth**:

  * one very large rollout batch
  * one gradient estimate
  * one parameter update

* The idea is to spend compute estimating the **first step extremely well**, rather than repeatedly re-estimating similar steps over time.

## Method

* The method has four steps:

### 1. Sample a massive rollout batch from the base policy

* Start from the base model
* Sample a very large number of rollouts

  * roughly 10K to 50K trajectories
* Use relatively high temperature to increase coverage and diversity

### 2. Score rollouts with a verifier

* Use a binary verifier to label trajectories as correct or incorrect
* Examples:

  * exact answer match for math
  * unit tests for code
  * any automatic correctness signal in a verifiable environment

### 3. Compute one policy gradient step

* Use a GRPO-style normalized advantage signal
* Increase probability on better trajectories
* Decrease probability on worse ones
* Compute the gradient only once, at the base parameters

### 4. Line-search over step size

* The update direction may be good, but the correct step size is unknown

* A step that is too small wastes signal

* A step that is too large overshoots the useful region

* So instead of committing to one learning rate:

  * evaluate several candidate step sizes
  * choose the one that performs best on a held-out validation set

## Why this might work

* Standard RLVR may be wasting compute re-estimating the same direction over and over

* If the training trajectory is mostly linear, then later steps are not discovering new behavior

* They are mostly continuing along the direction already found near the beginning

* In that view, standard RLVR looks like:

  * estimate a noisy direction from a small batch
  * take a tiny step
  * repeat hundreds or thousands of times

* One-Shot RLVR instead says:

  * estimate the direction once using a huge batch
  * take the step immediately

* So the real tradeoff may be:

  * **rollout breadth vs. rollout depth**
  * not simply RL vs. no RL

## Overshoot and stability

* The main risk is overshooting

* A large update could move the model past the good region and into a worse one

* That is why line search is central

* We explicitly evaluate different update magnitudes and choose the best one

* Another useful free diagnostic is **entropy**

* If entropy collapses sharply as step size increases:

  * the update may be too aggressive
  * the model may be collapsing into a narrow and degenerate mode

* The expected pattern is:

  * small step: underpowered
  * medium step: best performance
  * huge step: overshoot

## How to test the hypothesis

* The cleanest experiment is to compare one-shot training with standard RLVR at fixed rollout budget

* Example:

  * **1 step × 50,000 rollouts**
  * versus
  * **1,000 steps × 50 rollouts**

* Both use the same total amount of rollout data

* The only difference is how that compute is allocated

* If one-shot RLVR matches or approaches the performance of standard RLVR, that would suggest much of the sequential training was unnecessary

## Useful diagnostics

### Cosine similarity to a real RL trajectory

* Run normal RLVR for a small number of steps
* Compare the resulting parameter displacement to the one-shot gradient direction
* High cosine similarity would suggest the one-shot step is tracking the same trajectory RL would have followed

### Cross-subset consistency

* Split the large rollout batch into multiple subsets
* Compute a gradient on each subset
* If the gradients align well, the estimated direction is stable

### Correct vs. incorrect decomposition

* Compute gradients from correct and incorrect rollouts separately
* These should be roughly anti-parallel
* If they are, that suggests the verifier signal is inducing a coherent update direction

## Relation to no-RL alternatives

* This proposal also connects to methods that skip RL entirely, such as:

  * rejection sampling plus SFT
  * DPO on correct/incorrect rollout pairs
  * direct probes or linear directions extracted from hidden states
  * training-free perturbation methods like RandOpt

* These baselines are useful because they test whether policy gradient machinery is even needed

* Still, One-Shot RLVR preserves something important:

  * it uses verifier-weighted on-policy trajectories directly
  * rather than reducing the problem entirely to imitation or preference learning

## Failure modes

* The method may fail when the base model pass rate is too low

* If the large rollout batch contains almost no correct examples:

  * there may be too little positive signal
  * the one-shot gradient may be weak or noisy

* Code may be harder than math because rewards are often sparser

* Very small models may also be poor candidates because:

  * nearby expert solutions may be less dense
  * the gradient estimate may be less stable

* Another risk is overfitting to the sampled batch rather than learning a robust generalizable direction

## Fallback outcome

* Even if exactly one step is too aggressive or too brittle, the idea may still hold in a softened form

* For example:

  * 5 to 10 large-batch steps may recover most of the benefit of 1,000 small-batch steps

* That would still be a meaningful simplification

* So the main scientific object is not just whether **k = 1** works

* It is the broader **Pareto frontier between batch size and number of steps**

## The broader claim

* The provocative takeaway is:

  * **RLVR’s compute may be mostly wasted**

* If:

  * pretrained models already sit near dense task-specialist solutions
  * RL trajectories are mostly linear

* then standard RLVR may be solving the wrong optimization problem

* It may be treating learning as a long sequential search problem

* when in reality the main challenge is just:

  * estimating the right first step

## Closing 

* The central message of One-Shot RLVR is simple:

  * maybe RL post-training does not need long training runs
  * maybe it just needs one very good gradient step
