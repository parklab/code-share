import argparse
import os
import sys

def parse_args():
    """Uses argparse to enable user to customize script functionality"""
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', required=True, help='Path to input VCF file. Should be gunzipped and indexed.')
    parser.add_argument('-o', '--output', required=True, help='Path to output directory')
    parser.add_argument('-r', '--reference', required=True, default='nopath', help='Original reference file used to align genome prior to variant calling')
    parser.add_argument('-c', '--threads', required=True, default='24', help='Number of threads to be used')
    parser.add_argument('-v', '--version', default='105', help='Version of VEP used')
    parser.add_argument('-a', '--assembly', default='GRCh38', help='Version of reference genome used for alignment')
    parser.add_argument('-s', '--chunk_size', type=int, default='200000', help='Chunk size for variants after splitting file by chromosome')
    parser.add_argument('--ids_and_outputs', action='store_true', help='Use additional output and identifier flags (--sift --polyphen --ccds --hgvs --symbol --numbers --domains --regulatory --canonical --protein --biotype --uniprot --tsl --appris --gene_phenotype --pubmed --var_synonyms --variant_class --mane)')
    parser.add_argument('--entscan', action='store_true', help='Use entscan plugin')
    parser.add_argument('--dbnsfp', action='store_true', help='Use dbNSFP plugin')
    parser.add_argument('--spliceai', action='store_true', help='Use SpliceAI plugin')
    parser.add_argument('--cadd', action='store_true', help='Use CADD plugin')
    parser.add_argument('--clinvar', action='store_true', help='Use custom clinvar annotations')
    parser.add_argument('--gnomad', action='store_true', help='Use custom gnomad annotations')
    parser.add_argument('--gnomad2', action='store_true', help='Use custom gnomad2 annotations')
    parser.add_argument('--phylop100', action='store_true', help='Use custom phylop100 annotations')
    parser.add_argument('--phylop30', action='store_true', help='Use custom phylop30 annotations')
    parser.add_argument('--phastcons100', action='store_true', help='Use custom phastcons100 annotations')
    parser.add_argument('--all_plugins', action='store_true', help='Uses all additional plugins')
    parser.add_argument('--all_custom', action='store_true', help='Uses all custom annotations')
    return parser.parse_args()


