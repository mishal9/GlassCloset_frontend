# GlassCloset Design System

This document provides guidance on how to use the glassmorphic/visionOS-style design system throughout the GlassCloset app.

## Overview

The GlassCloset design system implements a consistent glassmorphic/visionOS-style design language that:
- Works seamlessly with both dark and light modes
- Can be easily inherited by components
- Provides a modern, elegant aesthetic
- Is modular and reusable across the app

## Key Components

### 1. Colors

The design system includes a set of predefined colors that adapt to light and dark mode:

```swift
GlassDesignSystem.Colors.primary      // Main brand color
GlassDesignSystem.Colors.secondary    // Secondary brand color
GlassDesignSystem.Colors.accent       // Accent color for highlights
GlassDesignSystem.Colors.textPrimary  // Primary text color
// and more...
```

### 2. Typography

Consistent text styles across the app:

```swift
GlassDesignSystem.Typography.largeTitle  // 34pt bold rounded
GlassDesignSystem.Typography.title1      // 28pt bold rounded
GlassDesignSystem.Typography.bodyMedium  // 15pt regular rounded
// and more...
```

### 3. Spacing

Consistent spacing values:

```swift
GlassDesignSystem.Spacing.xs  // 4pt
GlassDesignSystem.Spacing.sm  // 8pt
GlassDesignSystem.Spacing.md  // 16pt
// and more...
```

### 4. Radius

Consistent corner radius values:

```swift
GlassDesignSystem.Radius.sm  // 8pt
GlassDesignSystem.Radius.md  // 12pt
GlassDesignSystem.Radius.lg  // 16pt
// and more...
```

### 5. Shadows

Adaptive shadows for light and dark mode:

```swift
GlassDesignSystem.Shadows.subtle(colorScheme: colorScheme)
GlassDesignSystem.Shadows.medium(colorScheme: colorScheme)
GlassDesignSystem.Shadows.strong(colorScheme: colorScheme)
```

## View Modifiers

The design system includes several view modifiers to easily apply the glassmorphic style:

### Glass Background

```swift
Text("Hello, World!")
    .padding()
    .glassBackground(cornerRadius: GlassDesignSystem.Radius.lg)
```

### Glass Card

```swift
VStack {
    // Your content here
}
.glassCard(cornerRadius: GlassDesignSystem.Radius.lg)
```

### Glass Button

```swift
Button("Press Me") {
    // Action
}
.buttonStyle(GlassButtonStyle())
```

### Primary Glass Button

```swift
Button("Primary Action") {
    // Action
}
.buttonStyle(PrimaryGlassButtonStyle())
```

### Floating Effect

```swift
Text("I'm floating!")
    .padding()
    .glassBackground()
    .floatingEffect(intensity: 1.0)
```

## Reusable Components

### GlassCard

```swift
GlassCard {
    VStack {
        Text("Card Title")
        Text("Card content goes here")
    }
    .padding()
}
```

### GlassContainer

```swift
GlassContainer {
    VStack {
        Text("Container Title")
        Text("Container content goes here")
    }
    .padding()
}
```

## Best Practices

1. **Consistency**: Use the design system components and values consistently throughout the app.
2. **Color Scheme Awareness**: Always consider both light and dark mode when implementing UI.
3. **Accessibility**: Ensure text has sufficient contrast against backgrounds.
4. **Performance**: Use the floating effect sparingly as animations can impact performance.
5. **Depth**: Create a sense of depth by layering glass components with different opacities.

## Color Assets Setup

Make sure to set up the color assets in your Assets.xcassets catalog as described in the ColorAssets.swift file.
