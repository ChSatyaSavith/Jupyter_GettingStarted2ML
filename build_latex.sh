#!/bin/bash

# Description:        Compile PDF from Jupyter notebook with BibLaTeX references
### END INIT INFO
#
# Author:             Bjoern Kasper
# Copyright:          GPL v3.0 and later
# Date:               2022-08-29
# Changed:            
#
# Short-Description:  Compile PDF from Jupyter notebook with BibLaTeX references
#
# Changelog:
#
###

CMD=$1
NOTEBOOK_FILE=`basename ${2%.*}`

USED_PROGRAMS_ARRAY=(
    "jupyter"
    "pdflatex"
    "biber"
    )

LATEX_FILE_EXTENSIONS_TO_CLEAN_ARRAY=(
    ".aux"
    ".bbl"
    ".bcf"
    ".blg"
    ".log"
    ".out"
    ".run.xml"
    ".toc"
    ".synctex.gz"
    )

LATEX_TMP_DIRECTORY_TO_CLEAN=${NOTEBOOK_FILE}_files

#function that checks if dependencies are installed
function check_software {
    printf "Checking if dependencies are installed ...\n";
    for index in ${!USED_PROGRAMS_ARRAY[*]}
    do
        if !( type "${USED_PROGRAMS_ARRAY[$index]}" > /dev/null 2>&1 ); then
            printf "Error: Please install %s first!\n" "${USED_PROGRAMS_ARRAY[$index]}";
            exit 1;
        fi
    done
    printf "Success: All dependencies are installed\n";
}

#function that cleans temporary build files and folders
function clean_build_artefacts {
    printf "Cleaning temporary build artefacts ...\n";
    for index in ${!LATEX_FILE_EXTENSIONS_TO_CLEAN_ARRAY[*]}
    do
        FILE_TO_CLEAN="$NOTEBOOK_FILE${LATEX_FILE_EXTENSIONS_TO_CLEAN_ARRAY[$index]}"
        if [ -f $FILE_TO_CLEAN ]; then
            printf "File to remove: %s\n" "$FILE_TO_CLEAN";
            rm -rf $FILE_TO_CLEAN
        else
            printf "Error: file for cleaning not found: %s\n" "$FILE_TO_CLEAN";
        fi
    done

    if [ -d $LATEX_TMP_DIRECTORY_TO_CLEAN ]; then
        printf "Directory to remove: %s\n" "$LATEX_TMP_DIRECTORY_TO_CLEAN";
        rm -rf $LATEX_TMP_DIRECTORY_TO_CLEAN
    else
        printf "Error: directory for cleaning not found: %s\n" "$LATEX_TMP_DIRECTORY_TO_CLEAN"
    fi
}

function usage {
    printf "***\n"
    printf "Usage:\n"
    printf "Compile PDF from Juypter notebook: %s compile <notebook file>\n" "$0";
    printf "Cleanup temporary build artefacts: %s clean <notebook file>\n" "$0";
    printf "***\n"
    exit 0;
}

check_software;

case "$CMD" in
    compile)
        # command "test -n" is buggy! using negated "test -z"!
        if ! [ -z $NOTEBOOK_FILE.ipynb ]; then
            jupyter nbconvert $NOTEBOOK_FILE.ipynb --to latex
            pdflatex $NOTEBOOK_FILE.tex
            biber $NOTEBOOK_FILE.bcf
            pdflatex $NOTEBOOK_FILE.tex
            pdflatex $NOTEBOOK_FILE.tex

            printf "Compiling was successful.\n";
        else
            printf "Error: Please provide a valid filename for compiling!\n";
            usage;
            exit 1;
        fi

        exit 0
        ;;

    clean)
        if [ -f $NOTEBOOK_FILE.ipynb ]; then
            clean_build_artefacts;
        else
            printf "Error: Please provide a valid filename for cleaning!\n";
            usage;
            exit 1;
        fi

        exit 0
        ;;

    *)
        usage;

        exit 1
        ;;

esac

exit 0
