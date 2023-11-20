################################################
#   Libraries
################################################

import click
from granite.lib import vcf_parser
import os


################################################
#   Top level variables
################################################


CHUNK_SIZE = 200000
CHUNK_PREFIX = "vep_chunk"


################################################
#   Functions
################################################

@click.command()
@click.help_option("--help", "-h")
@click.option(
    "-i",
    "--input-vcf",
    required=True,
    type=str,
    help="Jointly called VCF (gzipped)",
)
@click.option(
    "-o",
    "--out",
    required=True,
    type=str,
    help="The output file name of the gzipped VCF after filtering",
)
@click.option(
    "-s",
    "--user_chunk_size",
    required=True,
    type=int,
    help="The chunk size for splitting variants",
)
# Chunk size added by William Feng

def main(input_vcf, user_chunk_size, out):


    input_name = input_vcf.rsplit('/', 1)[1]
    path = input_vcf.rsplit('/', 1)[0]
    os.chdir(path)
    vcf_obj = vcf_parser.Vcf(input_vcf)
    CHUNK_SIZE = user_chunk_size

    num_variants = 0

    chunk = 0
    chunk_files = []
    f_out = None

    for record in vcf_obj.parse_variants():
        
        if num_variants % CHUNK_SIZE == 0:
            compress_and_close_chunk(chunk-1, input_name, f_out)
            chunk_file = f"{CHUNK_PREFIX}_{input_name}_{chunk}.vcf"
            f_out = open(chunk_file, "w")
            chunk_files.append(f"{CHUNK_PREFIX}_{input_name}_{chunk}")
            vcf_obj.write_header(f_out)
            chunk += 1
        
        num_variants += 1
        vcf_obj.write_variant(f_out, record)

    compress_and_close_chunk(chunk-1, input_name, f_out)

    with open(out, "a") as f: #"vep_chunk_files.txt"
        for line in chunk_files:
            f.write(line + "\n") 



def compress_and_close_chunk(chunk:int, input_name, file_handle):
    if chunk < 0 or not file_handle or file_handle.closed:
        return
    file_handle.close()
    file_name = f"{CHUNK_PREFIX}_{input_name}_{chunk}.vcf"
    os.system(f"bgzip --threads 12 -c {file_name} > {file_name}.gz || exit 1")
    os.system(f"rm -f {file_name}")
    cmd_result = os.system(f"tabix -p vcf -f {file_name}.gz || exit 1")
    if cmd_result > 0: # exit status shows error
        raise Exception(f"tabix command failed for {file_name}.gz.")



if __name__ == "__main__":
    main()
