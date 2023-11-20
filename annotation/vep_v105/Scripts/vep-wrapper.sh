#!/bin/bash

#############################################################################
# Modified by William Feng
#############################################################################

SCRIPT_LOCATION="/n/data1/hms/dbmi/park/william_feng/tools/vep/Scripts"
IFS=' ' read -r input_vcf directory nthreads chunk_size dbnsfp_gz vep_command <<< $@

# setting up output directory
mkdir -p $directory/split_vcfs

# rename with version
dbnsfp=dbNSFP4.1a.gz

# rename dbNSFP
ln -s ${dbnsfp_gz} ${directory}/${dbnsfp}
ln -s ${dbnsfp_gz}.tbi ${directory}/${dbnsfp}.tbi


# Split file by chromosome and then in chunk of 2200k (originally 500K) variants
echo "Splitting files"
bcftools index -s $input_vcf | cut -f 1 > ${directory}/chromfile.txt
vep_chunk_file="${directory}/vep_chunk_files.txt"
rm -f $vep_chunk_file
command="bcftools view -O z --threads 8 -o ${directory}/split_vcfs/split_by_chr.{}.vcf.gz $input_vcf {} || exit 1; python $SCRIPT_LOCATION/split_vcf.py -i ${directory}/split_vcfs/split_by_chr.{}.vcf.gz -s $chunk_size -o $vep_chunk_file || exit 1; rm ${directory}/split_vcfs/split_by_chr.{}.vcf.gz"
cat ${directory}/chromfile.txt | xargs -P $nthreads -i bash -c "$command" || exit 1 


# running VEP in parallel
echo "Running VEP"
echo "Command: ${vep_command}"
cat $vep_chunk_file | xargs -P $nthreads -i bash -c "$vep_command" || exit 1


# merging the results
echo "Merging vcf.gz files"
array=(${directory}/*.vep.vcf.gz)

IFS=$'\n' sorted=($(sort -V <<<"${array[*]}"))
unset IFS

files_sorted=""

for filename in ${sorted[@]};
  do
    #echo "Indexing file $filename"
    #tabix -p vcf -f "$filename" || exit 1
    files_sorted="$files_sorted$filename "
  done

echo "Concatenating files: $files_sorted"
bcftools concat -o ${directory}/combined.vep.vcf.gz --threads 24 -O z $files_sorted || exit 1
echo "Removing temporary files"
rm -f $files_sorted
# echo "Sorting and indexing combined file"
# bcftools sort -o combined.vep.vcf.gz -O z combined.vep.unsorted.vcf.gz || exit 1
echo "Indexing combined file"
tabix -p vcf ${directory}/combined.vep.vcf.gz || exit 1
