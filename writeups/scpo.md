[← back](../index.html){.back}

# Idea: Toward Self-Critic Policy Optimization (SCPO) for RL Post-Training

::: {.date}
April 12, 2026
:::



RL post-training for language models has recently converged on a simple and effective pattern: sample rollouts, score them with a verifier, and optimize the policy online. This recipe has worked especially well in domains like math and code, where final answers can be checked automatically. In practice, GRPO-style methods have become a strong default because they avoid the instability and engineering overhead of explicit critics, value functions, and reward models.

But this simplicity comes with a cost.

In verifier-based RL, the learning signal is often just a binary outcome: the answer passed or it did not. That signal can be enough to make progress, but it also throws away a huge amount of structure. It ignores intermediate reasoning quality, discards rich environment feedback, and can collapse entirely when all sampled rollouts in a group either succeed or fail. In those cases, there is little or no gradient signal left to learn from.

At the same time, a new line of work on self-distillation has shown that a policy can often improve itself by taking a second pass with privileged context, such as verifier outcomes or environment feedback. These methods are exciting because they can turn sparse supervision into richer learning signals without requiring an external process reward model. But they also have limitations. Most importantly, they frame the privileged second pass as something the model should imitate.

That framing may be too restrictive.

## The core idea

My proposal is to use self-distillation as **evaluation**, not **imitation**.

Instead of asking the policy to mimic a privileged self-teacher, we can ask the privileged pass to produce a better reward-like or critic-like signal for policy optimization. The second pass should not be treated as a target trajectory to copy. It should be treated as a mechanism for scoring, diagnosing, or valuing the original rollout more intelligently than a binary verifier alone can.

This leads to a simple guiding question:

**How do we turn verifier outcomes and privileged feedback into a robust online reward signal for policy optimization?**

That is the central problem.

## Why the current setup is unsatisfying

Verifier-only RL has several obvious weaknesses.

First, binary rewards are extremely sparse. A full reasoning trace may be nearly correct, yet receive the same reward as a completely nonsensical one. Second, the verifier usually compresses everything down to one bit, which means almost all useful information is discarded. Third, group-relative methods can lose signal entirely when every rollout in a batch gets the same score. And fourth, any rich feedback from the environment, such as compiler errors, failed unit tests, traceback information, or structured hints, is typically ignored.

Self-distillation methods help with some of this by injecting privileged information into a second pass. But they introduce their own problems.

A self-teacher can be wrong. Reverse-KL-style imitation can reduce diversity and concentrate the policy on a narrower set of modes. That may suppress exploration and reduce the chance of discovering genuinely new reasoning strategies. More broadly, forcing a student to imitate a teacher is not obviously the right abstraction for reasoning. In many settings, we do not want the model to copy a privileged solution; we want it to think better on its own.

A useful analogy is a student taking a math exam. After receiving feedback, the student should use that evaluation to improve, not merely memorize a teacher’s answer path. The goal is stronger reasoning, not better imitation.

## What a better method should do

An ideal method would satisfy several desiderata.

It should remain online and adapt as the policy changes, rather than relying on a static reward model that can drift out of sync. It should exploit verifier information and any available environment feedback. It should preserve or even improve diversity rather than collapsing onto a single mode. It should not suppress emergent reasoning. And it should fit naturally into standard RL post-training pipelines for math and code.

More concretely, I want a method that is:

* online and preferably on-policy
* richer than a binary verifier reward
* compatible with existing RLVR workflows
* resistant to reward hacking and collapse
* capable of supporting long-horizon reasoning
* potentially scalable with additional compute or larger policy models

## A possible direction: self-critic policy optimization

One natural direction is what I would call **Self-Critic Policy Optimization**.

The high-level idea is simple. Given a sampled rollout, run a privileged second pass that has access to the verifier outcome and possibly extra environment feedback. But instead of using that pass to generate a target to imitate, use it to estimate a scalar or structured evaluative signal for the original rollout. Then feed that signal back into the policy optimization objective.

There are several ways this could be instantiated.

### 1. Add a small reward or value head to the policy

One option is to attach a lightweight head to the policy backbone. During the privileged pass, this head consumes hidden states from the rollout together with verifier-side context and outputs a better reward estimate. That estimate can then replace or augment the raw binary verifier signal inside a GRPO-style objective.

