### QPCR: quantitative real-time PCR

**REAGENTS**
(per N samples, where N = 3 * (number environmental samples + 8 dilution steps))
- primer 1 @ 10uM
- primer 2 @ 10uM
- probe @ 10uM
- PCR Master Mix @ 1x
- PCR grade water

**CONSUMABLES** (per N samples)
- 1.5mL tubes (1 per primer set)
- PCR plate (96 or 384 wells)
- 1000uL filter tips (4N)
- 10uL filter tips (1)

**EQUIPMENT**
- centrifuge for plates
- pipettes (including a repeater pipette)
- vortexer

#### PREPARING THE REACTIONS
- **Vortex** the master mix, primers, and probe.
- Make PCR soup by adding appropriate amounts of the following to a 1.5 mL tube:
  - **master mix**, **water**, **primer 1**, **primer 2**, and **probe**.
- Pipette up and down to mix.
- Get out a plate and set it on a Kimwipe. It is very important to keep it away from dust and lint, as this will affect the ability of the laser to get good readings.
- Mark conspicuously the top left corner (well A1)
- Mark the top of the plate to indicate where blocks of samples and controls go.
- Using a repeater pipette, add the appropriate amount of PCR soup to each well.
- Using fresh tips each time, add samples to each of the wells of the plate.
- Cover the plate with a clear seal, and wipe with a rubber spatula to seal it tightly.
- Keeping a Kimwipe underneath, load the plate and centrifuge it briefly.

#### RUNNING THE MACHINE (Applied Biosystems 7900HT)
- Open the software SDS.
- File > New
- Assay: Standard Curve.
- Add detector:
  - Under "Setup" tab: New > Name, reporter = FAM
  - select the new row and "copy to plate document"
- highlight wells for NTC
- highlight wells, select "standard" and set quantity
- Tab: Instrument:
  - **IMPORTANT!** Set the volume correctly!
  - Set thermal cycler conditions
  - REAL TIME:
    - Connect to instrument
    - Select "Open/Close"
    - Load plate with first well (A1) in the correct position
- Hit Start Run,
- Select Save Changes
- Select a place to save it.
- GO!
