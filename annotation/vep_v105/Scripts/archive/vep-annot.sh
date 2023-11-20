#!/bin/bash

SCRIPT_LOCATION="/n/data1/hms/dbmi/park/william_feng/tools/vep/Scripts"

# variables from command line
input_vcf=${1}
reference=${2}
regionfile=${3}
# data sources
### vep_tar_gz=${4}
clinvar_gz=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_clinvar.vcf.gz
dbnsfp_gz=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_dbnsfp.dbnsfp.gz
### fordownload_tar_gz=${5}
fordownload=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/fordownload
spliceai_snv_gz=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_spliceai-snv.vcf.gz
spliceai_indel_gz=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_spliceai-indel.vcf.gz
gnomad_gz=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_gnomad.vcf.gz
gnomad_gz2=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_gnomad2.vcf.gz
CADD_snv=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_cadd-snv.tsv.gz
CADD_indel=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_cadd-indel.tsv.gz
phylop100bw=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_phylop100bw.bw
phylop30bw=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_phylop30bw.bw
phastc100bw=/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_phastc100bw.bw
# parameters
nthreads=${4}
version=${5} # 105
assembly=${6} # GRCh38

# self variables
directory=${7}

##############################################################################################################
cache=/n/data1/hms/dbmi/park/william_feng/tools/vep/Cache

# provide output path and file name
output=${7}
### output=/n/data1/hms/dbmi/park/william_feng/test/vep_comparison_20230920/output_o2_chr1_allPlugins.vcf
##############################################################################################################

# rename with version
dbnsfp=dbNSFP4.1a.gz

# rename dbNSFP
ln -s $dbnsfp_gz $dbnsfp
ln -s ${dbnsfp_gz}.tbi ${dbnsfp}.tbi
### ln -s ${dbnsfp_gz%.*}.readme.txt dbnsfp.readme.txt

# unpack data sources
### tar -xzf $vep_tar_gz
### tar -xzf ${vep_tar_gz%%.*}.plugins.tar.gz
### tar -xzf $fordownload_tar_gz

# setting up output directory
mkdir -p $directory

# command line VEP
# plugins
plugin_entscan="--plugin MaxEntScan,${fordownload}"
plugin_dbnsfp="--plugin dbNSFP,${dbnsfp},phyloP100way_vertebrate_rankscore,GERP++_RS,GERP++_RS_rankscore,SiPhy_29way_logOdds,SiPhy_29way_pi,PrimateAI_score,PrimateAI_pred,PrimateAI_rankscore,CADD_raw_rankscore,Polyphen2_HVAR_pred,Polyphen2_HVAR_rankscore,Polyphen2_HVAR_score,SIFT_pred,SIFT_converted_rankscore,SIFT_score,REVEL_rankscore,REVEL_score,Ensembl_geneid,Ensembl_proteinid,Ensembl_transcriptid"
plugin_spliceai="--plugin SpliceAI,snv=${spliceai_snv_gz},indel=${spliceai_indel_gz}"
plugin_CADD="--plugin CADD,${CADD_snv},${CADD_indel}"

plugins="--dir_plugins VEP_plugins --plugin SpliceRegion,Extended --plugin TSSDistance $plugin_entscan $plugin_dbnsfp $plugin_spliceai $plugin_CADD"

# customs
custom_clinvar="--custom ${clinvar_gz},ClinVar,vcf,exact,0,ALLELEID,CLNSIG,CLNREVSTAT,CLNDN,CLNDISDB,CLNDNINCL,CLNDISDBINCL,CLNHGVS,CLNSIGCONF,CLNSIGINCL,CLNVC,CLNVCSO,CLNVI,DBVARID,GENEINFO,MC,ORIGIN,RS,SSR"
custom_gnomad="--custom ${gnomad_gz},gnomADg,vcf,exact,0,AC,AC-XX,AC-XY,AC-afr,AC-ami,AC-amr,AC-asj,AC-eas,AC-fin,AC-mid,AC-nfe,AC-oth,AC-sas,AF,AF-XX,AF-XY,AF-afr,AF-ami,AF-amr,AF-asj,AF-eas,AF-fin,AF-mid,AF-nfe,AF-oth,AF-sas,AF_popmax,AN,AN-XX,AN-XY,AN-afr,AN-ami,AN-amr,AN-asj,AN-eas,AN-fin,AN-mid,AN-nfe,AN-oth,AN-sas,nhomalt,nhomalt-XX,nhomalt-XY,nhomalt-afr,nhomalt-ami,nhomalt-amr,nhomalt-asj,nhomalt-eas,nhomalt-fin,nhomalt-mid,nhomalt-nfe,nhomalt-oth,nhomalt-sas"
custom_gnomad2="--custom ${gnomad_gz2},gnomADe2,vcf,exact,0,AC,AN,AF,nhomalt,AC_oth,AN_oth,AF_oth,nhomalt_oth,AC_sas,AN_sas,AF_sas,nhomalt_sas,AC_fin,AN_fin,AF_fin,nhomalt_fin,AC_eas,AN_eas,AF_eas,nhomalt_eas,AC_amr,AN_amr,AF_amr,nhomalt_amr,AC_afr,AN_afr,AF_afr,nhomalt_afr,AC_asj,AN_asj,AF_asj,nhomalt_asj,AC_nfe,AN_nfe,AF_nfe,nhomalt_nfe,AC_female,AN_female,AF_female,nhomalt_female,AC_male,AN_male,AF_male,nhomalt_male,AF_popmax"
custom_phylop100="--custom ${phylop100bw},phylop100verts,bigwig,exact,0"
custom_phylop30="--custom ${phylop30bw},phylop30mams,bigwig,exact,0"
custom_phastcons100="--custom ${phastc100bw},phastcons100verts,bigwig,exact,0"

