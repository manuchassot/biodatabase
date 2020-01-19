root_path <- "/home/stagiaire/Emotion3/"
#root_path <- "/media/manu/A40A57B30A5780EA/desktopmanu/ongoing/datapaper_emotion/Emotion3/"
melting_fish <- function(file)
{
  library(reshape)
    fish_measurements <- read.table(paste0(root_path,"CSV/metadata/fish_measures_details.csv"),header = TRUE, sep ="\t",quote="",dec=",")
    fish <- read.table(file,header = TRUE, sep ="\t",quote="",dec=".",na.strings=c("",NA))
    nb_col = ncol(fish)
    v_type <- lapply(fish, class)

    measures = character()
    measures_lg = 1
    for(j in 1:nb_col) {
      not_empty = sum(!is.na(fish[[colnames(fish)[j]]]))
      if(not_empty!=0){
        if(colnames(fish)[j] %in% fish_measurements$measure_name) {
          measures[measures_lg] = colnames(fish)[j]
          measures_lg = measures_lg + 1
        }
      }
    }

    mdata<- melt(fish, id.vars="fish_identifier",measure.vars=measures,na.rm = TRUE)
    write.table(mdata, paste0(root_path,"CSV/fish/melting_fish_measurements.txt"), sep="\t",row.names = FALSE)
}

melting_fish(paste0(root_path,"/CSV/fish/fish_emotion3.csv"))
