params.step = 0


workflow{

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        in_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true)
        in_ch.view()
    }


    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {
        in_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true).map{
            row ->
                def meta = row.findAll { key, value -> !key.startsWith('fastq')}
                def fastq_1 = row.fastq_1
                def fastq_2 = row.fastq_2
                def fastqs = [fastq_1, fastq_2]
                [meta,fastqs]
        }
        in_ch.view()
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {
    in_ch = channel.fromPath('samplesheet.csv')
        .splitCsv(header:true)
        .map { row ->
            def meta = row.findAll { k, v -> !k.startsWith('fastq') }
            def fastqs = row.findAll { k, v -> k.startsWith('fastq') }.values().toList()
            [meta, fastqs]
        }
    grouped_by_strand = in_ch.map { meta, fastqs -> tuple( meta.strandedness, meta.sample, fastqs)}.groupTuple(by: 0)
    grouped_by_strand.view { strand, metas, fastq_lists ->
        "Strandedness=${strand} | meta=${metas} | fastqs=${fastq_lists}"
    }
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {
            in_ch = channel.fromPath('samplesheet.csv')
        .splitCsv(header:true)
        .map { row ->
            def meta = row.findAll { k, v -> !k.startsWith('fastq') }
            def fastqs = row.findAll { k, v -> k.startsWith('fastq') }.values().toList()
            [meta, fastqs]
        }
    grouped_by_strand = in_ch.map { meta, fastqs -> tuple( meta.strandedness, meta.sample, fastqs)}.groupTuple(by: [0,1])
    grouped_by_strand.view { strand, metas, fastq_lists ->
        "Strandedness=${strand} | meta=${metas} | fastqs=${fastq_lists}"
    }
    }



}