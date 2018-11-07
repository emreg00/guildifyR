
#' Return the base url
#'
#' @return html address
#' @keywords internal
get.url <- function() {
    #if(exists("guildifyR.url", envir = .guldifyR.data, inherits = F))
    #	return(.guildifyR.data$guildifyR.url)
    html <- httr::POST(url = guildifyR:::url) 
    html <- httr::content(html)
    url <- guildifyR:::url
    for(txt in html %>% rvest::html_nodes(xpath="//meta") %>% rvest::html_attr("content")) {
	idx <- regexpr("url=", txt)
	if(!is.na(idx) & idx > 0) {
	    url <- substr(txt, idx + nchar("url="), nchar(txt))
	    #print(url)
	}
    }
    return(url)
}

