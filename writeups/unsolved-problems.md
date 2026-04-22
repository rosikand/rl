[← back](../index.html){.back}

# Problems not yet solved

::: {.date}
April 12, 2026
:::


Having combed through lots of the modern RL post-training literature, I began to sit and wonder... with all of these papers coming out, what are problems that aren't solved yet? It seems like every week there is a new policy optimization method, claiming to be slightly better than GRPO. But what else is there left to do? 

I personally take the position that reward shaping and reward design is a huge component. Not just how you optimize the policy, but figuring out what to optimize for. How you specify your reward is how you tweek the behavior of your policy. Optimization developments just give you a more efficient way of getting you there.

With that being said, a couple thoughts: 
 

## Continual learning 

This is the obvious one and the number of people interested in this problem is not lacking. This problem perhaps represents the greatest real world impact if solved. Agents are being deployed in enterprises, but the environment of each enterprise constantly evolves. So ideally you need to respond to changes in the environment with changes to your policy. And how exactly you do this is what this problem space aims to think about. The naive approach which many seem to be doing is to do periodic updates: gather the new data from the environment and fine-tune your policy. This does work for a lot of cases, but its a hacky solution. Ideally, you want something more principled. Thankfully, the classical RL folks have been studying this paradigm for a long time and mathematically, people call it *lifelong learning*. 


## Long-horizon reward design 

Agents can now think for long periods of time, on the order of days for hard problems. This is a different regime altogether than the types of problems we were trying to solve 2-3 years back. So it begs the question: is standard reward design and policy optimization still efficient in this domain? Thus, research needs to be done on designing rewards and learning signals for long-horizon reasoning, treating the long-horizon aspect as a first class citizen. Perhaps the reward design you'd do in the short-horizon scenarios is less optimal when scaled to a longer horizon. 



## True search and exploration 


The classical RL guys (the Sutton clan) have been studying search, the explore-exploit paradigm in RL for many decades. But the recent language model folks use RL merely as a sampling tool. That is, they use GRPO/RLVR as a means to better sample from an underlying base model. A happy marriage between the two would be a good step forward. How can we induce more "search"/explore style paradigms in RL post-training of LLM's? 

In RLVR land today, the core mechanism is sampling + reweighting, not search. GRPO and its variants sample rollouts from the current policy, score them with a verifier, and upweight good ones / downweight bad ones. The Invisible Leash paper @wu2025invisible formalizes this precisely: RLVR is a support-constrained optimizer. It can only move probability mass onto completions the base model already assigns non-negligible probability to. However, there is one caveat worth noting: what RL can do is induce compositional reassembly of subskills the base model already possesses individually but hasn't composed correctly.


## The never ending experiment: adding to the support set of the base model through environment reaction 


Right now, language models cannot sample solutions that don't exist in the base models' support set. Meaning, RLVR just learns an operation to center mass on the support that contains the solution to the task (i.e., sharpens the distribution) such that the model samples that solution specifically/more frequently. That implies two things: (1) RL is being used an elaborate sampling mechanism and (2) a model fundamentally cannot solve a problem if it cannot sample the solution. Thus, people have been coming up with concepts like mid-training and continued pre-training (CTP) as mechanisms for injecting more solution sets to the support of the model and then hill climbing on some task to sharpen the distribution to enable sampling the solutions. This is fine and works well. But what if there was a way add information to the support set on the fly, during online training? This would theoretically enable models to hill climb on more tasks and potentially avoid the whole mid-training and CTP saga. 

One angle for thinking about this is learning during online environment interaction. The environment can provide external information beyond just a reward. For example, in coding environments, feedback in the form of a stack trace is often provided. In biology and wet lab experiments, data can be gathered from analyzing the result of an experiment. Each unit of information that the environment provides is something that expand the base model support. 



## Stale and off-policy reasoning 

In the real world, you cannot just think about theoretical properties. You also need practicality and as such, lots of engineering effort has been focused on making RL more efficient due to things like compute constraints and budgets.

How can we develop methods that better scale with stale data and off-policyness? See OAPL for a good example of this. 


## Robotics: long-horizon reward modeling for robotic manipulation 

Unrelated to post-training LLM's but a lot of the same problems are now occurring in robotic manipulation land as well. Particularly, as models like VLA's get larger and larger, their expressiveness increases. This enables them to do longer horizon tasks. In addition, another framing is how can we elicit long horizon behavior out of VLA's when designing reward signals. SARM is an interesting direction here. 


