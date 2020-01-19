### Libraries
library(rmarkdown)  #function render
library(prettydoc)  #function prettydoc
library(RPostgreSQL,quietly = TRUE)

# Path
wd <- '/home/stagiaire/Emotion3/queries/SEYFISH/'
setwd(wd)

# Swith to English for date format in title
Sys.setlocale("LC_TIME", 'en_GB.UTF-8')

### Check starting time
starttime <- Sys.time()

## Data set of stable isotopes of carbon and nitrogen (si) and metallic contaminants, including mercury
render('./seyfish_eez_dataset_si_metals.Rmd',output_format = html_pretty(theme="leonids",toc=TRUE,toc_depth=2,highlight = 'vignette'),output_file = 'seyfish_eez_dataset_si_metals.html')

### Check ending time
endtime <- Sys.time()

### Display running time
print(paste('The report was generated in ',round(difftime(endtime,starttime,units = 'sec')),' sec',sep=''))

#render('./seyfish_eez_dataset_si_metals.Rmd',output_format = html_pretty(theme="leonids",toc=TRUE,toc_depth=2,highlight = 'vignette'),output_file = paste('seyfish_eez_dataset_si_metals_',Sys.Date(),'.html',sep=''))

## Data set of lipid classes (lc), fatty acids (fa), and proteins
#render('./seyfish_eez_dataset_lc_fa_prot.Rmd',output_format = html_pretty(theme="leonids",toc=TRUE,toc_depth=2,highlight = 'vignette'),output_file = 'seyfish_eez_dataset_lc_fa_prot.html')

#render('./seyfish_eez_dataset_lc_fa_prot.Rmd',output_format = html_pretty(theme="leonids",toc=TRUE,toc_depth=2,highlight = 'vignette'),output_file = paste('seyfish_eez_dataset_lc_fa_prot_',Sys.Date(),'.html',sep=''))




