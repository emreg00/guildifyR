
#' Submit job using the guildifyR query result table 
#'
#' @param query.table Data frame contaning information from guildifyR query (user entitiy info, network info, source etc...)
#' @param species Species tax identifier (9606: human, 10090: mouse, etc., see get.species.info method)
#' @param tissue Tissue identifier (all, liver, lung, etc., see get.species.info method)
#' @param network.source Interaction network source (BIANA, STRING, HIPPIE, etc.)
#' @param scoring.options Prioritization method options (default NetCombo) 
#' @return job id
#' @examples
#' species="10090"
#' tissue="all"
#' network.source="BIANA"
#' result.table = query("alzheimer", species, tissue, network.source)
#' #Diamond
#' scoring.options = list(diamond=T)
#' #NetScore
#' scoring.options = list(netscore=T, repetitionSelector=3, iterationSelector=2)
#' #NetZcore
#' scoring.options = list(netzcore=T, repetitionZelector=3)
#' #NetShort
#' scoring.options = list(netshort=T)
#' #NetCombo
#' scoring.options = list(netcombo=T)
#' job.id = submit.job(result.table, species, tissue, network.source, scoring.options)
#' @export
submit.job<-function(result.table, species, tissue, network.source, scoring.options=list(netcombo=T)) {
    guildifyR:::check.parameters(species, tissue, network.source, scoring.options)
    job.id = NULL
    if(!is.null(scoring.options$netcombo)) {
	# NetScore
	scoring.options = list(netscore=T, repetitionSelector=3, iterationSelector=2)
	# NetZcore
	scoring.options = c(scoring.options, list(netzcore=T, repetitionZelector=3))
	# NetShort
	scoring.options = c(scoring.options, list(netshort=T))
    }
    # Filter entries that are not in the network #! should make sure that it does not cause an error to submit them 
    result.table <- result.table[result.table$in.network==1,]
    parameters <- c(list(species=species, tissue=tissue, network_source=network.source), as.list(setNames(c(result.table$id), result.table$id)), scoring.options)
    html <- httr::POST(url = paste0(guildifyR:::get.url(), "/status"), body = parameters) 
    html <- httr::content(html)
    job.id <- html %>% rvest::html_nodes("table") %>% rvest::html_table() %>% .[[1]] %>% .[1,2] # as.data.frame()[1,2]
    print("Your job has been submitted! Please do not submit the same job (you can check its status using 'retrieve.job' method.)")
    print(sprintf("Job id: %s", job.id))
    return(job.id)
}

