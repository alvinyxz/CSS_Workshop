import os
import torch
import torch.nn.functional as F
import pandas as pd
import numpy as np
from transformers import CLIPProcessor, CLIPModel
from PIL import Image
from tqdm import tqdm
from sklearn.metrics import classification_report
import pandas as pd
from torch.utils.data import Dataset, DataLoader
from torch.optim import AdamW
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    confusion_matrix,
    classification_report
)

####################################
############### CLIP ###############
####################################

# Set device
os.environ["TOKENIZERS_PARALLELISM"] = "false"


device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")
base_model = "openai/clip-vit-base-patch32"

def classification_CLIP_0_shot(
    text_path,
    img_dir=None,
    mode= None,
    prompt=None,
    text_column=["headline"],
    predict_column="label",
):
    """
    Perform zero-shot classification using the CLIP model and predefined prompt

    Parameters:
        text_path: Path to the data file (supports .csv/.txt/.jsonl/.xlsx/.xls)
        img_dir: Path to the image directory (required only when mode includes "image")
        mode: Modality to use
            - "text": text only
            - "image": image only
            - "both": text + image
        prompt: List of category prompt
        text_column: List of text column names (used only when use_text=True)
        predict_column: Name of the column to store prediction results

    Returns:
        DataFrame: DataFrame with a prediction column
    """
    # Parameter validation
    if mode not in ["text", "image", "both"]:
        raise ValueError("mode must be 'text', 'image', or 'both'")
    if prompt is None:
        prompt = prompt_D1_CLIP

    use_text  = mode in ["text", "both"]
    use_image = mode in ["image", "both"]

    if use_text and not text_path:
        raise ValueError("text_path cannot be empty")
    if use_image and not img_dir:
        raise ValueError("img_dir cannot be empty")

    # Load CLIP
    model     = CLIPModel.from_pretrained(base_model).to(device)
    processor = CLIPProcessor.from_pretrained(base_model)

    # Read data
    if text_path.endswith(".csv") or text_path.endswith(".txt"):
        df = pd.read_csv(text_path)
    elif text_path.endswith(".jsonl"):
        df = pd.read_json(text_path, lines=True)
    elif text_path.endswith((".xlsx", ".xls")):
        df = pd.read_excel(text_path)
    else:
        raise ValueError("Unsupported file format")
    print(f"Loaded {len(df)} records")

    # Pre-encode prompt
    with torch.no_grad():
        t_inputs       = processor(text=prompt, return_tensors="pt", padding=True).to(device)
        prompt_features = model.get_text_features(**t_inputs)
        prompt_features = F.normalize(prompt_features, p=2, dim=1)

    predictions = []

    for _, row in tqdm(df.iterrows(), total=len(df), desc="Predicting"):
        # Concatenate text (if needed)
        sample_text = ""
        if use_text:
            sample_text = " ".join(str(row[c]).strip() for c in text_column
                                    if c in row and pd.notna(row[c]))

        # Load image only when use_image
        if use_image:
            img_path = os.path.join(img_dir, f"{row['image_id']}.jpg")
            if os.path.exists(img_path):
                image = Image.open(img_path).convert("RGB")
            else:
                print(f"Image does not exist: {img_path}")
                image = Image.new("RGB", (224, 224), color="white")
        else:
            image = None

        # Feature extraction & similarity calculation
        with torch.no_grad():
            if use_text and use_image:
                inputs       = processor(text=sample_text, images=image, return_tensors="pt").to(device)
                text_f       = model.get_text_features(
                    **{k: v for k, v in inputs.items() if k in ["input_ids", "attention_mask", "position_ids"]}
                )
                img_f        = model.get_image_features(inputs.pixel_values)
                sample_feat  = F.normalize((text_f + img_f) / 2, p=2, dim=1)

            elif use_text:
                inputs       = processor(text=sample_text, return_tensors="pt").to(device)
                text_f       = model.get_text_features(**inputs)
                sample_feat  = F.normalize(text_f, p=2, dim=1)

            else:  # use_image
                inputs       = processor(images=image, return_tensors="pt").to(device)
                img_f        = model.get_image_features(inputs.pixel_values)
                sample_feat  = F.normalize(img_f, p=2, dim=1)

            sim      = sample_feat @ prompt_features.t()
            pred_cls = sim.argmax().item() + 1
            predictions.append(pred_cls)

    # Add predictions to DataFrame and return
    df[predict_column] = predictions
    return df



############### Fine-tune ###############
# Define the CLIP classification model class
class CLIPClassifier(torch.nn.Module):
    def __init__(self, clip_model, num_classes, use_text=True, use_image=True):
        super().__init__()
        self.clip_model = clip_model
        self.use_text = use_text
        self.use_image = use_image
        self.dropout = torch.nn.Dropout(0.3)
        self.classifier = torch.nn.Linear(clip_model.config.projection_dim, num_classes)

    def forward(self, **inputs):
        # extract features depending on the mode
        feats = []
        if self.use_text:
            text_feats = self.clip_model.get_text_features(
                input_ids=inputs["input_ids"],
                attention_mask=inputs.get("attention_mask", None)
            )
            feats.append(text_feats)

        if self.use_image:
            img_feats = self.clip_model.get_image_features(
                pixel_values=inputs["pixel_values"]
            )
            feats.append(img_feats)

        # combine (either single or multimodal)
        if len(feats) == 2:
            combined = (feats[0] + feats[1]) / 2
        else:
            combined = feats[0]

        # normalize, dropout, classify
        combined = torch.nn.functional.normalize(combined, p=2, dim=-1)
        out = self.dropout(combined)
        logits = self.classifier(out)
        return logits, None



