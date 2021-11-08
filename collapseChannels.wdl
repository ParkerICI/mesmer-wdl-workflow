## Copyright Parker Institute for Cancer Immunotherapy, 2021
##
## # collapseChannels
##
## Workflow for combining/flattening channels from a multi-layer tiff
##  
## ### Inputs
## multi_tiff: multi-channel tiff file
## channel_ids: list of channels to combine/collapse, json string (i.e. "[1, 2, 3]")
## sample_id: ID of the sample 
## rename_to_sampleid: resulting file is renamed to the provided sample ID (default FALSE)
##
## Maintainer: Marshall Thompson (mthompson@parkerici.org)
##
## Github: [https://github.com/ParkerICI/mesmer-wdl-workflow](https://github.com/ParkerICI/mesmer-wdl-workflow)
## 
## Licensing :
## This script is released under the PICI Informatics License (GPL-3.0) Note however that the programs it calls may
## be subject to different licenses. Users are responsible for checking that they are
## authorized to run all programs before running this script.

workflow collapseChannels {
    File multi_tiff
    String channel_ids
    Boolean? rename_to_sampleid = false
    String? sample_id 
    Int mem_gb = 2
    String docker_image = "gcr.io/pici-internal/tiff-tools"

    String outfile = if !rename_to_sampleid then "combined.tif" else (sample_id + "_combined.tif")

    call collapse { input: multi_tiff=multi_tiff, mem_gb=mem_gb, docker_image=docker_image, channel_ids=channel_ids, outfile=outfile }
}

task collapse {

    File multi_tiff
    String docker_image
    Int mem_gb
    String channel_ids
    String outfile

    command <<<

    python3 /collapse.py "${multi_tiff}" "${outfile}" 
    
    >>>

    output {
        File combined_tiff = "${outfile}"
    }

    runtime {
        docker: docker_image
        memory: mem_gb + "GB"
    }
}
