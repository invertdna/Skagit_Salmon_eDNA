#!/usr/bin/env bash

# Author: Jimmy O'Donnell <jodonnellbio@gmail.com>

################################################################################

target_dir="${1}"

outfile="${target_dir}"/packages_required.txt

if [[ -f "${outfile}" ]]; then
    echo "${outfile}" exists. Overwriting...
fi

egrep '(library\(|require\()' -r "${target_dir}" \
    --include \*.r --include \*.R  |\
    awk -F'[()]' '{ print $2 }' |\
    sort |\
    uniq > "${outfile}"

echo "Required R packages:"
cat "${outfile}"

echo
echo "Written to ""${outfile}"

