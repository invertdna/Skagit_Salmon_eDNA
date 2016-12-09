### QPCR: quantitative real-time PCR

#### General Tips
Follow the MIQE Guidelines.
recomendations:
  - refer to Taqman probes as hydrolysis probes

- Mix reagents well
-

For all following procedures, conduct at LEAST three replicate PCRs per DNA sample (include extraction negative and positive controls, and field negative controls, as well as PCR negative controls, and standard dilution series).

First, rule out the possibility of falsely low concentration of target DNA by using an internal positive control:

[TaqMan Exogenous Internal Positive Control , catalog number 4308323](https://www.thermofisher.com/order/catalog/product/4308323)

If there is an indication of inhibition, you can use this to try to remove it:

[Zymo Research OneStep PCR Inhibitor Removal Kit](https://www.zymoresearch.com/rna/rna-clean-up/rt-pcr-inhibitor-removal/onestep-pcr-inhibitor-removal-kit)

Using a TaqMan gene expression assay from Life Technologies, custom designed by Marshal Hoy et al (in prep):

>USGS_CKCO3-F
ATTCCATGGCCTACACGTGATT

>USGS_CKCO3-R
GGTATTGGACCTGTCGCAGAAG

>USGS_CKCO3-R-RC
GGTATTGGACCTGTCGCAGAAG

>USGS_CKCO3-PROBE
ATCAACCTTTCTAGCCGTT

MH: These come as 20x stock, and are then diluted to 10x working solution in ultrapure water.

current probe: "Custom TaqMan MGB Probe, 100 uM" (separate email indicates 6000 pmol total; thus there must be 60uL liquid)
more info [here](https://www.thermofisher.com/us/en/home/technical-resources/technical-reference-library/real-time-digital-PCR-applications-support-center/taqman-primers-and-probes-support/taqman-primers-and-probes-support-getting-started.html).

**Inhibition**
Marshal Hoy recommends checking for inhibitation first using an internal positive control.


### Quantitation

#### serial dilution:
MH:6 point serial dilution from 100,000 to 10 copies/reaction

To prepare 3 sets of dilutions:
  - if V is the volume of template needed for each reaction,
  - and you will do 3 replicates per plate
  - you will need 3V per dilution series per plate, plus 10% extra for pipetting error (call this 3VE)
    - whatever, let's just say we need 2uL/rxn, and will make batches of 7uL
  - for a strip of 8 tubes:
    - add 18 uL water to tube 2:8
    - add 20 uL sample to tube 1; discard tip
    - transfer 2 uL from tube 1 to tube 2, mix, discard tip.
    - transfer 2 uL from tube 2 to tube 3, mix, discard tip.
    - ...
    - transfer 2 uL from tube 6 to tube 7, mix, discard tip.
    - transfer 2 uL from tube 7 to THE TRASH! LEAVE IT PURE WATER.
  - aliquot of full strength template added to strip
  -


For each quantitation reaction:

- 5 microliter TaqMan Gene Expression Mastermix
- 0.5 microliter 10x primer/probe mix
- 3 microliter DNA template
- ??? microliter water
- 10 microliter total volume (Anna Elz uses 12uL)


Materials:
- Plate
- tips
-


#### NOTES
- It seems the standard volume of mastermix is 0.5 * total reaction volume
- EMM2 = TaqMan® Environmental Master Mix 2.0 (Applied Biosystems); ThermoFisher Scientific Catalog number: 4396838;	200 reactions	$550.40


version 2016-12-08:
- total vol:      20
- Taqman EMM2.0:  1


**REAGENTS** (per N samples, where N = 3 * (number environmental samples + 8 dilution steps))
- primer 1 @ 10uM: 0.9uL
- primer 2 @ 10uM: 0.9uL
- probe @ 10uM: 0.2uL
- EMM2 (see note) @ 1x:
-
-
- 5M NaCl (20uL)
- isopropanol aka 2-propanol 99.9% (500uL)
- PCR grade water (200uL)

**CONSUMABLES** (per N samples)
- 1.5mL tubes (1N)
- 2mL tubes (2N)
- 1000uL filter tips (4N)
- 10uL filter tips (1)

**EQUIPMENT**
- fume hood
- incubator (water bath or oven)
- centrifuge
- dryer
- pipettes (1000uL, 100uL or 20uL, 10uL)
