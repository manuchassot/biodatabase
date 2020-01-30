### Libraries
library(rmarkdown)  #function render
library(prettydoc)  #function prettydoc
library(RPostgreSQL,quietly = TRUE)

# Path
wd <- '/home/stagiaire/Emotion3/R/'
setwd(wd)

# Swith to English for date format in title
Sys.setlocale("LC_TIME", 'en_GB.UTF-8')

### PDF
render('./load_reference_tables.Rmd',output_format = pdf_document(highlight = "espresso",keep_tex = FALSE))

### HTML PRETTY
#render('./load_reference_tables.Rmd',output_format = html_pretty(theme="leonids",toc=TRUE))

