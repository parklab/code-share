# Ensembl Variant Effect Predictor on O2

The Variant Effect Predictor (VEP) is a tool for annotating a set of variants. This pipeline uses VEP v105 and is designed to run on O2, the Harvard Medical School cluster, with the SLURM job scheduler.

The pipeline includes several useful features. The pipeline breaks up the input VCF by chromosome and then further breaks up each chromosome into chunks of 200000 variants by default (the chunk size can be set manually via flags). These chunks are each annotated in parallel and then merged back together to allow for faster compute times. The tool also allows for the usage of all additional plugins and custom tracks used in the CGAP version of the VEP pipeline (github.com/dbmi-bgm/cgap-pipeline-SNV-germline/blob/8d991a7e4e5ef524ba1a49c6f65291429d687323/dockerfiles/snv_germline_vep/vep-annot.sh) through the setting of various flags. If you would like to run VEP with default settings, these flags do not need to be set. Finally, there are several wrapper scripts that enable the VEP tool to be more easily run.

## Usage
To run VEP on a VCF file, follow the steps provided in the file 00_o2_vep_pipeline.sh. Set the variables at the top of the file to your specific desired input file and output directory, among other settings. Step 0 of the file instructs you to create and activate a conda environment for VEP based on the provided .yaml file. Step 1 then runs VEP on the provided VCF file with the specified custom tracks and plugins. The pipeline presumes the input VCF file is formatted properly (indexed and gunzipped and with a header).

For reference, to analyze 540K variants with a chunk size of 100000, the allocated resources were 32GB RAM, 8 cores, and 2 hours. To analyze 6.7M variants with a chunk size of 200000, the allocated resources were 128GB RAM, 24 cores, and 6 hours. These resources will likely have to be adjusted to fit your specific files.

## Known Warning Messages and Bugs
The following warning messages are known to be returned to the Slurm output file:

```Possible precedence issue with control flow operator at /home/wif049/.conda/envs/vep/lib/site_perl/5.26.2/Bio/DB/IndexedBase.pm line 805.``` 
This warning message is a BioPerl issue and harmless. It has been reported previously (https://github.com/bioperl/bioperl-live/issues/236, https://github.com/bioperl/bioperl-live/issues/355, https://github.com/Ensembl/ensembl-vep/issues/75) and was supposedly fixed in a previous version of BioPerl.

```gzip: stdout: Broken pipe``` 
This warning message has been previously reported (https://github.com/Ensembl/ensembl-vep/issues/817 and https://github.com/Ensembl/ensembl-vep/issues/720). It is still unclear why exactly the error is occurring, but it is likely harmless and related to the input VCF file.

```Use of uninitialized value $readme_file in concatenation (.) or string at /home/wif049/.conda/envs/vep/share/ensembl-vep-105.0-0/dbNSFP.pm line 279.``` 
This warning message appears due to the lack of a README file for dbNSFP and is harmless.

```Use of uninitialized value $gene_symbol in hash element at /home/wif049/.conda/envs/vep/share/ensembl-vep-105.0-0/SpliceAI.pm line 293, <$fh> line XXXX.``` 
This warning message is thrown when a gene symbol is not defined in Ensembl (https://bytemeta.vip/repo/Ensembl/VEP_plugins/issues/472). The warning should be harmless and can be ignored.

