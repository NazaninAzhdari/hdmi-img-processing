# HDMI Image Processing on Cyclone V GX

Welcome to the **HDMI Image Processing** project. This design shows how an FPGA can read an image from memory, apply visual effects in real time, and drive a display over HDMI using a Cyclone V GX device.

---

## Project Overview
This project is a hardware image-processing pipeline built in VHDL. It stores a static image in BRAM, reads pixels in sync with display timing, converts the stored compact color format into a full-color representation, and applies one of many visual effects before sending the result to a monitor.

The image is first converted by Python into a small 8-bit RGB332 format and stored as a `.mif` file. In the FPGA, each pixel is read in real time and expanded into a 24-bit RGB888 color value so the effect modules can process it with greater precision.

The system can display the original image, mirrored image, pixelized image, or many color and stylized filter effects. It also supports simulation for verification before deploying to the hardware.

---



---
In this digital image processing system, each visual effect is implemented using specific mathematical logic or bit manipulation. The system processes **24-bit RGB** data (8 bits each for Red, Green, and Blue) to generate the output for each module.  
  
This is the original image that I have stored in the BRAM:  
![Original Image](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/in/png/my_picture.png)  

Below are the formulas and logic used for each effect:


### **Intensity and Contrast Effects**
*   **Brightness (`effect_bright`):** Each color channel is increased by a constant value ($g\_BRIGHT = 128$). The system adds this to the input and "clamps" the result at 255 to avoid errors.
    *   $Channel_{out} = \min(Channel_{in} + 128, 255)$  
![Brightness Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_23.png)  
    
*   **Darkness (`effect_dark`):** This is the opposite of brightness. It subtracts a value ($g\_DARK = 128$) and ensures the result does not go below 0.
    *   $Channel_{out} = \max(Channel_{in} - 128, 0)$  
![Darkness Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_07.png)  
  
*   **Contrast (`effect_contrast`):** This increases the difference between light and dark areas. It uses a midpoint (128) and a multiplier ($g\_CONTRAST = 2$).
    *   $Channel_{out} = 128 + (Channel_{in} - 128) \times 2$  
![Contrast Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_24.png)  
  
*   **Fade (`effect_fade`):** This reduces the intensity of the image by keeping only the most significant bits and masking the rest. It essentially "mutes" the colors by shifting the data.
    *   $Channel_{out} = (Channel_{in} \text{ bitwise AND } 11100000) \text{ then shifted}$  
![Fade to Black Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_25.png)  
  
### **Color Conversion and Grayscale Effects**
*   **Negative (`effect_negative`):** This inverts the colors. In hardware, this is done by using a **NOT** gate on every bit, which is the same as subtracting from 255.
    *   $Channel_{out} = 255 - Channel_{in}$  
![Negative Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_14.png)  
  
*   **Grayscale Averaged (`effect_grayscale_averaged`):** It calculates the average of all three colors to find the brightness level.
    *   $Gray = (Red + Green + Blue) / 3$
    *   $Output = (Gray, Gray, Gray)$  
![Averaged Gray Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_10.png)  
  
*   **Grayscale Channel-Mix (`effect_grayscale_channelMix`):** Instead of math, it creates a gray look by taking specific high-order bits from Red (bits 7:5), Green (bits 7:5), and Blue (bits 7:6) to form a new 8-bit signal.  
![Channel-Mix Gray Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_11.png)  
  
*   **Inverted Grayscale (Averaged/Channel-Mix):** These modules calculate the grayscale value first and then apply the "Negative" formula ($255 - Gray$).  
![Inversion of Averaged Gray Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_12.png)  
  
![Inversion of Channel-Mix Gray Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_13.png)  
  
*   **Black and White (`effect_BW`):** This compares the total brightness to a threshold (225). If the sum of R+G+B is higher, the pixel becomes pure white; otherwise, it is pure black.
    *   $\text{If } (R+G+B) > 225 \text{ then White, else Black}$  
![Black-White Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_03.png)  
  
### **Stylistic and Tint Effects**
*   **Warm Tint (`effect_warm_tint`):** This amplifies the Red and Blue components (specifically using a $3\times$ multiplier in the source) to give the image a "hot" look.  
![Warm Tint Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_21.png)  
  
