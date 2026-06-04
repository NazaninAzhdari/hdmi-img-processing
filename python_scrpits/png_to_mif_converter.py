from PIL import Image
import sys

#This python scripts converts .png file to .mif file.
#This scripts supports:
#   1- Any image size: Automatically reads "width" × "height" from the PNG. (Remember to cut your pic to your desired pixel size)
#   2- Any color format, you can choose:
#       "GRAY8" → 8‑bit grayscale
#       "RGB12" → 4‑4‑4 RGB
#       "RGB16" → 5‑6‑5 RGB
#       "RGB24" → 8‑8‑8 RGB
#   3- Also it Automaticlly computes MIF width/depth
#       WIDTH = bits per pixel (determined based on color format)
#       DEPTH = "width" × "height"

#To use this scripts run "python png_to_mif_converter.py XXX.png XXX.mif RGBXXX"
#Give the name of the picture you want to convert, in the format of XXX.png, replace the XXX by the name of picture
#Give the name of output file that you want, in the format of "XXX.mif", replace the XXX by the name of output file you want
#Give the Color Format you want to use in the format of "RGBXXX", replace XXX by 8, 12, 16, 24  (RGB8, RGB12, RGB16, RGB24)


# -----------------------------
#  CONFIGURABLE COLOR FORMATS
# -----------------------------
def convert_pixel(r, g, b, mode):
    """
    Convert X-bit RGB pixel to desired bit depth.
    Returns integer "pixel value" and "number of bits(bit-width)".
    """

    if mode == "GRAY8":
        gray = (r + g + b) // 3
        return gray, 8

    elif mode == "RGB12":  # 4-4-4
        r4 = r >> 4
        g4 = g >> 4
        b4 = b >> 4
        return (r4 << 8) | (g4 << 4) | b4, 12

    elif mode == "RGB16":  # 5-6-5
        r5 = r >> 3
        g6 = g >> 2
        b5 = b >> 3
        return (r5 << 11) | (g6 << 5) | b5, 16

    elif mode == "RGB24":  # 8-8-8
        return (r << 16) | (g << 8) | b, 24

    else:
        raise ValueError("Unsupported color mode: " + mode)


# -----------------
#  MAIN CONVERTER
# -----------------
def png_to_mif(input_png, output_mif, mode):
    # Open image and convert to RGB
    img = Image.open(input_png).convert("RGB")

    # Optionally resize to desired resolution
    width, height = img.size

    pixels = img.load()

    # Convert first pixel to detect bit width
    _, bit_width = convert_pixel(*pixels[0, 0], mode)

    depth = width * height

    with open(output_mif, "w") as f:
        f.write(f"WIDTH = {bit_width};\n")
        f.write(f"DEPTH = {depth};\n")
        f.write("ADDRESS_RADIX = DEC;\n")
        f.write("DATA_RADIX = HEX;\n")
        f.write("CONTENT BEGIN\n")

        addr = 0
        for y in range(height):
            for x in range(width):
                r, g, b = pixels[x, y]
                value, _ = convert_pixel(r, g, b, mode)
                f.write(f"    {addr} : {value:X};\n")
                addr += 1

        f.write("END;\n")

    print(f"Done! Generated {output_mif}")
    print(f"Image size: {width}x{height}")
    print(f"Color mode: {mode} ({bit_width} bits per pixel)")
    print(f"Total pixels: {depth}")


# ----------------------
#  COMMAND LINE ENTRY
# ----------------------
if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python png_to_mif.py input.png output.mif RGB12")
        print("Modes: GRAY8, RGB12, RGB16, RGB24")
        sys.exit(1)

    png_to_mif(sys.argv[1], sys.argv[2], sys.argv[3])
