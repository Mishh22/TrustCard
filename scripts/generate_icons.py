#!/usr/bin/env python3
"""
Script to generate app icons for Android and iOS from a base logo image.
This script uses PIL (Pillow) to resize the base image to all required sizes.
"""

import os
from PIL import Image
import sys

def create_icon_sizes():
    """Generate all required icon sizes for Android and iOS"""
    
    # Check if base logo exists
    base_logo_path = "assets/images/logo.png"
    if not os.path.exists(base_logo_path):
        print("❌ Base logo not found at assets/images/logo.png")
        print("Please ensure you have a logo.png file in the assets/images/ directory")
        return False
    
    # Load the base image
    try:
        base_image = Image.open(base_logo_path)
        print(f"✅ Loaded base logo: {base_image.size}")
    except Exception as e:
        print(f"❌ Error loading base logo: {e}")
        return False
    
    # Android icon sizes (in pixels)
    android_sizes = [
        (48, "mipmap-mdpi"),
        (72, "mipmap-hdpi"), 
        (96, "mipmap-xhdpi"),
        (144, "mipmap-xxhdpi"),
        (192, "mipmap-xxxhdpi")
    ]
    
    # iOS icon sizes (in pixels)
    ios_sizes = [
        (20, "20pt"),
        (29, "29pt"),
        (40, "40pt"),
        (58, "58pt"),
        (60, "60pt"),
        (76, "76pt"),
        (80, "80pt"),
        (87, "87pt"),
        (114, "114pt"),
        (120, "120pt"),
        (152, "152pt"),
        (167, "167pt"),
        (180, "180pt"),
        (1024, "1024pt")
    ]
    
    # Create Android icons
    print("\n📱 Generating Android icons...")
    android_dir = "android/app/src/main/res"
    
    for size, folder in android_sizes:
        try:
            # Create directory if it doesn't exist
            icon_dir = os.path.join(android_dir, folder)
            os.makedirs(icon_dir, exist_ok=True)
            
            # Resize image
            resized = base_image.resize((size, size), Image.Resampling.LANCZOS)
            
            # Save as ic_launcher.png
            icon_path = os.path.join(icon_dir, "ic_launcher.png")
            resized.save(icon_path, "PNG")
            print(f"✅ Created {icon_path} ({size}x{size})")
            
        except Exception as e:
            print(f"❌ Error creating {size}x{size} icon: {e}")
    
    # Create iOS icons
    print("\n🍎 Generating iOS icons...")
    ios_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(ios_dir, exist_ok=True)
    
    for size, name in ios_sizes:
        try:
            # Resize image
            resized = base_image.resize((size, size), Image.Resampling.LANCZOS)
            
            # Save with appropriate name
            icon_path = os.path.join(ios_dir, f"icon-{name}.png")
            resized.save(icon_path, "PNG")
            print(f"✅ Created {icon_path} ({size}x{size})")
            
        except Exception as e:
            print(f"❌ Error creating {size}x{size} icon: {e}")
    
    # Create Contents.json for iOS
    contents_json = '''{
  "images" : [
    {
      "filename" : "icon-20pt.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-20pt.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-29pt.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-29pt.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-40pt.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-40pt.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-60pt.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "icon-60pt.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "icon-20pt.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-20pt.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon-29pt.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-29pt.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon-40pt.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-40pt.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon-76pt.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "icon-76pt.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "icon-83.5pt.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "icon-1024pt.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}'''
    
    contents_path = os.path.join(ios_dir, "Contents.json")
    with open(contents_path, 'w') as f:
        f.write(contents_json)
    print(f"✅ Created {contents_path}")
    
    print("\n🎉 Icon generation complete!")
    print("📝 Next steps:")
    print("1. Review the generated icons")
    print("2. Replace with higher quality versions if needed")
    print("3. Test the app to ensure icons display correctly")
    
    return True

if __name__ == "__main__":
    print("🚀 TrustCard App Icon Generator")
    print("=" * 40)
    
    # Check if PIL is available
    try:
        from PIL import Image
    except ImportError:
        print("❌ PIL (Pillow) not found. Please install it:")
        print("pip install Pillow")
        sys.exit(1)
    
    success = create_icon_sizes()
    if success:
        print("\n✅ All icons generated successfully!")
    else:
        print("\n❌ Icon generation failed. Please check the errors above.")
        sys.exit(1)
