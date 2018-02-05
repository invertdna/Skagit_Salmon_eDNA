### PCR: 2018-01-10


#### Samples
| row | col | sample            | rep | 
|-----|-----|-------------------|-----| 
| a   | 1   | SKA-063-Z-10      | 1   | 
| b   | 1   | SKA-064-Z-10      | 1   | 
| c   | 1   | SKA-069-Z-10      | 1   | 
| d   | 1   | SKA-358-Z-10      | 1   | 
| e   | 1   | AMCPMOO101−161012 | 1   | 
| f   | 1   | DIH20             | 1   | 
| a   | 2   | SKA-063-Z-10      | 2   | 
| b   | 2   | SKA-064-Z-10      | 2   | 
| c   | 2   | SKA-069-Z-10      | 2   | 
| d   | 2   | SKA-358-Z-10      | 2   | 
| e   | 2   | AMCPMOO101−161012 | 2   | 
| f   | 2   | DIH20             | 2   | 
| a   | 3   | SKA-063-Z-10      | 3   | 
| b   | 3   | SKA-064-Z-10      | 3   | 
| c   | 3   | SKA-069-Z-10      | 3   | 
| d   | 3   | SKA-358-Z-10      | 3   | 
| e   | 3   | AMCPMOO101−161012 | 3   | 
| f   | 3   | DIH20             | 3   | 



#### Reagents

| param_type | param_name                                                          | uL_per_rxn | uL_batch | uL_extra | 
|------------|---------------------------------------------------------------------|------------|----------|----------| 
| mastermix  | Phusion High-Fidelity PCR Master Mix with HF Buffer                 | 12.5       | 225      | 250      | 
| DMSO       | DMSO                                                                | 0.75       | 13.5     | 15       | 
| primer     | 50-50 mix of 16S groundfish and salmon forward primers with adapter | 1.25       | 22.5     | 25       | 
| primer     | 16S prey reverse with adapter                                       | 1.25       | 22.5     | 25       | 
| water      | water                                                               | 5.25       | 94.5     | 105      | 
| template   | Zymo cleaned and diluted 1:10                                       | 4          |          |          | 


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
