[← back](../index.html){.back}

# What are the problems with self-distillation?

::: {.date}
April 4, 2026
:::

::: {.callout-note}
> See @kim2026does for a good summary. Also see @firth2026supervisionhorizon, @kirkby2026dense, @partridge_opsd_x_post, @song2026survey.  
:::



## The Quiet Failure Mode of Self-Distillation

Self-distillation — where a model teaches itself by conditioning one copy on privileged information (e.g., ground-truth solutions) and training the other to match — has been a hot post-training paradigm. SDPO, OPSD, and friends show impressive results: shorter responses, higher accuracy, rapid convergence. What's not to like?

Turns out, quite a lot — at least in some domains. Kim et al. (2026) [1] systematically document when and why self-distillation *degrades* reasoning, with performance drops of up to 40% on math benchmarks. And the failure modes go deeper than just accuracy numbers. For a broader survey of on-policy distillation methods and where they sit relative to SFT and RL, see Song & Zheng (2026) [5].

## The self-distillation objective

In self-distillation, the same model plays both student and teacher under different conditioning contexts. The student generates a sequence $y \sim \pi_\theta(\cdot \mid x)$. The teacher sees a richer context $c$ (e.g., the ground-truth solution) and produces $\pi_\theta^T(\cdot \mid x, c)$. Training minimizes the token-level KL divergence:

$$\mathcal{L}_{\text{SD}}(\theta) = \sum_t \text{KL}\Big[\pi_\theta(\cdot \mid x, y_{<t}) \;\|\; \text{sg}\big[\pi_\theta(\cdot \mid x, c, y_{<t})\big]\Big]$$

This looks clean. But there are at least four structural problems lurking inside.

## Problem 1: Epistemic verbalization suppression

Strong reasoning models (DeepSeek-R1, Qwen3 in thinking mode) pepper their chain-of-thought with uncertainty markers — "Wait," "Hmm," "let me check" — that look like noise but actually serve a functional role. These tokens signal that a reasoning path might be flawed, enabling the model to backtrack and explore alternatives. Kim et al. (2026) call this *epistemic verbalization* and formalize the information-theoretic mechanism behind its suppression.

They define the informativeness of the teacher's context as the conditional mutual information:

$$I(y; c \mid x) = H(y \mid x) - H(y \mid x, c)$$

When $I(y; c \mid x)$ is high — i.e., the teacher context substantially reduces uncertainty about the target — the teacher's reasoning traces become confident and stripped of epistemic markers. The student learns to imitate this confident style, but at inference time it doesn't have access to $c$. It's been trained to reason as if it knows things it doesn't.

The empirical results are stark. On DeepSeek-R1-Distill-Qwen-7B, SDPO with full solution conditioning ($c = s$) drops AIME24 accuracy by ~40% relative to the base model. Usage of epistemic tokens like "wait" drops by 60.8 counts relative to base, while GRPO *increases* it by 28.5. The model gets shorter and more confident — and worse.

## Problem 2: The teacher is off-policy for its own generations

This is the point Partridge makes in his thread [4] on why OPSD isn't a silver bullet, and that Firth [2] explores in depth as the *supervision horizon* problem. The standard self-distillation implementation minimizes token-level KL:

$$\mathbb{E}_{y \sim \pi_\theta(\cdot \mid x)}\left[\sum_{t=1}^T D_{\text{KL}}\big(\pi_\theta(\cdot \mid y_{<t}, x) \;\|\; \pi_\theta(\cdot \mid y_{<t}, x, c)\big)\right]$$

But this is *not* the same as minimizing the true sequence-level divergence $D_{\text{KL}}(\pi_\theta(\cdot \mid x) \| \pi_\theta(\cdot \mid x, c))$. The token-level estimator is on-policy for the student but *off-policy for the teacher*: the teacher is being force-fed the student's tokens, which may be wildly inconsistent with what the teacher would have generated. The original SDPO paper (Hübotter et al., 2026) acknowledges this bias in their appendix — the token-level estimator has lower variance than sample-based alternatives but remains biased at the sequence level because it doesn't account for how $y_t$ influences future states $y_{>t}$.

Partridge [4] walks through a concrete failure case. Suppose the student writes "the answer might be 3" when the correct answer is 7. At the token "3", the teacher receives high loss — good. But *after* that point, the teacher is stuck in an impossible state: it knows the answer is 7 but finds itself having said 3. The only coherent interpretation available to the teacher is that the "assistant" has adopted an ignorant or confused persona (cf. persona vectors, Anthropic 2025). The supervision signal after the divergence point may be actively harmful — the teacher is essentially teaching the student to play a character that doesn't know what it's doing.

