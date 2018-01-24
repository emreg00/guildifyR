
#' Retrieve overlap between two results using two job ids
#'
#' @param job.id1 Job id 1
#' @param job.id2 Job id 2
#' @param fetch.files Flag to fetch result files from server and save them locally in output.dir
#' @param output.dir Directory to save the ranking, function, subnetwork and drug info files fetched from the server
#' @return list containing scores of common top-ranking proteins, 
#'         common functions enriched among top-ranking proteins,
#'         drugs targeting common top-ranking proteins
#'         (Note that the number of top-ranking proteins and common functions are limited to 500)
#' @examples
#' result = retrieve.job(job.id)
#' names(result)
#' head(result$score.table)
#' @export
retrieve.job<-function(job.id1, job.id2, fetch.files=F, output.dir="./") {
    result.table = NULL
    go.table <- NULL
    drug.table <- NULL
    html <- httr::POST(url = paste0(guildifyR::get.url(), "/result_overlap/", job.id1, job.id2, "/1/500/1/500/1")) 
    html <- httr::content(html)
    heading <- html %>% rvest::html_nodes(xpath="//table/tr/th") %>% rvest::html_text() 
    result.all <- html %>% rvest::html_nodes("table") %>% html_table() 
    # Get overlap stats
    names <- heading[1:6]
    result.table <- result.all %>% .[[1]] %>% as.data.frame()
    colnames(result.table) <- tolower(gsub(" ", ".", trimws(names)))
    print(result.table)
    # Get overlap proteins
    names <- heading[7:9]
    result.table <- result.all %>% .[[2]] %>% as.data.frame()
    colnames(result.table) <- tolower(gsub(" ", ".", trimws(names)))
    result.table$seed <- ifelse(grepl("^seed ", result.table$gene.symbol), 1, 0)
    result.table$gene.symbol <- gsub("^seed ", "", result.table$gene.symbol) 
    # Get GO overlap stats
    names <- heading[10:15]
    go.table <- result.all %>% .[[3]] %>% as.data.frame()
    colnames(go.table) <- tolower(gsub(" ", ".", trimws(names)))
    print(go.table)
    # Get common GO functions of top ranking genes
    names <- heading[16:20]
    go.table <- result.all %>% .[[4]] %>% as.data.frame()
    colnames(go.table) <- tolower(gsub(" ", ".", trimws(names)))
    # Get drugs targeting top ranking genes
    names <- heading[21:length(heading)]
    drug.table <- result.all %>% .[[5]] %>% as.data.frame()
    colnames(drug.table) <- tolower(gsub(" ", ".", trimws(names)))
    # Save results in file
    if(fetch.files) {
	suffix <- "1"
	download.file(url = paste0(guildifyR::get.url(), "/data/", job.id, "/drugs.txt.", suffix), destfile=paste0(output.dir, job.id, "_drugs_top_", suffix, ".txt"), method="auto", quiet = FALSE)
	write.table(result.table, file = paste0(output.dir, job.id1, job.id2, "_proteins_top_", suffix, ".txt"), quote = F, sep = "\t", row.names=F, col.names = gsub("[.]", " ", sapply(colnames(result.table), function(x) { substr(x, 1, 1) <- toupper(substr(x, 1, 1)); return(x) }, USE.NAMES=F)))
	write.table(go.table, file = paste0(output.dir, job.id1, job.id2, "_functions_top_", suffix, ".txt"), quote = F, sep = "\t", row.names=F, col.names = gsub("[.]", " ", sapply(colnames(go.table), function(x) { substr(x, 1, 1) <- toupper(substr(x, 1, 1)); return(x) }, USE.NAMES=F)))
	write.table(drug.table, file = paste0(output.dir, job.id1, job.id2, "_drugs_top_", suffix, ".txt"), quote = F, sep = "\t", row.names=F, col.names = gsub("[.]", " ", sapply(colnames(drug.table), function(x) { substr(x, 1, 1) <- toupper(substr(x, 1, 1)); return(x) }, USE.NAMES=F)))
    }
    return(list(protein.table=result.table, function.table=go.table, drug.table=drug.table))
}

