## Copyright Parker Institute for Cancer Immunotherapy, 2022
##
## # expandSegmentation
##
## Workflow for expanding original segment borders using the output of pixel typing.
##  
## ### Inputs
## mask: whole cell segmentation mask (tif)
## segment_types_csv: output from segment typing (csv)
## pixel_types_csv: output from pixel typing (csv)
## cell_types: potential cell type assignments and their priorities (csv)
## sample_id: ID of the sample
## rename_to_sampleid: resulting file is renamed to the provided sample ID (default FALSE)
##
##
##
## Maintainer: Jessica Maxey (jmaxey@parkerici.org)
##
## Github: [https://github.com/ParkerICI/mesmer-wdl-workflow](https://github.com/ParkerICI/mesmer-wdl-workflow)
## 
## Licensing :
## This script is released under the PICI Informatics License (GPL-3.0) Note however that the programs it calls may
## be subject to different licenses. Users are responsible for checking that they are
## authorized to run all programs before running this script.

workflow expandSegmentation {
    File mask
    File segment_types_csv
    File pixel_types_csv
    Boolean? rename_to_sampleid = false
    String? sample_id 
    Int mem_gb = 4
    String docker_image = "gcr.io/pici-internal/tiff-tools"

    String outfile = if !rename_to_sampleid then "expanded_segment_types.csv" else (sample_id + "_expanded_segment_types.csv")
    String outmask = if !rename_to_sampleid then "expanded_full_mask.tif" else (sample_id + "_expanded_full_mask.tif")
    
    call runExpansion   {         input: mask=mask,
                                  mem_gb=mem_gb,
                                  docker_image=docker_image,
                                  segment_types_csv=segment_types_csv,
                                  pixel_types_csv=pixel_types_csv,
                                  outfile=outfile,
                                  outmask=outmask}
}

task runExpansion {

    File mask
    File segment_types_csv
    File pixel_types_csv
    String docker_image
    Int mem_gb
    String outfile
    String outmask

    command <<<

    python /expand_segmentation.py "${mask}" "${segment_types_csv}" "${pixel_types_csv}"
    mv expanded_segment_types.csv "${outfile}" ## Rename segment_types.csv to "outfile" 
    mv expanded_full_mask.tif "${outmask}"

    >>>

    output {
        File output_expanded_segment_file = "${outfile}"
        File output_expanded_mask_file = "${outmask}"
    }

    runtime {
        docker: docker_image
        memory: mem_gb + "GB"
    }
}
