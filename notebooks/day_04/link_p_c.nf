#!/usr/bin/env nextflow

process SPLITLETTERS {
    input:
    tuple val(block_size), val(in_str), val(prefix)

    output:
    tuple val(prefix), path("chunks/*.txt")

    script:
    """
    mkdir -p chunks
    python3 -c "
import sys, os
bs = int('${block_size}')
string = '${in_str}'
outfile = '${prefix}'
os.makedirs('chunks', exist_ok=True)
for i in range(0, len(string), bs):
    idx = i//bs + 1
    with open(os.path.join('chunks', f'{outfile}_{idx}.txt'), 'w') as f:
        f.write(string[i:i+bs])
"
    """
}
process CONVERTTOUPPER {

input:
    tuple val(prefix), path(chunk_files)

    output:
    stdout

    script:
    """
    for file in ${chunk_files}; do
        tr '[:lower:]' '[:upper:]' < \$file
        echo ""
    done
    """
}
workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    in_ch = channel.fromPath('samplesheet_2.csv').splitCsv(header:true)
        .map { row ->
        def block_size = row.block_size
        def string = row.input_str
        def outfile = row.out_name
        [block_size, string, outfile]
        }
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
        split_ch = SPLITLETTERS(in_ch)
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout
        CONVERTTOUPPER(split_ch).view()
    // read in samplesheet}

    // split the input string into chunks

    // lets remove the metamap to make it easier for us, as we won't need it anymore

    // convert the chunks to uppercase and save the files to the results directory
 individual_files = split_ch
        .transpose()
        .view { prefix, file -> "${file}" }

}