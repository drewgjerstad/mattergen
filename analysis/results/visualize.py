"""
Visualize metrics for set of MatterGen evaluation results.

This script is based on this notebook: benchmark/plot_benchmark_results.ipynb.
"""

import os
from pathlib import Path
import json
import pandas as pd
from matplotlib import pyplot as plt
import seaborn as sns

# Define Path to Results Directory
RESULTS_ROOT = Path(__file__).parent

# Paths to JSON files
metric_sources = {
    "Unconditional": "/unconditional_01_13/metrics.json",
    "Bulk-Mod-Liquid": "/bulk_modulus_01_13/003_liquid/metrics.json",
    "Bulk-Mod-Steel": "/bulk_modulus_01_13/160_steel/metrics.json",
    "Bulk-Mod-Diamonds": "/bulk_modulus_01_13/440_diamond/metrics.json",
}

# Read Metrics Files
metrics_data = []
for name, filepath in metric_sources.items():
    full_filepath = RESULTS_ROOT / filepath.lstrip("/")
    with open(full_filepath) as f:
        data = json.load(f)

    # Process metrics data
    data = {
        k: v["value"] for k, v in data.items()
    }
    data["model"] = name
    metrics_data.append(data)

# Convert to DataFrame
metrics_df = pd.DataFrame(metrics_data)

# Define Display Names for Plotting
model_display_names = {
    "Unconditional": "Unconditional Generation",
    "Bulk-Mod-Liquid": "Property Conditioned Bulk Modulus\n(Liquid, 3GPa)",
    "Bulk-Mod-Steel": "Property Conditioned Bulk Modulus\n(Steel, 160GPa)",
    "Bulk-Mod-Diamonds": "Property Conditioned Bulk Modulus\n(Diamond, 440GPa)"
}

# Maintain Order
metrics_df["model"] = pd.Categorical(metrics_df["model"],
                                     categories=metric_sources.keys(),
                                     ordered=True)

# Compute Percentage Metrics
metrics = {
    "frac_novel_unique_stable_structures": "% S.U.N. Structures (MatterSim)",
    "frac_stable_structures": "% Stable Structures",
    "avg_rmsd_from_relaxation": "Avg. RMSD During Relaxation"
}
plot_export = {
    "frac_novel_unique_stable_structures": "plots/metrics_sun.png",
    "frac_stable_structures": "plots/metrics_stable.png",
    "avg_rmsd_from_relaxation": "plots/metrics_rmsd.png"
}

for metric_key, metric_name in metrics.items():
    if metric_key.startswith('frac'):
        metrics_df[metric_name] = 100 * metrics_df[metric_key]
    else:
        metrics_df[metric_name] = metrics_df[metric_key]

metrics_df.model = metrics_df.model.cat.rename_categories(model_display_names)

# Generate Plots
for metric_key, metric_name in metrics.items():
    plt.figure(figsize=(8,4))
    sns.barplot(
        data=metrics_df,
        x="model",
        hue="model",
        legend=False,
        y=metric_name,
        saturation=1
    )
    plt.xticks(rotation=30, ha='right')
    plt.xlabel("")

    x_tick_rotation = 30
    locs, labels_out = plt.xticks(ha='right', rotation=x_tick_rotation)
    for l in labels_out:
        # manually draw for slight adjustmnets
        x, y = l.get_position()
        plt.text(x=x + 0.2, y=y, s=l.get_text(), rotation=x_tick_rotation,
                ha='right', va='top')
    ax = plt.gca()
    # remove originally drawn labels
    ax.set_xticklabels([], minor=False)
    ax.tick_params(axis='x', which='major', pad=-1, width=0.5, length=2)
    ax.tick_params(axis='y', which='major', pad=1, width=0.5, length=2)
    plt.xlim(-1.0, len(metric_sources.keys()))

    if metric_key.startswith('frac'):
        plt.yticks([0.0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
    else:
        plt.ylim((0.0, 1.0))
    plt.tight_layout()
    plt.savefig(os.path.join(RESULTS_ROOT, plot_export[metric_key]),
                bbox_inches="tight")
