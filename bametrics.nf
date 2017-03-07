#! /usr/bin/env nextflow

// usage : ./bametrics.nf --bam_folder BAM/ --input_positions positions_by_sample.txt --output_file bametrics_output.txt

// parameters definition

params.help = null
params.bam_folder = null
params.input_positions = null
params.output_file = null
output_file = params.output_file ? params.output_file : "bametrics_output.txt"
params.metrics = "AS"
params.nb_chunks = 1
params.out_folder = "."

bam = Channel.fromPath( params.bam_folder+'/*.bam' ).collect()
bai = Channel.fromPath( params.bam_folder+'/*.bam.bai' ).collect()
input_positions = file(params.input_positions)

if (params.help) {
    log.info ''
    log.info '-----------------------------------------------------------------'
    log.info '                 BAMETRICS PIPELINE WITH NEXTFLOW                  '
    log.info '-----------------------------------------------------------------'
    log.info ''
    log.info 'Usage: '
    log.info 'nextflow run /bametrics.nf --bam_folder BAM/ --input_positions positions_by_sample.txt --out_file bametrics_output.txt --metrics AS,XS,MQ'
    log.info ''
    log.info 'Mandatory arguments:'
    log.info '    --bam_folder         FOLDER                  Folder containing BAM for each sample you want metrics on position.'
    log.info '    --input_positions    FILE                    File containing position-sample, in line-form "chr pos sample".'
    log.info 'Optional arguments:'
    log.info '    --nb_chunks          INTEGER                 Value defining the number of parallelized processed chunks.'
    log.info '    --output_file        FILE                    File name of the output. Default: bametrics_output.txt'
    log.info '    --out_folder         FOLDER                  Output directory, by default current working directory.'
    log.info '    --metrics            comma-del STRING        List of bam metrics, comma delimited. Default:AS.'
    log.info ''
    log.info ''
    exit 1
}

process split_positions {

  input:
  file input_positions

  output:
  file 'split*' into splitted_positions mode flatten

  shell:
  '''
  split.sh !{input_positions} !{params.nb_chunks}
  '''

}

process get_bam_metrics {

  input:
  file spos from splitted_positions
  file 'BAM/*' from bam
  file 'BAM/*' from bai

  output:
  file '*.txt' into output_bam_metrics_process

  shell:
  '''
  get_metrics.sh !{spos} !{spos}_output_bam_metrics.txt !{params.metrics}
  '''

}

process merge_bam_metrics {

  publishDir params.out_folder, mode: 'move'

  input:
  val output_file
  file all_bam_metrics_files from output_bam_metrics_process.toList()

  output:
  file "$output_file" into merged_bam_metrics

  shell:
  '''
  head -n1 !{all_bam_metrics_files[0]} > !{output_file}
  for file in !{all_bam_metrics_files}
  do
	 tail -n+2 $file >> !{output_file}
  done
  '''

}
