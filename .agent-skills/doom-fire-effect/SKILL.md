---
name: doom-fire-effect
description: A highly optimized, canvas-based "Doom Fire" effect with organic turbulent physics, random flare-ups, and height-based intensity scaling.
---

# Doom Fire Effect

This skill provides a drop-in React component for a high-quality, procedural fire effect based on the classic "Doom Fire" algorithm, but modernized with particle-like source management, height-based intensity scaling, and organic turbulence.

## When to use this skill
- When the user wants a "cool" or "intense" visual effect for a container.
- When visualizing "intensity", "heat", "activity", or "chaos" (e.g., late tasks, server load).
- When a video background is too heavy (this uses efficient Canvas API).

## Features
- **Organic Physics**: Uses random "flicker" sources instead of a constant fuel line to prevent "jet/nozzle" looks.
- **Height Scaling**: Flames automatically scale down in size and duration as they spawn higher up to prevent UI obstruction.
- **Aggressive Dissipation**: Implements a "kill zone" at the top of the container to ensure flames fade out before overflowing.
- **Performance**: Runs on a single Canvas 2D context with a low-res pixel grid scaled up via CSS, ensuring 60fps even on low-end devices.

## Implementation

To use this skill, create the component file `FireAnimation.jsx` with the following code.

**Path**: `frontend/src/components/FireAnimation.jsx` (or adapted to project structure)

