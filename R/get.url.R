
#' Return the base url
#'
#' @return html address
#' @export
get.url <- function() {
    #if(exists("guildifyR.url", envir = .guldifyR.data, inherits = F))
    #	return(.guildifyR.data$guildifyR.url)
    return(guildifyR:::url)
}

