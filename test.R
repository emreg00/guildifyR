# Example query and retrieve results code
library(guildifyR)

species="9606"
tissue="All"
result.table = query("alzheimer", species, tissue)
job.id = submit.job(result.table, species, tissue, list(netscore=T, repetitionSelector=1, iterationSelector=1))
result = retrieve.job(job.id)
result = retrieve.job(job.id, n.top=120, fetch.files=T, output.dir="./")
result.table = query("lung neoplasms", species, tissue)
job.id2 = submit.job(result.table, species, tissue, list(netscore=T, repetitionSelector=1, iterationSelector=1))
result = retrieve.overlap(job.id, job.id2)
keywords = "Sfn;Krt6a;Krt42;Krt16;Arfip1;Dsp;Clic4;H2afz;Tmsb4x;Lsm4;Ubxn8;Dtd1;Atg4b;Rab8b;D430041D05Rik;Timm8a1;Arsb;Cox5a;Mecr;Riok1;Psmd14;Mtch1;Try10;1810063B05Rik;Nrgn;Atp5j;Tmem44;Sirpb1c"
result.table = query(keywords, species, tissue)
job.id = submit.job(result.table, species, tissue, list(netcombo=T))
keywords = "nonsensemakingtestquery"
result.table = query(keywords, species, tissue)
