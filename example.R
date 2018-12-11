# Example query and retrieve results code
library(guildifyR)

# Parameters
species="9606"
tissue="All"
network.source="BIANA"

# Alzheimer query & NetScore run
result.table = query("alzheimer", species, tissue, network.source)
job.id = submit.job(result.table, species, tissue, network.source, list(netscore=T, repetitionSelector=3, iterationSelector=2))
result = retrieve.job(job.id)
result = retrieve.job(job.id, n.top=150, fetch.files=T, output.dir="./")

# Lung disease query & NetScore run
result.table = query("lung neoplasms", species, tissue, network.source)
job.id2 = submit.job(result.table, species, tissue, network.source, list(netscore=T, repetitionSelector=3, iterationSelector=2))
result = retrieve.overlap(job.id, job.id2)

# Query using gene symbols
species="10090"
keywords = "Sfn;Krt6b;Krt12;Krt21"
result.table = query(keywords, species, tissue, network.source)
job.id = submit.job(result.table, species, tissue, network.source, list(netcombo=T))

# Query with no result
keywords = "nonsensemakingtestquery"
result.table = query(keywords, species, tissue, network.source)

# Retrieving results from a previous run
job.id = "4a720f37-de37-434a-8334-0dee3b702d9c"
result = retrieve.job(job.id)

# Overlap between two results
result = retrieve.overlap("alzheimer", "lung neoplasms", fetch.files=T)

# Yet another query using oxidative keyword on mouse data
species="10090"
tissue="All"
result.table = query("oxidative", species, tissue, network.source)
job.id = submit.job(result.table, species, tissue, network.source, list(netscore=T, repetitionSelector=3, iterationSelector=2))
result = retrieve.job(job.id)
result = retrieve.job(job.id, fetch.files=T, output.dir="test")