# Define the dataset class
class NewsDataset(Dataset):
    def __init__(
        self,
        dataframe,
        processor,
        text_column=None,
        img_dir=None,
        use_text=True,
        use_image=True,
        true_label=None,
        prompt=None,
    ):
        self.df = dataframe
        self.processor = processor
        self.text_column = text_column
        self.img_dir = img_dir
        self.use_text = use_text
        self.use_image = use_image
        self.true_label = true_label
        self.prompt = prompt
        # tokenizer’s max length for padding/truncation
        self.max_length = processor.tokenizer.model_max_length

    def __len__(self):
        return len(self.df)

    def __getitem__(self, idx):
        row = self.df.iloc[idx]

        # --- build text input only if requested ---
        text = None
        if self.use_text:
            if isinstance(self.text_column, list):
                text = " ".join(
                    str(row[col]).strip()
                    for col in self.text_column
                    if col in row and pd.notna(row[col])
                )
            else:
                text = str(row[self.text_column]).strip()

            if self.prompt:
                text = f"{self.prompt} {text}"

        # --- build image input only if requested ---
        image = None
        if self.use_image and self.img_dir:
            img_id = row.get("image_id", row.name)
            img_path = os.path.join(self.img_dir, f"{img_id}.jpg")
            if os.path.exists(img_path):
                image = Image.open(img_path).convert("RGB")
            else:
                print(f"Image not found, using blank image for {img_id}")
                image = Image.new("RGB", (224, 224), color="white")
        # if use_image=False (or img_dir=None), image stays None

        # --- prepare inputs for CLIPProcessor ---
        proc_kwargs = {
            "return_tensors": "pt",
            "padding": "max_length",
            "truncation": True,
            "max_length": self.max_length,
        }
        if self.use_text:
            proc_kwargs["text"] = text
        if self.use_image:
            proc_kwargs["images"] = image

        inputs = self.processor(**proc_kwargs)
        # remove the extra batch dimension
        inputs = {k: v.squeeze(0) for k, v in inputs.items()}

        # --- label handling ---
        if self.true_label:
            label = int(row[self.true_label])
            # if labels start at 1, shift to zero‐based
            if self.df[self.true_label].min() == 1:
                label -= 1
        else:
            label = 0

        return inputs, label



def classification_CLIP_finetuned(
    mode=None,
    text_path=None,
    text_column=["headline"],
    img_dir=None,
    prompt=None,
    model_name="best_clip_model.pth",
    batch_size=8,
    num_classes=24,
    predict_column="label",
    true_label=None,
):
    """
    Use the fine-tuned CLIP model for prediction

    Parameters:
        mode: modality to use ("text"/"image"/"both")
        text_path: path to the data file
        text_column: list of column names used for text input
        img_dir: path to the image directory
        prompt: optional prompt
        model_name: path to the model weights file
        batch_size: batch size
        predict_column: column name to save prediction results
        true_label: label column name used to determine number of classes; can be None during prediction

    Returns:
        DataFrame: DataFrame containing the prediction results
    """
    # Parameter validation
    if mode not in ["text", "image", "both"]:
        raise ValueError("mode must be one of 'text', 'image', or 'both'")

    # Load data
    if text_path.endswith(".csv") or text_path.endswith("txt"):
        df = pd.read_csv(text_path)
    elif text_path.endswith(".jsonl"):
        df = pd.read_json(text_path, lines=True)
    elif text_path.endswith(".xlsx") or text_path.endswith(".xls"):
        df = pd.read_excel(text_path)
    else:
        raise ValueError("Unsupported file format")
    print(f"{len(df)} pieces of data loaded")

    # Load model and processor
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    processor = CLIPProcessor.from_pretrained(base_model)

    # Create model instance
    model = CLIPClassifier(
        CLIPModel.from_pretrained(base_model),
        num_classes,
        use_text=(mode in ["text", "both"]),
        use_image=(mode in ["image", "both"]),
    ).to(device)

    # Load model weights
    if not os.path.exists(model_name):
        raise ValueError(f"Model weights file does not exist: {model_name}")

    # Load entire model state dictionary
    checkpoint = torch.load(model_name, map_location=device, weights_only=True)
    model.load_state_dict(checkpoint["model_state_dict"])
    model.eval()

    # Create dataset and loader
    dataset = NewsDataset(
        df, text_column=text_column, img_dir=img_dir, processor=processor, prompt=prompt, true_label=true_label
    )
    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=False)

    # Store prediction results
    predictions = []

    # Predict
    with torch.no_grad():
        for batch_idx, (inputs, _) in enumerate(tqdm(dataloader, desc="predicting")):
            # Move data to device
            for k, v in inputs.items():
                inputs[k] = v.to(device)

            # Forward pass
            logits, _ = model(**inputs)

            # Get predicted classes
            _, predicted = logits.max(1)

            # If labels start from 1, add 1 to predictions
            predicted = predicted + 1

            # Append to prediction list
            predictions.extend(predicted.cpu().numpy())

    # Add prediction results to the DataFrame
    df[predict_column] = predictions

    print("Labeling completed!")

    return df

