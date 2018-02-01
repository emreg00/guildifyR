
# GifyResult class containing data from GUILDify results 

setClassUnion("characterOrNULL", members=c("character", "NULL"))
setClassUnion("integerOrNULL", members=c("integer", "NULL"))

setClass("GifyResult",
    slots = c(scores="data.frame", 
	      functions="data.frame", 
	      drugs="data.frame", 
	      cutoff="integerOrNULL",
	      job.id="characterOrNULL",
	      job.id2="characterOrNULL"),
    prototype = list(cutoff=NULL, job.id1=NULL, job.id2=NULL)
)

#' Read/use only class
#' @export C
GifyResult <- function(score.table, function.table, drug.table, enrichment.cutoff, job.id, job.id2)
    new("GifyResult", scores=score.table, functions=function.table, drugs=drug.table, cutoff=enrichment.cutoff, job.id=job.id, job.id2=job.id2)


setGeneric("scores", function(x) standardGeneric("scores"))
setMethod("scores", "GifyResult", function(x) x@scores)
setGeneric("functions", function(x) standardGeneric("functions"))
setMethod("functions", "GifyResult", function(x) x@functions)
setGeneric("drugs", function(x) standardGeneric("drugs"))
setMethod("drugs", "GifyResult", function(x) x@drugs)
setGeneric("cutoff", function(x) standardGeneric("cutoff"))
setMethod("cutoff", "GifyResult", function(x) x@cutoff)
setGeneric("id", function(x) standardGeneric("id"))
setMethod("id", "GifyResult", function(x) x@job.id)
setGeneric("id2", function(x) standardGeneric("id2"))
setMethod("id2", "GifyResult", function(x) x@job.id2)


setMethod("length", "GifyResult", function(x) sprintf("%d top-ranking proteins, %d functions, %d drugs", nrow(x@scores), nrow(x@functions), nrow(x@drugs)))

setMethod("show", "GifyResult", function(object) cat(class(object), "instance with", length(object), "\n"))


setValidity("GifyResult",
    function(object)
    {
        if (ncol(object@scores) != 6)
            return("'scores' table must have 6 columns")
        if (ncol(object@functions) != 5)
            return("'functions' table must have 5 columns")
        if (ncol(object@drugs) != 6)
            return("'drugs' table must have 6 columns")
        if (!is.null(object@cutoff))
	    if (!(object@cutoff > 0))
		return("'cutoff' has invalid value")
        if (!is.null(object@job.id))
	    if (nchar(object@job.id) != 36)
		return("'job.id' must have 36 characters")
        if (!is.null(object@job.id2))
	    if(nchar(object@job.id2) != 36)
		return("'job.id2' must have 36 characters")
        TRUE
    }
)


#setAs("GifyResult", "data.frame",
#function(from) from@scores 
#    # data.frame(functions=from@functions$go.id[1:20], drugs=from@drugs$drugbank.id[1:20])
#      )

