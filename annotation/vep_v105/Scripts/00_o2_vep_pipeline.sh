###############################################################################################################
## Test VEP Implementation (CGAP version) on O2
## GitHub: https://github.com/dbmi-bgm/cgap-pipeline-SNV-germline/blob/8d991a7e4e5ef524ba1a49c6f65291429d687323/dockerfiles/snv_germline_vep/vep-annot.sh
## GitHub: https://github.com/dbmi-bgm/cgap-pipeline-cohort/blob/main/dockerfiles/cohort_vep/vep-annot.sh
## Script written by William Feng (william_feng@hms.harvard.edu)
###############################################################################################################

#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <step>"
  exit 1
fi

# step to run specified by your bash command
step=$1

# email for job notifications
email=wfeng.slurm@gmail.com

# path to input vcf
input_vcf=/n/data1/hms/dbmi/park/william_feng/test/vep/vep_ten_chr_test_20231013/input_ten_chr.vcf.gz
# input_vcf=/n/data1/hms/dbmi/park/william_feng/test/vep/vep_full_genome_test_20231003/input_cgap.vcf.gz

# path output directory (don't include a slash at the end of the path)
output_dir=/n/data1/hms/dbmi/park/william_feng/test/vep/vep_ten_chr_test_20231013
# output_dir=/n/data1/hms/dbmi/park/william_feng/test/vep/vep_full_genome_test_20231003

# assembly genome version
assembly=GRCh38

# number of threads
threads=24
# threads=32

# variant chunk size
chunk_size=200000

# reference file 
reference=/n/data1/hms/dbmi/park/SOFTWARE/REFERENCE/hg38/cgap_matches/Homo_sapiens_assembly38.fa

# directory containing pipeline scripts (do not change this)
tool_dir=/n/data1/hms/dbmi/park/william_feng/tools/vep/Scripts

# vep version (do not change this)
version=105


case $step in

0)
    # load the necessary environments
    echo "Set up virtual env (only need to do it once). If already made this for another pipeline, just use it."
    echo "conda env create -f /n/data1/hms/dbmi/park/william_feng/tools/vep/Scripts/vep.yml"
    echo "To activate your environment, run this line (assuming you kept the name of the conda env as vep:"
    echo "conda activate vep"

;;
1)
    ## STEP 1: annotate vcf with vep_wrapper.py

    # -t 16:00:00 --mem=128G
    sbatch -J "vep_1" -p park -A park_contrib -t 8:00:00 --mem=128G -c $threads --mail-type=ALL --mail-user=$email \
            --wrap="python ${tool_dir}/vep-wrapper-wrapper.py -i $input_vcf -o $output_dir -r $reference \
            -c $threads -v $version -a $assembly -s $chunk_size --ids_and_outputs --all_plugins --all_custom"

;;
*)
    echo "select a step (first argument for this script)" 
;;
esac