# Main function to fine-tune the CLIP model
def finetune_CLIP(
    mode="both",
    text_path="Demo_data/D1_1.csv",
    text_column=["headline"],
    img_dir="Demo_data/D1_imgs_1",
    true_label="section_numeric",
    prompt=None,
    model_name="best_clip_model.pth",
    num_epochs=20,
    batch_size=8,
    learning_rate=1e-5,
):
    if mode not in ["text", "image", "both"]:
        raise ValueError("mode must be one of 'text', 'image', or 'both'")
    # Set use_text and use_image according to mode
    use_text = mode in ["text", "both"]
    use_image = mode in ["image", "both"]
    if use_text and not text_path:
        raise ValueError("text_path cannot be empty")
    if use_image and not img_dir:
        raise ValueError("img_dir cannot be empty")
    # Ensure at least one modality is enabled
    if not use_text and not use_image:
        raise ValueError("At least one of text or image mode must be enabled")

    # Load training data
    if text_path.endswith(".csv") or text_path.endswith("txt"):
        df = pd.read_csv(text_path)
    elif text_path.endswith(".jsonl"):
        df = pd.read_json(text_path, lines=True)
    elif text_path.endswith(".xlsx") or text_path.endswith(".xls"):
        df = pd.read_excel(text_path)
    else:
        raise ValueError("Unsupported file format")
    print(f"Loaded {len(df)} records")

    # Split into training and validation sets (80:20)
    val_size = int(len(df) * 0.2)
    train_df, val_df = df.iloc[:-val_size], df.iloc[-val_size:]

    # Determine number of classes
    if min(df[true_label].unique()) == 1:
        num_classes = int(df[true_label].max())
    else:
        num_classes = int(df[true_label].max()) + 1

    print(f"Number of classes: {num_classes}")
    print(f"Use text: {use_text}, Use image: {use_image}")
    print(f"Text columns: {text_column}")
    print(f"Label column: {true_label}")
    if prompt:
        print(f"Using prompt: {prompt}")

    # Load CLIP model and processor
    clip_model = CLIPModel.from_pretrained(base_model)
    processor = CLIPProcessor.from_pretrained(base_model)

    # Check sample counts per class
    train_class_counts = train_df[true_label].value_counts()
    val_class_counts = val_df[true_label].value_counts()
    print(f"Training set class distribution: {train_class_counts}")
    print(f"Validation set class distribution: {val_class_counts}")

    # Create datasets
    train_dataset = NewsDataset(
        train_df,
        processor,
        text_column=text_column,
        img_dir=img_dir,
        use_text=use_text,
        use_image=use_image,
        true_label=true_label,
        prompt=prompt
    )
    val_dataset = NewsDataset(
        val_df,
        processor,
        text_column=text_column,
        img_dir=img_dir,
        use_text=use_text,
        use_image=use_image,
        true_label=true_label,
        prompt=prompt
    )



    # Create data loaders
    train_dataloader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    val_dataloader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)

    # Instantiate the combined model
    model = CLIPClassifier(clip_model, num_classes, use_text, use_image).to(device)

    # Set up optimizer
    optimizer = AdamW(model.parameters(), lr=learning_rate)

    # Set loss function
    criterion = torch.nn.CrossEntropyLoss()

    # Training loop
    best_accuracy = 0.0

    for epoch in range(num_epochs):
        # Training mode
        model.train()

        train_loss = 0.0
        train_correct = 0
        train_total = 0

        # Train for one epoch
        for batch_idx, (inputs, labels) in enumerate(
            tqdm(train_dataloader, desc=f"Epoch {epoch+1}/{num_epochs} [Train]")
        ):
            # Move data to device
            for k, v in inputs.items():
                inputs[k] = v.to(device)
            labels = labels.to(device)

            # Zero gradients
            optimizer.zero_grad()

            # Forward pass
            logits, _ = model(**inputs)

            # Compute loss
            loss = criterion(logits, labels)

            # Backward pass and optimization
            loss.backward()
            optimizer.step()

            # Statistics
            train_loss += loss.item()
            _, predicted = logits.max(1)
            train_total += labels.size(0)
            train_correct += predicted.eq(labels).sum().item()

            # Print every 10 batches
            if (batch_idx + 1) % 10 == 0:
                print(
                    f"Batch {batch_idx+1}/{len(train_dataloader)}: Loss: {loss.item():.4f} | Acc: {100.*train_correct/train_total:.2f}%"
                )

        # Validation mode
        model.eval()

        val_loss = 0.0
        val_correct = 0
        val_total = 0

        all_preds = []
        all_labels = []

        with torch.no_grad():
            for batch_idx, (inputs, labels) in enumerate(
                tqdm(val_dataloader, desc=f"Epoch {epoch+1}/{num_epochs} [Val]")
            ):
                # Move data to device
                for k, v in inputs.items():
                    inputs[k] = v.to(device)
                labels = labels.to(device)

                # Forward pass
                logits, _ = model(**inputs)

                # Compute loss
                loss = criterion(logits, labels)

                # Statistics
                val_loss += loss.item()
                _, predicted = logits.max(1)
                val_total += labels.size(0)
                val_correct += predicted.eq(labels).sum().item()

                # Collect predictions and labels for classification report
                all_preds.extend(predicted.cpu().numpy())
                all_labels.extend(labels.cpu().numpy())

        # Print epoch results
        train_loss = train_loss / len(train_dataloader)
        train_acc = 100.0 * train_correct / train_total
        val_loss = val_loss / len(val_dataloader)
        val_acc = 100.0 * val_correct / val_total

        print(
            f"Epoch {epoch+1}/{num_epochs}: Train Loss: {train_loss:.4f} | Train Acc: {train_acc:.2f}% | Val Loss: {val_loss:.4f} | Val Acc: {val_acc:.2f}%"
        )

        # Save best model
        if val_acc > best_accuracy:
            best_accuracy = val_acc
            torch.save(
                {"model_state_dict": model.state_dict(), "epoch": epoch, "best_accuracy": best_accuracy}, model_name
            )
            print(f"Model saved! Best validation accuracy: {best_accuracy:.2f}%")

    print(f"Fine-tuning complete! Best validation accuracy: {best_accuracy:.2f}%")

    return best_accuracy




