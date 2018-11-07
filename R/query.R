
#' Get protein/gene info associated with the query keywords
#'
#' @param keywords Text containing description of a phenotype or list of genes (seperated by ";")
#' @param species Species tax identifier (9606: human, 10090: mouse, etc., see get.species.info method)
#' @param tissue Tissue identifier (all, liver, lung, etc., see get.species.info method)
#' @param network.source Interaction network source (BIANA, STRING, HIPPIE, etc.)
#' @param quote.keywords Quotes the keywords to treat whitespaces as ANDs (e.g., "Muscular Dystrophy")
#' @return result.table Data frame containing list of matching proteins/genes and their description
#' @examples
#' result.table = query("alzheimer", species="10090", tissue="all", network.source="BIANA")
#' @export
query<-function(keywords, species="9606", tissue="all", network.source="BIANA", quote.keywords=T) {
    guildifyR:::check.parameters(species, tissue, network.source)
    result.table <- NULL
    if(quote.keywords) {
	keywords <- gsub('"', '', keywords) 
	if(!grepl(';', keywords)) {
	    if(!startsWith(keywords, '"')) {
		keywords <- paste0("\"", keywords)
	    } 
	    if(!endsWith(keywords, '"')) {
		keywords <- paste0(keywords, "\"")
	    }
	}
    }
    html <- httr::POST(url = paste0(guildifyR:::get.url(), "/query"), body = list(keywords=keywords, species=species, tissue=tissue, network_source=network.source)) 
    html <- httr::content(html)
    txt <- html %>% rvest::html_nodes(xpath="//p") %>% rvest::html_text() %>% .[1] %>% trimws()
    if(txt == "No match for the query!") {
	stop(txt)
    }
    # Get query result table
    get.query.result.table<-function(html, idx.table) {
	heading <- html %>% rvest::html_nodes(xpath="//thead/tr/th") %>% rvest::html_text()
	heading <- heading[1:(length(heading)/2)][-1]
	result <- data.frame(matrix(nrow = 0, ncol = length(heading)+1)) # +2
	colnames(result) <- c("id", tolower(gsub(" ", ".", trimws(heading)))) #, "source")
	i <- 0
	for(row in (html %>% rvest::html_nodes("table") %>% .[[idx.table]] %>% rvest::html_nodes(xpath= ".//tr"))) {
	    if(i == 0) {
		i <- i + 1
		next
	    }
	    result[i, 1] <- row %>% rvest::html_nodes(xpath=".//input") %>% rvest::html_attr("name")
	    j <- 1
	    evidences <- c()
	    for(element in (row %>% rvest::html_nodes(xpath=".//td"))){
		if(j == 1) {
		    j <- j + 1
		    next
		}
		result[i, j] <- rvest::html_text(element, trim=T) 
		#if(colnames(result)[j] == "description") { # Not necessary anymore
		#    for(txt in (row %>% rvest::html_nodes(".success"))) {
		#	evidences <- c(evidences, rvest::html_text(txt)) 
		#    }
		#    evidences <- unique(evidences)
		#}
		j <- j + 1
	    }
	    #result[i, j] <- paste(evidences, collapse=",")
	    i <- i + 1
	}
	return(result)
    }
    #result <- get.query.result.table(html, 3)
    result <- tryCatch({
	get.query.result.table(html, 3)
    }, error = function(e) {
	warning(e)
	stop("An error occurred with the query, make sure the provided keywords are correct!")
    })
    if(nrow(result) > 0) {
	result[, "in.network"] <- 1
    }
    result.out <- rbind(get.query.result.table(html, 4)) 
    if(nrow(result.out) > 0) {
	result.out[, "in.network"] <- 0
    }
    result.table <- rbind(result, result.out)
    print(sprintf("%d entries are retrieved (%d not in network)", nrow(result.table), nrow(result.out)))
    return(result.table)
}


