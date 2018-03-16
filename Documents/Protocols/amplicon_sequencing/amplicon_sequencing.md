# Amplicon Sequencing Protocol

Author: Jimmy O'Donnell

Revised: 2018-03-16

## Background

The workflow for preparing DNA for sequencing roughly follows the Illumina document '16S Metagenomic Sequencing Library Preparation' (Part # 15044223 Rev. B; there should be a copy of the PDF in this directory).
In short, the protocol consists of two subsequent PCRs: one to amplify the region of interest (aka insert), and one to attach to the resulting amplicons some DNA that will allow them to be read by the sequencer.
We generally refer to these as 'PCR1' and 'PCR2'; however, Illumina and others sometimes refer to them as 'Amplicon PCR' and 'Index PCR', respectively.

The other important aspect of the protocol is removing byproducts of PCR after each of the reactions ('PCR cleanup').
If byproducts remain, these could result in non-target amplification, which ultimately decreases the proportion of good data from the machine (but causes lots of other headaches).
The challenge, though, is retaining enough of the _target_ product after the cleanups, as no cleanup protocol is 100% efficient.

Some general notes:
- **Use IE-HPLC or PAGE purified primers.** Primers are very long, and unintentionally truncated primers can result in unintentional amplification of non-target DNA.
- **Use Phusion High-Fidelity PCR Master Mix with HF Buffer.** From New England Biolabs (#M0531L)

## Protocols


### Primer setup for sample indexing using Nextera XT kit with 16S 'prey' primers 

Note ambiguity in 2 forward primers (Y = C or T).
Originally, only one of these was used, but a second primer was generated to amplify more species.
These were originally ordered and maintained separately, and mixed prior to use in order to guarantee a 50/50 mix of the two sequences (containing C and T)


Legend:
- p = locus-specific primer
- s = sequencing primer
- l = linker to allow attachment of indexed adapters
- i = 8 bp index (bp represented as X; see below)
- a = adapter that binds to flowcell


#### PCR 1: amplify target locus

Forward 1 Salmon (61bp)
```
TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGGCAATCACTTGTCTTTTAAATGAAGACC
llllllllllllllssssssssssssssssssspppppppppppppppppppppppppppp
..................................^..........................
```

```
Forward 2 Groundfish (61bp)
TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGGTAATCACTTGTCTTTTAAATGAAGACC
llllllllllllllssssssssssssssssssspppppppppppppppppppppppppppp
..................................^..........................
```

```
Reverse (54bp)
GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGGATTGCGCTGTTATCCCTA
lllllllllllllllssssssssssssssssssspppppppppppppppppppp
```

#### PCR 2: add DNA needed for sequencing

Forward
```
AATGATACGGCGACCACCGAGATCTACACXXXXXXXXTCGTCGGCAGCGTC
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaiiiiiiiillllllllllllll
```

Reverse 
```
CAAGCAGAAGACGGCATACGAGATXXXXXXXXGTCTCGTGGGCTCGG
aaaaaaaaaaaaaaaaaaaaaaaaiiiiiiiilllllllllllllll
```


#### Indexes

S501 TAGATCGC 
S502 CTCTCTAT 
S503 TATCCTCT 
S504 AGAGTAGA 

N701 TAAGGCGA 
N702 CGTACTAG 
N703 AGGCAGAA 
N704 TCCTGAGC 
N705 GGACTCCT 
N706 TAGGCATG 


From Illumina:

Index 1 read (i7; from reverse primer)
CAAGCAGAAGACGGCATACGAGAT[i7]GTCTCGTGGGCTCGG

Index 2 Read (i5; from forward primer)
AATGATACGGCGACCACCGAGATCTACAC[i5]TCGTCGGCAGCGTC
