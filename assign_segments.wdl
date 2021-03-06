## Copyright Parker Institute for Cancer Immunotherapy, 2022
##
## # assignSegments
##
## Workflow for assigning cell types to segments using the output of pixel typing.
##  
## ### Inputs
## mask: whole cell segmentation mask (tif)
## types_csv: output from pixel typing (csv)
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

workflow assignSegments {
    File mask
    File types_csv
    File cell_types
    Boolean? rename_to_sampleid = false
    String? sample_id 
    Int mem_gb = 4
    String docker_image = "gcr.io/pici-internal/tiff-tools"

    String outfile = if !rename_to_sampleid then "typed_segments.csv" else (sample_id + "_typed_segments.csv")
    
    call runAssignment  {         input: mask=mask,
                                  mem_gb=mem_gb,
                                  docker_image=docker_image,
                                  types_csv=types_csv,
                                  cell_types=cell_types,
                                  outfile=outfile}
}

task runAssignment {

    File mask
    File types_csv
    File cell_types
    String docker_image
    Int mem_gb
    String outfile

    command <<<

    python /type_segments.py "${mask}" "${types_csv}" "${cell_types}"
    mv segment_types.csv "${outfile}" ## Rename segment_types.csv to "outfile" 

    >>>

    output {
        File output_segment_class_file = "${outfile}"
    }

    runtime {
        docker: docker_image
        memory: mem_gb + "GB"
    }
}
