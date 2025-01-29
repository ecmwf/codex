#!/bin/bash
echo "Running post generation tasks..."

# Get the directory of the generated project
project_dir=$(pwd)

# Get the logo paths from the cookiecutter context
logo_path_light="{{ cookiecutter.logo_path_light }}"
logo_path_dark="{{ cookiecutter.logo_path_dark }}"

# If no logo path is provided, skip the copying process
if [[ -z "$logo_path_light" ]]; then
    echo "/!\ No logo path provided. Skipping logo file copying."
else
    # Check if the file exists at the provided path
    if [[ ! -f "$logo_path_light" ]]; then
        echo "ERROR: The logo file at '$logo_path_light' does not exist. Please check the path."
        exit 1
    fi

    # Use same logo for light and dark if dark not provided
    if [[ -z "$logo_path_dark" ]]; then
        logo_path_dark="{{ cookiecutter.logo_path_light }}"
    fi
    # Check the extensions
    if [[ "$logo_path_light" != *.png ]] || [[ "$logo_path_dark" != *.png ]]; then
        echo "Error: The logo files must have a .png extension."
        exit 1
    fi

    # Push logos to github logos repo
    logos_repo_url="git@github.com:ecmwf/logos.git"
    # Unique branch name with timestamp
    branch_name="feature/add-logo-{{ cookiecutter.project_slug }}-$(date +'%Y%m%d%H%M%S')"
    light_name="{{ cookiecutter.project_slug }}_light.png"
    dark_name="{{ cookiecutter.project_slug }}_dark.png"

    # Clone the repository (to a temp directory to avoid affecting current working directory)
    temp_dir=$(mktemp -d)
    git clone "$repo_url" "$temp_dir"
    cd "$temp_dir" || exit

    # Create a new branch
    git checkout -b "$branch_name"

    # Copy the logo to the root of the project
    cp "$logo_path_light" "./logos/$light_name"
    cp "$logo_path_dark" "./logos/$dark_name"

    # Add, commit, and push the changes
    git add "./logos/$light_name"
    git add "./logos/$dark_name"
    git commit -m "Add new logo for {{ cookiecutter.project_slug }} repository"
    git push origin "$branch_name"

    # Create a Pull Request via GitHub CLI
    gh pr create --base main --head "$branch_name" --title "Add logo for {{ cookiecutter.project_slug }} repository" --body "This PR adds a new logo under the logos directory."

    # Clean up: Remove the temporary clone directory
    cd ..
    rm -rf "$temp_dir"

    # Confirm the logo has been copied
    echo "Logo files pushed to logo repository, and PR created successfully"
fi