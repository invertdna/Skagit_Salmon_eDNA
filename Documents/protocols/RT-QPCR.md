### QPCR: quantitative real-time PCR

Follow the MIQE Guidelines.
recomendations:
  - refer to Taqman probes as hydrolysis probes

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

current probe: "Custom TaqMan MGB Probe, 100 uM"
more info [here](https://www.thermofisher.com/us/en/home/technical-resources/technical-reference-library/real-time-digital-PCR-applications-support-center/taqman-primers-and-probes-support/taqman-primers-and-probes-support-getting-started.html).

**Inhibition**

For each reaction testing inhibition:

- 5 microliter TaqMan Gene Expression Mastermix
- 0.5 microliter 10x primer/probe mix
- 1 microliter DNA template
- 1 microliter 10x internal positive control mix
- 0.22 microliter EXO-IPC DNA
- ??? microliter water
- 10 microliter total volume

Thermal cycling conditions (Instrument: ABI ViiA7)
initialization1_temp: 120 seconds
initialization1_time: 50C
initialization2_temp: 600 seconds
initialization2_time: 95C
n_cycles: 40
step1_temp: 95C
step1_time: 15 seconds
step2_temp: 60C
step2_time: 60 seconds
step3_temp:
step3_time:
final_temp:
final_time:

### Quantitation

#### serial dilution:
MH:6 point serial dilution from 100,000 to 10 copies/reaction

To prepare dilution, repeat this procedure for each :
  - aliquot of full strength template added to strip
  -


For each quantitation reaction:

- 5 microliter TaqMan Gene Expression Mastermix
- 0.5 microliter 10x primer/probe mix
- 3 microliter DNA template
- ??? microliter water
- 10 microliter total volume (Anna Elz uses 12uL)

Thermal cycling conditions (Instrument: ABI ViiA7)
(note: same as above but with 45 cycles instead of 40)
initialization1_temp: 120 seconds
initialization1_time: 50C
initialization2_temp: 600 seconds
initialization2_time: 95C
n_cycles: 45
step1_temp: 95C
step1_time: 15 seconds
step2_temp: 60C
step2_time: 60 seconds
step3_temp:
step3_time:
final_temp:
final_time:
