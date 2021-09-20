## Copyright Parker Institute for Cancer Immunotherapy, 2021
##
## # Mesmer
##
## Workflow for Mesmer segmentation of tiff images
##  
## ### Inputs
## flat_nuc: flattened (single channel) nuclear image, Required
## flat_cyto: flattened (single channel) cytoplasmic/membrane image
## compartment: type of segmentation to run. must be one of: "nuclear", whole-cell", "both"
##     NOTE: use of "whole-cell" or "both" requires a flat_cyto input file
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

    Int mem_gb = 4
    String docker_image = "vanvalenlab/deepcell-applications:0.3.0"

    if (compartment == "both") { 
        call mesmer_both { input: flat_nuc=flat_nuc, flat_cyto=flat_cyto, mem_gb=mem_gb,
                         docker_image = docker_image }
    }
    if (compartment == "whole-cell") { 
        call mesmer_wc { input: flat_nuc=flat_nuc, flat_cyto=flat_cyto, mem_gb=mem_gb,
                         docker_image = docker_image }
    }
    if (compartment == "nuclear") { 
        call mesmer_nuc { input: flat_nuc=flat_nuc, mem_gb=mem_gb, docker_image = docker_image }
    }    
}

task mesmer_nuc {

    File flat_nuc
    String docker_image
    Int mem_gb

    command <<<

    export NUC_FILE=${flat_nuc}

    python /usr/src/app/run_app.py mesmer --nuclear-image $NUC_FILE \
      --output-directory /usr/src/app --output-name mask.tif \
      --compartment "nuclear"

    echo "copying result mask"
    cp /usr/src/app/mask.tif .
    
    >>>

    output {
        File cell_mask = "mask.tif"
    }

    runtime {
        docker: docker_image
        memory: mem_gb + "GB"
    }
}

task mesmer_wc {
    File flat_cyto
    File flat_nuc
    String docker_image
    Int mem_gb

    command <<<

    export NUC_FILE=${flat_nuc}
    export MEM_FILE=${flat_cyto}

    python /usr/src/app/run_app.py mesmer --nuclear-image $NUC_FILE \
      --membrane-image $MEM_FILE --output-directory /usr/src/app \
      --output-name mask.tif --compartment "whole-cell"

    echo "copying result mask"
    cp /usr/src/app/mask.tif .
    
    >>>

    output {
        File cell_mask = "mask.tif"
    }

    runtime {
        docker: docker_image
        memory: mem_gb + "GB"
    }
}

task mesmer_both {

    File flat_cyto
    File flat_nuc
    String docker_image
    Int mem_gb

    command <<<

    export NUC_FILE=${flat_nuc}
    export MEM_FILE=${flat_cyto}

    python /usr/src/app/run_app.py mesmer --nuclear-image $NUC_FILE \
      --membrane-image $MEM_FILE --output-directory /usr/src/app \
      --output-name mask.tif --compartment "both"

    echo "copying result mask"
    cp /usr/src/app/mask.tif .
    
    >>>

    output {
        File cell_mask = "mask.tif"
    }

    runtime {
        docker: docker_image
        memory: mem_gb + "GB"
    }

}


