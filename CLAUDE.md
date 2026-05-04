# RL Research Notebook

This is a Quarto-based research notebook site about RL post-training for foundation models.

## Adding a paper review

When the user gives you a link to a paper (e.g. an arXiv URL) and asks you to add it:

1. **Fetch the paper** using WebFetch on the URL (for arXiv, use the abstract page, e.g. `https://arxiv.org/abs/...`).
2. **Pick a short filename** based on the paper's key contribution or method name (e.g. `grpo`, `dapo`, `reinforce-plus-plus`).
3. **Run `add-paper.sh`** to scaffold the file and update the index:
   ```
   bash add-paper.sh <filename> "<Title of the Paper>"
   ```
4. **Fill in the review** by editing `papers/<filename>.md` with:
   - **Authors** and **Link** fields
   - **Summary**: 3-5 sentence overview of the paper
   - **Key Ideas**: bullet points of main contributions/techniques
   - **Strengths**: what the paper does well
   - **Weaknesses**: limitations, open questions
   - **Relevance to Our Work**: how it connects to RL post-training research in this notebook (reference existing writeups where relevant)
5. Write the review from the perspective of an RL post-training researcher. Be opinionated. Connect ideas back to topics covered in the writeups/ directory.

## Project structure

- `index.md` — main page with links to all writeups, papers, and experiments
- `writeups/` — research notes, ideas, and explanations
- `papers/` — paper reviews
- `experiments/` — experiment logs
- `new.sh` — interactive script to create new writeups, experiments, or papers
- `add-paper.sh` — non-interactive script to scaffold a paper review and update the index
