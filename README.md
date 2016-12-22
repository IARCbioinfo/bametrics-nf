# bametrics-nf

###  Nextflow pipeline to compute average metrics from reads that overlap a given set of positions

#### Dependencies

1. Install [nextflow](http://www.nextflow.io/).

	```bash
	curl -fsSL get.nextflow.io | bash
	```
	And move it to a location in your `$PATH` (`/usr/local/bin` for example here):
	```bash
	sudo mv nextflow /usr/local/bin
	```
#### Input files and options

Command line example:
```
nextflow run bametrics.nf --bam_folder BAM/ --input_positions positions_by_sample.txt --output_file bametrics_output.txt
```

Options:

| Parameter | Default value | Description |
|-----------|--------------:|-------------|
|	|	required	|	|
| bam_folder    |            - | Folder containing BAM for each sample you want metrics on position |
| input_positions | - |  File containing position-sample, in line-form "chr pos sample" |
|	|	optional	|	|
| nb_chunks | 1 | Value defining the number of parallelized processed chunks |
| output_file | bametrics_output.txt | File name of the output |
| out_folder | . | Output directory |
| metrics | "AS" | List of bam metrics, comma delimited |

#### Pipeline execution DAG
<img align="center" src="https://cloud.githubusercontent.com/assets/13535602/21317846/24ba8f90-c607-11e6-88e5-469f9e21f16f.png" width="400">
