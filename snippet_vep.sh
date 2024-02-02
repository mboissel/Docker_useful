
## input 
# https://www.ensembl.org/info/docs/tools/vep/vep_formats.html
## option
# https://www.ensembl.org/info/docs/tools/vep/script/vep_options.html


#### Exemple  1 ====================================================================================
docker run
  --volume /media/Datatmp/OMproject/09-vep_vcf_docker:/data_dir
  --volume /media/Data/ExternalData/vep_data:/opt/vep/.vep
  --rm
  --name vep
  ensemblorg/ensembl-vep:release_99.2 /bin/bash -c "./vep
    --input_file /data_dir/snps_locations.txt.gz
    --cache
    --offline
    --fork 100
    --force_overwrite
    --assembly GRCh37
    --check_existing
    --no_check_alleles
    --symbol
    --output_file /data_dir/snps_vep_v99.2_GRCh37.txt && 
      cut -f 1-4,13-14 /data_dir/snps_vep_v99.2_GRCh37.txt | 
      bgzip --thread 100 -f > /data_dir/snps_vep_v99.2_GRCh37.txt.gz "
  

#### Exemple  2 ====================================================================================
docker run --rm --name vep 
  --volume /media/Datatmp/PNproject/11-vep_vcf_docker:/data_dir  
  --volume /media/Data/ExternalData/vep_data:/opt/vep/.vep ensemblorg/ensembl-vep:release_102.0 /bin/bash -c "./vep 
    --input_file /data_dir/snps_locations.txt.gz 
    --cache 
    --offline 
    --fork 100 
    --force_overwrite 
    --assembly GRCh38 
    --check_existing 
    --no_check_alleles 
    --symbol 
    --output_file /data_dir/snps_vep_v102.0_GRCh38.txt && 
      cut -f 1-4,13-14 /data_dir/snps_vep_v102.0_GRCh38.txt |  
      bgzip --thread 100 -f > /data_dir/snps_vep_v102.0_GRCh38.txt.gz " 

# run --rm : will remove the docker after running
# --name vep : the name of the container
# --volume /media/Datatmp/PNproject/11-vep_vcf_docker:/data_dir : Alias where are the data in the container
# --volume /media/Data/ExternalData/vep_data:/opt/vep/.vep : By Default where cache and pluging must be
# ensemblorg/ensembl-vep:release_102.0 : the version of VEP used 
# /bin/bash -c : just easier to give a one line command 
# ./vep : run VEP 
# --input_file /data_dir/snps_locations.txt.gz : the snps to annotate
# --cache --offline : will use local cache (safer, no need internet connection)
# --fork 100 : number core like
#  --force_overwrite : force overwrite if file check_exist
# --assembly GRCh38 : here HG38
# --check_existing --no_check_alleles : if REF/ALT are switched, no check (in array likely possible) 
# --symbol : to get the gene symbol
#  --output_file /data_dir/snps_vep_v102.0_GRCh38.txt : output file 
# && cut -f 1-4,13-14 /data_dir/snps_vep_v102.0_GRCh38.txt : only get some column 
# | bgzip --thread 100 -f : compress it 
# /data_dir/snps_vep_v102.0_GRCh38.txt.gz  : final results 



#### Exemple  3 ====================================================================================
# Un exemple d'annotation en hg19 (build 37) pour Homo Sapiens avec juste le “gene symbol”

datadirectory=/media/Data/Projects/OMproject/cohortname/QC/Omni2.5

mkdir --mode=777 ${datadirectory}/vcf_annot

for ichr in {1..22}
do
  docker run \
    --rm \
    --volume ${datadirectory}:/data_dir \
    --volume /media/Data/ExternalData/vep_data:/opt/vep/.vep \
    ensemblorg/ensembl-vep:release_99.2 /bin/bash -c "./vep \
    --input_file /data_dir/vcf_imputed/${ichr}.pbwt_reference_impute.vcf.gz \
    --format vcf \
    --cache \
    --offline \
    --fork 124 \
    --force_overwrite \
    --assembly GRCh37 \
    --symbol \
    --output_file /data_dir/vcf_annot/${ichr}.annot_v99_GRCh37.txt \
    && bgzip --thread 50 /data_dir/vcf_annot/${ichr}.annot_v99_GRCh37.txt"
done

chmod a-w ${datadirectory}/vcf_annot
chown -R root:staff ${datadirectory}/vcf_annot

## Exemple 
docker run \
  -it \
  --volume /media/Data/Projects/OMproject/cohortname/QC/Omni2.5:/data_dir \
  --volume /media/Data/ExternalData/vep_data:/opt/vep/.vep \
  ensemblorg/ensembl-vep:release_99.2 ./vep \
    --input_file /data_dir/vcf_imputed/22.pbwt_reference_impute.vcf.gz \
    --format vcf \
    --cache \
    --offline \
    --fork 25 \
    --force_overwrite \
    --assembly GRCh37 \
    --symbol \
    --output_file STDOUT | bgzip -c > /data_dir/vcf_annot/22.annot_v99_GRCh37.txt.gz



#### Annotated my bed ####
# docker run  \
#   --volume /disks/PROJECT/Rproject/Data/09-format_data:/data_dir  \
#   --volume /media/Data/ExternalData/vep_data:/opt/vep/.vep  \
#   --rm  \
#   --name vep_Rproject  \
#   ensemblorg/ensembl-vep:release_99.2 /bin/bash -c "./vep 
#     --input_file /data_dir/bed_snp.txt.gz 
#     --cache 
#     --offline 
#     --fork 20 
#     --force_overwrite 
#     --assembly GRCh37 
#     --check_existing 
#     --no_check_alleles 
#     --symbol 
#     --output_file /data_dir/snps_vep_v99.2_GRCh37.txt && 
#       cut -f 1-4,13-14 /data_dir/snps_vep_v99.2_GRCh37.txt |  
#       bgzip --thread 100 -f > /data_dir/snps_vep_v99.2_GRCh37.txt.gz "



