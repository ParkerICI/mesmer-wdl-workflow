## Copyright Parker Institute for Cancer Immunotherapy, 2021
##
## # Boundary Analysis
##
## Workflow for boundary segment analysis
##  
## ### Inputs
## multi_tiff: multi-layer tiff file
## nuc_mask: nuclear mask (Mesmer output)
## wc_mask: whole cell mask (Mesmer output)
## 
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

workflow boundaryAnalysis {
    File multi_tiff
    File nuc_mask
    File wc_mask
    Boolean? rename_to_sampleid = false
    String? sample_id 

    Int mem_gb = 4
    String docker_image = "gcr.io/pici-internal/tiff-tools"

    String outfile_prefix = if !rename_to_sampleid then "segment_analysis" else sample_id

    call segment_analysis { 
        input: 
        multi_tiff=multi_tiff,
        nuc_mask=nuc_mask,
        wc_mask=wc_mask,
        outfile_prefix=outfile_prefix,
        mem_gb=mem_gb, 
        docker_image=docker_image 
    }
}

task segment_analysis {

    File multi_tiff
    File nuc_mask
    File wc_mask
    String docker_image
    Int mem_gb
    String outfile_prefix

    command <<<

    python3 /segment_summary.py "${multi_tiff}" "${wc_mask}" "${nuc_mask}" "${outfile_prefix}" 

    cp /usr/src/app/$OUT_FILE .
    
    >>>

    output {
        File nuc_intensities = "${outfile_prefix}.nuclear_intensities.tsv"
        File nonnuc_intensities = "${outfile_prefix}.nonnuclear_intensities.tsv"
        File membrane_intensities = "${outfile_prefix}.membrane_intensities.tsv"
        File segment_intensities = "${outfile_prefix}.segment_intensities.tsv"
        File segment_features = "${outfile_prefix}.segment_features.tsv"
        File boundary_features = "${outfile_prefix}.boundary_features.tsv"
        File boundary_intensities = "${outfile_prefix}.boundary_intensities.tsv"
    }

    runtime {
        docker: docker_image
        memory: mem_gb + "GB"
    }
}