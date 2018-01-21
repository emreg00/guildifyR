
#' Retrieve results using job id
#'
#' @param job.id Job id
#' @param n.top Number of top proteins to retrieve
#' @param fetch.files Flag to fetch result files from server and save them locally in output.dir
#' @param output.dir Directory to save the files feched from the server
#' @return list containing scores of all proteins, 
#'         top-ranking subnetwork cutoff (Todo), 
#'         functions enriched among top-ranking proteins (Todo)
#' @examples
#' result = retrieve.job(job.id)
#' @export
retrieve.job<-function(job.id, n.top=500, fetch.files=F, output.dir="./") {
    result.table = NULL
    html <- httr::POST(url = paste0(guildifyR:::url, "/result/", job.id, "/1/", n.top, "/1")) #! guildifyR::get.url()
    html <- httr::content(html)
    # Get scoring result table
    #! Adjust heading for v2
    heading <- html %>% rvest::html_nodes(xpath="//table/tr/th") %>% rvest::html_text()
    result <- html %>% rvest::html_nodes("table") %>% html_table() %>% .[[1]] %>% as.data.frame()
    colnames(result) <- tolower(gsub(" ", ".", trimws(heading)))
    result$gene.symbol <- gsub("seed ", "", result$gene.symbol) #result$gene.symbol %<>% gsub("seed ", "", .) 
    cutoff <- NULL
    for(txt in html %>% rvest::html_nodes(xpath=".//input") %>% rvest::html_attr("onclick")) {
	idx <- regexpr("enrich_", txt)
	if(!is.na(idx) & idx > 0) {
	    cutoff <- substr(txt, idx + nchar("enrich_"), nchar(txt))
	}
    }
    #! Add function cutoff
    go.table <- NULL
    #! Add save file option
    return(list(score.table=score.table, cutoff.index=cutoff, function.table=go.table))
}

