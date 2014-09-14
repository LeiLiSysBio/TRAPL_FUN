main(){
	PYTHON_PATH=python3.4
	TRAPL_FUN_PATH=bin/traplfun
	TRAPL_FUN_FOLDER=TRAPL_FUN_analysis
	FTP_SOURCE=ftp://ftp.ncbi.nih.gov/genomes/Bacteria/Salmonella_enterica_serovar_Typhimurium_SL1344_uid86645/
	KEGG_organism_code=sey
	
	# create_folders
	# set_up_analysis_folder
	# get_gff_files
	# get_expression_files
	# run_blast2go
	# run_retrieveGO
	# run_go_enrichment_analysis
	# run_viz_go
	# run_retrievepathway
	# run_pathway_enrichment_analysis
	# run_viz_pathway
	# run_clustering
	# run_gsea_analysis
	# generate_package_to_send
 	# compress_files
}

create_folders(){
    for FOLDER in bin
    do
	if ! [ -d $FOLDER ]
	then
	    mkdir -p $FOLDER
	fi
    done
}

set_up_analysis_folder(){
    if ! [ -d $TRAPL_FUN_FOLDER ]
    then
        $PYTHON_PATH $TRAPL_FUN_PATH create $TRAPL_FUN_FOLDER
    fi
}

get_gff_files(){
    echo "Downloading GFF annotation files"
    wget -cP $TRAPL_FUN_FOLDER/input/annotations/ \
	$FTP_SOURCE/*gff
    echo "----------------------------------------"
    echo "Content of" $TRAPL_FUN_FOLDER/input/annotations/
    ls -l $TRAPL_FUN_FOLDER/input/annotations/
}

get_expression_files(){
	SOURCE=XXX
	DEST=XXX
	for file in ${SOURCE}/*.csv
	do
		grep "^sense" $file|grep "="|awk -F"\t" '{print $10 "\t" $(NF-2)}'| \
			awk -F"=" '{print $(NF)}' > ${DEST}/${file##*/}.txt
	done
	
}
run_blast2go(){
	if ! [ -f ${TRAPL_FUN_FOLDER}/input/blast2go_xml/* ]
	then
		echo "Please provide the blast xml file"
	else
		$PYTHON_PATH $TRAPL_FUN_PATH \
		blast2go \
		$TRAPL_FUN_FOLDER
	fi
}

run_retrieveGO(){
	# ensemble id to gene ontology
	$PYTHON_PATH $TRAPL_FUN_PATH \
	retrieve \
	$TRAPL_FUN_FOLDER
}

run_retrievepathway(){
	$PYTHON_PATH $TRAPL_FUN_PATH \
	retrieve_pa \
	-c $KEGG_organism_code \
	$TRAPL_FUN_FOLDER
}

run_go_enrichment_analysis(){
	$PYTHON_PATH $TRAPL_FUN_PATH \
	go_stat \
	$TRAPL_FUN_FOLDER	
}

run_viz_go(){
	$PYTHON_PATH $TRAPL_FUN_PATH \
	go_viz \
	$TRAPL_FUN_FOLDER
}

run_pathway_enrichment_analysis(){	
	$PYTHON_PATH $TRAPL_FUN_PATH \
	pathway_stat \
	$TRAPL_FUN_FOLDER	
}

run_clustering(){
	$PYTHON_PATH $TRAPL_FUN_PATH \
	clustering \
	-co red_black_green \
	$TRAPL_FUN_FOLDER
}

run_gsea_analysis(){
	$PYTHON_PATH $TRAPL_FUN_PATH \
	gsea \
	$TRAPL_FUN_FOLDER
}

run_viz_pathway(){
	$PYTHON_PATH $TRAPL_FUN_PATH \
	path_viz \
	-c $KEGG_organism_code \
	$TRAPL_FUN_FOLDER
}
generate_package_to_send(){
	SEND_FOLDER=XXX-Functional-annotation-analysis
	mkdir ${SEND_FOLDER}
	cp -r ${TRAPL_FUN_FOLDER}/ ${SEND_FOLDER}
	zip -r ${SEND_FOLDER}.zip ${SEND_FOLDER}
}

compress_files(){
	find ${TRAPL_FUN_FOLDER} -type f -print0 | xargs -n1 -0 -P24 bzip2
}

main