This is appealing because it keeps everything tightly coupled and online. The evaluative signal evolves with the policy, which may reduce drift relative to a separate static reward model.

### 2. Derive the signal without adding new parameters

Another option is to avoid adding explicit heads at all. The privileged pass could still produce a reward-like or advantage-like signal through some operator over internal states or distributions. For example, one could imagine computing a score from hidden-state geometry, teacher-student divergence, or some learned but parameter-efficient transformation.

This direction is attractive if the goal is to preserve the simplicity of critic-free RL while still recovering richer supervision.

### 3. Use the model itself as a judge in the privileged pass

A third possibility is to explicitly prompt the privileged pass to evaluate the rollout and produce a scalar or rubric-style judgment in natural language or structured form. This would treat the self-teacher as an LLM judge, but crucially the output would be used as an evaluative signal for RL, not as a target reasoning trace to imitate.

### 4. Learn a separate critic or reward model online

A more classical alternative is to introduce a distinct critic or reward model, but train it online using rollout data and verifier feedback. This is less elegant, but it may still be the right design if richer evaluation truly requires separate capacity. The important point is that the auxiliary model should evolve with the policy instead of remaining fixed.

## Why this is different from “just add a critic”

The weak version of this idea is simply: attach a value head to GRPO.

That alone is not very interesting. It imports standard actor-critic machinery into a setting that was explicitly designed to avoid it, without addressing the deeper question of where useful intermediate supervision should come from.

The stronger version is more specific:

* the privileged second pass has access to verifier outcomes and environment feedback
* the second pass is used to construct a better evaluative signal
* the policy is not trained to imitate the privileged pass
* the goal is to recover the benefits of dense or informed supervision without incurring the usual imitation and mode-collapse issues of self-distillation

That is a more novel framing. It treats self-distillation as a route to online reward construction rather than trajectory imitation.

## Key research questions

A number of research questions fall out of this framing.

The first is granularity: what level of supervision is actually best? Full token-level signals may be too constraining, while final outcome-only rewards are too sparse. Perhaps the best answer lies somewhere in between.

The second is parameterization: should the evaluative mechanism live inside the policy, alongside the policy, or emerge from a parameter-free operator? Each choice has different tradeoffs in stability, expressivity, and engineering cost.

The third is exploration. If the evaluative signal becomes too sharp, does it reduce diversity and hurt pass@k even as pass@1 improves? Or can it actually improve both by giving the policy more informative gradients?

The fourth is long-horizon reasoning. Sparse verifier rewards become especially problematic when solving difficult problems over long trajectories. Could a self-critic framework help here by assigning meaningful value to partially successful reasoning before the final answer is known?

The fifth is robustness. If the privileged pass itself becomes stronger over training, perhaps the resulting evaluative signal improves over time as well. But that also raises the possibility of reward hacking or self-reinforcing errors. Understanding calibration and failure modes will be essential.

## Benchmarks and domains

This idea is most naturally suited to verifier-rich domains such as math and code. Initial experiments could focus on benchmarks like GSM8K, MBPP or MBPP+, and LiveCodeBench-style settings. These domains offer a useful testbed because they expose both binary outcomes and richer structured feedback, such as failed tests or execution traces.

Longer term, it would be interesting to ask whether the same framework can be extended beyond fully verifiable domains. There, recent work on learned rewards, inverse RL, and adversarial imitation may become relevant.

## A broader perspective

One way to view this project is as an attempt to unify several threads:

* verifier-based RL, which is simple but sparse
* self-distillation, which is rich but often imitation-centric
* reward modeling and critics, which are expressive but can drift or destabilize training

The hope is to get the best of all three. Use the verifier as ground truth where possible. Use the privileged second pass to extract more information from each rollout. And use that information to shape policy optimization directly, without requiring the policy to copy the teacher’s trajectory.

If that works, it could offer a cleaner path toward robust online RL for reasoning models: more informative than verifier-only RL, less collapse-prone than imitation-heavy self-distillation, and lighter-weight than maintaining a fully separate reward-modeling stack.

## Closing thought

The main conceptual shift here is small but important.

Self-distillation does not have to mean “generate a better trace and imitate it.” It can also mean “use privileged context to evaluate a trace better.” In verifier-based RL for language models, that distinction may matter a lot.

What I want is not a better teacher to copy. I want a better signal to optimize.


