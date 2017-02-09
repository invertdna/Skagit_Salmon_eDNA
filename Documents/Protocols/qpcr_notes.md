#### General Tips
Follow the MIQE Guidelines.
recomendations:
  - refer to Taqman probes as hydrolysis probes

For all following procedures, conduct at LEAST three replicate PCRs per DNA sample (include extraction negative and positive controls, and field negative controls, as well as PCR negative controls, and standard dilution series).


**Inhibition**
Marshal Hoy recommends checking for inhibitation first using an internal positive control.

First, rule out the possibility of falsely low concentration of target DNA by using an internal positive control:

[TaqMan Exogenous Internal Positive Control , catalog number 4308323](https://www.thermofisher.com/order/catalog/product/4308323)

If there is an indication of inhibition, you can use this to try to remove it:

[Zymo Research OneStep PCR Inhibitor Removal Kit](https://www.zymoresearch.com/rna/rna-clean-up/rt-pcr-inhibitor-removal/onestep-pcr-inhibitor-removal-kit)

Using a TaqMan gene expression assay from Life Technologies, custom designed by Marshal Hoy et al (in prep):

MH: These come as 20x stock, and are then diluted to 10x working solution in ultrapure water.

current probe: "Custom TaqMan MGB Probe, 100 uM" (separate email indicates 6000 pmol total; thus there must be 60uL liquid)
more info [here](https://www.thermofisher.com/us/en/home/technical-resources/technical-reference-library/real-time-digital-PCR-applications-support-center/taqman-primers-and-probes-support/taqman-primers-and-probes-support-getting-started.html).


### Quantitation

#### NOTES
- It seems the standard volume of mastermix is 0.5 * total reaction volume
- EMM2 = TaqMan® Environmental Master Mix 2.0 (Applied Biosystems); ThermoFisher Scientific Catalog number: 4396838;	200 reactions	$550.40
- In order to minimize the number of times that reagents are frozen and thawed, try to prepare stocks in amounts that will be used up in one go (i.e. for batches of 96 reactions with extra to account for pipetting errors)


### qPCR Assay Design (primers and Taqman/MGB/Hydrolysis probe)
[source1](https://www.thermofisher.com/us/en/home/references/ambion-tech-support/rtpcr-analysis/general-articles/top-ten-pitfalls-in-quantitative-real-time-pcr-primer.html)
[source2](http://www.idtdna.com/pages/decoded/decoded-articles/pipet-tips/decoded/2013/10/21/designing-pcr-primers-and-probes)
1. Melting temp of each primer should be between 58 and 60 ºC
2. Melting temp of primers should be within 1 ºC of each other
3. Melt temp of probe should be ~10 ºC (source1) or 6-8 ºC (source2) higher than primers. Note: Minor groove binder (MGB) moiety increases the Tm of the probe by several degrees.
4. Amplicon length should be between 50 and 150 bp. Longer amplicons may required thermal profile optimization.
5. primers between 18 and 30 bases; however, the most important considerations for primer design should be their Tm value and specificity. 
6. Primer sequences should not contain regions of 4 or more consecutive G residues. (source2)
7. GC content is 35–65%, with an ideal content of 50% for both primers and probe.
8. Probe: avoid a G at the 5’ end to prevent quenching of the 5’ fluorophore. (source2)
9. Check Oligos against this (see source2): https://www.idtdna.com/calc/analyzer