*   **Cool Tint (`effect_cool_tint`):** This favors the blue spectrum by increasing blue-related values and decreasing red-related values.  
![Cool Tint Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_05.png)  
  
*   **Solarize (`effect_solarize`):** This effect inverts a pixel’s color only if it is already very bright (above a threshold of 225).
    *   $\text{If } (R+G+B) > 225 \text{ then } (255-R, 255-G, 255-B), \text{ else original}$  
![Solarize Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_20.png)  
  
*   **Posterize (Warm/Cool):** These modules "chop" the lower bits of the color data to reduce the total number of colors (creating a "poster" look) and then apply a warm or cool color offset.  
![Warm Posterize Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_17.png)  
  
![Cool Posterize Effect](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/doc/out/png/output_image_16.png)  
  
*   **Warm Negative (`effect_negative_warm`):** It first inverts the colors (negative) and then adds a warm tint offset to the result.
*   **Fire Effect (`effect_fire`):** This calculates the average brightness of a pixel and then uses that number to choose a color from a "fire" color ramp (transitioning from black to red, then orange, then yellow).

### **Coordinate and Dynamic Effects**
*   **Checkerboard (`effect_checkerboard`):** It looks at the 5th bit of the X and Y coordinates. If you XOR these two bits and get '1', it shows the image; if '0', it shows black. This creates $32 \times 32$ pixel squares.
    *   $\text{Output} = \text{Image if } (X \text{ XOR } Y) = '1' \text{ else Black}$
*   **CRT Scanlines (`effect_CRT`):** This simulates an old TV by making every other line darker. It checks the last bit of the Y coordinate ($Y \text{ mod } 2$).
    *   $\text{If } Y = '1' \text{ then } Channel_{out} = Channel_{in} / 2, \text{ else } Channel_{in}$
*   **TV Noise (`effect_TV_noise`):** This ignores the image data and fills the screen with random pixels generated by the **LFSR8** (Linear Feedback Shift Register) module.
*   **Rainbow (`effect_rainbow`):** This ignores the image and creates a color gradient based on the Y coordinate. As the screen draws downward, the colors transition through the spectrum.
*   **RGB Cycling (`effect_RGB_cycling`):** Similar to the rainbow effect, but it "rotates" the Red, Green, and Blue channels based on the current row ($Y$) to create a moving color cycle.

### **Expansion Effects**
*   **BBCE (Bright-Biased Color Expansion):** This logic expands the color range specifically in the bright areas of the image to make highlights pop more.
*   **DBCE (Dark-Biased Color Expansion):** This expands the range in the darker areas of the image to show more detail in shadows.


## System Architecture
The architecture is a pipeline of modules, each with a clear role:

1. **Clock and timing generation** - produces the pixel clock and VGA/HDMI sync signals.
2. **Pixel coordinate generation** - tracks the current display position in X and Y.
3. **ROM address generation** - converts coordinates into the correct memory address.
4. **ROM read** - fetches the stored 8-bit pixel from BRAM.
5. **Format conversion** - expands RGB332 into RGB888 for processing.
6. **Effect processing** - feeds the full-color pixel into multiple filter modules.
7. **Selection and output** - selects the final effect pixel and sends it to HDMI.

This flow allows the system to keep the image data small in memory while still applying high-quality effects at the output stage.

## Effect Module Details

### Color and Brightness Effects

**`effect_bright.vhd`**
- This effects Adds a constant brightness factor to each RGB channel. it clamps values at 255 to avoid overflow. and Produces a brighter overall image.
    *   $Red_{out} = Red_{in} + 128$
    *   $Green_{out} = Green_{in} + 128$
    *   $Blue_{out} = Blue_{in} + 128$

**`effect_dark.vhd`**
- Subtracts a constant from each RGB channel.
- Creates a darker image without changing the color ratios.

**`effect_BBCE.vhd`**
- Bright-Biased Color Expansion.
- Repeats the high-order bits of each channel to produce stronger highlights.
- Creates a richer, brighter look without a direct add operation.

**`effect_DBCE.vhd`**
- Dark-Biased Color Expansion.
- Uses lower-order bits with repeated channel segments to produce deeper tones.
- Creates a more muted, shadow-rich appearance.

**`effect_contrast.vhd`**
- Applies a contrast gain around the mid-level value 128.
- Darker pixels become darker, and brighter pixels become brighter.
- Useful for sharpening visual detail.

