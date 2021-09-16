## Test workflow for mesmer
## Super minimal

workflow mesmerWorkflow {
    File flat_nuc
    File flat_cyto
    Int mem_gb
    
    call mesmer { input: flat_nuc=flat_nuc, flat_cyto=flat_cyto, mem_gb=mem_gb }
}

task mesmer {

    File flat_nuc
    File flat_cyto
    Int mem_gb
    
    command <<<

    export NUCLEAR_FILE=${flat_nuc}
    export MEMBRANE_FILE=${flat_cyto}

    python /usr/src/app/run_app.py mesmer --nuclear-image $NUCLEAR_FILE \
      --nuclear-channel 0 --membrane-image $MEMBRANE_FILE \
      --membrane-channel 1 --output-directory /usr/src/app --output-name mask.tif \
      --compartment whole-cell

    echo "copying result mask"
    cp /usr/src/app/mask.tif .
    
    >>>

    output {
        File cell_mask = "mask.tif"
    }

    runtime {
        docker: "vanvalenlab/deepcell-applications:0.3.0"
        memory: mem_gb + "GB"
    }
}