####################################################################
######################  Verification Function ######################
####################################################################
def auto_verification(
    df: pd.DataFrame,
    predicted_cols,
    true_cols,
    category: list = None,
    sample_size: int = None
) -> dict:
    """
    Compute accuracy, precision, recall, F1, plus full report and confusion matrix.
    Handles:
      - single-/multi-col inputs
      - list-like single-element preds (e.g. [1])
      - 'Unknown' or unparseable entries as NaN
      - optional category name→index mapping
    """

    def _extract_scalar(x):
        # flatten [n] → n
        if isinstance(x, (list, tuple)) and len(x) == 1:
            x = x[0]
        # treat 'Unknown' or non-int as NaN
        try:
            return int(x)
        except:
            return np.nan

    def _normalize_series(col: pd.Series) -> pd.Series:
        # 1) map category names → ints if requested
        if category and col.dtype == object and not pd.api.types.is_list_like(col.iloc[0]):
            mapping = {name: idx + 1 for idx, name in enumerate(category)}
            col = col.map(mapping).astype(float)
        # 2) flatten lists / unknown strings → float (with NaNs)
        if col.dtype == object or pd.api.types.is_list_like(col.iloc[0]):
            col = col.map(_extract_scalar)
        return col

    # Wrap single names into lists
    if isinstance(predicted_cols, str):
        predicted_cols = [predicted_cols]
    if isinstance(true_cols, str):
        true_cols = [true_cols]

    # Ensure the lists are the same length
    if len(predicted_cols) != len(true_cols):
        raise ValueError("The number of predicted columns must match the number of true columns.")

    # accumulate results if multi-col
    total_correct, total_count = 0, 0
    overall_results = {}

    # Compare each prediction column with its corresponding true column
    for p, t in zip(predicted_cols, true_cols):
        if p not in df or t not in df:
            raise KeyError(f"Column '{p}' or '{t}' not in DataFrame")
        
        s_pred = _normalize_series(df[p])
        s_true = _normalize_series(df[t])

        # Ensure there are valid rows to compare
        valid = pd.concat([s_pred, s_true], axis=1).dropna()
        
        if len(valid) == 0:
            print(f"No valid data to compare for '{p}' vs '{t}'. Skipping.")
            continue

        # Skip NaN rows only (this is already handled by dropna above)
        if sample_size and len(valid) > sample_size:
            valid = valid.sample(sample_size, random_state=42)

        y_pred, y_true = valid.iloc[:, 0], valid.iloc[:, 1]

        # core metrics
        results = {
            "accuracy": accuracy_score(y_true, y_pred),
            "precision_macro": precision_score(y_true, y_pred, average='macro', zero_division=0),
            "recall_macro": recall_score(y_true, y_pred, average='macro', zero_division=0),
            "f1_macro": f1_score(y_true, y_pred, average='macro', zero_division=0),
            "precision_micro": precision_score(y_true, y_pred, average='micro', zero_division=0),
            "recall_micro": recall_score(y_true, y_pred, average='micro', zero_division=0),
            "f1_micro": f1_score(y_true, y_pred, average='micro', zero_division=0),
            "report": classification_report(y_true, y_pred, zero_division=0),
            "confusion_matrix": confusion_matrix(y_true, y_pred)
        }

        print(f"\n== Verification of '{p}' vs. '{t}' ==")
        print(f"Accuracy:   {results['accuracy']:.2%}")
        print(f"Macro F1:   {results['f1_macro']:.2%}")
        print(f"Micro  F1:  {results['f1_micro']:.2%}")
        print("\nFull classification report:")
        print(results["report"])
        print("\nConfusion matrix:")
        print(results["confusion_matrix"])

        # accumulate totals
        total_correct += (y_pred == y_true).sum()
        total_count += len(valid)

        # store individual results
        overall_results[f"{p} vs {t}"] = results

    # Final overall accuracy
    overall_accuracy = total_correct / total_count if total_count else 0.0
    print(f"\n>> Overall accuracy: {overall_accuracy:.2%}")
    
    # Add to the final dictionary
    overall_results["overall_accuracy"] = overall_accuracy


####################################################################
######################  GPT Function ###############################
####################################################################
import os
import json
import pandas as pd
import numpy as np
from PIL import Image
from sklearn.metrics.pairwise import cosine_similarity
import torch
from transformers import CLIPProcessor, CLIPModel
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    confusion_matrix,
    classification_report
)
from tqdm import tqdm
tqdm.pandas()
from collections import Counter
from IPython.display import display, clear_output
import ast, os, pandas as pd, numpy as np
from PIL import Image
from sklearn.preprocessing import MultiLabelBinarizer
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from transformers import CLIPProcessor, get_linear_schedule_with_warmup
from torch.optim import AdamW
import torch
import warnings
from sklearn.preprocessing import MultiLabelBinarizer
from datetime import datetime
from tqdm.auto import tqdm

# Set environment variable for tokenizers
os.environ["TOKENIZERS_PARALLELISM"] = "true"



import os
import base64
import json
import time
import hashlib
import threading
import re
from dataclasses import dataclass
import csv
import pandas as pd
import sqlitedict
from loguru import logger
from openai import OpenAI
from tqdm import tqdm
from sklearn.metrics import accuracy_score
import numpy as np


###################### price estimation ######################

