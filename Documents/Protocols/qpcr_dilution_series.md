### Serial Dilution

Prepare a series of 10-fold dilutions for qPCR.

The general idea is as follows: using a set of 8 tubes, the tube on one end contains full-strength DNA, and the tube on the other end contains no DNA (no template control). The tubes in between contain decreasing amounts of DNA by an order of magniture.

Two things to consider:
  1. You'll run replicate reactions on each plate.
  2. You'll probably run multiple plates.

So you'll certainly need more than just enough for one reaction of each. 
But because DNA degrades each time it is frozen and thawed, you probably don't want to make a huge amount of each of the dilution levels that you'll thaw over and over again. 
Instead, it makes sense to make multiple batches, where each batch will be thawed only once before use, and contains enough for all the replicates needed per plate. 
This should also yield better consistency across runs.

#### To prepare sets of dilutions:

If **V** is the volume of template needed for each reaction, 

And **R** is the number of replicates per plate,

You'll need **VR** per tube in a strip of tubes for each plate, 

Plus an extra reaction's worth for pipetting error: **V(R+1)**

_Example_: Your reactions need 2uL template, and you'll do 4 replicates per plate, so you should prepare dilution series containing 10uL per tube (2*(4+1)).

Now, if you'd like to make sets of dilution series for multiple (**P**) plates, you should make tubes containing **V(R+1) x P** solution of each step in the dilution series, and then transfer **V(R+1)** aliquots to each well of your final strip tubes.

**MATERIALS**
- Strips of 8 tubes
- DNA-free water
- Target DNA template solution
- Pipettes and tips

**PROCEDURE**
1. Add **V(R+1) x P** water to tubes 2:8.
2. Add **V(R+1) x P x 1.1** DNA template solution to tube 1; mix and discard tip.
3. Transfer **V(R+1) x P x 0.1** from tube 1 to tube 2, mix, discard tip.
4. Transfer **V(R+1) x P x 0.1** from tube 2 to tube 3, mix, discard tip.
5. ...
6. Transfer **V(R+1) x P x 0.1** from tube 6 to tube 7, mix, discard tip.
7. Transfer **V(R+1) x P x 0.1** from tube 7 to **THE TRASH**! LEAVE IT PURE WATER.
8. Finally, transfer **V(R+1)** from the tubes in this strip to the corresponding tube in **P** other strips of tubes. That is, from tube 1 to tube 1, tube 2 to tube 2, and so on.

_EXAMPLE_: 2uL per reaction are needed, 4 replicates per plate, and 8 plates. 80uL of water goes into tubes 2:8. 88uL of template goes into tube 1. 8uL are transferred from tube 1 to tube 2, and so on to create dilution series. 10uL of this solution is transferred to 7 other strips of tubes, which are then sealed, labeled, and frozen.

Notes: 
  - MH: 6 point serial dilution from 100,000 to 10 copies/reaction
