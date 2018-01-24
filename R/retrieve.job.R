
#' Retrieve results using job id
#'
#' @param job.id Job id
#' @param n.top Number of top proteins to retrieve. If NULL top enriched proteins are provided (upto 500 proteins)
#' @param fetch.files Flag to fetch result files from server and save them locally in output.dir
#' @param output.dir Directory to save the ranking, function, subnetwork and drug info files fetched from the server
#' @return list containing scores of top-ranking proteins, 
#'         functions enriched among top-ranking proteins,
#'         drugs targeting top-ranking proteins,
#'         top-ranking subnetwork cutoff
#' @examples
#' result = retrieve.job(job.id)
#' names(result)
#' head(result$score.table)
#' @export
retrieve.job<-function(job.id, n.top=NULL, fetch.files=F, output.dir="./") {
    result.table = NULL
    go.table <- NULL
    drug.table <- NULL
    if(is.null(n.top)) {
	n.top2 <- 500
    } else {
	n.top2 <- n.top
    }
    html <- httr::POST(url = URLencode(paste0(guildifyR:::get.url(), "/result/", job.id, "/1/", n.top2, "/1"))) 
    html <- httr::content(html)
    # Get scoring result table
    heading <- html %>% rvest::html_nodes(xpath="//table/tr/th") %>% rvest::html_text() 
    result.all <- html %>% rvest::html_nodes("table") %>% rvest::html_table() # %>% .[[1]] %>% as.data.frame()
    names <- heading[1:5]
    result.table <- result.all %>% .[[1]] %>% as.data.frame()
    colnames(result.table) <- tolower(gsub(" ", ".", trimws(names)))
    result.table$seed <- ifelse(grepl("^seed ", result.table$gene.symbol), 1, 0)
    result.table$gene.symbol <- gsub("^seed ", "", result.table$gene.symbol) #result.table$gene.symbol %<>% gsub("seed ", "", .) 
    result.table$uniprot.id <- gsub(" ", ", ", result.table$uniprot.id) 
    # Get functional enrichment based top ranking cutoff
    cutoff <- NULL
    for(txt in html %>% rvest::html_nodes(xpath=".//input") %>% rvest::html_attr("onclick")) {
	idx <- regexpr("enrich_", txt)
	if(!is.na(idx) & idx > 0) {
	    cutoff <- substr(txt, idx + nchar("enrich_"), nchar(txt)-2)
	    cutoff <- as.integer(cutoff)
	}
    }
    if(is.null(n.top)) {
	result.table <- result.table[1:cutoff,]
    }
    # Get GO functions of top ranking genes
    names <- heading[11:15]
    go.table <- result.all %>% .[[2]] %>% as.data.frame()
    colnames(go.table) <- tolower(gsub(" ", ".", trimws(names)))
    # Get drugs targeting top ranking genes
    #names <- heading[16:length(heading)]
    names <- html %>% rvest::html_nodes(xpath="//thead/tr/th") %>% rvest::html_text() 
    drug.table <- result.all %>% .[[4]] %>% as.data.frame()
    colnames(drug.table) <- tolower(gsub(" ", ".", trimws(names)))
    drug.table$type.of.drug <- gsub(";", ", ", drug.table$type.of.drug) 
    drug.table$targets <- gsub(";", ", ", drug.table$targets) 
    # Save results in file
    if(fetch.files) {
	if(is.null(n.top)) {
	    suffix <- paste0("enrich_", cutoff)
	} else {
	    suffix <- "1"
	}
	download.file(url = paste0(guildifyR:::get.url(), "/data/", job.id, "/guild_scores.txt"), destfile=paste0(output.dir, job.id, ".txt"), method="auto", quiet = FALSE)
	download.file(url = paste0(guildifyR:::get.url(), "/data/", job.id, "/subnetwork.sif.", suffix), destfile=paste0(output.dir, job.id, "_subnetwork_top_", suffix, ".sif"), method="auto", quiet = FALSE)
	download.file(url = paste0(guildifyR:::get.url(), "/data/", job.id, "/drugs.txt.", suffix), destfile=paste0(output.dir, job.id, "_drugs_top_", suffix, ".txt"), method="auto", quiet = FALSE)
	write.table(go.table, file = paste0(output.dir, job.id, "_functions_top_", suffix, ".txt"), quote = F, sep = "\t", row.names=F, col.names = gsub("[.]", " ", sapply(colnames(go.table), function(x) { substr(x, 1, 1) <- toupper(substr(x, 1, 1)); return(x) }, USE.NAMES=F)))
    }
    return(list(score.table=result.table, function.table=go.table, drug.table=drug.table, cutoff.index=cutoff))
}

