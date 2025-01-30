import os
import pandas as pd
from datetime import datetime

def save_dataframes(dataframes, output_dir="output_data"):
    """
    Saves one or multiple dataframes as CSV files in the specified directory.
    Filenames are based on the dataframe names and include a timestamp for versioning.

    Args:
        dataframes (dict): A dictionary where keys are dataframe names and values are dataframes.
        output_dir (str): Directory where CSV files will be saved.
    """
    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Get the current timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    # Save each dataframe with its name and timestamp
    for name, df in dataframes.items():
        filename = f"{name}_{timestamp}.csv"
        filepath = os.path.join(output_dir, filename)
        df.to_csv(filepath, index=False)
        print(f"Saved: {filepath}")


def load_dataframes(dataframe_names, output_dir="output_data"):
    """
    Loads the latest versions of specified dataframes from the output directory.

    Args:
        dataframe_names (list): List of dataframe names to load (without timestamp).
        output_dir (str): Directory where CSV files are located.

    Returns:
        dict: A dictionary where keys are dataframe names and values are loaded dataframes.
    """
    loaded_dataframes = {}
    for name in dataframe_names:
        # Find all matching files for the dataframe name
        matching_files = [
            f for f in os.listdir(output_dir)
            if f.startswith(name) and f.endswith(".csv")
        ]
        if not matching_files:
            print(f"No saved files found for dataframe: {name}")
            continue

        # Sort files by timestamp and load the latest one
        matching_files.sort(reverse=True)
        latest_file = matching_files[0]
        filepath = os.path.join(output_dir, latest_file)
        loaded_dataframes[name] = pd.read_csv(filepath)
        print(f"Loaded: {filepath}")

    return loaded_dataframes