```jsx
import React, { useEffect, useRef } from 'react';

const FireAnimation = ({ intensity = 0.5, className = "w-full h-full absolute inset-0" }) => {
    // Handle string intensity (backward compatibility)
    const normalizedIntensity = typeof intensity === 'string'
        ? (intensity === 'high' ? 0.8 : intensity === 'low' ? 0.3 : 0)
        : intensity;

    const canvasRef = useRef(null);
    const requestRef = useRef(null);
    const containerRef = useRef(null);

    useEffect(() => {
        const canvas = canvasRef.current;
        const container = containerRef.current;
        if (!canvas || !container) return;

        // Skip if intensity is 0
        if (normalizedIntensity <= 0) {
            const ctx = canvas.getContext('2d');
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            return;
        }

        const ctx = canvas.getContext('2d');
        const DPR = window.devicePixelRatio || 1;

        // Configuration
        const CELL_WIDTH = 6 * DPR; 
        const CELL_HEIGHT = 6 * DPR;
        const FLAME_COLOR_DEPTH = 32;
        const FLAME_COLOR_TABLE = [
            [0, 'rgba(0,0,0,0)'],
            [0.1, 'rgba(30,30,30,0.2)'], // Very feint smoke
            [0.2, 'rgba(60,60,60,0.4)'], // Smoke
            [0.3, 'rgba(120,50,50,0.6)'], // Dark embers
            [0.4, '#a52a06'], // Deep Red (Transition)
            [0.5, '#df3f08'], // Red-Orange
            [0.7, '#ef7d26'], // Orange
            [0.9, '#f7c460'], // Yellow
            [1, '#ffefba'], // White-Yellow
        ];

        let pixels = [];
        let rows = 0;
        let columns = 0;
        let colors = [];

        // Helper: Create Gradient Table
        const createGradientArray = (size, colorStops) => {
            const canvasVal = document.createElement('canvas');
            const ctxVal = canvasVal.getContext('2d');
            canvasVal.width = size;
            canvasVal.height = 1;

            const gradient = ctxVal.createLinearGradient(0, 0, size, 0);
            colorStops.forEach(args => gradient.addColorStop(...args));

            ctxVal.fillStyle = gradient;
            ctxVal.fillRect(0, 0, size, 1);

            return Array(size).fill(null).map((_, x) => {
                const data = ctxVal.getImageData(x, 0, 1, 1).data;
                // Use RGBA for transparency
                return `rgba(${data[0]}, ${data[1]}, ${data[2]}, ${data[3] / 255})`;
            });
        };

        colors = createGradientArray(FLAME_COLOR_DEPTH, FLAME_COLOR_TABLE);

        // Resize Handling
        const resize = () => {
            const { width, height } = container.getBoundingClientRect();
            canvas.width = width * DPR;
            canvas.height = height * DPR;
            canvas.style.width = '100%';
            canvas.style.height = '100%';

            rows = Math.ceil(canvas.height / CELL_HEIGHT);
            columns = Math.ceil(canvas.width / CELL_WIDTH);

            // Re-init pixels
            pixels = [];
            for (let y = 0; y < rows; y++) {
                const rowPixels = [];
                for (let x = 0; x < columns; x++) {
                    rowPixels.push({
                        idx: 0, // start cool
                        x: x * CELL_WIDTH,
                        y: y * CELL_HEIGHT
                    });
                }
                pixels.push(rowPixels);
            }
        };

        // Source Management (INCREASED FOR VOLUME)
        const MAX_SOURCES = 15; 
        let sources = [];

        const update = () => {
             // 1. Manage Sources
            sources = sources.filter(s => s.duration > 0);

            if (sources.length < MAX_SOURCES && normalizedIntensity > 0) {
                // High frequency for "sparking"
                const spawnChance = normalizedIntensity * 0.45; // Increased spawn chance
                
                if (Math.random() < spawnChance) {
                    // Random position
                    const x = Math.floor(Math.random() * (columns - 4)) + 2;
                    
                    // Spawn safely in bottom mostly, but some higher up
                    // Range: Bottom (rows-4) up to Top 20% (row 0.2*rows)
                    const y = Math.floor(rows - 4 - Math.random() * (rows * 0.8));

                    // HEIGHT SCALING logic
                    const relativeY = y / rows; // 0.0=Top, 1.0=Bottom
                    
                    // Duration: Scale by height. 
                    const durationMultiplier = Math.max(0.2, relativeY);
                    const duration = Math.floor((8 + Math.random() * 14) * durationMultiplier); 

                    sources.push({ x, y, duration });
                }
            }

            // 2. Propagate fire (Standard Doom Fire Logic)
            for (let col = 0; col < columns; col++) {
                for (let row = 1; row < rows; row++) {
                    const srcIds = pixels[row][col].idx;

                    if (srcIds === 0) {
                         if(pixels[row - 1]) pixels[row - 1][col].idx = 0;
                    } else {
                        // Random spread
                        const rand = Math.floor(Math.random() * 3); // 0 to 3 range
                        const dstCol = col - rand + 1; // spread left/right/center
                        const dstRow = row - 1; // move up

                        // DECAY TUNING
                        let decay = (rand & 1); // 0 or 1
                        
                        // Height-Based Decay Boost (Prevent top overflow)
                        const relativeHeight = row / rows; // 0=Top, 1=Bottom
                        
                        // Top 30%: Aggressive cooling
                        if (relativeHeight < 0.3) {
                            decay += 2; // Kill fire fast
                        } else if (relativeHeight < 0.5) {
                            decay += 1; // Moderate cooling
                        } else {
                            // Bottom half: Make it HOTTER (Less decay)
                            if (decay > 0 && Math.random() < 0.6) { // 60% chance to skip decay in bottom half
                                decay = 0;
                            }
                        }

                        const newIdx = srcIds - decay;

                        if (dstCol >= 0 && dstCol < columns && dstRow >= 0) {
                            pixels[dstRow][dstCol].idx = Math.max(0, newIdx);
                        }
                    }
                }
            }

            // 3. Apply Active Sources
            sources.forEach(source => {
                source.duration--;
                if (source.duration > 0) {
                    if (pixels[source.y] && pixels[source.y][source.x]) {
                        // FLICKERING SOURCE (Anti-Jet)
                        
                        // Height Scaling for Intensity
                        const relativeY = source.y / rows; // 0=Top, 1=Bottom
                        
                        // Max Heat: 
                        // Bottom -> White (31)
                        // Top -> Orange (20)
                        const maxPossibleHeat = Math.floor(colors.length - 1 - (1.0 - relativeY) * 10);
                        
                        // Flicker Noise
                        const noise = Math.floor(Math.random() * 5); 
                        let targetHeat = Math.max(10, maxPossibleHeat - noise);
                        
                        pixels[source.y][source.x].idx = targetHeat;
                        
                        // 2. Point Spread: Rapid falloff from center to avoid "blocky" look
                        if (normalizedIntensity > 0.4) {
                            const sideHeat = Math.max(0, targetHeat - 8);
                            
                            if (pixels[source.y][source.x+1]) pixels[source.y][source.x+1].idx = Math.max(pixels[source.y][source.x+1].idx, sideHeat);
                            if (pixels[source.y][source.x-1]) pixels[source.y][source.x-1].idx = Math.max(pixels[source.y][source.x-1].idx, sideHeat);
                            
                            // Bottom anchor to give it "weight"
                            if (pixels[source.y+1] && pixels[source.y+1][source.x]) pixels[source.y+1][source.x].idx = targetHeat;
                        }
                    }
                }
            });
        };

        const draw = () => {
            ctx.clearRect(0, 0, canvas.width, canvas.height); // clear for transparency

            for (let row = 0; row < rows; row++) {
                for (let col = 0; col < columns; col++) {
                    const pixel = pixels[row][col];
                    if (pixel.idx > 0) {
                        ctx.fillStyle = colors[pixel.idx];
                        ctx.fillRect(pixel.x, pixel.y, CELL_WIDTH + 1, CELL_HEIGHT + 1); // +1 to avoid gaps
                    }
                }
            }
        };

        const loop = () => {
            requestRef.current = requestAnimationFrame(loop);
            update();
            draw();
        };

        // Init
        resize();
        loop();

        // Listen for resize
        const resizeObserver = new ResizeObserver(() => {
            resize();
        });
        resizeObserver.observe(container);

        return () => {
            cancelAnimationFrame(requestRef.current);
            resizeObserver.disconnect();
        };
    }, [normalizedIntensity]);

    return (
        <div ref={containerRef} className={`${className} pointer-events-none fade-in z-0`}>
            <canvas ref={canvasRef} className="block w-full h-full opacity-90" />
        </div>
    );
};

export default FireAnimation;
```

## Usage Example

```jsx
import FireAnimation from './FireAnimation';

export default function DangerCard() {
    return (
        <div className="relative w-64 h-64 bg-gray-900 rounded-xl overflow-hidden shadow-xl border border-red-900/50">
            {/* The Fire Effect */}
            <FireAnimation intensity={0.8} />
            
            {/* Content overlay */}
            <div className="relative z-10 p-6 text-center">
                <h2 className="text-2xl font-bold text-white mb-2">CRITICAL ERROR</h2>
                <p className="text-red-200">System overheating...</p>
            </div>
        </div>
    );
}
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `intensity` | `number` \| `string` | `0.5` | Fire intensity (0.0 to 1.0). String 'high'/'low' supported. |
| `className` | `string` | `"w-full h-full absolute inset-0"` | CSS classes for the container. |
