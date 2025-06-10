
# LabelGenius

LabelGenius is a Python package designed for zero‑shot and fine‑tuned classification tasks using CLIP and GPT models. It offers seamless integration with OpenAI models for text‑ and image‑based classification, fine‑tuning, and price estimation.

---

## Installation

Install the latest release from PyPI:

```bash
pip install LabelGenius==0.1.0
```

—or install the development version from source:

```bash
git clone https://github.com/mediaccs/LabelGenius
cd LabelGenius
pip install -e .
```

---

## Modules & Functions

### 1. CLIP‑based Classification

| Function | Purpose |
|----------|---------|
| `classification_CLIP_0_shot` | Perform zero‑shot classification with CLIP |
| `classification_CLIP_finetuned` | Use a fine‑tuned CLIP model for classification |
| `finetune_CLIP` | Fine‑tune CLIP on your dataset |

### 2. GPT‑based Classification

| Function | Purpose |
|----------|---------|
| `classification_GPT` | Perform text classification with GPT (zero‑shot or few‑shot) |
| `generate_GPT_finetune_jsonl` | Prepare JSONL files for GPT fine‑tuning |
| `finetune_GPT` | Fine‑tune a GPT model on your labelled data |

### 3. Utility Functions

| Function | Purpose |
|----------|---------|
| `price_estimation` | Estimate the cost of OpenAI API calls |

---

## Usage Examples

### Zero‑Shot Classification with CLIP

```python
from labelgenius import classification_CLIP_0_shot

D1c_CLIP_inital_labeling = classification_CLIP_0_shot(
    text_path="Demo_data/D1_1.csv",
    img_dir="Demo_data/D1_imgs_1",
    mode="both",
    prompt=prompt_D1_CLIP,
    text_column=["headline", "abstract"],
    predict_column="D1c_CLIP_inital_labeling",
)

```

### Zero‑Shot Classification with GPT

```python
from labelgenius import classification_GPT

D1c_GPT_4o_inital_lableing = classification_GPT(
    text_path="Demo_data/D1_1.csv",
    image_dir="Demo_data/D1_imgs_1",
    category=category_D1_GPT,
    prompt=prompt_D1_GPT,
    column_4_labeling=["headline", "article", "abstract"],
    model = "gpt-4o-mini",
    api_key = api_key,
    temperature = 1,
    mode = "both",
    output_column_name="D1c_GPT_4o_inital_lableing",
    num_themes = 1,
    num_votes = 1)


```

### Fine‑Tune CLIP Model

```python
from labelgenius import finetune_CLIP, classification_CLIP_finetuned

finetune_CLIP(
    mode="both",
    text_path="Demo_data/D1_1.csv",
    text_column=["headline", "abstract"],
    img_dir="Demo_data/D1_imgs_1",
    true_label="section_numeric",
    model_name="Demo_finetuned_CLIP/D1c_CLIP_model_finetuned.pth",
    num_epochs=20,
    batch_size=8,
    learning_rate=1e-5,
)

D1c_CLIP_finetuned = classification_CLIP_finetuned(
    mode="both",
    text_path="Demo_data/D1_2.csv",
    text_column=["headline", "abstract"],
    img_dir="Demo_data/D1_imgs_2",
    model_name="Demo_finetuned_CLIP/D1c_CLIP_model_finetuned.pth",
    predict_column="D1c_CLIP_finetuned",
    
)
D1c_CLIP_finetuned.to_csv("Demo_result/D1c_CLIP_finetuned.csv", index=False)

```

### Fine‑Tune GPT Model (text-only)

```python
from labelgenius import generate_GPT_finetune_jsonl, finetune_GPT

generate_GPT_finetune_jsonl(
    D1a_GPT_4o_inital_lableing,
    output_path="Demo_result/D1a_GPT_4o_inital_lableing.jsonl",
    system_prompt=prompt_D1_GPT,
    input_col=["headline", "article", "abstract"],
    label_col=["section_numeric"]
)

D1a_GPT_4o_model_finetune = finetune_GPT(
    training_file_path="Demo_result/D1a_GPT_4o_inital_lableing.jsonl",
    model="gpt-4o-mini-2024-07-18",  
    hyperparameters={"batch_size":8, "learning_rate_multiplier":0.01},
    api_key= api_key  
)

```


---

## Demos

Complete, runnable notebooks that walk through CLIP and GPT workflows—from data preparation to fine‑tuning—are provided in the **DEMO/** directory. Open the files in Jupyter or VS Code and run each cell to reproduce the results.

---

## Contributing

We welcome contributions! Feel free to open an issue for bugs or feature requests, or submit a pull request to improve the codebase and documentation.

---

## License

LabelGenius is released under the MIT License.
