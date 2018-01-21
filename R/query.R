
#' Get protein/gene info associated with the query keywords
#'
#' @param keywords Text containing description of a phenotype or list of genes (seperated by ;)
#' @param species Species tax id identifier (9606: human, 10090: mouse, etc.)
#' @return result.table Data frame containing list of matching proteins/genes and their description
#' @examples
#' result.table = query("alzheimer", species="10090")
#' @export
query<-function(keywords, species="9606") {
    result.table <- NULL
    html <- httr::POST(url = paste0(guildifyR:::url, "/query"), body = list(keywords=keywords, species=species)) #! guildifyR::get.url()
    html <- httr::content(html)
    # Get query result table
    get.query.result.table<-function(html, idx.table) {
	heading <- html %>% rvest::html_nodes(xpath="//table/tr/th") %>% rvest::html_text()
	heading <- heading[1:(length(heading)/2)][-1]
	result <- data.frame(matrix(nrow = 0, ncol = length(heading)+2))
	colnames(result) <- c("id", tolower(gsub(" ", ".", trimws(heading))), "source")
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
		if(colnames(result)[j] == "description") {
		    for(txt in (row %>% rvest::html_nodes(".success"))) {
			evidences <- c(evidences, rvest::html_text(txt)) 
		    }
		    evidences <- unique(evidences)
		}
		j <- j + 1
	    }
	    result[i, j] <- paste(evidences, collapse=",")
	    i <- i + 1
	}
	return(result)
    }
    result <- get.query.result.table(html, 2)
    result[, "in.network"] <- 1
    result.out <- rbind(get.query.result.table(html, 3)) 
    result.out[, "in.network"] <- 0
    result.table <- rbind(result, result.out)
    return(result.table)
}

