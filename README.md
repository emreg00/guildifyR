# guildifyR: A package for accessing GUILDify v2.0 server via R
Methods to connect GUILDify v2.0 web server to
retrieve genes associated with a given phenotype and 
to apply interactome-based prioritization of genes in
the species / tissue specific protein interaction network.

# Requirements
- Depends:
    * R (>= 3.0.2)
    * magrittr

- Imports:
    * httr
    * rvest

## Generating man files / installation using roxygen / devtools
library(devtools)
setwd("guildifyR")
document()
setwd("..")
install("guildifyR)

## Generating tar.gz archieve
tar cvzf guildifyR.tgz --exclude .git guildifyR/

## Generating manual using Rd2pdf
R CMD Rd2pdf --pdf --title='guildifyR' -o guildifyR.pdf man/*.Rd

## Install from tgz file
R CMD INSTALL guildifyR.tgz

## Example query and retrieve results code
```R
library(guildifyR)

species="9606"
tissue="All"
result.table = query("alzheimer", species, tissue)
job.id = submit.job(result.table, species, tissue, list(netscore=T, repetitionSelector=3, iterationSelector=2))
result = retrieve.job(job.id)
result.table = query("lung neoplasms", species, tissue)
job.id2 = submit.job(result.table, species, tissue, list(netscore=T, repetitionSelector=3, iterationSelector=2))
result = retrieve.overlap(job.id, job.id2)
```

