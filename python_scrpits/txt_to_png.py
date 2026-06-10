from PIL import Image

def convert_txt_to_png(txt_filename, png_filename, width=640, height=480):
    print("I'm Reading the TXT file Naz! be patient. Hahaha=))))")
    
    img = Image.new("RGB", (width, height))
    pixels = img.load()
    
    with open(txt_filename, "r") as f:
        lines = f.readlines()
        
    idx = 0
    for y in range(height):
        for x in range(width):
            if idx < len(lines):
                r, g, b = map(int, lines[idx].strip().split())
                pixels[x, y] = (r, g, b)
                idx += 1
                
    img.save(png_filename, "PNG")
    print(f"Your Image is Reeady Naz!. Name of image:'{png_filename}' ")


convert_txt_to_png("image_00.txt", "filtered_output.png")