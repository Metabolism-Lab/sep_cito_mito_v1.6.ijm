# sep_cito_mito_v1.6.ijm

## Overview
This repository provides a Fiji/ImageJ macro for semi-automated image analysis.  
The macro performs:
- ROI-based mask creation using a selected frame and thresholding (Mixture Modeling plugin),
- background subtraction per stack,
- and output of filtered image stacks.

## Usage
1. Works with 8-bit sequential image stacks (channels C1 and C2).
2. Open your image stacks in Fiji/ImageJ.
3. Draw an ROI around the region of interest.
4. Run the macro (`sep_cito_mito_v1.6.ijm`).
5. Provide:
   - the frame number to compute the mask threshold,
   - the “real threshold” value (from Mixture Modeling).
6. The macro outputs filtered versions of C1 and C2, along with a binary mask.

## Dependencies
- Fiji (ImageJ with plugins)
  - Mixture Modeling
  - Slice Keeper

## License
This project is licensed under the [MIT License](LICENSE).
