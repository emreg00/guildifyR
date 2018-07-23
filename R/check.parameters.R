
#' Check whether provided species, tissue and scoring parameter values are valid
#' @param species Species tax id
#' @param tissue Tissue name
#' @param network.source Interaction network source (BIANA, STRING, HIPPIE, etc.)
#' @param scoring.options Parameters for prioritization
#' @keywords internal
check.parameters<-function(species, tissue, network.source, scoring.options=NULL) {
    result = guildifyR::get.species.info()
    if(!(species %in% result$species) | !(tissue %in% result$tissues) | !(network.source %in% result$network.sources)) {
	print("Please provide an allowed species tax id and/or tissue! Available species tax ids and tissues:")
	print(result)
	stop(paste0("You provided: ", species, " & ", tissue, " & ", network.source))
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
	if("netscore" %in% names(scoring.options)) {
	    if(!("repetitionSelector" %in% names(scoring.options) & "iterationSelector" %in% names(scoring.options))) {
		stop(paste0("netscore needs the following additional parameters: ", "repetitionSelector", ", ", "iterationSelector"))
	    }
	}
	if("netzcore" %in% names(scoring.options)) {
	    if(!("repetitionZelector" %in% names(scoring.options))) {
		stop(paste0("netzcore needs the following additional parameter: ", "repetitionZelector"))
	    }
	}
    }
}


