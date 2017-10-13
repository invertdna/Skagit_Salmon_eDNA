# Lab Update

2017-10-13

- Final goal: A sample for sequencing containing equal number of molecules from each sample
- Constructing this 'manually':
  - quantify (qubit) each sample (~ $0.5 /sample)
  - pipette different, small volumes that are unlikely to be accurate
  - or, dilute products to pipette larger volumes, followed by concentration (increased potential for contamination/loss of product)
-Constructing this 'automatically':
  - pipette full PCR product into 96 well sequalprep plate (~$1/sample)
  - elute off plate
  - result: equal concentrations, some cleanup
  - Sequalprep requires as input **no more** than 25uL of PCR product, containing **no less** than 250 ng of amplicons.
- Thus, concentration after cleanup of PCR2 must be at least 10 ng/uL

- Here's what we've learned:
  - Uncleaned DNA doesn't amplify
    - Clean using Zymo OneStep PCR cleanup
  - Diluted DNA (1:10) yields more product than full strength, even after cleanup
  - 

1. Cleanup (OneStep)
2. Dilute
3. PCR1
4. Cleanup (SPRI, 0.8:1)
5. Cleanup (SPRI, 0.7:1)
6. PCR2
7. Cleanup (SPRI, 0.7:1)
8. Normalize conc. (SequalPrep)

|a|f|
|---|---|
|a|f|

Notes from Linda
- run field and/or extraction blanks in qPCR to guard against spurious amplification out at 45 cycles
- try testing single sample multiple qpcr runs

- search for effect of freeze/thaw vs fridge over time for qPCR? (ask Penny's lab? Yan)

- put all samples from site on one run; spread field replicates across runs
