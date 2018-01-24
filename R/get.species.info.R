
#' Get info on available species and tissues
#'
#' @return result List containing available species tax ids and names for tissue-specific networks
#' @examples
#' result = get.species.info()
#' @export
query<-function() {
    result <- NULL
    html <- httr::POST(url = paste0(guildifyR::get.url())) 
    html <- httr::content(html)
    species = c()
    tissues = c()
    i <- 1
    for(row in html %>% rvest::html_nodes("select")) { # %>% .[[1]] %>% rvest::html_nodes(xpath= ".//option"))) {
	for(element in row %>% rvest::html_nodes(xpath=".//option")) {
	    if(i == 1) {
		species <- c(species, element %>% rvest::html_attr("value"))
	    } else if(i == 2) {
		tissues <- c(tissues, element %>% rvest::html_text())
	    }
	}
	i <- i + 1
    }
    result <- list(species = species, tissues = tissues)
    return(result)
}


