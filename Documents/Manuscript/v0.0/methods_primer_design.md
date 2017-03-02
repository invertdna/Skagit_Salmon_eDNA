### Species-specific assays

We used species-specific qPCR assays for multiple species:

1. Oncorhynchus tshawytscha (Chinook Salmon) is of primary interest to our study, and we used an assay developed by Duda, Hoy, and Ostberg (?CITATION?).

2. Cymatogaster aggregata (Shiner Surfperch) is reliably abundant and spatially variable in the habitats surveyed by both beach seine and fyke traps.
They lack any external, microscopic life history stage that could obscure the relationship between counts of macroscopic individuals and DNA concentration: Along with all confamilials, they are internally fertilized and give birth to live young.
Within the family, their entire clade is distinct from other inhabitants of Puget Sound (CITE LONGO AND BERNARDI 2015 MPE, CITE http://www.burkemuseum.org/static/FishKey/embio.html).
The in-silico based qPCR assay design approach is as follows:

- Using (alignments and visual inspection?), identify a region of the mitochondrial genome where there are fixed differences between target species, their close relatives, and a selection of non-targets. Ryan found that Cytochrome c oxidase subunit I (MT-CO1) was (________ why was CO1 bad?), while cytochrome b (MY-CYB).
- We gathered sequence data from NCBI's nucleotide sequence database ('GenBank') using the query '"Embiotocidae"[organism] AND gene_in_mitochondrion[PROP] AND ("cytochrome b") NOT ("COI")'.
- After properly formatting the database (using 'ecoPCRFormat.py --taxonomy (path to taxdump) --name (output name) --genbank (path to our embiotocid sequence database)'), we used ecoPrimers to (DO SOME STUFF)