def price_estimation(
    response,
    num_rows: int,
    input_cost_per_million: float,
    output_cost_per_million: float,
    num_votes: int = 1
) -> float:
    """
    Estimate total cost based on the last OpenAI ChatCompletion response.

    Parameters:
    - response: The ChatCompletion object (can be a dict or Pydantic model).
    - num_rows: Number of unique input rows (e.g., text prompt).
    - input_cost_per_million: Cost per 1 million prompt tokens.
    - output_cost_per_million: Cost per 1 million completion tokens.
    - num_votes: Number of times each row is processed (e.g., for majority voting). Default is 1.

    Returns:
    - Estimated total cost as a float.
    """
    # Extract usage details
    usage = getattr(response, "usage", None)
    if usage is None:
        usage = response.get("usage", {})

    # Extract token counts
    if isinstance(usage, dict):
        input_tokens = usage.get("prompt_tokens", usage.get("input_tokens", 0))
        output_tokens = usage.get("completion_tokens", usage.get("output_tokens", 0))
    else:
        input_tokens = getattr(usage, "prompt_tokens", getattr(usage, "input_tokens", 0))
        output_tokens = getattr(usage, "completion_tokens", getattr(usage, "output_tokens", 0))

    # Token pricing
    in_price = input_cost_per_million / 1_000_000
    out_price = output_cost_per_million / 1_000_000

    # Cost per call and total
    cost_per_call = input_tokens * in_price + output_tokens * out_price
    total_calls = num_rows * num_votes
    total = cost_per_call * total_calls
    low = total * 0.90
    high = total * 1.10

    # Summary
    print(f"\n🧮 Estimated Cost for {total_calls:,} calls ({num_rows:,} rows × {num_votes} votes)")
    print(f"• Avg prompt tokens/call:     {input_tokens}")
    print(f"• Avg completion tokens/call: {output_tokens}")
    print(f"• Pricing ($/1M tokens): prompt=${input_cost_per_million}, completion=${output_cost_per_million}")
    print(f"💰 Total: ${total:.4f}    (±10% → ${low:.4f}–${high:.4f})\n")

    return total


###################### Utility  ######################
# ───────────────────────────────────────────────────────────────
# Utility: local file → base-64 data URL
# ───────────────────────────────────────────────────────────────
def image_file_to_data_url(path: str) -> str:
    try:
        with open(path, "rb") as f:
            data = f.read()
        b64 = base64.b64encode(data).decode("utf-8")
        return f"data:image/jpeg;base64,{b64}"
    except Exception as e:
        logger.error(f"[image_data_url] {path}: {e}")
        return ""

# ───────────────────────────────────────────────────────────────
# Dataclasses
# ───────────────────────────────────────────────────────────────
@dataclass
class ClassificationQuestion:
    prompt: str
    model_name: str
    valid_values: list[str]
    temperature: float | None
    effort: str | None
    column_4_labeling: str            # "text_class" | "image_class" | "final_class"
    text: str                         # text snippet OR data URL OR multimodal combo
    label_num: int = 1
    max_verify_retry: int = 2

    # cache key
    def get_key(self) -> str:
        parts = [
            self.prompt,
            self.model_name,
            ",".join(self.valid_values),
            str(self.temperature),
            self.column_4_labeling,
            self.text or "",
            str(self.label_num),
            str(self.max_verify_retry),
        ]
        return hashlib.md5("|".join(parts).encode()).hexdigest()


@dataclass
class ClassificationTask:
    column: str
    prompt: str
    model_name: str
    valid_values: list[str]
    temperature: float | None
    effort: str | None
    column_4_labeling: str
    label_num: int = 1
    once_verify_num: int = 1
    max_verify_retry: int = 3

    def create_question(self, content: str) -> ClassificationQuestion:
        return ClassificationQuestion(
            prompt=self.prompt,
            model_name=self.model_name,
            valid_values=self.valid_values,
            temperature=self.temperature,
            effort=self.effort,
            column_4_labeling=self.column_4_labeling,
            text=content,
            label_num=self.label_num,
            max_verify_retry=self.max_verify_retry,
        )


# ───────────────────────────────────────────────────────────────
# Tiny sqlite memo-cache
# ───────────────────────────────────────────────────────────────
class DBCache:
    def __init__(self):
        self.db = sqlitedict.SqliteDict("db.sqlite", autocommit=True)

    def add(self, q: ClassificationQuestion, res):
        self.db[q.get_key()] = res

    def get(self, q: ClassificationQuestion):
        return self.db.get(q.get_key())


class MaxRetryException(Exception):
    pass

###################### GPT Dataclasses ######################

