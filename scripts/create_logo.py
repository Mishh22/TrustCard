#!/usr/bin/env python3
"""
Create a simple logo for TrustCard app
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_logo():
    """Create a simple logo with TrustCard text"""
    
    # Create a 512x512 image with white background
    size = 512
    img = Image.new('RGB', (size, size), color='white')
    draw = ImageDraw.Draw(img)
    
    # Try to use a system font, fallback to default if not available
    try:
        # Try different font paths
        font_paths = [
            '/System/Library/Fonts/Arial.ttf',
            '/System/Library/Fonts/Helvetica.ttc',
            '/Library/Fonts/Arial.ttf'
        ]
        
        font = None
        for font_path in font_paths:
            if os.path.exists(font_path):
                font = ImageFont.truetype(font_path, 60)
                break
        
        if font is None:
            font = ImageFont.load_default()
    except:
        font = ImageFont.load_default()
    
    # Draw a blue circle background
    circle_size = 400
    circle_x = (size - circle_size) // 2
    circle_y = (size - circle_size) // 2
    draw.ellipse([circle_x, circle_y, circle_x + circle_size, circle_y + circle_size], 
                 fill='#2196F3', outline='#1976D2', width=4)
    
    # Add "TC" text in the center
    text = "TC"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    text_x = (size - text_width) // 2
    text_y = (size - text_height) // 2 - 20
    
    draw.text((text_x, text_y), text, fill='white', font=font)
    
    # Add "TrustCard" text below
    small_font_size = 30
    try:
        small_font = ImageFont.truetype(font_paths[0], small_font_size) if font_paths[0] else ImageFont.load_default()
    except:
        small_font = ImageFont.load_default()
    
    trustcard_text = "TrustCard"
    bbox = draw.textbbox((0, 0), trustcard_text, font=small_font)
    text_width = bbox[2] - bbox[0]
    text_x = (size - text_width) // 2
    text_y = text_y + text_height + 20
    
    draw.text((text_x, text_y), trustcard_text, fill='white', font=small_font)
    
    # Save the logo
    logo_path = "assets/images/logo.png"
    os.makedirs(os.path.dirname(logo_path), exist_ok=True)
    img.save(logo_path, "PNG")
    
    print(f"✅ Created logo at {logo_path}")
    return True

if __name__ == "__main__":
    print("🎨 Creating TrustCard Logo")
    print("=" * 30)
    
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("❌ PIL (Pillow) not found. Please install it:")
        print("pip install Pillow")
        exit(1)
    
    success = create_logo()
    if success:
        print("✅ Logo created successfully!")
    else:
        print("❌ Logo creation failed.")
        exit(1)
