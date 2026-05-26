---
name: Bubbly Arcade
colors:
  surface: '#f6fce9'
  surface-dim: '#d7dcca'
  surface-bright: '#f6fce9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f6e3'
  surface-container: '#ebf0dd'
  surface-container-high: '#e5ebd8'
  surface-container-highest: '#dfe5d2'
  on-surface: '#181d12'
  on-surface-variant: '#414a36'
  inverse-surface: '#2d3226'
  inverse-on-surface: '#edf3e0'
  outline: '#717a64'
  outline-variant: '#c0cab1'
  surface-tint: '#3a6a00'
  primary: '#3a6a00'
  on-primary: '#ffffff'
  primary-container: '#7ed321'
  on-primary-container: '#2e5600'
  inverse-primary: '#87dc2c'
  secondary: '#0060ac'
  on-secondary: '#ffffff'
  secondary-container: '#68abff'
  on-secondary-container: '#003e73'
  tertiary: '#a000bf'
  on-tertiary: '#ffffff'
  tertiary-container: '#f39fff'
  on-tertiary-container: '#83009d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a1fa49'
  primary-fixed-dim: '#87dc2c'
  on-primary-fixed: '#0e2000'
  on-primary-fixed-variant: '#2a5000'
  secondary-fixed: '#d4e3ff'
  secondary-fixed-dim: '#a4c9ff'
  on-secondary-fixed: '#001c39'
  on-secondary-fixed-variant: '#004883'
  tertiary-fixed: '#fed6ff'
  tertiary-fixed-dim: '#f6adff'
  on-tertiary-fixed: '#350040'
  on-tertiary-fixed-variant: '#7a0092'
  background: '#f6fce9'
  on-background: '#181d12'
  surface-variant: '#dfe5d2'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  display-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '800'
    lineHeight: '1.2'
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: '1.3'
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: '1.5'
  label-bold:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '800'
    lineHeight: '1'
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 8px
  container-padding: 24px
  gutter: 16px
  border-depth-sm: 4px
  border-depth-md: 8px
---

## Brand & Style

The design system is centered on a high-energy, playful arcade aesthetic. It is designed for casual gaming and social entertainment platforms where the UI is an active participant in the experience rather than a passive container.

The visual style is **Tactile & Glossy**, characterized by "bubbly" proportions, physical depth through simulated 3D borders, and a high-shine finish. Every interaction should feel squishy, responsive, and rewarding. The UI prioritizes high contrast and exaggerated affordances to create a sense of fun and accessibility.

## Colors

The palette is vibrant and highly saturated. The design system uses a multi-primary approach where colors represent functional categories or rarity tiers (e.g., Green for Success/Action, Blue for Information, Purple for Premium/Epic, Orange for Alerts/Shop).

- **Gloss Overlays:** Use a semi-transparent white gradient (top-down) to create the "shine" effect.
- **Depth Borders:** Every primary color has a corresponding "Shadow Color" (the base hex at -20% brightness) used for the thick bottom borders to simulate 3D depth.
- **Backgrounds:** Primarily light blue and white surfaces to allow the saturated components to pop.

## Typography

This design system uses **Plus Jakarta Sans** for its friendly, rounded terminals that complement the "bubbly" UI shapes.

- **Outlines:** All text placed on colored buttons or ribbons must use a 2px-4px outside stroke (White for dark backgrounds, Dark Blue/Purple for light backgrounds) to ensure readability.
- **Drop Shadows:** Use a subtle, hard-edged shadow on text to match the 3D effect of the containers.
- **Hierarchy:** High contrast in weight is preferred over size variations. Use Bold (700) or ExtraBold (800) for almost all UI labels.

## Layout & Spacing

The layout follows a **Fixed Grid** model for modals and a **Fluid Grid** for main game screens. 

- **The 8px Rhythm:** All spacing, margins, and paddings must be multiples of 8px.
- **Depth Offset:** Spacing must account for the "Depth Border" (the thick bottom border). Padding should be measured from the inner container edge, not the outer shadow.
- **Responsive Behavior:** On mobile, containers scale to 100% width with 16px side margins. Modals maintain a maximum width of 600px on desktop to preserve the "handheld" feel.

## Elevation & Depth

Hierarchy is achieved through physical simulation rather than ambient shadows:

1.  **Primary Depth:** Created using a solid, darker-colored bottom border (4px to 8px thick) that gives the appearance of a physical "slab."
2.  **Glossy Finish:** An inner white highlight (10-20% opacity) at the top of elements suggests a light source from above.
3.  **Floating Elements:** Main containers (modals) use a soft, dark-blue ambient drop shadow (0px 10px 30px) to lift them off the background.
4.  **Pressed State:** When active, components should shift down by the exact pixel height of their depth border, simulating a button being pushed into the surface.

## Shapes

The shape language is strictly **Pill-shaped and Rounded**. 

- **Outer Radii:** All main buttons and input fields use a full pill radius (999px or matching half their height).
- **Container Radii:** Modals and cards use a `rounded-xl` (1.5rem / 24px) or higher setting to maintain the friendly, soft aesthetic.
- **Icons:** Icons are always encased in circular or rounded-square containers with a thick white stroke to make them feel like "collectible tokens."

## Components

### Buttons
Buttons are the core of this design system. They must feature a linear gradient (light to dark), a thick 6px-8px bottom "depth" border, and a subtle white inner-glow at the top edge. Labels should be uppercase with a hard drop shadow.

### Ribbons & Headers
Section headers (like "Shop" or "Settings") use a "Ribbon" style. These are horizontal banners that slightly overlap the edges of the main container, featuring "folded" darker corners to create a 3D layered effect.

### Progress Bars
Bars should have a recessed background (inner shadow) and a high-gloss, striped or gradient fill. The progress fill should look "liquified" or "beaded."

### Toggle Switches
Toggles are oversized and "juicy." The track uses a deep inset shadow, while the thumb is a high-gloss sphere that changes color based on the On/Off state.

### Cards & Lists
List items inside containers should use alternating light/dark pastel backgrounds or a 2px colored border. Every list item should have a slight "bounce" hover effect.