[← back](../index.html){.back}

# The rl data and fine-tuning market

::: {.date}
April 13, 2026
:::

*Note: will update more of this note soon and I may also move it to a blog post on my personal website instead since this isn't exactly a "research" topic*  

This will be a periodically updated note which contains some thoughts, analysis, and information on the RL market. 

While it is fun to think about research ideas in RL, the method itself has had and will continue to have enormous economic impact. As such, in this note, we'll try to make an understanding of all of this. 


At a high level, here is what is happening: 

- LLM's cannot solve tasks that [aren't in the support set](../writeups/support-leash.html) of the base model
- Thus, you need some expert demonstrations or trajectories to inject into the model 
- Then, you need to define an RL environment from which you can optimize the base model/policy in with RL. 
- Finally, once you've injected the task into the base model support and defined your environment, you optimize your policy with RL. This in it of itself is a very challenging task for most engineering teams. You need principled research methods, lots of compute budget, and an async rl infra setup (this one is perhaps the biggest key but also the hardest to build out). All of which are a challenge for the vast majority of startups.



## Consequences and implications 


This have several consequences and implications for what is happening. I denote some of them here and dedicate a subsection to a few of them. 

### Proprietary fine-tuned model as the moat

...

### Knowledge workers become AI teachers

...


### Increase in RL environment makers, RL-as-a-service fine-tuning shops, and data marketplaces

...


### Products as a vehicle for data collection


...


### Tech companies turn from product to consulting

...


### The only moats that exist are data and distribution

...


## Business strategies


### RL-as-a-Service 

This industry deserves its own section because of the enormous impact it can have and its relevance in the modern AI landscape. 


Target customers: 

There are two ends of the spectrum: 

- Domain, high end engineering teams (e.g., AC <--> Cognition)
- Non-domain teams (e.g., a hypothetical would a RLaaS consultancy forward deploying engineers in a non-tech firm)

### Product based offerings 

Examples: 

- Tinker
- Prime Intellect 


These are traditional tech startup offerings: no forward-deployed/consultancy. Just pure, scale-able product. They make a product and sell it to end customers. Nothing fancy here. 



### Data marketplaces 

- Mercor

These are firms which recruit experts to generate and label data for the labs. They act as a middle man between the expert and the ai research lab. They pay the experts and the ai research lab pays them. 


### Data brokers 

- Protege AI 

These are firms that simply connect the buyers and the sellers. That is, they connect the startups trying to sell data to the labs, with research members from the lab. 


## Mapping the landscape 

Here are a few players who operate in this space. 

### RL-as-a-Service 

- Applied Compute 
- OpenAI FDE arm 
- Anthropic Applied AI 
- Trajectory 
- AfterQuery 
- Fleet 
- Thoughtful  
- Thinking Machines Lab 
- Prime Intellect 


The last two seemingly operate as a product whereas the remaining ones seemingly operate as a consultancy.  


### Data collection marketplaces 


- Mercor
- Scale 
- Surge 
- Handshake 


## Some questions I have 


- If the research labs themselves recruit experts, does that eliminate the need for middlemen like surge and mercor? 
- In the RLaaS market, I see two problems with the two ends of the spectrum of customers:
	- Non-technical teams: forward deploying becomes more difficult. Unlikely to benefit. 
	- Technical teams: should theoretically have the talent to train RL models in house. 
- What is the size of the RLaaS market?
- What are the margins of RLaaS players and how can this be made more efficiently? 

