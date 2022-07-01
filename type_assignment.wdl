## Copyright Parker Institute for Cancer Immunotherapy, 2021
##
## # Segment typing 
##
## Workflow for running segment typing using pixel bootstrapping 
##  
## ### Inputs
## multi_tiff: multi-layer tiff file to be segmented
## hierarchy: a yml file with cell types and markers for cell types.
## panel_excel_file: Excel file containing list of cell types and corresponding priority.
## panel_sheet: Sheet which contains panel info in Excel file.
## cell_types: potential cell type assignments and their priorities (csv)
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

import "https://raw.githubusercontent.com/ParkerICI/mesmer-wdl-workflow/master/bootstrap-mibi-pixels.wdl" as type_pixels
import "https://raw.githubusercontent.com/ParkerICI/mesmer-wdl-workflow/master/assign_segments.wdl" as type_segments

workflow segmentation {
    File multi_tiff
    File hierarchy
    File panel_excel_file
    File cell_types
    String panel_sheet

    Boolean? rename_to_sampleid = false
    String? sample_id 

    Int mem_gb = 4
    String pixels_docker_image = "gcr.io/pici-internal/tiff-tools:0.6"
    String segments_docker_image = "gcr.io/pici-internal/tiff-tools:0.6"

    String outim = if !rename_to_sampleid then "classified.tif" else (sample_id + "_classified.tif")
    String outclasses = if !rename_to_sampleid then "class_labels.csv" else (sample_id + "_class_labels.csv")
    String outpixels = if !rename_to_sampleid then "pixel_labels.csv" else (sample_id + "_pixel_labels.csv")
    String outsegments = if !rename_to_sampleid then "typed_segments.csv" else (sample_id + "_typed_segments.csv")

    call type_pixels.bootstrapPixels as bootstrapPixels { 
        input: 
        multi_tiff=multi_tiff,
        mem_gb=mem_gb,
        docker_image=pixels_docker_image,
        hierarchy=hierarchy,
        panel_excel_file=panel_excel_file,
        panel_sheet=panel_sheet,
        outim=outim,
        outclasses=outclasses,
        outpixels=outpixels
    }
    call type_segments.runAssignment as runAssignment { 
        input: 
        mask=mask,
        mem_gb=mem_gb,
        docker_image=segments_docker_image,
        types_csv=bootstrapPixels.output_pixel_labels_csv,
        cell_types=cell_types,
        outsegments=outsegments

    }


      output {
        File nuc_mask = mesmerNuc.cell_mask
        File? wc_mask = mesmerWC.cell_mask

        File output_class_image_file = bootstrapPixels.output_class_image_file
        File output_class_labels_csv = bootstrapPixels.output_class_labels_csv
        File output_pixel_labels_csv = bootstrapPixels.output_pixel_labels_csv

        File output_segment_class_file = runAssignment.output_segment_class_file

      }
}


