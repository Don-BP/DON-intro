---
name: animation-design
description: Advanced animation and motion design combining Three.js 3D graphics, GSAP animation, WebGL, Framer Motion, and p5.js generative art
---

# Animation & Motion Design - Enhanced Edition

Professional animation framework combining **Three.js 3D graphics**, **GSAP advanced animations**, **WebGL optimization**, **Framer Motion for React**, **p5.js generative art**, and **motion design principles**.

## When to Use

- ✅ Building **3D interactive experiences** (product viewers, data visualizations)
- ✅ Creating **advanced animations** (scroll triggers, physics-based motion)
- ✅ Implementing **microinteractions** (hover effects, loading states, transitions)
- ✅ **Generative art** and algorithmic design
- ✅ **WebGL-based visualizations** for performance-critical UIs
- ✅ **Animated presentations** and storytelling
- ✅ **Real-time data visualization** in 3D space

## Core Patterns

### 1. Three.js 3D Scene

```javascript
import * as THREE from 'three';

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });

renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Create 3D object
const geometry = new THREE.BoxGeometry();
const material = new THREE.MeshPhongMaterial({ color: 0x00ff00 });
const cube = new THREE.Mesh(geometry, material);
scene.add(cube);

// Add lighting
const light = new THREE.DirectionalLight(0xffffff, 1);
light.position.set(5, 5, 5);
scene.add(light);

// Animation loop
function animate() {
  requestAnimationFrame(animate);
  cube.rotation.x += 0.01;
  cube.rotation.y += 0.01;
  renderer.render(scene, camera);
}
animate();
```

### 2. GSAP Advanced Animations

```javascript
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

// Scroll-triggered animation
gsap.to('.element', {
  scrollTrigger: {
    trigger: '.element',
    start: 'top center',
    end: 'bottom center',
    scrub: 1 // smooth scrub
  },
  x: 500,
  rotation: 360,
  duration: 3
});

// Staggered animations
gsap.to('.item', {
  duration: 1,
  opacity: 1,
  y: 0,
  stagger: 0.1 // 100ms between each
});

// Physics-based animation
gsap.to('.ball', {
  duration: 2,
  y: 500,
  ease: 'power1.in',
  physics: {
    gravity: 500,
    elasticity: 0.8
  }
});
```

### 3. Framer Motion React

```javascript
import { motion } from 'framer-motion';

export const AnimatedButton = () => (
  <motion.button
    whileHover={{ scale: 1.1, boxShadow: '0 0 20px rgba(0,0,0,0.2)' }}
    whileTap={{ scale: 0.95 }}
    initial={{ opacity: 0, y: -20 }}
    animate={{ opacity: 1, y: 0 }}
    transition={{ duration: 0.3 }}
  >
    Click me
  </motion.button>
);

// Staggered list animation
export const AnimatedList = ({ items }) => (
  <motion.ul
    initial="hidden"
    animate="visible"
    variants={{
      hidden: { opacity: 0 },
      visible: {
        opacity: 1,
        transition: {
          staggerChildren: 0.1
        }
      }
    }}
  >
    {items.map((item) => (
      <motion.li
        key={item}
        variants={{
          hidden: { opacity: 0, x: -20 },
          visible: { opacity: 1, x: 0 }
        }}
      >
        {item}
      </motion.li>
    ))}
  </motion.ul>
);
```

### 4. p5.js Generative Art

```javascript
import p5 from 'p5';

const sketch = (p) => {
  p.setup = function() {
    p.createCanvas(800, 600);
  };

  p.draw = function() {
    p.background(220);

    // Generative pattern
    for (let i = 0; i < p.width; i += 20) {
      for (let j = 0; j < p.height; j += 20) {
        const distance = p.dist(i, j, p.mouseX, p.mouseY);
        const size = p.map(distance, 0, 200, 20, 0);
        p.fill(255 - distance, 100, 200);
        p.ellipse(i, j, size);
      }
    }
  };
};

new p5(sketch);
```

### 5. WebGL Performance Optimization

```javascript
// Use buffer geometry for large datasets
const positions = new Float32Array(particleCount * 3);
const colors = new Float32Array(particleCount * 3);

const geometry = new THREE.BufferGeometry();
geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));

// Use instancing for repeated objects
const geometry = new THREE.BoxGeometry(1, 1, 1);
const material = new THREE.MeshPhongMaterial();
const mesh = new THREE.InstancedMesh(geometry, material, 1000);

// Use LOD (Level of Detail) for complex scenes
const lod = new THREE.LOD();
const high = new THREE.Mesh(highResGeometry, material);
const low = new THREE.Mesh(lowResGeometry, material);
lod.addLevel(high, 0);
lod.addLevel(low, 100);
scene.add(lod);
```

### 6. Motion Design Principles

**Microinteractions:**
- **Feedback:** Visual response to user action
- **Transitions:** Smooth state changes (0.2-0.3s optimal)
- **Easing:** Natural curves (ease-out for enter, ease-in for exit)
- **Staggering:** Sequential animations feel coordinated
- **Scale:** Larger movements attract attention

```javascript
// Loading animation
gsap.fromTo('.spinner',
  { rotation: 0 },
  {
    rotation: 360,
    duration: 1,
    ease: 'none',
    repeat: -1
  }
);

// Hover feedback
element.addEventListener('mouseenter', () => {
  gsap.to(element, { scale: 1.05, duration: 0.2 });
});

element.addEventListener('mouseleave', () => {
  gsap.to(element, { scale: 1, duration: 0.2 });
});
```

## Tool References

- **Three.js:** https://threejs.org
- **GSAP:** https://greensock.com/gsap
- **Framer Motion:** https://www.framer.com/motion/
- **p5.js:** https://p5js.org
- **Babylon.js:** https://doc.babylonjs.com/ (alternative)

## Common Use Cases

1. **Product Configurators** → 3D models with animation
2. **Data Dashboards** → Animated charts and visualizations
3. **Landing Pages** → Scroll-triggered storytelling
4. **Loading States** → Engaging spinner animations
5. **Interactive Art** → Generative and algorithmic art

---

**Enhanced version combining Three.js, GSAP, Framer Motion, p5.js, and motion design principles.**
