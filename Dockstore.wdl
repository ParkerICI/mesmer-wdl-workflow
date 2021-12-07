## Copyright Parker Institute for Cancer Immunotherapy, 2021
##
## # Mesmer segmentation 
##
## Workflow for running mesmer segmentation of tiff images
##  
## ### Inputs
## multi_tiff: multi-layer tiff file to be segmented
## nuc_channel_ids: list of channels to combine/collapse for nuclear signal, json string (i.e. "[1, 2, 3]")
## wc_channel_ids: list of channels to combine/collapse for membrane signal, json string (i.e. "[1, 2, 3]")
## run_wc: boolean indicating whether whole cell segmentation should be run (default false)
##     NOTE: use of "run_wc" requires a wc_channel_ids argument
## sample_id: ID of the sample
## rename_to_sampleid: resulting mask files are renamed to the provided sample ID (default false)
##
## mem_gb: Gb of memory to provision for the mesmer worker
## mesmer_docker_image: docker image that includes the mesmer tool
## tiff_tools_docker_image: docker image that includes combine/collapse tiff tool
## 
## Maintainer: Marshall Thompson (mthompson@parkerici.org)
##
## Github: [https://github.com/ParkerICI/mesmer-wdl-workflow](https://github.com/ParkerICI/mesmer-wdl-workflow)
## 
## Licensing :
## This script is released under the PICI Informatics License (GPL-3.0) Note however that the programs it calls may
## be subject to different licenses. Users are responsible for checking that they are
## authorized to run all programs before running this script.

import "https://github.com/ParkerICI/mesmer-wdl-workflow/blob/master/mesmerSeg.wdl" as mesmer
import "https://github.com/ParkerICI/mesmer-wdl-workflow/blob/master/collapseChannels.wdl" as tifftools

workflow segmentation {
    File multi_tiff
    String nuc_channel_ids
    String? wc_channel_ids
    Boolean? run_wc = false

    Boolean? rename_to_sampleid = false
    String? sample_id 

    Int mem_gb = 4
    String mesmer_docker_image = "vanvalenlab/deepcell-applications:0.3.1"
    String tiff_tools_docker_image = "gcr.io/pici-internal/tiff-tools"


    String nuc_outfile = if !rename_to_sampleid then "combined.tif" else (sample_id + "_combined.tif")
    String nuc_mask_name = if !rename_to_sampleid then "nuc_mask.tif" else (sample_id + "_nuc_mask.tif")

    call tifftools.collapse as nucCollapse { 
        input: 
        multi_tiff=multi_tiff, 
        mem_gb=mem_gb, 
        docker_image=tiff_tools_docker_image, 
        channel_ids=channel_ids, 
        outfile=nuc_outfile 
    }
    call mesmer.mesmer_nuc as mesmerNuc { 
        input: 
        flat_nuc=nucCollapse.combined_tiff, 
        mem_gb=mem_gb, 
        mask_name=nuc_mask_name, 
        docker_image=mesmer_docker_image 
    }

    if(run_wc){
        String wc_outfile = if !rename_to_sampleid then "combined.tif" else (sample_id + "_combined.tif")
        String wc_mask_name = if !rename_to_sampleid then "wc_mask.tif" else (sample_id + "_wc_mask.tif")
        call tifftools.collapse as wcCollapse { 
            input: 
            multi_tiff=multi_tiff, 
            mem_gb=mem_gb, 
            docker_image=tiff_tools_docker_image, 
            channel_ids=channel_ids, 
            outfile=wc_outfile 
        }
        call mesmer.mesmer_wc as mesmerWC { 
            input: 
            flat_nuc=nucCollapse.combined_tiff, 
            flat_cyto=wcCollapse.combined_tiff, 
            mem_gb=mem_gb,
            mask_name=wc_mask_name, 
            docker_image=mesmer_docker_image 
        }
    }

      output {
        File nuc_mask = mesmerNuc.cell_mask
        File? wc_mask = mesmerWC.cell_mask
      }
}


