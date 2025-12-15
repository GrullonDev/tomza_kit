# Font Installation Instructions

## Roboto Mono Bold Font

The thermal PDF generator requires the Roboto Mono Bold font for optimal printing quality.

### Option 1: Download from Google Fonts (Recommended)

1. Visit: https://fonts.google.com/specimen/Roboto+Mono
2. Click "Download family"
3. Extract the ZIP file
4. Copy `RobotoMono-Bold.ttf` to this directory (`assets/fonts/`)

### Option 2: Download Direct Link

Download directly from GitHub:
https://github.com/google/fonts/raw/main/apache/robotomono/RobotoMono-Bold.ttf

Save as: `assets/fonts/RobotoMono-Bold.ttf`

### Option 3: Use Alternative Font

If you prefer a different monospaced bold font:

1. Place your `.ttf` file in this directory
2. Update `pubspec.yaml`:
   ```yaml
   fonts:
     - family: RobotoMonoBold
       fonts:
         - asset: assets/fonts/YourFont-Bold.ttf
           weight: 700
   ```

### Verification

After placing the font file, run:
```bash
flutter pub get
```

The font should be at:
`c:\Users\jgrullon\Documents\Apps_Sugerencia_tropi\tomza_kit\assets\fonts\RobotoMono-Bold.ttf`

### Fallback

If no font is provided, the system will use Courier as a fallback, but print quality may not be optimal.
