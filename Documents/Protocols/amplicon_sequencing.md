# Amplicon Sequencing Protocol

Author: Jimmy O'Donnell

Revised: 2018-03-16

## Background

The workflow for preparing DNA for sequencing roughly follows the Illumina document ''

# Primer setup for sample indexing using Nextera XT kit with 16S 'prey' primers 

Note:
  - IE-HPLC cleaned primers
  - ambiguity in 2 forward primers (Y = C or T)

#-------------------------------------------------------------------------------
PCR 1: amplify target locus
#-------------------------------------------------------------------------------

Forward 1 Salmon (61bp)
TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGGCAATCACTTGTCTTTTAAATGAAGACC
llllllllllllllssssssssssssssssssspppppppppppppppppppppppppppp
..................................^..........................

Forward 2 Groundfish (61bp)
TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGGTAATCACTTGTCTTTTAAATGAAGACC
llllllllllllllssssssssssssssssssspppppppppppppppppppppppppppp
..................................^..........................


Reverse (54bp)
GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGGATTGCGCTGTTATCCCTA
lllllllllllllllssssssssssssssssssspppppppppppppppppppp




#-------------------------------------------------------------------------------
# PCR 2: add DNA needed for sequencing
#-------------------------------------------------------------------------------

Forward
AATGATACGGCGACCACCGAGATCTACACXXXXXXXXTCGTCGGCAGCGTC
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaiiiiiiiillllllllllllll

Reverse 
CAAGCAGAAGACGGCATACGAGATXXXXXXXXGTCTCGTGGGCTCGG
aaaaaaaaaaaaaaaaaaaaaaaaiiiiiiiilllllllllllllll


#-------------------------------------------------------------------------------
# LEGEND
#-------------------------------------------------------------------------------

p = locus-specific primer
s = sequencing primer
l = linker to allow attachment of indexed adapters
i = 8 bp index (bp represented as X; see below)
a = adapter that binds to flowcell


INDEXES

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