def main():
    args = parse_args()
    if args.all_plugins:
        args.entscan = args.dbnsfp = args.spliceai = args.cadd = True
    if args.all_custom:
        args.clinvar = args.gnomad = args.gnomad2 = args.phylop100 = args.phylop30 = args.phastcons100 = True

    SCRIPT_LOCATION="/n/data1/hms/dbmi/park/william_feng/tools/vep/Scripts"

    # data sources
    cache="/n/data1/hms/dbmi/park/william_feng/tools/vep/Cache"
    fordownload="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/fordownload"
    dbnsfp="dbNSFP4.1a.gz"
    dbnsfp_gz="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_dbnsfp.dbnsfp.gz"
    spliceai_snv_gz="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_spliceai-snv.vcf.gz"
    spliceai_indel_gz="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_spliceai-indel.vcf.gz"
    cadd_indel="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_cadd-indel.tsv.gz"
    cadd_snv="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_cadd-snv.tsv.gz"
    clinvar_gz="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_clinvar.vcf.gz"
    gnomad_gz="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_gnomad.vcf.gz"
    gnomad_gz2="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_gnomad2.vcf.gz"
    phylop100bw="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_phylop100bw.bw"
    phylop30bw="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_phylop30bw.bw"
    phastc100bw="/n/data1/hms/dbmi/park/william_feng/tools/vep/Plugins/vep_phastc100bw.bw"
    
    # commands for each plugin and custom data source
    plugin_entscan="--plugin MaxEntScan," + fordownload
    plugin_dbnsfp="--plugin dbNSFP," + args.output + "/" + dbnsfp + ",phyloP100way_vertebrate_rankscore,GERP++_RS,GERP++_RS_rankscore,SiPhy_29way_logOdds,SiPhy_29way_pi,PrimateAI_score,PrimateAI_pred,PrimateAI_rankscore,CADD_raw_rankscore,Polyphen2_HVAR_pred,Polyphen2_HVAR_rankscore,Polyphen2_HVAR_score,SIFT_pred,SIFT_converted_rankscore,SIFT_score,REVEL_rankscore,REVEL_score,Ensembl_geneid,Ensembl_proteinid,Ensembl_transcriptid"
    plugin_spliceai="--plugin SpliceAI,snv=" + spliceai_snv_gz + ",indel=" + spliceai_indel_gz
    plugin_cadd="--plugin CADD," + cadd_snv + "," + cadd_indel
      
    custom_clinvar="--custom " + clinvar_gz + ",ClinVar,vcf,exact,0,ALLELEID,CLNSIG,CLNREVSTAT,CLNDN,CLNDISDB,CLNDNINCL,CLNDISDBINCL,CLNHGVS,CLNSIGCONF,CLNSIGINCL,CLNVC,CLNVCSO,CLNVI,DBVARID,GENEINFO,MC,ORIGIN,RS,SSR"
    custom_gnomad="--custom " + gnomad_gz + ",gnomADg,vcf,exact,0,AC,AC-XX,AC-XY,AC-afr,AC-ami,AC-amr,AC-asj,AC-eas,AC-fin,AC-mid,AC-nfe,AC-oth,AC-sas,AF,AF-XX,AF-XY,AF-afr,AF-ami,AF-amr,AF-asj,AF-eas,AF-fin,AF-mid,AF-nfe,AF-oth,AF-sas,AF_popmax,AN,AN-XX,AN-XY,AN-afr,AN-ami,AN-amr,AN-asj,AN-eas,AN-fin,AN-mid,AN-nfe,AN-oth,AN-sas,nhomalt,nhomalt-XX,nhomalt-XY,nhomalt-afr,nhomalt-ami,nhomalt-amr,nhomalt-asj,nhomalt-eas,nhomalt-fin,nhomalt-mid,nhomalt-nfe,nhomalt-oth,nhomalt-sas"
    custom_gnomad2="--custom " + gnomad_gz2 + ",gnomADe2,vcf,exact,0,AC,AN,AF,nhomalt,AC_oth,AN_oth,AF_oth,nhomalt_oth,AC_sas,AN_sas,AF_sas,nhomalt_sas,AC_fin,AN_fin,AF_fin,nhomalt_fin,AC_eas,AN_eas,AF_eas,nhomalt_eas,AC_amr,AN_amr,AF_amr,nhomalt_amr,AC_afr,AN_afr,AF_afr,nhomalt_afr,AC_asj,AN_asj,AF_asj,nhomalt_asj,AC_nfe,AN_nfe,AF_nfe,nhomalt_nfe,AC_female,AN_female,AF_female,nhomalt_female,AC_male,AN_male,AF_male,nhomalt_male,AF_popmax"
    custom_phylop100="--custom " + phylop100bw + ",phylop100verts,bigwig,exact,0"
    custom_phylop30="--custom " + phylop30bw + ",phylop30mams,bigwig,exact,0"
    custom_phastcons100="--custom " + phastc100bw + ",phastcons100verts,bigwig,exact,0"


    # command line VEP
    plugins_cmd = "--dir_plugins VEP_plugins --plugin SpliceRegion,Extended --plugin TSSDistance"
    if args.entscan:
        plugins_cmd = plugins_cmd + " " + plugin_entscan  
    if args.dbnsfp:
        plugins_cmd = plugins_cmd + " " + plugin_dbnsfp
    if args.spliceai:
        plugins_cmd = plugins_cmd + " " + plugin_spliceai
    if args.cadd:
        plugins_cmd = plugins_cmd + " " + plugin_cadd
    
    customs_cmd = ""
    if args.clinvar:
        customs_cmd = customs_cmd + " " + custom_clinvar
    if args.gnomad:
        customs_cmd = customs_cmd + " " + custom_gnomad
    if args.gnomad2:
        customs_cmd = customs_cmd + " " + custom_gnomad2
    if args.phylop100:
        customs_cmd = customs_cmd + " " + custom_phylop100
    if args.phylop30:
        customs_cmd = customs_cmd + " " + custom_phylop30
    if args.phastcons100:
        customs_cmd = customs_cmd + " " + custom_phastcons100

    basic_vep_cmd = ""
    if args.ids_and_outputs:
        basic_vep_cmd = "--sift b --polyphen b --ccds --hgvs --symbol --numbers --domains --regulatory --canonical --protein --biotype --uniprot --tsl --appris --gene_phenotype --pubmed --var_synonyms --variant_class --mane"

    # options and full command line
    options_cmd = "--fasta " + args.reference + " --assembly " + args.assembly + " --use_given_ref --offline --cache_version " + args.version + " --dir_cache " + cache + " " +  basic_vep_cmd + " --force_overwrite --vcf --compress_output bgzip"
    command = "vep -i " + args.output + "/split_vcfs/{}.vcf.gz -o " + args.output + "/{}.vep.vcf.gz " + options_cmd + " " + plugins_cmd + " "  + customs_cmd + " || exit 1; rm {}.vcf.gz || exit 1"
    # print(command)
    os.system("bash " + SCRIPT_LOCATION + "/vep-wrapper.sh " + args.input + " " + args.output + " " +  args.threads + " " + str(args.chunk_size) + " " + dbnsfp_gz + " " +  command)

if __name__ == "__main__":
    main()
