### PCR: 2018-01-10


#### Samples
| row | col | sample          | rep1 | 
|-----|-----|-----------------|------| 
| a   | 1   | SKA-063-Z-10    | 1    | 
| b   | 1   | SKA-064-Z-10    | 1    | 
| c   | 1   | SKA-069-Z-10    | 1    | 
| d   | 1   | SKA-232-Z-10    | 1    | 
| e   | 1   | SKA-358-Z-10    | 1    | 
| f   | 1   | positivecontrol | 1    | 
| g   | 1   | DIH20           | 1    | 
| a   | 2   | SKA-063-Z-10    | 2    | 
| b   | 2   | SKA-064-Z-10    | 2    | 
| c   | 2   | SKA-069-Z-10    | 2    | 
| d   | 2   | SKA-232-Z-10    | 2    | 
| e   | 2   | SKA-358-Z-10    | 2    | 
| f   | 2   | positivecontrol | 2    | 
| g   | 2   | DIH20           | 2    | 


#### Reagents

| param_type | param_name                                                                 | uL_per_rxn | uL_batch | uL_extra | 
|------------|----------------------------------------------------------------------------|------------|----------|----------| 
| mastermix  | Phusion High-Fidelity PCR Master Mix with HF Buffer                        | 12.5       | 187.5    | 200      | 
| DMSO       | DMSO                                                                       | 0.75       | 11.25    | 12       | 
| primer     | 50-50 mix of 16S prey forward primers (groundfish and salmon) with adapter | 1.25       | 18.75    | 20       | 
| primer     | 16S prey reverse with adapter                                              | 1.25       | 18.75    | 20       | 
| water      | water                                                                      | 5.25       | 78.75    | 84       | 
| template   | "Zymo cleaned and diluted 1:10"                                            | 4          |          |          | 


#### Thermocycling

| param_name | units   | value | 
|------------|---------|-------| 
| init_temp  | C       | 98    | 
| init_time  | seconds | 30    | 
| n_cycles   | cycles  | 35    | 
| step1_temp | C       | 98    | 
| step1_time | seconds | 10    | 
| step2_temp | C       | 60    | 
| step2_time | seconds | 30    | 
| step3_temp | C       | 72    | 
| step3_time | seconds | 30    | 
| final_temp | C       | 72    | 
| final_time | seconds | 420   | 
