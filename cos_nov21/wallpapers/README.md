# CustomOS Wallpapers

This folder contains wallpapers that will be included in your CustomOS installation.

## 📁 Adding Your Wallpapers

To add wallpapers:
1. Copy your wallpaper images to this folder **BEFORE** building the ISO
2. Supported formats: PNG, JPG, JPEG, WebP
3. The build script will automatically include them in the ISO

Example:
```bash
# From the CustomOS/cos_nov21 directory
cp ~/Downloads/my-awesome-wallpaper.jpg wallpapers/
cp ~/Pictures/*.png wallpapers/

# Then build ISO
bash build-hyprland-iso.sh
```

## 📍 Location on Installed System

Wallpapers will be copied to: `~/Pictures/wallpapers/`

## 🎨 Default Behavior

- **With wallpapers**: First wallpaper found (alphabetically) will be used automatically on boot
- **Without wallpapers**: Solid color background (#1e1e2e - Catppuccin Mocha dark gray)

## 🖼️ Dynamic Wallpaper Management

The optimized wallpaper system includes:
- Automatic wallpaper detection and loading
- Smooth transitions with swww (if available)
- Fallback to swaybg and hyprpaper
- Shared library for all wallpaper scripts

## 🔄 Changing Wallpapers After Installation

### Using Scripts:
- **Next wallpaper**: `~/.config/hypr/scripts/wallpaper-next.sh`
- **Previous wallpaper**: `~/.config/hypr/scripts/wallpaper-prev.sh`
- **Random wallpaper**: `~/.config/hypr/scripts/wallpaper-random.sh`
- **Choose wallpaper**: `~/.config/hypr/scripts/wallpaper-select.sh`

### Manually:
```bash
# Kill current wallpaper daemon
pkill swaybg

# Set new wallpaper
swaybg -i ~/Pictures/wallpapers/your-image.png -m fill &
```

## 🌐 Finding Wallpapers

Great places to find high-quality wallpapers:
- **[Unsplash](https://unsplash.com)** - Free high-resolution photos
- **[Wallhaven](https://wallhaven.cc)** - Huge collection, many anime/minimalist options
- **[Pexels](https://www.pexels.com)** - Free stock photos and videos
- **[Reddit r/wallpapers](https://reddit.com/r/wallpapers)** - Community curated
- **[Reddit r/wallpaper](https://reddit.com/r/wallpaper)** - More options
- **[Pling](https://www.pling.com/browse?cat=300&ord=latest)** - Linux-specific wallpapers

## 💡 Pro Tips

1. **Resolution**: Use wallpapers at or above your screen resolution for best quality
2. **File size**: Keep wallpapers under 10MB each for faster ISO builds
3. **Organization**: Create theme folders like `wallpapers/catppuccin-mocha/` for theme-specific wallpapers
4. **Login screen**: The first wallpaper found will also be used for the login screen
