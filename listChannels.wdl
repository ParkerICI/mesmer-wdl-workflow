## Copyright Parker Institute for Cancer Immunotherapy, 2021
##
## # listChannels
##
## Workflow for listing channel names from a multi-layer tiff
##  
## ### Inputs
## multi_tiff: multi-channel tiff file
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

workflow listChannels {
    File multi_tiff
    Boolean? rename_to_sampleid = false
    String? sample_id 
    Int mem_gb = 2
    String docker_image = "gcr.io/pici-internal/tiff-tools"

    String outfile = if !rename_to_sampleid then "channellist.txt" else (sample_id + "_channellist.txt")

    call list { input: multi_tiff=multi_tiff, mem_gb=mem_gb, docker_image=docker_image, outfile=outfile }
}

task list {

    File multi_tiff
    String docker_image
    Int mem_gb
    String outfile

    command <<<

    python3 /listchannels.py "${multi_tiff}" "${outfile}"
    
    >>>

    output {
        File channel_list = "${outfile}"
    }

    runtime {
        docker: docker_image
        memory: mem_gb + "GB"
    }
}
