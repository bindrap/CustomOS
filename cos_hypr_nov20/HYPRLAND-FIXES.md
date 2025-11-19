# Hyprland Configuration Fixes - cos_hypr_nov20

## Summary

Fixed Hyprland configuration errors caused by deprecated shadow syntax in newer Hyprland versions.

## Issues Fixed

### 1. Deprecated Shadow Syntax in hyprland.conf
**Location:** `custom-arch-setup/dotfiles/hypr/hyprland.conf` lines 87-90

**Old (Deprecated) Syntax:**
```
decoration {
    drop_shadow = true
    shadow_range = 8
    shadow_render_power = 2
    shadow_offset = 0 2
}
```

**New (Fixed) Syntax:**
```
decoration {
    shadow {
        enabled = true
        range = 8
        render_power = 2
        offset = 0 2
    }
}
```

**Errors Fixed:**
- ✓ `decoration:drop_shadow` does not exist
- ✓ `decoration:shadow_range` does not exist
- ✓ `decoration:shadow_render` does not exist
- ✓ `decoration:shadow_offset` does not exist

### 2. Deprecated col.shadow in theme-apply.sh
**Location:** `custom-arch-setup/dotfiles/hypr/scripts/theme-apply.sh` line 40

**Old (Deprecated) Syntax:**
```
decoration {
    col.shadow = $SHADOW_COLOR
}
```

**New (Fixed) Syntax:**
```
decoration {
    shadow {
        color = $SHADOW_COLOR
    }
}
```

**Errors Fixed:**
- ✓ `decoration:col:shadows` does not exist (in colors.conf)

### 3. Updated Build Scripts
Updated the following files to reference `cos_hypr_nov20` instead of `cos_hypr_nov19`:
- ✓ `build-hyprland-iso.sh`
- ✓ `build-hyprland-iso-clean.sh`

## Changes Made

1. **hyprland.conf** - Updated shadow configuration to use nested `shadow { }` block
2. **theme-apply.sh** - Updated generated colors.conf to use `shadow { color = ... }` syntax
3. **Build scripts** - Updated folder references from cos_hypr_nov19 to cos_hypr_nov20

## Testing

The configuration now uses Hyprland v0.40+ syntax and should no longer produce config errors.

To test:
```bash
cd cos_hypr_nov20
./test-iso-qemu-install.sh
```

## Compatibility

These fixes ensure compatibility with:
- Hyprland v0.40 and newer
- Current Arch Linux packages

## Next Steps

1. Build the ISO with the fixed configuration
2. Test in QEMU/VirtualBox
3. Verify terminal opens without config errors
4. Check that shadows render correctly

## Files Modified

- `custom-arch-setup/dotfiles/hypr/hyprland.conf`
- `custom-arch-setup/dotfiles/hypr/scripts/theme-apply.sh`
- `cos_hypr_nov20/build-hyprland-iso.sh`
- `cos_hypr_nov20/build-hyprland-iso-clean.sh`
