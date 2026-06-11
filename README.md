# HDMI Image Processing on Cyclone V GX

This design shows how we can read an image from BRAM, apply visual effects in real time, and drive a display over HDMI using a Cyclone V GX FPGA.  
For this project, I chose to use a photo of myself (from when I was young and beautiful, hahaha), because there’s something special about seeing your own face transformed by hardware you programmed. After converting the image into a .mif file (my_picture_RGB8.mif) and loading it into the FPGA’s Block RAM, I built a series of VHDL modules to apply various visual effects.  
It would’ve been easy to use a phone app for similar edits, but creating these effects in VHDL and watching them run on real hardware is a completely different experience. I did really LOVE it. =)))

---

## Project Overview
This project is a hardware image-processing pipeline built in VHDL. It stores a static image in BRAM, reads pixels in sync with display timing, converts the stored compact color format into a full-color representation, and applies one of many visual effects before sending the result to a monitor.  
The image is first converted by Python into a small 8-bit RGB332 format and stored as a `.mif` file. In the FPGA, each pixel is read in real time and expanded into a 24-bit RGB888 color value so the effect modules can process it with greater precision.  
The system can display the original image, mirrored image, pixelized image, or many color and stylized filter effects. It also supports simulation for verification before deploying to the hardware.


---
In this digital image processing system, each visual effect is implemented using specific mathematical logic or bit manipulation. The system processes **24-bit RGB** data (8 bits each for Red, Green, and Blue) to generate the output for each module.  
Below are the formulas and logic used for each effect:


### **Intensity and Contrast Effects**
*   **Brightness (`effect_bright`):** Each color channel is increased by a constant value ($g\_BRIGHT = 128$). The system adds this to the input and "clamps" the result at 255 to avoid errors.
    *   $Channel_{out} = Channel_{in} + g\_BRIGHT$   
    
*   **Darkness (`effect_dark`):** This is the opposite of brightness. It subtracts a value ($g\_DARK = 128$) and ensures the result does not go below 0.
    *   $Channel_{out} = Channel_{in} - g\_DARK$ 
  
*   **Contrast (`effect_contrast`):** This increases the difference between light and dark areas. It uses a midpoint (128) and a multiplier ($g\_CONTRAST = 2$).
    *   $Channel_{out} = 128 + (Channel_{in} - 128) \times g\_CONTRAST$  
  
*   **Fade (`effect_fade`):** This reduces the intensity of the image by keeping only the most significant bits and masking the rest. It essentially "mutes" the colors by shifting the data.
    *   $Channel_{out} = (Channel_{in} \text{ AND } 11100000) $  
  
![Intensity and Contrast Effects](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/assets/Slide1.PNG)  
  


### **Black-white and Grayscale Effects**
*   **Grayscale Averaged (`effect_grayscale_averaged`):** It calculates the average of all three colors to find the brightness level.
    *   $Gray = (Red + Green + Blue) / 3$
    *   $Output = (Gray, Gray, Gray)$  
  
*   **Grayscale Channel-Mix (`effect_grayscale_channelMix`):** Instead of math, it creates a gray look by taking specific high-order bits from Red (bits 7:5), Green (bits 7:5), and Blue (bits 7:6) to form a new 8-bit signal.  
  
*   **Inverted Grayscale (Averaged/Channel-Mix):** These modules calculate the grayscale value first and then apply the "Negative" formula ($255 - Gray$).  
  
*   **Black and White (`effect_BW`):** This compares the total brightness to a threshold (225). If the sum of R+G+B is higher, the pixel becomes pure white; otherwise, it is pure black.
    *   $\text{If } (R+G+B) > 225 \text{ then White, else Black}$  
![Black-white and Grayscale Effects](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/assets/Slide2.PNG)  
  


### **Posterize and Tint Effects**
*   **Warm Tint (`effect_warm_tint`):** This amplifies the Red and Blue components (specifically using a $3\times$ multiplier in the source) to give the image a "hot" look.   
  
*   **Cool Tint (`effect_cool_tint`):** This favors the blue spectrum by increasing blue-related values and decreasing red-related values.  
   
*   **Posterize (Warm/Cool):** These modules "chop" the lower bits of the color data to reduce the total number of colors (creating a "poster" look) and then apply a warm or cool color offset.  
![Posterize and Tint Effects](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/assets/Slide5.PNG)  
  


