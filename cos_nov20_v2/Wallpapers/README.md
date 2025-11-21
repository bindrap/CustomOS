# CustomOS Wallpapers

This folder contains wallpapers that will be included in your CustomOS installation.

## ⚠️ Important: Add Your Wallpapers Here!

**This folder is currently empty.** CustomOS will use a solid color background by default.

To add wallpapers:
1. Copy your wallpaper images to this folder BEFORE building the ISO
2. Supported formats: PNG, JPG, JPEG, WebP
3. The build script will automatically include them

Example:
```bash
cp ~/Downloads/my-wallpaper.png cos_nov20_v2/Wallpapers/
```

## Location on Installed System

Wallpapers will be copied to: `~/Pictures/wallpapers/`

## Default Behavior

- **With wallpapers**: First wallpaper found will be used automatically
- **Without wallpapers**: Solid color background (#1e1e2e - dark gray)

## Changing Wallpaper After Installation

After installation, you can:
1. Add more wallpapers to `~/Pictures/wallpapers/`
2. Manually set with: `swaybg -i ~/Pictures/wallpapers/your-image.png &`
3. Restart Hyprland: `ALT + M` then login again

## Finding Wallpapers

Great places to find wallpapers:
- https://unsplash.com
- https://wallhaven.cc
- https://www.pexels.com
- /r/wallpapers on Reddit