**`effect_fade.vhd`**
- Reduces intensity across all channels.
- Creates a film-like fade effect.

### Tint and Tone Effects

**`effect_cool_tint.vhd`**
- Shifts image color balance toward cooler (blue-green) tones.
- Useful for icy or calm color grading.

**`effect_warm_tint.vhd`**
- Shifts color balance toward warmer red/orange tones.
- Gives the image a cozy or sunset-like feeling.

**`effect_negative_warm.vhd`**
- Produces a negative image with a warm bias.
- Inverts colors while preserving warm coloration.

### Grayscale and Inversion Effects

**`effect_grayscale_averaged.vhd`**
- Computes the average of red, green, and blue.
- Assigns that average to each channel.
- Produces a standard grayscale image.

**`effect_grayscale_channelMix.vhd`**
- Mixes high-order bits of R, G, and B into a single channel.
- Assigns that mix equally to all three outputs.
- Produces a stylized grayscale effect with reduced detail.

**`effect_invert_gray_averaged.vhd`**
- Converts the image to average grayscale, then inverts it.
- Creates a negative grayscale effect.

**`effect_invert_gray_channelMix.vhd`**
- Uses the channel-mix grayscale value and inverts it.
- Produces a different negative-grayscale appearance.

**`effect_negative.vhd`**
- Inverts each RGB channel separately.
- Produces a classic color negative.

### Posterize and Filter Effects

**`effect_posterize_cool.vhd`**
- Reduces each channel to a small set of values.
- Pads the lower bits to preserve contrast and adds a cool tone.
- Produces a posterized, simplified color palette.

**`effect_posterize_warm.vhd`**
- Similar to cool posterize, but with a warmer output.
- Retains strong color blocks for a stylized image.

**`effect_solarize.vhd`**
- Computes the pixel intensity sum.
- Inverts the pixel only when the sum is above a threshold.
- Produces a dramatic solarization effect.

**`effect_checkerboard.vhd`**
- Uses the X and Y pixel bits to build a tiled pattern.
- Darkens every other tile region.
- Gives a checkerboard overlay on the original image.

**`effect_CRT.vhd`**
- Creates horizontal intensity modulation based on vertical position.
- Emulates old CRT display scanline shading.

### Dynamic and Spatial Effects

**`effect_fire.vhd`**
- Computes the average brightness of the pixel.
- Assigns that average strongly to red, moderately to green, and weakly to blue.
- Produces a warm, flame-like palette.

**`effect_rainbow.vhd`**
- Applies different color tints in vertical bands.
- Gives each section a distinct hue: red, orange, yellow, green, blue, and violet.

**`effect_RGB_cycling.vhd`**
- Reorders or shifts RGB channels based on the vertical position.
- Produces a cycling color band effect.

**`effect_TV_noise.vhd`**
- Adds random noise from `LFSR8.vhd` to each channel.
- Simulates television static and visual noise.

**`effect_BW.vhd`**
- Converts the image to black and white using a threshold.
- Produces a high-contrast monochrome result.

## Explanation of Each Module and Its Job

### Core Modules

**`img_processing_top.vhd`**
- Top-level module that wires every block together.
- Accepts the 50 MHz board clock and a reset signal.
- Reads 5 input bits for effect selection and passes them through debouncers.
- Collects sync signals, pixel coordinates, ROM data, and processed pixel output.
- Drives the HDMI clock, data enable, HSYNC, VSYNC, and 24-bit video output.
- Routes the selected effect code to the LEDs so the current effect is visible.

**`VGAsync.vhd`**
- Generates standard 640x480 VGA timing at 25 MHz.
- Produces horizontal sync (`o_HS`), vertical sync (`o_VS`), and data enable (`o_DE`).
- Outputs X and Y pixel coordinates for each active display cycle.
- Acts as the timing reference for the whole image pipeline.

**`freq_divider.vhd`**
- Divides the 50 MHz input clock down to 25 MHz.
- Provides the pixel clock required by `VGAsync.vhd`.
- Ensures the display timing stays aligned with HDMI/VGA requirements.

**`debounce_filter.vhd`**
- Filters noisy mechanical switch inputs.
- Converts each raw input bit into a stable debounced signal.
- Prevents a single button press from generating multiple effect changes.

