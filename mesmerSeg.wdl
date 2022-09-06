## Copyright Parker Institute for Cancer Immunotherapy, 2021
##
## # Mesmer
##
## Workflow for Mesmer segmentation of tiff images
##  
## ### Inputs
## flat_nuc: flattened (single channel) nuclear image, Required
## flat_cyto: flattened (single channel) cytoplasmic/membrane image
## compartment: type of segmentation to run. must be one of: "nuclear" or whole-cell"
##     NOTE: use of "whole-cell" requires a flat_cyto input file
## sample_id: ID of the sample used for the cyto and nuc images
## rename_to_sampleid: resulting mask files are renamed to the provided sample ID (default FALSE)
##
## Maintainer: Marshall Thompson (mthompson@parkerici.org)
##
## Github: [https://github.com/ParkerICI/mesmer-wdl-workflow](https://github.com/ParkerICI/mesmer-wdl-workflow)
## 
## Licensing :
## This script is released under the PICI Informatics License (GPL-3.0) Note however that the programs it calls may
## be subject to different licenses. Users are responsible for checking that they are
## authorized to run all programs before running this script.

workflow mesmerWorkflow {
    File flat_nuc
    File? flat_cyto
    String compartment = "nuclear"
    Boolean? rename_to_sampleid = false
    String? sample_id 

    Int mem_gb = 4
    String docker_image = "vanvalenlab/deepcell-applications:0.4.0-gpu"

#    if (compartment == "both") { 
#        call mesmer_both { input: flat_nuc=flat_nuc, flat_cyto=flat_cyto, mem_gb=mem_gb,
#                         docker_image = docker_image }
#    }

    String nuc_mask_name = if !rename_to_sampleid then "nuc_mask.tif" else (sample_id + "_nuc_mask.tif")
    String wc_mask_name = if !rename_to_sampleid then "wc_mask.tif" else (sample_id + "_wc_mask.tif")

    if (compartment == "whole-cell") { 
        call mesmer_wc { input: flat_nuc=flat_nuc, flat_cyto=flat_cyto, mem_gb=mem_gb,
                         mask_name=wc_mask_name, docker_image=docker_image }
    }
    if (compartment == "nuclear") { 
        call mesmer_nuc { input: flat_nuc=flat_nuc, mem_gb=mem_gb,                         
                          mask_name=nuc_mask_name, docker_image=docker_image }
    }    
}

task mesmer_nuc {

    File flat_nuc
    String docker_image
    Int mem_gb
    String mask_name

    command <<<

    export NUC_FILE="${flat_nuc}"
    export OUT_FILE="${mask_name}"

    python /usr/src/app/run_app.py mesmer --nuclear-image "$NUC_FILE" \
      --output-directory /usr/src/app --output-name $OUT_FILE \
      --compartment "nuclear"

    echo "copying result mask"
    cp /usr/src/app/$OUT_FILE .
    
    >>>

    output {
        File cell_mask = "${mask_name}"
    }

    runtime {
        gpuType: "nvidia-tesla-k80"
        gpuCount: 2
        docker: docker_image
        memory: mem_gb + "GB"
    }
}

task mesmer_wc {
    File flat_cyto
    File flat_nuc
    String docker_image
    Int mem_gb
    String mask_name

    command <<<

    export NUC_FILE="${flat_nuc}"
    export MEM_FILE="${flat_cyto}"
    export OUT_FILE="${mask_name}"

    python /usr/src/app/run_app.py mesmer --nuclear-image "$NUC_FILE" \
      --membrane-image "$MEM_FILE" --output-directory /usr/src/app \
      --output-name $OUT_FILE --compartment "whole-cell"

    echo "copying result mask"
    cp /usr/src/app/$OUT_FILE .
    
    >>>

    output {
        File cell_mask = "${mask_name}"
    }

    runtime {
        docker: docker_image
        memory: mem_gb + "GB"
    }
}

## This task is commented for now, as the mesmer output when using "both"
## is not as expected (not creating a dual channel tiff)
# task mesmer_both {
#
#    File flat_cyto
#    File flat_nuc
#    String docker_image
#    Int mem_gb
#
#    command <<<
#
#    export NUC_FILE="${flat_nuc}"
#    export MEM_FILE="${flat_cyto}"
#
#    python /usr/src/app/run_app.py mesmer --nuclear-image "$NUC_FILE" \
#      --membrane-image "$MEM_FILE" --output-directory /usr/src/app \
#      --output-name mask.tif --compartment "both"
#
#    echo "copying result mask"
#    cp /usr/src/app/mask.tif .
#    
#    >>>
#
#    output {
#        File cell_mask = "mask.tif"
#    }
#
#    runtime {
#        docker: docker_image
#        memory: mem_gb + "GB"
#    }
# }