### **Stylistic and Color Conversion Effects**
*   **Solarize (`effect_solarize`):** This effect inverts a pixel’s color only if it is already very bright (above a threshold of 225).
    *   $\text{If } (R+G+B) > g_THRESHOLD \text{ then } (255-R, 255-G, 255-B), \text{ else original}$  

*   **Warm Negative (`effect_negative_warm`):** It first inverts the colors (negative) and then adds a warm tint offset to the result.
  
*   **Fire Effect (`effect_fire`):** This calculates the average brightness of a pixel and then uses that number to choose a color from a "fire" color ramp (transitioning from black to red, then orange, then yellow).  

*   **Negative (`effect_negative`):** This inverts the colors. In hardware, this is done by using a **NOT** gate on every bit, which is the same as subtracting from 255.
    *   $Channel_{out} = 255 - Channel_{in}$  
![Stylistic and Color Conversion Effects](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/assets/Slide6.PNG)  
  


### **Coordinate and Dynamic Effects**
*   **Checkerboard (`effect_checkerboard`):** It looks at the 5th bit of the X and Y coordinates. If you XOR these two bits and get '1', it shows the image; if '0', it shows black. This creates $32 \times 32$ pixel squares.
    *   $\text{Output} = \text{Image if } (X \text{ XOR } Y) = '1' \text{ else Black}$  

*   **CRT Scanlines (`effect_CRT`):** This simulates an old TV by making every other line darker. It checks the last bit of the Y coordinate ($Y \text{ mod } 2$).
    *   $\text{If } Y = '1' \text{ then } Channel_{out} = Channel_{in} / 2, \text{ else } Channel_{in}$  

*   **TV Noise (`effect_TV_noise`):** This ignores the image data and fills the screen with random pixels generated by the **LFSR8** (Linear Feedback Shift Register) module.  

*   **Rainbow (`effect_rainbow`):** This ignores the image and creates a color gradient based on the Y coordinate. As the screen draws downward, the colors transition through the spectrum.  

*   **RGB Cycling (`effect_RGB_cycling`):** Similar to the rainbow effect, but it "rotates" the Red, Green, and Blue channels based on the current row ($Y$) to create a moving color cycle.  
![Coordinate and Dynamic Effects-1](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/assets/Slide3.PNG)  
![Coordinate and Dynamic Effects-2](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/assets/Slide4.PNG)  
  

### **Expansion Effects**
*   **BBCE (Bright-Biased Color Expansion):** This logic expands the color range specifically in the bright areas of the image to make highlights pop more.  

*   **DBCE (Dark-Biased Color Expansion):** This expands the range in the darker areas of the image to show more detail in shadows.  

*   **Mirror Effect:** The Mirror effect creates a horizontal reflection by reversing the order in which pixels are read from each row of the memory. Normally, the system reads pixels from left to right ($0$ to $639$). To mirror the image, the system instead reads from right to left. When the screen wants to display the leftmost pixel ($X=0$), the system fetches the rightmost pixel from the ROM ($X=639$).
*   **Formula:**
    $$Address = ((\text{Image\_Width} - 1) - X) + (Y \times \text{Image\_Width})$$
    In your code, this is implemented as:
    $$Address = (639 - X) + (Y \times 640)$$.

*   **Pixelize Effect:** The Pixelize effect creates a "mosaic" or "blocky" look by forcing the system to display the same pixel value for a small square area (e.g., a $10 \times 10$ block).This is achieved by "quantizing" the coordinates. Instead of updating the memory address for every single pixel, the system uses integer division and multiplication to group coordinates together. This causes the $X$ and $Y$ values to stay the same for a specific range, effectively "stretching" one pixel across a larger block of the screen.
*   **Formula:**
    $$Address = \left(\left\lfloor \frac{X}{10} \right\rfloor \times 10\right) + \left(\left\lfloor \frac{Y}{10} \right\rfloor \times 10 \times \text{Image\_Width}\right)$$
    In hardware, the integer division $(\div 10)$ removes the remainder, and the multiplication $(\times 10)$ resets the coordinate to the start of the current 10-pixel block. This ensures that for every pixel inside a $10 \times 10$ area, the system reads the exact same data from the ROM.

![Expansion Effects](https://github.com/NazaninAzhdari/hdmi-img-processing/blob/main/assets/Slide7.PNG)  