@AEllisBloor observed empirical evidence for this: when using gold-standard demonstrations as privileged information, training sometimes collapsed into degenerate outputs. Before final collapse, the student produced outputs like `"[normal looking rollout]. This was a demonstration of an example answer"` — the teacher was predicting continuation tokens to reconcile the demonstration with the incorrect rollout rather than generating an EOS.

Firth [2] formalizes this as the *supervision horizon*: there's a finite window of tokens over which the teacher's signal remains useful. Beyond that horizon — as the student's trajectory diverges further from anything the teacher would produce — the teacher's predictions become uninformative or adversarial. This connects to the broader DAgger literature on compounding error in imitation learning, but with the twist that here teacher and student share weights, creating feedback dynamics that DAgger's analysis doesn't cover.

## Problem 3: The optimal mixture distribution is unknown

Even if you could perfectly minimize $\theta^* = \text{argmin}_\theta \; D_{\text{KL}}(\pi_\theta(\cdot \mid x) \| \pi_\theta(\cdot \mid x, c))$, it's not clear this gives you a good policy. There will always be some irreducible divergence between student and teacher — the student simply cannot match the teacher's distribution without access to $c$. So the divergence-minimizing policy is not the teacher's distribution, but some *mixture distribution*. As Partridge [4] puts it: "we would hope that this mixture distribution is doing something we like, but we have no such guarantees."

This is analogous to reward hacking in RL — the fundamental issue is that we don't know the shape of the optimal policy. OPSD gives you two potential benefits over RL (information density and generalizability), but the generalizability comes at a cost: you expose yourself to "OPSD mush" where the optimal mixture distribution is misaligned with what you're actually trying to achieve.

## Problem 4: Task coverage determines whether suppression helps or hurts

Kim et al. [1] identify two factors that modulate whether self-distillation succeeds:

**Information richness.** The richer the teacher's conditioning context, the more aggressively epistemic verbalization gets suppressed. Full solution conditioning ($c = s$) is worse than answer-only ($c = s_{\setminus \text{think}}$), which is worse than unguided generation.

**Task coverage.** When the training distribution is narrow (few problem types, repeated exposure), suppressing epistemic verbalization is actually fine — the model doesn't need to hedge on familiar problems. SDPO excels on Chemistry (6 problem types) and LiveCodeBench v6 (131 problems, repeated exposure). But as task diversity grows, suppression becomes catastrophic. OOD problems are precisely the ones where the model *needs* to express and process uncertainty. On DAPO-Math-17k (diverse math), even the largest dataset sizes show SDPO underperforming the base model on AIME24.

## The feedback loop

Things get worse with moving-target teachers (EMA updates). The model produces increasingly confident outputs → the updated teacher becomes even more confident → the next round of training suppresses even more epistemic verbalization. Even slow EMA rates (0.05) amplify this loop relative to a fixed teacher. Kim et al. interpret this as a self-reinforcing cycle: the training objective never penalizes epistemic suppression, so it accumulates silently.

## Dense + on-policy is necessary but not sufficient

The Baseten team (Kirkby & O'Neill, 2026) [3] provide a complementary perspective. Their experiments on constitutional alignment — using OPSD with a constitution as privileged context, training on BeaverTails safety data, and evaluating on BullshitBench — show that on-policy OPSD transfers principles to unseen domains where off-policy methods and sparse RL do not. Training on safety data alone, OPSD lifts Qwen3-4B to match Gemini 3 Pro on BullshitBench. This is encouraging: dense on-policy supervision *does* produce representations that generalize.

But it doesn't eliminate the structural problems above. The Baseten results are in a regime where task coverage is narrow and the privileged information is a constitution (relatively low $I(y; c \mid x)$ compared to full solutions). The Kim et al. results show that precisely when you scale up task diversity and information richness — i.e., the regime where you'd most want self-distillation to work — the failure modes bite hardest.

## Key takeaway

Correct answers aren't enough. *How* a model reasons — whether it maintains the capacity to express and act on uncertainty — matters as much as whether it gets the right answer. Self-distillation can silently strip away this capacity while the training loss looks great. The standard token-level KL objective conflates style transfer with information transfer, and you can't disentangle the two.