#   ---  GPTClassifier  -----------------------------------------
class GPTClassifier:
    def __init__(self, client: OpenAI):
        self.client = client
        self.cache  = DBCache()

    # -- low-level chat call with retry -----------------------
    def fetch(self, messages, model, temp_or_effort, n):
        # if this is a fine-tuned ft: model, call it with no temperature/effort
        if model.startswith("ft:"):
            return self.client.chat.completions.create(
                model=model,
                messages=messages,
                n=n
            )

        # otherwise fall back to your existing o-series vs non-o logic
        is_o = model.startswith("o")
        if not is_o and isinstance(temp_or_effort, str):
            temp_or_effort = {"low": 0.0, "medium": 0.5,
                              "high": 1.0}.get(temp_or_effort.lower(), 0.0)

        for _ in range(3):
            try:
                if is_o:
                    return self.client.chat.completions.create(
                        model=model, messages=messages, n=n
                    )
                else:
                    return self.client.chat.completions.create(
                        model=model,
                        messages=messages,
                        temperature=float(temp_or_effort),
                        n=n
                    )
            except Exception as e:
                logger.warning(f"API error, retrying: {e}")
                time.sleep(1)
        raise MaxRetryException("Failed after retries")

    # -- SINGLE call → parsed labels --------------------------
    def classify(self, q: ClassificationQuestion, n: int):
        # 1) build content
        if q.column_4_labeling == "text_class":
            content = [
                {"type": "text", "text": str(q.prompt)},
                {"type": "text", "text": str(q.text)},
            ]
        elif q.column_4_labeling == "image_class":
            content = [
                {"type": "text", "text": str(q.prompt)},
                {"type": "image_url", "image_url": {"url": q.text}},
            ]
        else:  # final_class
            if "data:image" in q.text:
                txt, img = q.text.split("data:image", 1)
                img = "data:image" + img
            else:
                txt, img = q.text, ""
            img = re.sub(r"\s+", "", img)
            content = [
                {"type": "text",
                 "text": f"{str(q.prompt)}\nText: {str(txt).strip()}"},
            ]
            if img.startswith("data:image"):
                content.append({"type": "image_url",
                                "image_url": {"url": img}})

        # 2) call API
        resp = self.fetch(
            [{"role": "user", "content": content}],
            q.model_name,
            q.effort if q.model_name.startswith("o") else q.temperature,
            n,
        )

        # 3) parse
        parsed = []
        for reply in (c.message.content.strip() for c in resp.choices):
            # a) JSON array with strings or ints
            if reply.startswith("[") and reply.endswith("]"):
                try:
                    arr = json.loads(reply)
                    if (isinstance(arr, list) and
                            len(arr) == q.label_num and
                            all(str(x) in q.valid_values for x in arr)):
                        parsed.append([int(x) for x in arr])
                        continue
                except Exception:
                    pass
            # b) bare '0,1,0,0…'
            flat = re.findall(r"\b[01]\b", reply)
            if len(flat) == q.label_num:
                parsed.append([int(x) for x in flat])
                continue
            # c) single / top-k
            matches = [p.strip(' ."') for p in reply.split(",")
                       if p.strip(' ."') in q.valid_values]
            if matches:
                parsed.append(matches[: q.label_num])
                continue
            m = re.search(r"\b(\d{1,2})\b", reply)
            if m and m.group(1) in q.valid_values:
                parsed.append([m.group(1)])

        if not parsed:
            logger.error(f"No valid labels parsed. Raw reply: {resp.choices}")
        return parsed

    # -- majority vote / cache --------------------------------
    def multi_verify(self, q: ClassificationQuestion, n, retry=1, freq=None):
        res = self.classify(q, n)
        if not res and retry < q.max_verify_retry:
            return self.multi_verify(q, n, retry + 1)
        if not res:
            raise MaxRetryException("No valid responses")

        # full vector → keep first
        if isinstance(res[0], list) and len(res[0]) == q.label_num:
            self.cache.add(q, res[0])
            return res[0]

        freq = freq or {}
        for r in res:
            lbl = r[0]
            freq[lbl] = freq.get(lbl, 0) + 1
        top = sorted(freq, key=freq.get, reverse=True)[: q.label_num]
        self.cache.add(q, top)
        return top

    # -- DataFrame helper -------------------------------------
    def classify_df(self, df: pd.DataFrame, task: ClassificationTask,
                    return_sample_response=False):
        out, sample = [], None
        for rec in tqdm(df.to_dict("records"),
                        desc=f"Classifying {task.column_4_labeling}", unit="item"):
            q = task.create_question(rec.get(task.column, ""))

            if return_sample_response and sample is None:
                sample = self.fetch(
                    [{"role": "user",
                      "content": [{"type": "text", "text": str(q.prompt)},
                                  {"type": "text", "text": str(q.text)}]}],
                    q.model_name,
                    q.effort if q.model_name.startswith("o") else q.temperature, 1
                )

            try:
                lbl = self.multi_verify(q, task.once_verify_num)
            except Exception as e:
                logger.error(e)
                lbl = ["99"] * task.label_num

            rec[task.column_4_labeling] = lbl
            out.append(rec)

        df_out = pd.DataFrame(out)
        return (df_out, sample) if return_sample_response else df_out
#   ---  end GPTClassifier  -------------------------------------


###################### classification GPT ######################


###################### classification GPT ######################

def classification_GPT(
    text_path: str | None = None,
    category: list[str] | None = None,
    image_dir: str | None = None,
    prompt: list[str] | str | None = None,
    column_4_labeling: list[str] | None = None,
    model: str = "gpt-4o-mini",
    api_key: str | None = None,
    temperature: float | None = None,
    effort: str | None = None,
    mode: str = "both",              # "text" | "image" | "both"
    output_column_name: str = "label",
    num_themes: int = 1,
    num_votes: int = 1,
) -> pd.DataFrame:

    # -- parameter guards -------------------------------------
    category = [str(c) for c in (category or [])]
    if model.startswith("o"):
        if effort is None:
            raise ValueError("effort required for o-series")
        temperature = None
    else:
        if temperature is None:
            raise ValueError("temperature required for non-o models")
        effort = None

    # -- 1. load data  → df0 ----------------------------------
    if mode == "image":
        if text_path and text_path.lower().endswith(".json"):
            df0 = pd.DataFrame(json.load(open(text_path, encoding="utf-8")))
            if "image_dir" not in df0.columns:
                df0["image_dir"] = df0["image_id"].apply(
                    lambda x: os.path.join(image_dir, f"{x}.jpg"))
        else:
            if not image_dir:
                raise ValueError("image_dir required (mode='image')")
            files = [f for f in os.listdir(image_dir)
                     if f.lower().endswith((".jpg", ".jpeg", ".png"))]
            df0 = pd.DataFrame({
                "image_id":   [os.path.splitext(f)[0] for f in files],
                "image_dir": [os.path.join(image_dir, f) for f in files],
            })
    else:
        if not text_path:
            raise ValueError("text_path required")
        ext = os.path.splitext(text_path)[1].lower()
        if ext == ".json":
            df0 = pd.DataFrame(json.load(open(text_path, encoding="utf-8")))
        elif ext == ".csv":
            df0 = pd.read_csv(text_path)
        elif ext in (".xls", ".xlsx"):
            df0 = pd.read_excel(text_path)
        else:
            raise ValueError(f"Unsupported file type: {ext}")

        if mode == "both" and "image_dir" not in df0.columns:
            if not image_dir:
                raise ValueError("image_dir required for mode='both'")
            df0["image_dir"] = df0["image_id"].apply(
                lambda x: os.path.join(image_dir, f"{x}.jpg"))

    # -- 2. helper columns on a copy --------------------------
    df = df0.copy()
    df["text_content"] = (df.apply(
        lambda r: " ".join(
            str(r[c]) for c in (column_4_labeling or [])
            if c in r and pd.notna(r[c])
        ), axis=1) if column_4_labeling else "")

    if mode in ("image", "both"):
        df["image_data_url"] = df["image_dir"].apply(image_file_to_data_url)
    else:
        df["image_data_url"] = ""

    if mode == "both":
        df["final_input"] = df["text_content"] + "\n" + df["image_data_url"]
    elif mode == "image":
        df["final_input"] = df["image_data_url"]
    else:
        df["final_input"] = df["text_content"]

    # -- 3. base prompt ---------------------------------------
    if isinstance(prompt, str) and prompt.strip():
        base_prompt = prompt.strip()
    else:
        defs = "; ".join(f"{c}: {d}" for c, d in zip(category, prompt)) if prompt else ""
        base_prompt = (
            f"Themes: {', '.join(category)}. {defs} "
            f"Return the top {num_themes} theme number(s) "
            "(or an 8-element JSON array of 0/1). No extra words."
        )

    # -- 4. task list -----------------------------------------
    if mode == "text":
        tasks = [("text_content",  "text_class",  base_prompt)]
    elif mode == "image":
        tasks = [("image_data_url","image_class", base_prompt)]
    else:
        tasks = [
            ("text_content",  "text_class",  base_prompt),
            ("image_data_url","image_class", base_prompt),
            ("final_input",   "final_class", base_prompt),
        ]

    # -- 5. run GPT classification ----------------------------
    clf   = GPTClassifier(OpenAI(api_key=api_key) if api_key else OpenAI())
    first = True
    for col, lab, pr in tasks:
        task = ClassificationTask(
            column=col, prompt=pr, model_name=model,
            valid_values=category, temperature=temperature, effort=effort,
            column_4_labeling=lab, label_num=num_themes,
            once_verify_num=num_votes, max_verify_retry=num_votes,
        )
        if first:
            df, _ = clf.classify_df(df, task, return_sample_response=True)
            first = False
        else:
            df = clf.classify_df(df, task)

    # -- 6. rename / explode ----------------------------------
    df.rename(columns={lab: output_column_name}, inplace=True)

    if isinstance(df[output_column_name].iloc[0], list) \
            and len(df[output_column_name].iloc[0]) == num_themes:
        raw = output_column_name + "_raw"
        df[raw] = df[output_column_name]
        for i in range(num_themes):
            df[f"{output_column_name}_{i+1}"] = df[output_column_name].apply(
                lambda v, idx=i: int(v[idx]) if isinstance(v, list) else np.nan
            )

    df[output_column_name] = df[output_column_name].apply(
        lambda x: x[0] if isinstance(x, list) and len(x) == 1 else x
    )
    return df




