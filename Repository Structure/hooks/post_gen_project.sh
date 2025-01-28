#!/bin/bash
echo "Running post generation tasks..."

# Get the directory of the generated project
project_dir=$(pwd)

# Get the logo path from the cookiecutter context
logo_path="{{ cookiecutter.logo_path }}"

# If no logo path is provided, skip the copying process
if [[ -z "$logo_path" ]]; then
    echo "/!\ No logo path provided. Skipping logo file copying."
else
    # Check if the file exists at the provided path
    if [[ ! -f "$absolute_logo_path" ]]; then
        echo "ERROR: The logo file at '$logo_path' does not exist. Please check the path."
        exit 1
    fi

    # Define the target path for the logo in the root of the generated project
    target_logo_path="$project_dir/logo.png"

    # Copy the logo to the root of the project
    cp "$logo_path" "$target_logo_path"

    # Confirm the logo has been copied
    echo "Logo file copied from '$logo_path' to '$target_logo_path'."
fi