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
```R
library(devtools)
#setwd("guildifyR")
document()
```

## Generating manual using Rd2pdf
```bash
R CMD Rd2pdf --pdf --title='guildifyR' -o guildifyR.pdf man/*.Rd
```

## Generating tar.gz archieve
```bash
tar cvzf guildifyR.tgz --exclude .git guildifyR/
```

## Install from tgz file
R CMD INSTALL guildifyR.tgz

## Install from source using devtools
```R
library(devtools)
setwd("..")
install("guildifyR")
```

## Install from GitHub repository using devtools
```R
library(devtools)
install_github("emreg00/guildifyR") 
```

## Example query and retrieve results code
```R
library(guildifyR)

species="9606"
tissue="all"
network.source="BIANA"
result.table = query("alzheimer", species, tissue, network.source)
job.id = submit.job(result.table, species, tissue, network.source, list(netscore=T, repetitionSelector=3, iterationSelector=2))
result = retrieve.job(job.id)
result.table = query("lung neoplasms", species, tissue, network.source)
job.id2 = submit.job(result.table, species, tissue, network.source, list(netscore=T, repetitionSelector=3, iterationSelector=2))
result = retrieve.overlap(job.id, job.id2)
```

