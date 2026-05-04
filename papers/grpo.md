[← back](../index.html){.back}

# DeepSeekMath: Pushing the Limits of Mathematical Reasoning in Open Language Models

::: {.date}
April 21, 2026
:::

**Authors:** Zhihong Shao, Peiyi Wang, Qihao Zhu, Runxin Xu, Junxiao Song, Mingchuan Zhang, Y.K. Li, Y. Wu, Daya Guo

**Link:** [arXiv:2402.03300](https://arxiv.org/abs/2402.03300)

## Summary

Introduces Group Relative Policy Optimization (GRPO), a variant of PPO that removes the need for a learned critic/value function. Instead of estimating advantages with a value network, GRPO samples a group of outputs for each prompt and computes advantages relative to the group's mean reward. This simplifies the RL pipeline significantly while achieving strong results on mathematical reasoning benchmarks. DeepSeekMath 7B achieves competitive performance with much larger models.

## Key Ideas

- **Group-based advantage estimation**: for each prompt, sample $G$ completions, score them, and normalize rewards within the group to get advantages. No value function needed.
- **Variance reduction via grouping**: the group normalization acts as a built-in baseline, similar in spirit to REINFORCE with baseline but without learning the baseline.
- Combines RL with large-scale math pretraining (120B math tokens) — both the data and the RL matter.
- Shows that online RL (GRPO) outperforms rejection sampling and offline methods like DPO on math tasks.

## Strengths

- Dramatically simplifies the RL stack — no critic network, no GAE, fewer hyperparameters.
- Clean ablation showing GRPO > RFT > DPO for math reasoning.
- Practical and reproducible: the method is simple enough that many groups have re-implemented it.

## Weaknesses

- Group advantage goes to zero when all samples in a group succeed or all fail — no learning signal in those cases. This is a fundamental limitation for easy or very hard problems.
- The paper doesn't deeply explore failure modes or when GRPO breaks down relative to PPO with a learned critic.
- Evaluation is math-heavy; unclear how well this transfers to less verifiable domains.

## Relevance to Our Work

This is the baseline method for most RL post-training work right now. GRPO's simplicity is its strength but also its ceiling — the zero-advantage problem when groups are homogeneous is exactly what motivates richer reward signals (e.g., SCPO's self-critic approach). Understanding GRPO's limitations is key to knowing where to push next.
