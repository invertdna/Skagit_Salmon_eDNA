#!/usr/bin/env bash

# subset a geotif raster / array

# author: Jimmy O'Donnell < jodonnellbio@gmail.com >

infile="${1}"

outfile="${infile%.*}_subset.tif"

xleft="-122.84"
xright="-122.25"

yupper="48.48"
ylower="48.18"

gdal_translate \
    -projwin "${xleft}" "${yupper}" "${xright}" "${ylower}" \
    "${infile}" \
    "${outfile}"
