# --------------------
# Project: Recipe Manager
#
# Authors: RANNOU Elouan, ROBIN Maxime
#
# --------------------

#!/bin/bash

# Defines the directory containing the recipe files
REPERTOIRE="recipes-main/"

# Check if the directory exists and contains .cook files
if [ ! -e "$REPERTOIRE" ]
then
    echo "[ERROR] $REPERTOIRE folder does not exist"
    exit 1
elif [ "$(find "$REPERTOIRE" -name "*.cook")" == "" ]
then
    echo "[ERROR] $REPERTOIRE does not contain any .cook files."
    exit 1
fi

# Function to display the content of the help.txt file
fonction_help() {
    # Checks for the presence of the help.txt file
    if [ -e "help.txt" ]; then
        cat "help.txt"
    else
        echo "[ERROR] help file is not available."
    fi
}

# Function to list all available recipes
fonction_list() {
    # Finds all files with the .cook extension in the directory
    ALL_FILES=$(find "$REPERTOIRE" -name "*.cook")
    IFS=$'\n'
    for i in $ALL_FILES; do
        # Displays only the filename without the extension
        echo "$(basename $i | cut -d "." -f1)"
    done
}

# Function to search for an ingredient or tool in the recipes
fonction_search() {
    ARG_1="@$*"
    ALL_FILES=$(find "$REPERTOIRE" -name "*.cook")
    IFS=$'\n'
    for i in $ALL_FILES; do
        # Searches for elements containing ARG_1, with or without braces
        VARIABLES_WITH_BRACES=$(grep -o -E "@[^}]*" "$i" | grep "$ARG_1{")
        VARIABLES_WITHOUT_BRACES=$(grep -o -E "@[^ ]*" "$i" | grep -v "{" | grep "$ARG_1")
        if [[ -n $VARIABLES_WITH_BRACES || -n $VARIABLES_WITHOUT_BRACES ]]; then
            # Displays the relative path of the recipe
            echo -n "$(dirname $i | cut -d "/" -f2)""/"
            echo "$(basename $i | cut -d "." -f1)"
        fi
    done
}

# Function to extract the ingredients of a recipe
function_ingredients() {
    CHEMIN=$(find "$REPERTOIRE" | grep "$*.cook")

    # Error message if the recipe does not exist
    if [[ "$CHEMIN" == "" ]]; then
        echo "Error: Recipe does not exist"
        exit
    fi

    # Extracts ingredients with or without braces
    VARIABLES_WITHOUT_BRACES=$(grep -o -E -i "@[^@]*" "$CHEMIN" | grep -v "{" | cut -d " " -f1)
    VARIABLES_WITH_BRACES=$(grep -o -E -i "@[a-z ]+{" "$CHEMIN" | cut -d "{" -f1)

    # Merges and sorts the results alphabetically, removing duplicates
    VARIABLES=$(echo -e "$VARIABLES_WITH_BRACES\n$VARIABLES_WITHOUT_BRACES" | sort | uniq)

    # Displays each ingredient
    IFS=$'\n@'
    for i in $VARIABLES; do
        if [[ -n $i ]]; then
            echo "-" $i
        fi
    done
}

# Function to extract the tools needed for a recipe
function_tools() {
    CHEMIN=$(find "$REPERTOIRE" | grep "$*.cook")

    # Error message if the recipe does not exist
    if [[ "$CHEMIN" == "" ]]; then
        echo "Error: Recipe does not exist"
        exit
    fi

    # Extracts tools with or without braces
    VARIABLES_WITHOUT_BRACES=$(grep -o -E -i "#[a-z( {)]+" "$CHEMIN" | grep -v "{" | cut -d " " -f1)
    VARIABLES_WITH_BRACES=$(grep -o -E -i "#[a-z ]+{" "$CHEMIN" | cut -d "{" -f1)

    # Merges and sorts the results alphabetically, removing duplicates
    VARIABLES=$(echo -e "$VARIABLES_WITH_BRACES\n$VARIABLES_WITHOUT_BRACES" | sort | uniq)

    # Displays each tool
    IFS=$'\n#'
    for i in $VARIABLES; do
        if [[ -n $i ]]; then
            echo "-" $i
        fi
    done
}

# Function to generate a menu from multiple recipes
function_menu() {
    # Checks the existence of each recipe
    for i in "${@:2}"; do
        CHEMIN=$(find "$REPERTOIRE" | grep "$i.cook")
        if [[ "$CHEMIN" == "" ]]; then
            echo "[ERROR] $REPERTOIRE$i.cook does not exist."
            exit
        fi
    done

    # Displays the ingredients required for all recipes
    echo -e "Selected folder: $REPERTOIRE\n# Menu of $(date)\n## Ingredients\n"
    for i in "${@:2}"; do
        CHEMIN=$(find "$REPERTOIRE" | grep "$i.cook")
        VARIABLES_WITH_BRACES=$(grep -o -E -i "@[^ }]+}" "$CHEMIN")
        IFS=$'\n@'
        for i in $VARIABLES_WITH_BRACES; do
            if [[ -n $i ]]; then
                # Stores the obtained ingredients in a temporary file to display them in the correct format later
                echo "[ ]" $(echo $i | cut -d "{" -f2 | cut -d "}" -f1 | tr "%" " ") of $(echo $i | cut -d "{" -f1) >> tempo.txt
            fi
        done
    done
    # Displays ingredients in 4 columns
    paste -d '@' - - - - < tempo.txt | column -t -s '@'
    echo -e
    rm tempo.txt

    # Displays the required tools
    echo -e "## Tools\n"
    for i in "${@:2}"; do
        CHEMIN=$(find "$REPERTOIRE" | grep "$i.cook")
        VARIABLES_WITHOUT_BRACES=$(grep -o -E -i "#[a-z( {)]+" "$CHEMIN" | grep -v "{" | cut -d " " -f1)
        VARIABLES_WITH_BRACES=$(grep -o -E -i "#[a-z ]+{" "$CHEMIN" | cut -d "{" -f1)
        VARIABLES=$(echo -e "$VARIABLES_WITH_BRACES\n$VARIABLES_WITHOUT_BRACES" | sort | uniq)
        IFS=$'\n#'
        for i in $VARIABLES; do
            if [[ -n $i ]]; then
                # Stores the obtained tools in a temporary file to display them in the correct format later
                echo "[ ]" $i >> tempo.txt
            fi
        done
    done
    paste -d '@' - - - - < tempo.txt | column -t -s '@'
    echo -e
    rm tempo.txt

    # Displays the content of the recipes
    for i in "${@:2}"; do
        CHEMIN=$(find "$REPERTOIRE" | grep "$i.cook")
        echo "## Recipe: $(basename $CHEMIN)"
        cat "$CHEMIN"
    done
}

# Handles options passed as parameters
case $1 in
    "help") fonction_help ;;
    "list") fonction_list ;;
    "search") fonction_search $2 ;;
    "ingredients") function_ingredients $2 ;;
    "tools") function_tools $2 ;;
    "menu") function_menu "$@";;
    *)
        if [ $# != 0 ]; then
            echo "[ERROR] Incorrect parameter."
        else
            echo "[ERROR] one command is expected."
            fonction_help
        fi
esac
