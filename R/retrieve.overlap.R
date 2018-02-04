
#' Retrieve overlap between two results using two job ids
#'
#' @param job.id1 Job id 1
#' @param job.id2 Job id 2
#' @param fetch.files Flag to fetch result files (for top-ranking 1\%) from server and save them locally in output.dir
#' @param output.dir Directory to save the ranking, function, subnetwork and drug info files fetched from the server
#' @return result List containing scores of common top-ranking proteins, 
#'         common functions enriched among top-ranking proteins,
#'         drugs targeting common top-ranking proteins
#'         (Note that the number of top-ranking proteins and common functions are limited to 500)
#' @examples
#' result = retrieve.overlap(job.id1, job.id2)
#' getSlots(class(result))
#' #Scores
#' head(gScores(result))
#' #Functions
#' head(gFunctions(result))
#' #Drugs
#' head(gDrugs(result))
#' @export
retrieve.overlap<-function(job.id1, job.id2, fetch.files=F, output.dir=NULL) {
    result.table = NULL
    go.table <- NULL
    drug.table <- NULL
    message(paste("Retrieving the overlap between", job.id1, job.id2))
    html <- httr::POST(url = URLencode(paste0(guildifyR:::get.url(), "/result_overlap/", job.id1, "/", job.id2, "/1/500/1/500/1")))
    html <- httr::content(html)
    txt <- html %>% rvest::html_nodes(xpath="//h1") 
    if(length(txt) > 0) {
	txt <- txt %>% rvest::html_text() %>% trimws() 
	if(startsWith(txt, "Server Error")) {
	    warning("Server Error!")
	    stop("Please make sure that you have provided valid job ids and if the problem persists contact to web master.")
	}
    }
    heading <- html %>% rvest::html_nodes(xpath="//table/tr/th") %>% rvest::html_text() 
    result.all <- html %>% rvest::html_nodes("table") %>% rvest::html_table() 
    # Get overlap stats
    names <- heading[1:6]
    result.stats <- result.all %>% .[[1]] %>% as.data.frame()
    colnames(result.stats) <- tolower(gsub(" ", ".", trimws(names)))
    # Get overlap proteins
    names <- heading[7:9]
    result.table <- result.all %>% .[[2]] %>% as.data.frame()
    colnames(result.table) <- tolower(gsub(" ", ".", trimws(names)))
    result.table$seed <- ifelse(grepl("^seed ", result.table$gene.symbol), 1, 0)
    result.table$gene.symbol <- gsub("^seed ", "", result.table$gene.symbol) 
    result.table$uniprot.id <- gsub(" ", ", ", result.table$uniprot.id) 
    # Get GO overlap stats
    names <- heading[10:15]
    go.stats <- result.all %>% .[[3]] %>% as.data.frame()
    colnames(go.stats) <- tolower(gsub(" ", ".", trimws(names)))
    # Get common GO functions of top ranking genes
    names <- heading[16:20]
    go.table <- result.all %>% .[[4]] %>% as.data.frame()
    colnames(go.table) <- tolower(gsub(" ", ".", trimws(names)))
    # Get drugs targeting top ranking genes
    #names <- heading[21:length(heading)]
    names <- html %>% rvest::html_nodes(xpath="//thead/tr/th") %>% rvest::html_text() 
    if(length(names) > 0) {
	drug.table <- result.all %>% .[[5]] %>% as.data.frame()
	colnames(drug.table) <- tolower(gsub(" ", ".", trimws(names)))
	drug.table$type.of.drug <- gsub(";", ", ", drug.table$type.of.drug) 
	drug.table$targets <- gsub(";", ", ", drug.table$targets) 
    } else {
	drug.table<-data.frame()
    }
    # Print genetic and functional overlap
    message("Genetic overlap")
    print(result.stats)
    message("Functional overlap")
    print(go.stats)
    # Save results in file
    if(fetch.files) {
	suffix <- "1"
	if(is.null(output.dir)) {
	    output.dir = file.path(getwd(), paste(job.id1, job.id2, sep="-"))
	}
	dir.create(output.dir)
	write.table(result.table, file = file.path(output.dir, paste0("proteins_top_", suffix, ".txt")), quote = F, sep = "\t", row.names=F, col.names = gsub("[.]", " ", sapply(colnames(result.table), function(x) { substr(x, 1, 1) <- toupper(substr(x, 1, 1)); return(x) }, USE.NAMES=F)))
	write.table(go.table, file = file.path(output.dir, paste0("functions_top_", suffix, ".txt")), quote = F, sep = "\t", row.names=F, col.names = gsub("[.]", " ", sapply(colnames(go.table), function(x) { substr(x, 1, 1) <- toupper(substr(x, 1, 1)); return(x) }, USE.NAMES=F)))
	write.table(drug.table, file = file.path(output.dir, paste0("drugs_top_", suffix, ".txt")), quote = F, sep = "\t", row.names=F, col.names = gsub("[.]", " ", sapply(colnames(drug.table), function(x) { substr(x, 1, 1) <- toupper(substr(x, 1, 1)); return(x) }, USE.NAMES=F)))
    }
    #return(list(protein.table=result.table, function.table=go.table, drug.table=drug.table))
    gify <- GifyResult(result.table, go.table, drug.table, NULL, job.id1, job.id2)
    return(gify)
}

