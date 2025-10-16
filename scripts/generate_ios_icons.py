#!/usr/bin/env python3
"""
Generate iOS app icons from base logo
"""

from PIL import Image
import os

def generate_ios_icons():
    # Base logo path
    base_logo = "assets/images/logo.png"
    
    # Required iOS icon sizes
    ios_icons = {
        # iPhone icons
        "AppIcon-20@2x.png": 40,
        "AppIcon-20@3x.png": 60,
        "AppIcon-29@2x.png": 58,
        "AppIcon-29@3x.png": 87,
        "AppIcon-40@2x.png": 80,
        "AppIcon-40@3x.png": 120,  # Required for iPhone
        "AppIcon-60@2x.png": 120,  # Required for iPhone
        "AppIcon-60@3x.png": 180,
        
        # iPad icons
        "AppIcon-20.png": 20,
        "AppIcon-29.png": 29,
        "AppIcon-40.png": 40,
        "AppIcon-76.png": 76,
        "AppIcon-76@2x.png": 152,  # Required for iPad
        "AppIcon-83.5@2x.png": 167,  # Required for iPad Pro
        
        # App Store icon
        "AppIcon-1024.png": 1024
    }
    
    # Check if base logo exists
    if not os.path.exists(base_logo):
        print(f"Error: Base logo not found at {base_logo}")
        return False
    
    # Load base logo
    try:
        base_image = Image.open(base_logo)
        print(f"Loaded base logo: {base_image.size}")
    except Exception as e:
        print(f"Error loading base logo: {e}")
        return False
    
    # Create iOS app icons directory
    ios_icons_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(ios_icons_dir, exist_ok=True)
    
    # Generate all required icons
    for filename, size in ios_icons.items():
        try:
            # Resize image
            resized = base_image.resize((size, size), Image.Resampling.LANCZOS)
            
            # Save icon
            icon_path = os.path.join(ios_icons_dir, filename)
            resized.save(icon_path, "PNG")
            print(f"Generated: {filename} ({size}x{size})")
            
        except Exception as e:
            print(f"Error generating {filename}: {e}")
            return False
    
    print(f"\n✅ Successfully generated {len(ios_icons)} iOS app icons!")
    print(f"Icons saved to: {ios_icons_dir}")
    
    return True

if __name__ == "__main__":
    generate_ios_icons()
