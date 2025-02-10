# 3M Pipeline Project

This project contains various notebooks exploring different aspects of the MIMIC-IV database to demonstrate data science modeling capabilities.

In a broader perspective, this pipeline could facilitate advanced monitoring/alerting systems, extract insights for clinical decision making, and enable predictive modeling for patient outcomes.


## Pipeline Overview

- Vitals Analysis: Time series analysis and feature engineering of patient vital signs
- Medications Analysis: Clustering and pattern mining of medication administration data (todo)
- Labs Analysis: Predictive modeling using laboratory results (todo)
- Clinical Notes: NLP and text mining of clinical documentation (todo)
- Procedures: Sequential pattern mining of medical procedures (todo)
- Outcomes Analysis: Survival analysis and risk modeling (todo)


## Vitals Analysis Notebook (00_vitals_analysis.ipynb)

### Purpose
Analysis of patient vital signs data to identify patterns and relationships between measurements through feature engineering and statistical analysis.

### Key Components
- Temporal features (hour, day, etc.)
- Vital sign ratios (shock index, MAP, etc.) 
- Statistical metrics (mean, std, min/max)
- Variability measures (changes between measurements)

### Models & Analysis Methods
- K-means clustering for patient grouping
- Time series decomposition
- Principal Component Analysis (PCA) for dimension reduction
- Correlation analysis and heatmapping
- Distribution analysis with KDE
- Pattern detection using statistical tests
- Anomaly detection with Isolation Forest

