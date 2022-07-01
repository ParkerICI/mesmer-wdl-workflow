## Copyright Parker Institute for Cancer Immunotherapy, 2021
##
## # boostrapMibiPixels
##
## Workflow for using Zaid Bustami's boostrap immune cell phenotyping method applied to pixels,
## as adapted w/modifications to Python.
##  
## ### Inputs
## multi_tiff: multi-channel tiff file
## hierarchy: a yml file with cell types and markers for cell types.
## panel_excel_file: Excel file containing list of cell types and corresponding priority.
## panel_sheet: Sheet which contains panel info in Excel file.
## sample_id: ID of the sample
## rename_to_sampleid: resulting file is renamed to the provided sample ID (default FALSE)
##
##
##
## Maintainer: Ben Kamphaus (bkamphaus@parkerici.org)
##
## Github: [https://github.com/ParkerICI/mesmer-wdl-workflow](https://github.com/ParkerICI/mesmer-wdl-workflow)
## 
## Licensing :
## This script is released under the PICI Informatics License (GPL-3.0) Note however that the programs it calls may
## be subject to different licenses. Users are responsible for checking that they are
## authorized to run all programs before running this script.

workflow bootstrapMibiPixels {
    File multi_tiff
    File hierarchy
    File panel_excel_file
    String panel_sheet
    Boolean? rename_to_sampleid = false
    String? sample_id 
    Int mem_gb = 4
    String docker_image = "gcr.io/pici-internal/tiff-tools"

    String outfile = if !rename_to_sampleid then "classified.tif" else (sample_id + "_classified.tif")
    String outclasses = if !rename_to_sampleid then "class_labels.csv" else (sample_id + "_class_labels.csv")
    String outlabels = if !rename_to_sampleid then "pixel_labels.csv" else (sample_id + "_pixel_labels.csv")
    call bootstrapPixels { input: multi_tiff=multi_tiff,
                                  mem_gb=mem_gb,
                                  docker_image=docker_image,
                                  hierarchy=hierarchy,
                                  panel_excel_file=panel_excel_file,
                                  panel_sheet=panel_sheet,
                                  outfile=outfile,
                                  outclasses=outclasses,
                                  outlabels=outlabels }
}

task bootstrapPixels {

    File multi_tiff
    File hierarchy
    File panel_excel_file
    String panel_sheet
    String docker_image
    Int mem_gb
    String outfile
    String outclasses
    String outlabels

    command <<<

    python3 /bootstrap_mibi_pixels.py "${multi_tiff}" "${outfile}" --hierarchy "${hierarchy}" --excel "${panel_excel_file}" --excel-sheet "${panel_sheet}" --output-classes "${outclasses}" --output-pixel-labels "${outlabels}"
    
    >>>

    output {
        File output_class_image_file = "${outfile}"
        File output_class_labels_csv = "${outclasses}"
        File output_pixel_labels_tsv = "${outlabels}"
    }

    runtime {
        docker: docker_image
        memory: mem_gb + "GB"
    }
}