**`read_rom.vhd`**
- Translates pixel coordinates into a ROM address.
- Supports three address modes:
  - Normal image read.
  - Mirror mode, which flips the image horizontally.
  - Pixelize mode, which groups 4x4 pixel blocks into single source pixels.
- Provides the selected 8-bit pixel value to the color conversion block.
- Uses the same effect selection bits as `control_effects.vhd`, so the address-based transformations stay in sync with the chosen effect.

**`img_rom.vhd`**
- Implements the image memory block.
- Reads pixel data from a `.mif` file at synthesis time.
- Stores the image in compact RGB332 format to save BRAM resources.

**`RGB332_to_RGB888.vhd`**
- Expands the stored 8-bit pixel into 24-bit RGB color.
- Converts 3-bit red and green channels into 8-bit values by scaling.
- Converts 2-bit blue into 8-bit values using a larger multiplier.
- Prepares the pixel for full 24-bit effect processing.

**`control_effects.vhd`**
- Central effect manager.
- Instantiates every effect module in parallel.
- Uses the selected effect code to choose the final output pixel.
- Passes the X/Y coordinates and RGB888 pixel to modules that need spatial data.
- Supports direct output for original, mirror, and pixelize modes plus all filter effects.

---



### Utility and Support Modules

**`LFSR8.vhd`**
- Generates an 8-bit pseudo-random number.
- Used by `effect_TV_noise.vhd` to add random pixel noise.

**`img_processing_TB.vhd`**
- Testbench for verifying the complete image-processing pipeline.
- Useful for simulation before hardware deployment.

**`picture_reader_TB.vhd`**
- Testbench for verifying the ROM read and pixel conversion logic.
- Helps confirm image memory addressing.

---

## Hardware Deployment / Setup Guide

### 1) Prepare the Image
- Use the Python script `python_scrpits/png_to_mif_converter.py`.
- Convert your source image to 640x480 and RGB332 format.
- The script creates `.mif` files such as `my_picture_RGB8.mif`.
- Place the generated `.mif` file in the Quartus project and connect it to `img_rom`.

### 2) Compile the FPGA Project
- Open the Quartus project that contains the `rtl/` files.
- Confirm `img_rom.vhd` uses the generated `.mif` file.
- Run synthesis and fitting for the Cyclone V GX device.
- Generate the programming file and program the FPGA.

### 3) Connect HDMI and Power
- Connect the FPGA board’s HDMI output to a display.
- Power the board and verify the 50 MHz clock is active.
- Watch for the image output and the sync signals.

### 4) Select Effects
- Use the input switches to set the effect code.
- The debounced outputs ensure stable selection.
- LEDs display the current effect bits.
- The image will update in real time when the effect changes.

### 5) Simulate First (Recommended)
- Use `sim/img_processing_TB.vhd` in ModelSim or another VHDL simulator.
- Validate timing, ROM read, and effect output.
- Optionally convert simulator output back to PNG with `python_scrpits/txt_to_png_converter.py`.
- This step helps confirm the design before connecting hardware.

---

## Module Relationships and Data Flow

1. `img_processing_top.vhd` is the top module and the central hub.
2. `freq_divider.vhd` provides the pixel clock to `VGAsync.vhd`.
3. `VGAsync.vhd` produces coordinates and sync/video timing.
4. `read_rom.vhd` receives coordinates and effect selection, then reads `img_rom.vhd`.
5. `RGB332_to_RGB888.vhd` converts the ROM output into 24-bit pixel color.
6. `control_effects.vhd` applies the selected visual filter and produces the final output pixel.
7. `img_processing_top.vhd` sends the final RGB pixel only when `o_DE` is asserted, so the HDMI output is active during visible display periods.

This design keeps the data path simple: coordinate → ROM address → pixel fetch → color expansion → effect filter → HDMI output.

---

## Notes
- The image storage is optimized for low BRAM usage with RGB332 format.
- The effect selection uses the same input bits for both address-based modes and per-pixel filters.
- Use LEDs to see the selected effect code on the board.
- If you need a different resolution, update `VGAsync.vhd` timing constants and `read_rom.vhd` image dimensions.
- The project is designed for learning and demonstration: it shows how to connect memory, timing, and image processing in FPGA hardware.

Enjoy exploring the different effects and the hardware pipeline in this FPGA project!