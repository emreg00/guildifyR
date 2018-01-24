
#' Check whether provided species, tissue and scoring parameter values are valid
check.parameters<-function(species, tissue, scoring.options=NULL) {
    result = guildifyR::get.species.info()
    if(!(species %in% result$species) | !(tissue %in% result$tissues)) {
	print("Please provide an allowed species tax id and/or tissue! Available species tax ids and tissues:")
	print(result)
	stop(paste0("You provided: ", species, " & ", tissue))
    }
    valid.methods <- c("netscore", "netzcore", "netshort", "netcombo", "diamond")
    valid.names <- c("repetitionSelector", "iterationSelector", "repetitionZelector")
    valid.names <- c(valid.names, valid.methods)
    if(!is.null(scoring.options)) {
	if(length(intersect(names(scoring.options), valid.methods)) < 1) {
	    print("Please provide an allowed scoring method:")
	    print(valid.methods)
	    stop(paste0("You provided: ", paste0(names(scoring.options), collapse=", ")))
	}
	if(length(setdiff(names(scoring.options), valid.names)) > 0) {
	    sprintf("(Warning) The following parameters are ignored: %s", paste0(setdiff(names(scoring.options), valid.names), collapse=", "))
	}
    }
}