###################### Fine-tune preparation ######################
import json
import numpy as np
import pandas as pd
import logging

logger = logging.getLogger(__name__)

def generate_GPT_finetune_jsonl(
    df: pd.DataFrame,
    output_path: str = "classification_result.jsonl",
    label_col: str | list[str] = "true_class",
    system_prompt: str | list[str] | None = None,
    input_col: str | list[str] = "text_content",
) -> None:
    """
    Write a JSONL file for OpenAI chat-style fine-tuning.

    Each line will be:
    {
      "messages": [
        {"role":"system",    "content": <system_prompt>   },
        {"role":"user",      "content": <user_text>       },
        {"role":"assistant", "content": " " + <labels> + "\n"}
      ]
    }

    Parameters
    ----------
    df : DataFrame
      Source data.
    output_path : str
      Path to the .jsonl to create.
    label_col : str or list of str
      Column(s) containing the ground-truth label(s).
    system_prompt : str or list of str or None
      System message(s) to prepend to each example.
    input_col : str or list of str
      Column(s) whose values form the user prompt.
    """
    # — normalize system_prompt into one string —
    if isinstance(system_prompt, (list, tuple)):
        sys_txt = "\n".join(system_prompt).strip()
    else:
        sys_txt = system_prompt.strip() if isinstance(system_prompt, str) else None

    # — normalize columns —
    label_cols = list(label_col) if isinstance(label_col, (list, tuple)) else [label_col]
    input_cols = list(input_col) if isinstance(input_col, (list, tuple)) else [input_col]

    # — sanity checks —
    for c in input_cols:
        if c not in df.columns:
            raise ValueError(f"Missing input column: {c}")
    for c in label_cols:
        if c not in df.columns:
            logger.warning(f"Missing label column: {c}; skipping export")
            return

    # — write JSONL —
    with open(output_path, "w", encoding="utf-8") as fout:
        for _, row in df.iterrows():
            # build user text
            parts = [str(row[c]) for c in input_cols if pd.notna(row[c])]
            if not parts:
                continue
            user_text = " ".join(parts).strip()

            # collect and normalize labels
            raw = [row[c] for c in label_cols]
            flat = []
            for x in raw:
                flat.extend(x if isinstance(x, (list, np.ndarray)) else [x])
            clean = []
            for v in flat:
                if pd.isna(v):
                    continue
                try:
                    clean.append(str(int(v)))
                except:
                    clean.append(str(v))
            if not clean:
                continue
            label_str = ", ".join(clean)

            # assemble messages list
            msgs = []
            if sys_txt:
                msgs.append({"role": "system",    "content": sys_txt})
            msgs.append({"role": "user",      "content": user_text})
            # leading space & trailing newline per spec
            clean_label_str = label_str.strip()  # Remove any accidental spaces
            msgs.append({"role": "assistant", "content": clean_label_str})

            # write record
            fout.write(json.dumps({"messages": msgs}, ensure_ascii=False) + "\n")

###################### Fine-tune GPT ######################


