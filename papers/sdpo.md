[← back](../index.html){.back}

# Reinforcement Learning via Self-Distillation

::: {.date}
April 21, 2026
:::

**Authors:** Jonas Hübotter, Frederike Lübeck, Lejs Behric, Anton Baumann, Marco Bagatella, Daniel Marta, Ido Hakimi, Idan Shenfeld, Thomas Kleine Buening, Carlos Guestrin, Andreas Krause

**Link:** [arXiv:2601.20802](https://arxiv.org/abs/2601.20802)

## Summary

Current RL post-training methods like GRPO learn only from a scalar outcome reward per attempt, which throws away the rich feedback that verifiable environments (code interpreters, math checkers) naturally produce. This paper introduces Self-Distillation Policy Optimization (SDPO), which uses that textual feedback — runtime errors, test failures, etc. — as a dense learning signal. The key mechanism: condition the current policy on the feedback to produce a "corrected" second pass, then distill that corrected distribution back into the unconditional policy via KL minimization. No external reward model or teacher needed. They show improvements in sample efficiency and accuracy across scientific reasoning, tool use, and competitive programming, including 3x faster discovery of solutions on hard tasks.

## Key Ideas

- **Rich feedback as free signal**: verifiable environments already produce structured textual feedback (stack traces, test outputs, checker messages). Current RL methods ignore this and collapse everything to a scalar. SDPO exploits it.
- **Self-distillation mechanism**: the policy is run a second time conditioned on the feedback. This privileged second pass can retrospectively identify errors and produce better token-level predictions. The unconditional policy is then trained to match this corrected distribution.
- **KL distillation instead of imitation**: rather than imitating the self-teacher's trajectories directly (behavioral cloning), they minimize the KL divergence between the corrected and uncorrected policy distributions. This gives a denser, token-level gradient signal.
- **No external teacher**: the model is both student and teacher — the "teacher" is just the same model with access to feedback context.

## Strengths

- Elegant use of information that is already available but wasted by existing methods. Zero additional infrastructure needed beyond what GRPO already requires.
- The self-distillation framing is clean: it avoids the overhead of training a separate process reward model while still getting denser-than-outcome-level signal.
- Strong empirical results on sample efficiency — important for practical RL post-training where rollouts are expensive.
- The 3x speedup on hard problems is significant. Hard problems are exactly where GRPO-style methods struggle (all-fail groups → zero advantage).

## Weaknesses

- The self-teacher quality is bounded by the policy's own ability to correct given feedback. Early in training when the model is weak, the corrected pass may not be much better — bootstrapping could be slow.
- Distillation toward the self-teacher can be conservative: if the corrected pass is only marginally better, you're pulling the policy toward a mediocre target. There's a risk of mode collapse toward "safe" corrections.
- The framing treats the privileged pass as something to *imitate* (match the distribution). This is exactly the limitation identified in our SCPO work — imitation may be less effective than using the privileged pass as an *evaluator*.
- Evaluation domains are verifiable-only. Unclear how this extends to domains where feedback is less structured.

## Relevance to Our Work

This paper is the most direct comparison point for [SCPO](../writeups/scpo.html). Both papers start from the same observation: self-distillation with privileged feedback can produce richer signals than scalar rewards. But they make different design choices about what to do with the privileged pass:

- **SDPO**: use the privileged pass as a *teacher* — distill its distribution into the policy (imitation).
- **SCPO**: use the privileged pass as a *critic* — let it score/evaluate the original rollout to produce better advantages for policy optimization (evaluation).

The SCPO writeup explicitly argues that framing self-distillation as evaluation rather than imitation is less restrictive and avoids pulling the policy toward a potentially mediocre self-teacher. SDPO's results validate that rich feedback helps, but its distillation approach is exactly the ceiling that SCPO aims to break through. This paper is strong motivation for why SCPO's critic-based approach could be a meaningful next step.


