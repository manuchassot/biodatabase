root_path <- "/home/stagiaire/Emotion3/"
melting_analysis <- function(folder)
{
#chargement de la library reshape pour utiliser la fonction melt permettant de passer les données du format "large" au format "long"
library(reshape)

#lecture du fichier de metadonnées sur les traceurs pour avoir la liste des traceurs
metadata <- read.table(paste0(root_path,"CSV/metadata/analysis_tracers_details.csv"),header = TRUE, sep ="\t",quote="",dec=".",stringsAsFactors=FALSE)
#ouverture du dossier contenant les fichiers csv des analyses et récupération des fichiers dans la variable files
files <- list.files(path=folder, pattern="*.csv", full.names=T, recursive=FALSE)

#Variable permettant repérer le premier fichier parcouru. Si nous sommes sur le premier fichier, on crée un DF, si non, on fait un rbind pour 
#combiner les mesures du premier fichier et des suivants.
debut_meas=TRUE
debut_inf=TRUE

#debut de la boucle parcourant le dossier ou sont placés les fichiers d'analyses
for(i in 1:length(files)){
  #lecture du fichier csv d'analyse
	analysis <- read.table(files[i],header = TRUE, sep ="\t",quote="",dec=".",check.names = FALSE)
	#récupération du nombre de colonne du fichier csv pour faire une boucle sur ces noms de colonnes
	nb_col = ncol(analysis)
	#creation d'un tableau de charactères measures qui va contenir le nom des colonnes doivent être passées en lignes. la variable measures_lg sert
	#de compteur pour incrémenter ce tableau
	measures = character()
	measures_lg = 1

  #debut de la boucle sur le nom des colonnes du fichier csv
	for(j in 1:nb_col) {
	  #la variable not_empty va servir à compter les valeurs non-vides de chaque colonne, si elle vaut 0 la colonne est entierement vide
		not_empty = sum(!is.na(analysis[[colnames(analysis)[j]]]))
		#test pour vérifier si la colonne n'est pas entièrement vide
		if(not_empty!=0){
		  #si le nom de la colonne est contenu dans la colonne tracer_name du fichier de metadta analysis_tracers_details, alors on la met dans le tableau
		  #measures crée précédemment.
			if(colnames(analysis)[j] %in% metadata$tracer_name) {
				measures[measures_lg] = colnames(analysis)[j]
				measures_lg = measures_lg + 1
				#On convertit le contenu de la colonne en numérique pour être sur de n'avoir que des colonnes numériques lors de l'appel de la fonction melt
				analysis[[colnames(analysis)[j]]] <- as.numeric(analysis[[colnames(analysis)[j]]])
			}
		}
	}

	if(length(measures)>0){
		mdata_measures <- melt(analysis, id.vars="talend_an_id",measure.vars=measures,na.rm = TRUE)
		mdata_measures$value <- as.numeric(mdata_measures$value)

		if(debut_meas==TRUE){
		  measures_fusion <- mdata_measures
		  debut_meas=FALSE
		}
		else{
		  measures_fusion<-rbind(measures_fusion,mdata_measures)
		}
	}
}
write.table(measures_fusion, paste0(root_path,"CSV/analysis/melting_tracers.txt"),sep="\t",dec=".",row.names = FALSE)

#creation des vues pivot dans un fichier .sql spécifique dans le dossier /SQL/Views/pivot_tables
#csv_other_columns <- read.table("/home/stagiaire/Documents/Emotion/CSV/metadata/columns_details.csv",header = TRUE, sep ="\t",quote="",dec=",",stringsAsFactors=FALSE)
#csv_an_types <- read.table("/home/stagiaire/Documents/Emotion/CSV/metadata/analysis_types.csv",header = TRUE, sep ="\t",quote="",dec=",",stringsAsFactors=FALSE)
#analysis_types <- csv_an_types$analysis
#lg <- length(analysis_types)
#  for(i in 1:lg){
#      tracers_vars = metadata[metadata$analysis_type %in% analysis_types[i],]
#      tracers_vars_paste = paste(tracers_vars$tracer_name,collapse=",")
#      tracers_vars_double = paste(tracers_vars$tracer_name," double precision",collapse=",")
#      other_vars = csv_other_columns[csv_other_columns$table %in% analysis_types[i] & csv_other_columns$column_name != "analysis_id",]
#      other_vars = paste(other_vars$column_name,collapse=",")
#      tracers_method <- paste(other_vars,tracers_vars_paste,collapse=",")
#      first_letters_talend_id <- csv_an_types[csv_an_types$analysis %in% analysis_types[i],]
#      prefix <- first_letters_talend_id$first_letters_talend_id

#       tx  <- readLines("/home/stagiaire/Documents/Emotion/SQL/template_views/template_pivot.sql")
#       tx2  <- gsub(pattern = "[AN]", replace = prefix, x = tx)
#       tx3  <- gsub(pattern = "[method_and_tracers]", replace = tracers_method, x = tx2)
#       tx4  <- gsub(pattern = "[analysis_table]", replace = analysis_types[j], x = tx3)
#       tx4  <- gsub(pattern = "[tracers]", replace = tracers_vars_double, x = tx4)
#       chemin <- paste("/home/stagiaire/Documents/Emotion/SQL/views/pivot_tables/pivot_",prefix,".sql",collapse="")
#       writeLines(tx4, con=chemin)
#   }
}

melting_analysis(paste0(root_path,"CSV/analysis"))