def finetune_GPT(
    training_file_path: str,
    model: str = "gpt-4o-mini",
    method_type: str = "supervised",
    hyperparameters: dict = None,
    poll_interval: int = 15,
    max_wait_time: int = 60*60,
    api_key: str = None
) -> str:
    client = OpenAI(api_key=api_key) if api_key else OpenAI()

    # 1) upload the file
    filename = os.path.basename(training_file_path)
    with open(training_file_path, 'rb') as f:
        upload_resp = client.files.create(file=(filename, f), purpose="fine-tune")
    try:
        training_file_id = upload_resp.id
    except AttributeError:
        training_file_id = upload_resp['id']

    # 2) build method dict
    method = {
        "type": method_type,
        method_type: {
            "hyperparameters": hyperparameters or {}
        }
    }

    # 3) start the fine-tune job
    job_resp = client.fine_tuning.jobs.create(
        training_file=training_file_id,
        model=model,
        method=method
    )
    try:
        job_id = job_resp.id
    except AttributeError:
        job_id = job_resp['id']
    print("Started fine-tune job", job_id)

    # 4) poll for status
    elapsed = 0
    while elapsed < max_wait_time:
        status = client.fine_tuning.jobs.retrieve(job_id)
        try:
            st = status.status
        except AttributeError:
            st = status['status']
        print(f"[{elapsed}s] status={st}")

        if st == "succeeded":
            try:
                fine_model = status.fine_tuned_model
            except AttributeError:
                fine_model = status['fine_tuned_model']
            print("✅ succeeded:", fine_model)
            return fine_model

        if st in ("failed", "canceled", "cancelled"):
            # try to extract the error details
            try:
                error_info = status.error
            except AttributeError:
                error_info = status.get('error', None)
            print(f"❌ Job {job_id} ended with {st}. Error info: {error_info}")
            raise RuntimeError(f"Fine-tune job {job_id} ended with status '{st}'"
                               + (f": {error_info}" if error_info else ""))

        time.sleep(poll_interval)
        elapsed += poll_interval

    # timeout
    raise TimeoutError(f"Job {job_id} didn’t finish within {max_wait_time}s")



####################################################################
######################  Verification Function ######################
####################################################################
def auto_verification(
    df: pd.DataFrame,
    predicted_cols,
    true_cols,
    category: list = None,
    sample_size: int = None
) -> dict:
    """
    Compute accuracy, precision, recall, F1, plus full report and confusion matrix.
    Handles:
      - single-/multi-col inputs
      - list-like single-element preds (e.g. [1])
      - 'Unknown' or unparseable entries as NaN
      - optional category name→index mapping
    """

    def _extract_scalar(x):
        # flatten [n] → n
        if isinstance(x, (list, tuple)) and len(x) == 1:
            x = x[0]
        # treat 'Unknown' or non-int as NaN
        try:
            return int(x)
        except:
            return np.nan

    def _normalize_series(col: pd.Series) -> pd.Series:
        # 1) map category names → ints if requested
        if category and col.dtype == object and not pd.api.types.is_list_like(col.iloc[0]):
            mapping = {name: idx + 1 for idx, name in enumerate(category)}
            col = col.map(mapping).astype(float)
        # 2) flatten lists / unknown strings → float (with NaNs)
        if col.dtype == object or pd.api.types.is_list_like(col.iloc[0]):
            col = col.map(_extract_scalar)
        return col

    # Wrap single names into lists
    if isinstance(predicted_cols, str):
        predicted_cols = [predicted_cols]
    if isinstance(true_cols, str):
        true_cols = [true_cols]

    # Ensure the lists are the same length
    if len(predicted_cols) != len(true_cols):
        raise ValueError("The number of predicted columns must match the number of true columns.")

    # accumulate results if multi-col
    total_correct, total_count = 0, 0
    overall_results = {}

    # Compare each prediction column with its corresponding true column
    for p, t in zip(predicted_cols, true_cols):
        if p not in df or t not in df:
            raise KeyError(f"Column '{p}' or '{t}' not in DataFrame")
        
        s_pred = _normalize_series(df[p])
        s_true = _normalize_series(df[t])

        # Ensure there are valid rows to compare
        valid = pd.concat([s_pred, s_true], axis=1).dropna()
        
        if len(valid) == 0:
            print(f"No valid data to compare for '{p}' vs '{t}'. Skipping.")
            continue

        # Skip NaN rows only (this is already handled by dropna above)
        if sample_size and len(valid) > sample_size:
            valid = valid.sample(sample_size, random_state=42)

        y_pred, y_true = valid.iloc[:, 0], valid.iloc[:, 1]

        # core metrics
        results = {
            "accuracy": accuracy_score(y_true, y_pred),
            "precision_macro": precision_score(y_true, y_pred, average='macro', zero_division=0),
            "recall_macro": recall_score(y_true, y_pred, average='macro', zero_division=0),
            "f1_macro": f1_score(y_true, y_pred, average='macro', zero_division=0),
            "precision_micro": precision_score(y_true, y_pred, average='micro', zero_division=0),
            "recall_micro": recall_score(y_true, y_pred, average='micro', zero_division=0),
            "f1_micro": f1_score(y_true, y_pred, average='micro', zero_division=0),
            "report": classification_report(y_true, y_pred, zero_division=0),
            "confusion_matrix": confusion_matrix(y_true, y_pred)
        }

        print(f"\n== Verification of '{p}' vs. '{t}' ==")
        print(f"Accuracy:   {results['accuracy']:.2%}")
        print(f"Macro F1:   {results['f1_macro']:.2%}")
        print(f"Micro  F1:  {results['f1_micro']:.2%}")
        print("\nFull classification report:")
        print(results["report"])
        print("\nConfusion matrix:")
        print(results["confusion_matrix"])

        # accumulate totals
        total_correct += (y_pred == y_true).sum()
        total_count += len(valid)

        # store individual results
        overall_results[f"{p} vs {t}"] = results

    # Final overall accuracy
    overall_accuracy = total_correct / total_count if total_count else 0.0
    print(f"\n>> Overall accuracy: {overall_accuracy:.2%}")
    
    # Add to the final dictionary
    overall_results["overall_accuracy"] = overall_accuracy