customs="$custom_clinvar $custom_gnomad $custom_gnomad2 $custom_phylop100 $custom_phylop30 $custom_phastcons100"

basic_vep="--sift b --polyphen b --ccds --hgvs --symbol --numbers --domains --regulatory --canonical --protein --biotype --uniprot --tsl --appris --gene_phenotype --pubmed --var_synonyms --variant_class --mane"

# options and full command line
options="--fasta $reference --assembly $assembly --use_given_ref --offline --cache_version $version --dir_cache $cache $basic_vep --force_overwrite --vcf --compress_output bgzip"



# Split file by chromosome and then in chunk of 100k (originally 500K) variants
echo "Splitting files"
bcftools index -s $input_vcf | cut -f 1 > chromfile.txt
vep_chunk_file="./vep_chunk_files.txt"
command="bcftools view -O z --threads 8 -o split_by_chr.{}.vcf.gz $input_vcf {} || exit 1; python $SCRIPT_LOCATION/split_vcf.py -i split_by_chr.{}.vcf.gz -o $vep_chunk_file || exit 1; rm split_by_chr.{}.vcf.gz"
cat chromfile.txt | xargs -P $nthreads -i bash -c "$command" || exit 1 



# running VEP in parallel
echo "Running VEP"
command="vep -i {}.vcf.gz -o ${directory}{}.vep.vcf.gz $options $plugins $customs || exit 1; rm {}.vcf.gz || exit 1"
cat $vep_chunk_file | xargs -P $nthreads -i bash -c "$command" || exit 1



# merging the results
echo "Merging vcf.gz files"
array=(${directory}*.vep.vcf.gz)

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
bcftools concat -o combined.vep.vcf.gz --threads 24 -O z $files_sorted || exit 1
echo "Removing temporary files"
rm -f $files_sorted
# echo "Sorting and indexing combined file"
# bcftools sort -o combined.vep.vcf.gz -O z combined.vep.unsorted.vcf.gz || exit 1
echo "Indexing combined file"
tabix -p vcf combined.vep.vcf.gz || exit 1






#######################################################################################################
# From original vep-annot.sh script (dockerfiles/snv_germline_vep/vep-annot.sh)
<<Comment

command="tabix -h $input_vcf {} > {}.sharded.vcf || exit 1; if [[ -e {}.sharded.vcf ]] || exit 1; then if grep -q -v '^#' {}.sharded.vcf; then vep -i {}.sharded.vcf -o ${directory}{}.vep.vcf $options $plugins $customs || exit 1; fi; fi; rm {}.sharded.vcf || exit 1"


##########################################################################

echo "Running VEP"
vep -i ${input_vcf} -o ${output} ${options} ${plugins} ${customs} || exit 1

#########################################################################


# runnning VEP in parallel
echo "Running VEP"
cat $regionfile | xargs -P $nthreads -i bash -c "$command" || exit 1


# merging the results
echo "Merging vcf files"
array=(${directory}*.vep.vcf)

IFS=$'\n' sorted=($(sort -V <<<"${array[*]}"))
unset IFS

grep "^#" ${sorted[0]} > combined.vep.vcf

for filename in ${sorted[@]};
  do
    if [[ $filename =~ "M" ]]; then
      chr_M=$filename
    else
      grep -v "^#" $filename >> combined.vep.vcf
      rm -f $filename
    fi
  done

if [[ -v  chr_M  ]]; then
  grep -v "^#" $chr_M >> combined.vep.vcf
  rm -f $chr_M
fi

# compress and index output vcf
bgzip combined.vep.vcf || exit 1
tabix -p vcf combined.vep.vcf.gz || exit 1
Comment
################################################################################################################
