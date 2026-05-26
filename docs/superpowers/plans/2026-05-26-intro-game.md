# Self-Introduction Game Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Next.js 14 web app for a group self-introduction game with a team board, per-team 3D ball physics, plinko game integration via iframe+postMessage, a question bank, and synthesised sound effects.

**Architecture:** Next.js 14 App Router; Zustand persisted store for all game state; per–team-box Three.js + cannon-es scene rendered on a transparent `<canvas>` layered behind the team's UI; existing `3d_plinko_extreme.html` copied to `/public/plinko.html` with a one-line postMessage patch; Web Audio API for synthesised SFX (no audio files needed).

**Tech Stack:** Next.js 14, TypeScript, Tailwind CSS, Zustand + zustand/middleware persist, Three.js (npm), cannon-es, Web Audio API, Plus Jakarta Sans (Google Fonts)

---

## File Map

```
d:/Don_intro/
├── public/
│   ├── assets/balls/          ← existing marble PNGs (marble1–5.png)
│   ├── assets/buttons/        ← existing question_button.gif
│   └── plinko.html            ← Task 9: copy + patch of 3d_plinko_extreme.html
├── src/
│   ├── app/
│   │   ├── layout.tsx         ← Task 4: root layout, fonts, Header
│   │   ├── page.tsx           ← Task 6: main board page
│   │   ├── globals.css        ← Task 3: arcade CSS utilities
│   │   ├── plinko/[teamId]/
│   │   │   └── page.tsx       ← Task 10: plinko route
│   │   ├── questions/
│   │   │   └── page.tsx       ← Task 12: questions route
│   │   └── settings/
│   │       └── page.tsx       ← Task 5: settings route
│   ├── components/
│   │   ├── Header.tsx         ← Task 4: nav + sound controls
│   │   ├── board/
│   │   │   ├── TeamGrid.tsx   ← Task 6: responsive grid wrapper
│   │   │   └── TeamBox.tsx    ← Task 7: single team tile + canvas mount
│   │   ├── plinko/
│   │   │   └── PlinkoFrame.tsx ← Task 10: iframe + overlay
│   │   └── questions/
│   │       └── QuestionCard.tsx ← Task 12: individual flashcard
│   ├── hooks/
│   │   └── useBallPhysics.ts  ← Task 8: Three.js + cannon-es per-box scene
│   ├── lib/
│   │   ├── sounds.ts          ← Task 13: Web Audio API SFX
│   │   └── teamColors.ts      ← Task 3: color presets
│   └── store/
│       └── gameStore.ts       ← Task 2: Zustand store
├── src/__tests__/
│   └── store/gameStore.test.ts ← Task 2: store unit tests
├── jest.config.ts             ← Task 2
├── jest.setup.ts              ← Task 2
├── next.config.mjs            ← Task 1
├── tailwind.config.ts         ← Task 3
└── tsconfig.json              ← Task 1
```

---

### Task 1: Scaffold Next.js Project + Install Dependencies

**Files:**
- Create: `package.json`, `next.config.mjs`, `tsconfig.json`, `postcss.config.js`

- [ ] **Step 1: Run create-next-app inside the project directory**

```bash
cd d:/Don_intro
npx create-next-app@14 . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-git --yes
```

When prompted (if any), accept: TypeScript ✓, ESLint ✓, Tailwind ✓, `src/` dir ✓, App Router ✓, `@/*` alias ✓.

- [ ] **Step 2: Install additional dependencies**

```bash
npm install zustand three cannon-es howler
npm install -D @types/three @types/howler jest jest-environment-jsdom @testing-library/react @testing-library/jest-dom ts-jest
```

- [ ] **Step 3: Create `jest.config.ts`**

```typescript
// jest.config.ts
import type { Config } from 'jest'

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  setupFilesAfterFramework: ['<rootDir>/jest.setup.ts'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  testMatch: ['**/__tests__/**/*.test.ts?(x)'],
}

export default config
```

- [ ] **Step 4: Create `jest.setup.ts`**

```typescript
// jest.setup.ts
import '@testing-library/jest-dom'
```

- [ ] **Step 5: Add test script to `package.json`**

Open `package.json`, add to `"scripts"`:
```json
"test": "jest",
"test:watch": "jest --watch"
```

- [ ] **Step 6: Update `next.config.mjs` to allow canvas**

```js
// next.config.mjs
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Three.js needs to be transpiled for Next.js
  transpilePackages: [],
}
export default nextConfig
```

- [ ] **Step 7: Verify dev server starts**

```bash
npm run dev
```

Expected: server at `http://localhost:3000` with default Next.js page.

- [ ] **Step 8: Commit**

```bash
git init
git add package.json next.config.mjs tsconfig.json jest.config.ts jest.setup.ts
git commit -m "feat: scaffold Next.js 14 project with deps"
```

---

### Task 2: Zustand Game Store + Tests

**Files:**
- Create: `src/store/gameStore.ts`
- Create: `src/__tests__/store/gameStore.test.ts`

- [ ] **Step 1: Write failing tests first**

```typescript
// src/__tests__/store/gameStore.test.ts
import { useGameStore } from '@/store/gameStore'

// Reset store between tests
beforeEach(() => {
  useGameStore.setState(useGameStore.getInitialState())
})

describe('team management', () => {
  it('initialises with 4 teams', () => {
    const { teams } = useGameStore.getState()
    expect(teams).toHaveLength(4)
  })

  it('setTeamCount(6) rebuilds teams array to 6 entries', () => {
    useGameStore.getState().setTeamCount(6)
    expect(useGameStore.getState().teams).toHaveLength(6)
  })

  it('setTeamCount(8) rebuilds teams array to 8 entries', () => {
    useGameStore.getState().setTeamCount(8)
    expect(useGameStore.getState().teams).toHaveLength(8)
  })

  it('updateTeam changes name and preserves score', () => {
    const id = useGameStore.getState().teams[0].id
    useGameStore.getState().addScore(id, 5)
    useGameStore.getState().updateTeam(id, { name: 'Dragons' })
    const team = useGameStore.getState().teams.find(t => t.id === id)!
    expect(team.name).toBe('Dragons')
    expect(team.score).toBe(5)
  })
})

describe('scoring', () => {
  it('addScore increments team score', () => {
    const id = useGameStore.getState().teams[1].id
    useGameStore.getState().addScore(id, 10)
    useGameStore.getState().addScore(id, 5)
    const team = useGameStore.getState().teams.find(t => t.id === id)!
    expect(team.score).toBe(15)
  })

  it('addBalls increments ballCount and clamps at 50', () => {
    const id = useGameStore.getState().teams[0].id
    useGameStore.getState().addBalls(id, 60)
    const team = useGameStore.getState().teams.find(t => t.id === id)!
    expect(team.ballCount).toBe(50)
  })

  it('resetScores zeros score and ballCount on all teams', () => {
    const teams = useGameStore.getState().teams
    teams.forEach(t => {
      useGameStore.getState().addScore(t.id, 20)
      useGameStore.getState().addBalls(t.id, 5)
    })
    useGameStore.getState().resetScores()
    useGameStore.getState().teams.forEach(t => {
      expect(t.score).toBe(0)
      expect(t.ballCount).toBe(0)
    })
  })
})

describe('questions', () => {
  it('addQuestion appends to list', () => {
    useGameStore.getState().addQuestion('What is your name?')
    expect(useGameStore.getState().questions).toHaveLength(1)
    expect(useGameStore.getState().questions[0].text).toBe('What is your name?')
  })

  it('removeQuestion removes by id', () => {
    useGameStore.getState().addQuestion('Q1')
    useGameStore.getState().addQuestion('Q2')
    const id = useGameStore.getState().questions[0].id
    useGameStore.getState().removeQuestion(id)
    expect(useGameStore.getState().questions).toHaveLength(1)
    expect(useGameStore.getState().questions[0].text).toBe('Q2')
  })

  it('updateQuestionSize clamps between 12 and 48', () => {
    useGameStore.getState().addQuestion('Q')
    const id = useGameStore.getState().questions[0].id
    useGameStore.getState().updateQuestionSize(id, 100)
    expect(useGameStore.getState().questions[0].fontSize).toBe(48)
    useGameStore.getState().updateQuestionSize(id, -200)
    expect(useGameStore.getState().questions[0].fontSize).toBe(12)
  })
})
```

- [ ] **Step 2: Run tests — verify they all fail**

```bash
npm test -- --testPathPattern=gameStore
```

Expected: multiple failures like "Cannot find module '@/store/gameStore'".

- [ ] **Step 3: Create the store**

```typescript
// src/store/gameStore.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type TeamColor =
  | '#3a6a00' | '#0060ac' | '#a000bf' | '#b71c1c'
  | '#e65100' | '#00695c' | '#4527a0' | '#1565c0'

export const TEAM_COLOR_PRESETS: TeamColor[] = [
  '#3a6a00', '#0060ac', '#a000bf', '#b71c1c',
  '#e65100', '#00695c', '#4527a0', '#1565c0',
]

export interface Team {
  id: string
  name: string
  color: TeamColor
  score: number
  ballCount: number
}

export interface Question {
  id: string
  text: string
  fontSize: number
}

interface SoundSettings {
  muted: boolean
  volume: number
}

interface GameState {
  teams: Team[]
  teamCount: 4 | 6 | 8
  questions: Question[]
  sound: SoundSettings
  // actions
  setTeamCount: (count: 4 | 6 | 8) => void
  updateTeam: (id: string, updates: Partial<Pick<Team, 'name' | 'color'>>) => void
  addScore: (teamId: string, points: number) => void
  addBalls: (teamId: string, count: number) => void
  resetScores: () => void
  addQuestion: (text: string) => void
  removeQuestion: (id: string) => void
  updateQuestionSize: (id: string, delta: number) => void
  clearQuestions: () => void
  setMuted: (muted: boolean) => void
  setVolume: (volume: number) => void
}

function makeTeams(count: number): Team[] {
  const names = ['Team 1', 'Team 2', 'Team 3', 'Team 4', 'Team 5', 'Team 6', 'Team 7', 'Team 8']
  return Array.from({ length: count }, (_, i) => ({
    id: `team-${i + 1}`,
    name: names[i],
    color: TEAM_COLOR_PRESETS[i % TEAM_COLOR_PRESETS.length],
    score: 0,
    ballCount: 0,
  }))
}

const INITIAL_STATE = {
  teamCount: 4 as const,
  teams: makeTeams(4),
  questions: [] as Question[],
  sound: { muted: false, volume: 0.7 },
}

export const useGameStore = create<GameState>()(
  persist(
    (set) => ({
      ...INITIAL_STATE,

      setTeamCount: (count) =>
        set((s) => ({
          teamCount: count,
          teams: makeTeams(count).map((t, i) => ({
            ...t,
            name: s.teams[i]?.name ?? t.name,
            color: s.teams[i]?.color ?? t.color,
          })),
        })),

      updateTeam: (id, updates) =>
        set((s) => ({
          teams: s.teams.map((t) => (t.id === id ? { ...t, ...updates } : t)),
        })),

      addScore: (teamId, points) =>
        set((s) => ({
          teams: s.teams.map((t) =>
            t.id === teamId ? { ...t, score: t.score + points } : t
          ),
        })),

      addBalls: (teamId, count) =>
        set((s) => ({
          teams: s.teams.map((t) =>
            t.id === teamId
              ? { ...t, ballCount: Math.min(t.ballCount + count, 50) }
              : t
          ),
        })),

      resetScores: () =>
        set((s) => ({
          teams: s.teams.map((t) => ({ ...t, score: 0, ballCount: 0 })),
        })),

      addQuestion: (text) =>
        set((s) => ({
          questions: [
            ...s.questions,
            { id: `q-${Date.now()}-${Math.random()}`, text, fontSize: 20 },
          ],
        })),

      removeQuestion: (id) =>
        set((s) => ({ questions: s.questions.filter((q) => q.id !== id) })),

      updateQuestionSize: (id, delta) =>
        set((s) => ({
          questions: s.questions.map((q) =>
            q.id === id
              ? { ...q, fontSize: Math.max(12, Math.min(48, q.fontSize + delta)) }
              : q
          ),
        })),

      clearQuestions: () => set({ questions: [] }),

      setMuted: (muted) => set((s) => ({ sound: { ...s.sound, muted } })),
      setVolume: (volume) => set((s) => ({ sound: { ...s.sound, volume } })),
    }),
    { name: 'intro-game-state' }
  )
)

// Expose initial state for test resets
;(useGameStore as any).getInitialState = () => ({ ...INITIAL_STATE })
```

- [ ] **Step 4: Run tests — verify they all pass**

```bash
npm test -- --testPathPattern=gameStore
```

Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add src/store/gameStore.ts src/__tests__/store/gameStore.test.ts jest.config.ts jest.setup.ts
git commit -m "feat: add Zustand game store with tests"
```

---

### Task 3: Tailwind Config + Arcade CSS + Team Colors

**Files:**
- Modify: `tailwind.config.ts`
- Modify: `src/app/globals.css`
- Create: `src/lib/teamColors.ts`

- [ ] **Step 1: Replace `tailwind.config.ts` with arcade token config**

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#3a6a00',
        'primary-container': '#7ed321',
        'on-primary': '#ffffff',
        'on-primary-container': '#2e5600',
        secondary: '#0060ac',
        surface: '#f6fce9',
        'surface-variant': '#dfe5d2',
        'surface-container': '#ebf0dd',
        'surface-container-high': '#e5ebd8',
        'surface-container-low': '#f0f6e3',
        'on-surface': '#181d12',
        'on-surface-variant': '#414a36',
        outline: '#717a64',
        'outline-variant': '#c0cab1',
        background: '#f6fce9',
        'on-background': '#181d12',
        error: '#ba1a1a',
      },
      fontFamily: {
        sans: ['Plus Jakarta Sans', 'sans-serif'],
      },
      fontSize: {
        'display-lg': ['48px', { lineHeight: '1.1', letterSpacing: '-0.02em', fontWeight: '800' }],
        'display-md': ['36px', { lineHeight: '1.2', fontWeight: '800' }],
        'headline-lg': ['28px', { lineHeight: '1.3', fontWeight: '700' }],
        'body-lg': ['18px', { lineHeight: '1.5', fontWeight: '600' }],
        'label-bold': ['14px', { lineHeight: '1', fontWeight: '800' }],
      },
      borderRadius: {
        DEFAULT: '1rem',
        lg: '2rem',
        xl: '3rem',
        full: '9999px',
      },
      boxShadow: {
        'arcade-btn': 'inset 0 6px 8px rgba(255,255,255,0.45), 0 4px 0px #1B5E20, 0 8px 12px rgba(0,0,0,0.2)',
        'arcade-btn-active': 'inset 0 2px 4px rgba(255,255,255,0.3), 0 0px 0px #1B5E20',
        'arcade-card': '0 4px 0 #c0cab1',
        'arcade-inner': 'inset 0 -4px 0px rgba(0,0,0,0.15)',
      },
    },
  },
  plugins: [],
}
export default config
```

- [ ] **Step 2: Replace `src/app/globals.css`**

```css
/* src/app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@600;700;800&display=swap');

@layer base {
  body {
    @apply bg-background text-on-surface font-sans;
  }
  ::-webkit-scrollbar { width: 8px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background-color: #c0cab1; border-radius: 4px; }
}

@layer components {
  /* Arcade button — primary green */
  .btn-arcade {
    @apply relative px-6 py-3 rounded-full font-sans font-extrabold text-label-bold text-on-primary uppercase tracking-wide
           bg-gradient-to-b from-[#64DD17] to-[#33691E] border-2 border-[#F1F8E9]
           transition-all duration-75 cursor-pointer select-none;
    box-shadow: inset 0 6px 8px rgba(255,255,255,0.45), 0 4px 0px #1B5E20, 0 8px 12px rgba(0,0,0,0.2);
    text-shadow: 0 2px 1px rgba(0,0,0,0.3);
  }
  .btn-arcade:active {
    transform: translateY(4px);
    box-shadow: inset 0 2px 4px rgba(255,255,255,0.3), 0 0px 0px #1B5E20;
  }

  /* Arcade card */
  .card-arcade {
    @apply bg-white rounded-2xl border-2 border-surface-variant;
    box-shadow: 0 4px 0 #c0cab1;
  }

  /* Glossy top highlight */
  .glossy-top::before {
    content: '';
    position: absolute;
    inset: 0;
    height: 40%;
    background: linear-gradient(180deg, rgba(255,255,255,0.35) 0%, transparent 100%);
    border-radius: inherit;
    pointer-events: none;
  }

  /* Arcade ribbon */
  .ribbon-arcade {
    @apply relative flex items-center justify-center h-14 rounded-xl font-extrabold text-white uppercase tracking-widest;
    background: linear-gradient(180deg, #FFB300 0%, #FF8F00 100%);
    box-shadow: inset 0 4px 10px rgba(255,255,255,0.4), 0 4px 8px rgba(0,0,0,0.1);
  }
}
```

- [ ] **Step 3: Create `src/lib/teamColors.ts`**

```typescript
// src/lib/teamColors.ts
export interface TeamColorDef {
  hex: string
  gradient: string       // CSS gradient for team box background
  shadow: string         // bottom shadow color
  buttonGrad: string     // play button gradient
  buttonShadow: string   // play button bottom shadow
  ballHex: number        // Three.js hex for ball color
  ballSpec: number       // Three.js hex for ball specular
}

export const TEAM_COLORS: Record<string, TeamColorDef> = {
  '#3a6a00': {
    hex: '#3a6a00',
    gradient: 'linear-gradient(160deg, #7ed321 0%, #3a6a00 100%)',
    shadow: '#2e5600',
    buttonGrad: 'linear-gradient(180deg,#64DD17,#33691E)',
    buttonShadow: '#1B5E20',
    ballHex: 0x81c784,
    ballSpec: 0xe8f5e9,
  },
  '#0060ac': {
    hex: '#0060ac',
    gradient: 'linear-gradient(160deg, #42A5F5 0%, #0060ac 100%)',
    shadow: '#004d8a',
    buttonGrad: 'linear-gradient(180deg,#42A5F5,#0060ac)',
    buttonShadow: '#004d8a',
    ballHex: 0x64b5f6,
    ballSpec: 0xe3f2fd,
  },
  '#a000bf': {
    hex: '#a000bf',
    gradient: 'linear-gradient(160deg, #CE93D8 0%, #a000bf 100%)',
    shadow: '#7b0092',
    buttonGrad: 'linear-gradient(180deg,#CE93D8,#a000bf)',
    buttonShadow: '#7b0092',
    ballHex: 0xce93d8,
    ballSpec: 0xf3e5f5,
  },
  '#b71c1c': {
    hex: '#b71c1c',
    gradient: 'linear-gradient(160deg, #EF5350 0%, #b71c1c 100%)',
    shadow: '#7f0000',
    buttonGrad: 'linear-gradient(180deg,#EF5350,#b71c1c)',
    buttonShadow: '#7f0000',
    ballHex: 0xef9a9a,
    ballSpec: 0xffebee,
  },
  '#e65100': {
    hex: '#e65100',
    gradient: 'linear-gradient(160deg, #FFA726 0%, #e65100 100%)',
    shadow: '#bf360c',
    buttonGrad: 'linear-gradient(180deg,#FFA726,#e65100)',
    buttonShadow: '#bf360c',
    ballHex: 0xffb74d,
    ballSpec: 0xfff3e0,
  },
  '#00695c': {
    hex: '#00695c',
    gradient: 'linear-gradient(160deg, #4DB6AC 0%, #00695c 100%)',
    shadow: '#004d40',
    buttonGrad: 'linear-gradient(180deg,#4DB6AC,#00695c)',
    buttonShadow: '#004d40',
    ballHex: 0x80cbc4,
    ballSpec: 0xe0f2f1,
  },
  '#4527a0': {
    hex: '#4527a0',
    gradient: 'linear-gradient(160deg, #7E57C2 0%, #4527a0 100%)',
    shadow: '#311b92',
    buttonGrad: 'linear-gradient(180deg,#7E57C2,#4527a0)',
    buttonShadow: '#311b92',
    ballHex: 0xb39ddb,
    ballSpec: 0xede7f6,
  },
  '#1565c0': {
    hex: '#1565c0',
    gradient: 'linear-gradient(160deg, #5C9CE6 0%, #1565c0 100%)',
    shadow: '#0d47a1',
    buttonGrad: 'linear-gradient(180deg,#5C9CE6,#1565c0)',
    buttonShadow: '#0d47a1',
    ballHex: 0x90caf9,
    ballSpec: 0xe3f2fd,
  },
}

export function getTeamColor(hex: string): TeamColorDef {
  return TEAM_COLORS[hex] ?? TEAM_COLORS['#3a6a00']
}
```

- [ ] **Step 4: Verify styles compile**

```bash
npm run dev
```

Navigate to `http://localhost:3000`. No CSS errors in console.

- [ ] **Step 5: Commit**

```bash
git add tailwind.config.ts src/app/globals.css src/lib/teamColors.ts
git commit -m "feat: configure Tailwind arcade tokens and team color presets"
```

---

### Task 4: Root Layout + Header

**Files:**
- Modify: `src/app/layout.tsx`
- Create: `src/components/Header.tsx`

- [ ] **Step 1: Create `src/components/Header.tsx`**

```tsx
// src/components/Header.tsx
'use client'
import Image from 'next/image'
import Link from 'next/link'
import { useGameStore } from '@/store/gameStore'
import { playClick } from '@/lib/sounds'

export default function Header() {
  const { sound, setMuted, setVolume } = useGameStore()

  return (
    <header className="fixed top-0 inset-x-0 z-50 flex items-center justify-between px-4 py-2
                       bg-surface border-b-2 border-surface-variant"
            style={{ boxShadow: '0 2px 8px rgba(0,0,0,0.08)' }}>
      {/* Logo / home link */}
      <Link href="/" className="font-extrabold text-display-md text-primary drop-shadow-[0_2px_0_rgba(0,0,0,0.15)]
                                 text-xl leading-none">
        🎮 INTRO GAME
      </Link>

      {/* Nav */}
      <nav className="flex items-center gap-2">
        <Link href="/questions" className="p-2 rounded-full hover:bg-surface-container transition-colors">
          <Image src="/assets/buttons/question_button.gif" alt="Questions" width={36} height={36}
                 className="rounded-full" unoptimized />
        </Link>
        <Link href="/settings"
              className="p-2 rounded-full bg-surface-variant hover:bg-surface-container transition-colors
                         text-on-surface-variant"
              title="Settings">
          <span style={{ fontSize: 22 }}>⚙️</span>
        </Link>

        {/* Volume controls */}
        <div className="flex items-center gap-2 ml-2 bg-surface-container rounded-full px-3 py-1.5">
          <button onClick={() => { setMuted(!sound.muted); playClick() }}
                  className="text-on-surface-variant hover:text-on-surface transition-colors text-lg"
                  title={sound.muted ? 'Unmute' : 'Mute'}>
            {sound.muted ? '🔇' : '🔊'}
          </button>
          <input
            type="range" min={0} max={1} step={0.05}
            value={sound.muted ? 0 : sound.volume}
            onChange={(e) => { setVolume(Number(e.target.value)); if (sound.muted) setMuted(false) }}
            className="w-20 accent-primary"
          />
        </div>
      </nav>
    </header>
  )
}
```

- [ ] **Step 2: Update `src/app/layout.tsx`**

```tsx
// src/app/layout.tsx
import type { Metadata } from 'next'
import './globals.css'
import Header from '@/components/Header'

export const metadata: Metadata = {
  title: 'Intro Game',
  description: 'Self-introduction team game',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-background">
        <Header />
        <main className="pt-14 h-screen overflow-hidden">
          {children}
        </main>
      </body>
    </html>
  )
}
```

- [ ] **Step 3: Verify header renders**

```bash
npm run dev
```

Visit `http://localhost:3000` — header shows with logo, question gif, settings icon, sound controls.

- [ ] **Step 4: Commit**

```bash
git add src/app/layout.tsx src/components/Header.tsx
git commit -m "feat: add root layout and header with sound controls"
```

---

### Task 5: Settings Page

**Files:**
- Create: `src/app/settings/page.tsx`

- [ ] **Step 1: Create settings page**

```tsx
// src/app/settings/page.tsx
'use client'
import { useRouter } from 'next/navigation'
import { useGameStore } from '@/store/gameStore'
import { TEAM_COLOR_PRESETS } from '@/store/gameStore'

export default function SettingsPage() {
  const router = useRouter()
  const { teams, teamCount, setTeamCount, updateTeam, resetScores, clearQuestions } = useGameStore()

  return (
    <div className="h-full overflow-y-auto bg-[#61B7F7] p-6">
      <div className="max-w-lg mx-auto">

        {/* Ribbon header */}
        <div className="ribbon-arcade mb-6 text-headline-lg w-full">⚙️ Settings</div>

        {/* Team Count */}
        <div className="card-arcade p-5 mb-4">
          <div className="font-extrabold text-label-bold text-on-surface-variant uppercase tracking-wide mb-3">
            Number of Teams
          </div>
          <div className="flex gap-3">
            {([4, 6, 8] as const).map((n) => (
              <button key={n} onClick={() => setTeamCount(n)}
                      className={`flex-1 py-3 rounded-xl font-extrabold text-lg transition-all
                                  ${teamCount === n
                                    ? 'bg-primary text-on-primary shadow-arcade-inner'
                                    : 'bg-surface-container text-on-surface hover:bg-surface-container-high'}`}>
                {n}
              </button>
            ))}
          </div>
        </div>

        {/* Team Names + Colors */}
        <div className="card-arcade p-5 mb-4">
          <div className="font-extrabold text-label-bold text-on-surface-variant uppercase tracking-wide mb-3">
            Team Names & Colors
          </div>
          <div className="flex flex-col gap-3">
            {teams.map((team) => (
              <div key={team.id} className="flex items-center gap-3">
                {/* Color picker */}
                <div className="flex gap-1 flex-wrap w-28">
                  {TEAM_COLOR_PRESETS.map((color) => (
                    <button key={color} onClick={() => updateTeam(team.id, { color })}
                            className="w-6 h-6 rounded-full border-2 transition-transform hover:scale-110"
                            style={{
                              background: color,
                              borderColor: team.color === color ? '#fff' : 'transparent',
                              outline: team.color === color ? `2px solid ${color}` : 'none',
                            }} />
                  ))}
                </div>
                {/* Name input */}
                <input
                  value={team.name}
                  onChange={(e) => updateTeam(team.id, { name: e.target.value })}
                  className="flex-1 px-3 py-2 rounded-xl border-2 border-outline-variant bg-surface-container-low
                             font-bold text-on-surface focus:outline-none focus:border-primary"
                  maxLength={20}
                />
              </div>
            ))}
          </div>
        </div>

        {/* Danger zone */}
        <div className="card-arcade p-5 mb-4 border-error/30">
          <div className="font-extrabold text-label-bold text-on-surface-variant uppercase tracking-wide mb-3">
            Reset
          </div>
          <div className="flex gap-3">
            <button onClick={() => { if (confirm('Reset all scores and balls?')) resetScores() }}
                    className="flex-1 py-2 rounded-xl bg-[#ffebee] text-error font-extrabold border-2 border-error/20
                               hover:bg-error hover:text-white transition-all">
              Reset Scores
            </button>
            <button onClick={() => { if (confirm('Clear all questions?')) clearQuestions() }}
                    className="flex-1 py-2 rounded-xl bg-surface-container text-on-surface-variant font-extrabold
                               border-2 border-outline-variant hover:bg-surface-container-high transition-all">
              Clear Questions
            </button>
          </div>
        </div>

        {/* Back */}
        <button onClick={() => router.push('/')} className="btn-arcade w-full mt-2">
          ← Back to Board
        </button>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: Verify settings page**

Visit `http://localhost:3000/settings`. Confirm: team count toggles, name inputs work, color dots are clickable, reset buttons show confirm dialog.

- [ ] **Step 3: Commit**

```bash
git add src/app/settings/page.tsx
git commit -m "feat: add settings page for team count, names, colors, reset"
```

---

### Task 6: Main Board Page + TeamGrid

**Files:**
- Modify: `src/app/page.tsx`
- Create: `src/components/board/TeamGrid.tsx`

- [ ] **Step 1: Create `src/components/board/TeamGrid.tsx`**

```tsx
// src/components/board/TeamGrid.tsx
'use client'
import { Team } from '@/store/gameStore'
import TeamBox from './TeamBox'

interface Props {
  teams: Team[]
  teamCount: 4 | 6 | 8
}

// Grid layouts: teamCount → [cols, rows]
const GRID_LAYOUT: Record<number, string> = {
  4: 'grid-cols-2 grid-rows-2',
  6: 'grid-cols-3 grid-rows-2',
  8: 'grid-cols-4 grid-rows-2',
}

export default function TeamGrid({ teams, teamCount }: Props) {
  return (
    <div className={`grid h-full w-full ${GRID_LAYOUT[teamCount]}`}
         style={{ gap: '3px', background: '#0d1b2a', padding: '3px' }}>
      {teams.map((team) => (
        <TeamBox key={team.id} team={team} />
      ))}
    </div>
  )
}
```

- [ ] **Step 2: Update `src/app/page.tsx`**

```tsx
// src/app/page.tsx
'use client'
import { useGameStore } from '@/store/gameStore'
import TeamGrid from '@/components/board/TeamGrid'

export default function BoardPage() {
  const { teams, teamCount } = useGameStore()

  return (
    <div className="h-full w-full overflow-hidden">
      <TeamGrid teams={teams} teamCount={teamCount} />
    </div>
  )
}
```

- [ ] **Step 3: Verify grid renders**

Visit `http://localhost:3000`. You should see a 2×2 (or configured) grid of placeholder boxes.

- [ ] **Step 4: Commit**

```bash
git add src/app/page.tsx src/components/board/TeamGrid.tsx
git commit -m "feat: add main board page with responsive team grid"
```

---

### Task 7: TeamBox Component (CSS + layout)

**Files:**
- Create: `src/components/board/TeamBox.tsx`

- [ ] **Step 1: Create `src/components/board/TeamBox.tsx`**

```tsx
// src/components/board/TeamBox.tsx
'use client'
import { useRef, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Team } from '@/store/gameStore'
import { getTeamColor } from '@/lib/teamColors'
import { useBallPhysics } from '@/hooks/useBallPhysics'
import { playClick, playBallDrop } from '@/lib/sounds'
import { useGameStore } from '@/store/gameStore'

interface Props {
  team: Team
}

export default function TeamBox({ team }: Props) {
  const router = useRouter()
  const containerRef = useRef<HTMLDivElement>(null)
  const colorDef = getTeamColor(team.color)
  const prevBallCount = useRef(team.ballCount)
  const { canvasRef, dropBalls } = useBallPhysics(containerRef, {
    ballHex: colorDef.ballHex,
    ballSpec: colorDef.ballSpec,
  })

  // Drop balls when ballCount increases
  useEffect(() => {
    const diff = team.ballCount - prevBallCount.current
    if (diff > 0) {
      dropBalls(diff)
      playBallDrop()
    }
    prevBallCount.current = team.ballCount
  }, [team.ballCount, dropBalls])

  // On mount: drop balls for existing count (page reload)
  useEffect(() => {
    if (team.ballCount > 0) {
      // Stagger so physics settles gracefully
      const perBatch = Math.min(team.ballCount, 50)
      for (let i = 0; i < perBatch; i++) {
        setTimeout(() => dropBalls(1), i * 80)
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const handlePlay = () => {
    playClick()
    router.push(`/plinko/${team.id}`)
  }

  return (
    <div
      ref={containerRef}
      className="relative overflow-hidden select-none"
      style={{ background: colorDef.gradient }}
    >
      {/* Glossy top sheen */}
      <div className="absolute inset-x-0 top-0 h-1/3 pointer-events-none"
           style={{ background: 'linear-gradient(180deg,rgba(255,255,255,0.22) 0%,transparent 100%)' }} />

      {/* Physics canvas — behind content */}
      <canvas
        ref={canvasRef}
        className="absolute inset-0 w-full h-full pointer-events-none"
        style={{ zIndex: 1 }}
      />

      {/* Team content — above canvas */}
      <div className="relative z-10 flex flex-col items-center justify-between h-full p-4
                      text-white" style={{ textShadow: '0 2px 6px rgba(0,0,0,0.5)' }}>
        {/* Team name */}
        <div className="font-extrabold uppercase tracking-widest text-sm opacity-90 mt-1">
          {team.name}
        </div>

        {/* Score */}
        <div className="font-black text-6xl leading-none drop-shadow-[0_4px_8px_rgba(0,0,0,0.4)]">
          {team.score}
        </div>

        {/* Play button */}
        <button
          onClick={handlePlay}
          className="relative px-6 py-2.5 rounded-full font-extrabold text-sm uppercase tracking-wide
                     text-white border-2 border-white/30 transition-all duration-75
                     hover:brightness-110 active:translate-y-1"
          style={{
            background: colorDef.buttonGrad,
            boxShadow: `inset 0 4px 6px rgba(255,255,255,0.35), 0 3px 0 ${colorDef.buttonShadow}`,
          }}
        >
          ▶ Play Plinko
        </button>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: Create stub for `useBallPhysics` (so the app compiles)**

```typescript
// src/hooks/useBallPhysics.ts  — STUB, replaced in Task 8
import { useRef, useCallback } from 'react'

export function useBallPhysics(
  _containerRef: React.RefObject<HTMLDivElement>,
  _opts: { ballHex: number; ballSpec: number }
) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const dropBalls = useCallback((_count: number) => {}, [])
  return { canvasRef, dropBalls }
}
```

- [ ] **Step 3: Create stub for `src/lib/sounds.ts`**

```typescript
// src/lib/sounds.ts — STUB, replaced in Task 13
export function playClick() {}
export function playBallDrop() {}
export function playScoreReveal() {}
export function playReturnToBoard() {}
export function playQuestionAdd() {}
```

- [ ] **Step 4: Verify board renders nicely**

Visit `http://localhost:3000`. Confirm: 4 colored team boxes fill the screen, each shows team name, score (0), and play button.

- [ ] **Step 5: Commit**

```bash
git add src/components/board/TeamBox.tsx src/hooks/useBallPhysics.ts src/lib/sounds.ts
git commit -m "feat: add TeamBox component with arcade styling and canvas placeholder"
```

---

### Task 8: useBallPhysics Hook (Three.js + cannon-es)

**Files:**
- Modify: `src/hooks/useBallPhysics.ts`

- [ ] **Step 1: Replace stub with full Three.js + cannon-es implementation**

```typescript
// src/hooks/useBallPhysics.ts
'use client'
import { useRef, useEffect, useCallback } from 'react'
import * as THREE from 'three'
import * as CANNON from 'cannon-es'

const MARBLE_PATHS = [
  '/assets/balls/marble1.png',
  '/assets/balls/marble2.png',
  '/assets/balls/marble3.png',
  '/assets/balls/marble4.png',
  '/assets/balls/marble5.png',
]

interface Options {
  ballHex: number
  ballSpec: number
}

export function useBallPhysics(
  containerRef: React.RefObject<HTMLDivElement>,
  options: Options
) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  // Keep stable refs to Three.js / Cannon objects across renders
  const sceneRef = useRef<{
    renderer: THREE.WebGLRenderer
    scene: THREE.Scene
    camera: THREE.PerspectiveCamera
    world: CANNON.World
    bodies: Array<{ body: CANNON.Body; mesh: THREE.Mesh }>
    animId: number
    WORLD_W: number
    FLOOR_Y: number
    ballMaterial: CANNON.Material
    textureLoader: THREE.TextureLoader
    textures: THREE.Texture[]
  } | null>(null)

  // ── Setup ──────────────────────────────────────────────────
  useEffect(() => {
    const canvas = canvasRef.current
    const container = containerRef.current
    if (!canvas || !container) return

    const W = container.clientWidth
    const H = container.clientHeight
    if (W === 0 || H === 0) return

    // Renderer — transparent so CSS gradient shows through
    const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true })
    renderer.setSize(W, H)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    renderer.shadowMap.enabled = true
    renderer.shadowMap.type = THREE.PCFSoftShadowMap
    renderer.setClearColor(0x000000, 0)

    // Scene + camera
    const scene = new THREE.Scene()
    const aspect = W / H
    const camera = new THREE.PerspectiveCamera(55, aspect, 0.1, 50)
    camera.position.set(0, 1.0, 7)
    camera.lookAt(0, -1.5, 0)

    // Lighting
    scene.add(new THREE.AmbientLight(0xffffff, 0.55))
    const sun = new THREE.DirectionalLight(0xffffff, 0.9)
    sun.position.set(3, 8, 5)
    sun.castShadow = true
    sun.shadow.mapSize.set(512, 512)
    sun.shadow.camera.left = -5
    sun.shadow.camera.right = 5
    sun.shadow.camera.top = 5
    sun.shadow.camera.bottom = -5
    sun.shadow.bias = -0.001
    scene.add(sun)
    scene.add(Object.assign(new THREE.DirectionalLight(0x8888ff, 0.3), { position: new THREE.Vector3(-4, 4, -4) }))

    // Physics world
    const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -28, 0) })
    world.broadphase = new CANNON.NaiveBroadphase()
    world.allowSleep = true

    const groundMat = new CANNON.Material('ground')
    const ballMat = new CANNON.Material('ball')
    world.addContactMaterial(new CANNON.ContactMaterial(groundMat, ballMat, { friction: 0.55, restitution: 0.22 }))
    world.addContactMaterial(new CANNON.ContactMaterial(ballMat, ballMat, { friction: 0.4, restitution: 0.18 }))

    // World dimensions — 6 units wide, proportional height
    const WORLD_W = 6
    const WORLD_H = WORLD_W / aspect
    const FLOOR_Y = -(WORLD_H / 2) - 0.2
    const WALL_T = 0.15

    function addStaticWall(x: number, y: number, z: number, hw: number, hh: number, hd: number) {
      const body = new CANNON.Body({ mass: 0, material: groundMat })
      body.addShape(new CANNON.Box(new CANNON.Vec3(hw, hh, hd)))
      body.position.set(x, y, z)
      world.addBody(body)
    }

    const halfW = WORLD_W / 2 + WALL_T
    addStaticWall(0, FLOOR_Y - WALL_T, 0, halfW, WALL_T, 2.5)           // floor
    addStaticWall(-halfW - WALL_T, 0, 0, WALL_T, WORLD_H, 2.5)          // left
    addStaticWall( halfW + WALL_T, 0, 0, WALL_T, WORLD_H, 2.5)          // right
    addStaticWall(0, 0, -2.5 - WALL_T, halfW + WALL_T * 2, WORLD_H, WALL_T) // back

    // Preload marble textures
    const textureLoader = new THREE.TextureLoader()
    const textures = MARBLE_PATHS.map(p => textureLoader.load(p))

    // Animation loop
    const bodies: Array<{ body: CANNON.Body; mesh: THREE.Mesh }> = []
    let animId = 0
    let lastTime = performance.now()

    function animate() {
      animId = requestAnimationFrame(animate)
      const now = performance.now()
      const dt = Math.min((now - lastTime) / 1000, 0.04)
      lastTime = now
      world.step(1 / 60, dt, 3)
      for (const { body, mesh } of bodies) {
        mesh.position.copy(body.position as unknown as THREE.Vector3)
        mesh.quaternion.copy(body.quaternion as unknown as THREE.Quaternion)
      }
      renderer.render(scene, camera)
    }
    animate()

    sceneRef.current = { renderer, scene, camera, world, bodies, animId, WORLD_W, FLOOR_Y, ballMaterial: ballMat, textureLoader, textures }

    // Handle resize
    const ro = new ResizeObserver(() => {
      const nW = container.clientWidth
      const nH = container.clientHeight
      renderer.setSize(nW, nH)
      camera.aspect = nW / nH
      camera.updateProjectionMatrix()
    })
    ro.observe(container)

    return () => {
      cancelAnimationFrame(animId)
      ro.disconnect()
      renderer.dispose()
      sceneRef.current = null
    }
  }, [containerRef])

  // ── Drop Balls ─────────────────────────────────────────────
  const dropBalls = useCallback((count: number) => {
    const s = sceneRef.current
    if (!s) return

    const BR = 0.28 // ball radius
    const { world, scene, bodies, WORLD_W, FLOOR_Y, ballMaterial, textures } = s

    // Enforce 50-ball cap: remove oldest
    while (bodies.length + count > 50) {
      const oldest = bodies.shift()
      if (oldest) {
        world.removeBody(oldest.body)
        scene.remove(oldest.mesh)
        oldest.mesh.geometry.dispose()
        ;(oldest.mesh.material as THREE.Material).dispose()
      }
    }

    for (let i = 0; i < count; i++) {
      setTimeout(() => {
        if (!sceneRef.current) return
        const halfW = WORLD_W / 2 - BR * 1.5
        const rx = (Math.random() * 2 - 1) * halfW
        const ry = FLOOR_Y + WORLD_W + BR + Math.random() * 0.5
        const rz = (Math.random() * 2 - 1) * 1.2

        // Physics
        const body = new CANNON.Body({
          mass: 1,
          material: ballMaterial,
          linearDamping: 0.02,
          angularDamping: 0.12,
          allowSleep: true,
          sleepSpeedLimit: 0.25,
        })
        body.addShape(new CANNON.Sphere(BR))
        body.position.set(rx, ry, rz)
        body.velocity.set((Math.random() - 0.5) * 0.5, 0, (Math.random() - 0.5) * 0.3)
        world.addBody(body)

        // Visual — marble texture
        const tex = textures[Math.floor(Math.random() * textures.length)]
        const geo = new THREE.SphereGeometry(BR, 24, 24)
        const mat = new THREE.MeshPhongMaterial({
          map: tex,
          color: options.ballHex,
          specular: options.ballSpec,
          shininess: 160,
        })
        const mesh = new THREE.Mesh(geo, mat)
        mesh.castShadow = true
        scene.add(mesh)
        bodies.push({ body, mesh })
      }, i * 120)
    }
  }, [options.ballHex, options.ballSpec])

  return { canvasRef, dropBalls }
}
```

- [ ] **Step 2: Verify balls drop**

Visit `http://localhost:3000/settings`, reset, go back to board.
Open browser console → run: `window.__testDrop?.()` (or just navigate to plinko and return later).
At this point, manually test by checking the board renders without errors.

- [ ] **Step 3: Commit**

```bash
git add src/hooks/useBallPhysics.ts
git commit -m "feat: implement Three.js + cannon-es ball physics per team box"
```

---

### Task 9: Patch Plinko HTML + Add postMessage Bridge

**Files:**
- Create: `public/plinko.html` (copy of `3d_plinko_extreme.html` with postMessage patch)

- [ ] **Step 1: Copy plinko file to public**

```bash
cp d:/Don_intro/3d_plinko_extreme.html d:/Don_intro/public/plinko.html
```

- [ ] **Step 2: Find the ball-land event in `public/plinko.html`**

Search for where the score is assigned/incremented after a ball lands. Look for code like:
```js
score += points
// or
currentScore = points
// or
function onBallLand(points) { ... }
```

- [ ] **Step 3: Add postMessage call immediately after the score is set**

Find the exact line where `score` or `points` is recorded (e.g., `score += landedPoints`), and add directly below it:

```js
// postMessage bridge — sends score to Next.js wrapper
if (window.parent !== window) {
  window.parent.postMessage({ type: 'plinko-score', points: landedPoints }, '*');
}
```

Replace `landedPoints` with whatever variable name holds the scored points in that file.

- [ ] **Step 4: Verify plinko.html is accessible**

Visit `http://localhost:3000/plinko.html` directly — the 3D plinko game should load and play exactly as before.

- [ ] **Step 5: Commit**

```bash
git add public/plinko.html
git commit -m "feat: add plinko.html to public with postMessage score bridge"
```

---

### Task 10: PlinkoFrame Component + Route

**Files:**
- Create: `src/components/plinko/PlinkoFrame.tsx`
- Create: `src/app/plinko/[teamId]/page.tsx`

- [ ] **Step 1: Create `src/components/plinko/PlinkoFrame.tsx`**

```tsx
// src/components/plinko/PlinkoFrame.tsx
'use client'
import { useEffect, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { useGameStore } from '@/store/gameStore'
import { playReturnToBoard, playScoreReveal } from '@/lib/sounds'

interface Props {
  teamId: string
}

export default function PlinkoFrame({ teamId }: Props) {
  const router = useRouter()
  const { teams, addScore, addBalls } = useGameStore()
  const team = teams.find(t => t.id === teamId)
  const hasScored = useRef(false)

  useEffect(() => {
    function onMessage(e: MessageEvent) {
      if (e.data?.type !== 'plinko-score') return
      const points = Number(e.data.points) || 0
      if (points > 0 && !hasScored.current) {
        hasScored.current = true
        addScore(teamId, points)
        addBalls(teamId, points)
        playScoreReveal()
      }
    }
    window.addEventListener('message', onMessage)
    return () => window.removeEventListener('message', onMessage)
  }, [teamId, addScore, addBalls])

  const handleReturn = () => {
    playReturnToBoard()
    router.push('/')
  }

  if (!team) {
    return <div className="flex items-center justify-center h-full text-white">Team not found</div>
  }

  return (
    <div className="relative w-full h-full">
      {/* Plinko iframe — fullscreen */}
      <iframe
        src="/plinko.html"
        className="absolute inset-0 w-full h-full border-none"
        title="Plinko Game"
        allow="autoplay"
      />

      {/* Team name overlay — top left */}
      <div className="absolute top-4 left-4 z-10 flex items-center gap-2
                      bg-black/50 backdrop-blur-sm rounded-xl px-4 py-2 pointer-events-none">
        <div className="w-3 h-3 rounded-full" style={{ background: team.color }} />
        <span className="font-extrabold text-white uppercase tracking-wide text-sm">
          {team.name}
        </span>
      </div>

      {/* Return button — bottom center */}
      <div className="absolute bottom-6 left-1/2 -translate-x-1/2 z-10">
        <button
          onClick={handleReturn}
          className="px-8 py-3 rounded-full font-extrabold text-sm uppercase tracking-wide text-white
                     transition-all hover:brightness-110 active:translate-y-1"
          style={{
            background: 'linear-gradient(180deg,#64DD17,#33691E)',
            boxShadow: 'inset 0 4px 6px rgba(255,255,255,0.35), 0 3px 0 #1B5E20, 0 6px 12px rgba(0,0,0,0.4)',
          }}
        >
          ← Return to Board
        </button>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: Create `src/app/plinko/[teamId]/page.tsx`**

```tsx
// src/app/plinko/[teamId]/page.tsx
import PlinkoFrame from '@/components/plinko/PlinkoFrame'

interface Props {
  params: { teamId: string }
}

export default function PlinkoPage({ params }: Props) {
  return (
    <div className="h-full w-full overflow-hidden">
      <PlinkoFrame teamId={params.teamId} />
    </div>
  )
}
```

- [ ] **Step 3: Test the plinko flow**

1. Visit `http://localhost:3000`
2. Click ▶ Play Plinko on any team box
3. Plinko game loads full-screen
4. Tap to drop a ball — verify the game works
5. Click ← Return to Board
6. Verify you're back at `http://localhost:3000`

- [ ] **Step 4: Commit**

```bash
git add src/components/plinko/PlinkoFrame.tsx src/app/plinko/[teamId]/page.tsx
git commit -m "feat: add plinko iframe wrapper with postMessage score listener"
```

---

### Task 11: Score → Ball Drop Integration Test

**Files:**
- Modify: `src/components/plinko/PlinkoFrame.tsx` (already complete from Task 10)

This task verifies the end-to-end score→ball-drop flow works.

- [ ] **Step 1: Simulate a score postMessage in the browser console**

1. Visit `http://localhost:3000/plinko/team-1`
2. Open DevTools console
3. Run: `window.postMessage({ type: 'plinko-score', points: 5 }, '*')`
4. Click ← Return to Board
5. Verify: Team 1's score shows 5, and 5 balls drop into Team 1's box

- [ ] **Step 2: Play through the real plinko game**

1. Click ▶ Play Plinko on Team 2
2. Tap the screen to drop a real ball
3. Note the score shown in plinko
4. Click ← Return to Board
5. Verify: Team 2's score matches what plinko showed, and that many balls drop in

- [ ] **Step 3: Commit verification notes**

```bash
git commit --allow-empty -m "test: verify score-to-ball-drop integration works end-to-end"
```

---

### Task 12: Questions Page

**Files:**
- Create: `src/components/questions/QuestionCard.tsx`
- Create: `src/app/questions/page.tsx`

- [ ] **Step 1: Create `src/components/questions/QuestionCard.tsx`**

```tsx
// src/components/questions/QuestionCard.tsx
'use client'
import { Question } from '@/store/gameStore'
import { useGameStore } from '@/store/gameStore'
import { playQuestionAdd } from '@/lib/sounds'

interface Props {
  question: Question
  index: number
}

export default function QuestionCard({ question, index }: Props) {
  const { removeQuestion, updateQuestionSize } = useGameStore()

  return (
    <div className="card-arcade flex items-start gap-3 p-4 group">
      {/* Number badge */}
      <div className="flex-shrink-0 w-8 h-8 rounded-xl bg-surface-container-low border-2 border-outline-variant
                      flex items-center justify-center font-extrabold text-sm text-on-surface-variant">
        {index + 1}
      </div>

      {/* Question text */}
      <p className="flex-1 font-bold text-on-surface leading-snug break-words"
         style={{ fontSize: question.fontSize }}>
        {question.text}
      </p>

      {/* Controls */}
      <div className="flex flex-col gap-1 flex-shrink-0">
        {/* Font size controls */}
        <div className="flex gap-1">
          <button
            onClick={() => updateQuestionSize(question.id, 2)}
            className="w-7 h-7 rounded-lg bg-surface-container border border-outline-variant
                       font-extrabold text-on-surface-variant hover:bg-primary hover:text-on-primary
                       transition-colors text-sm flex items-center justify-center"
            title="Increase size"
          >
            A+
          </button>
          <button
            onClick={() => updateQuestionSize(question.id, -2)}
            className="w-7 h-7 rounded-lg bg-surface-container border border-outline-variant
                       font-extrabold text-on-surface-variant hover:bg-surface-container-high
                       transition-colors text-xs flex items-center justify-center"
            title="Decrease size"
          >
            A−
          </button>
        </div>
        {/* Delete */}
        <button
          onClick={() => removeQuestion(question.id)}
          className="w-7 h-7 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity
                     bg-[#ffebee] text-error hover:bg-error hover:text-white text-xs
                     flex items-center justify-center"
          title="Delete"
        >
          ✕
        </button>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: Create `src/app/questions/page.tsx`**

```tsx
// src/app/questions/page.tsx
'use client'
import { useState, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { useGameStore } from '@/store/gameStore'
import QuestionCard from '@/components/questions/QuestionCard'
import { playQuestionAdd, playClick } from '@/lib/sounds'

export default function QuestionsPage() {
  const router = useRouter()
  const [input, setInput] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)
  const { questions, addQuestion } = useGameStore()

  const handleAdd = () => {
    const text = input.trim()
    if (!text) return
    addQuestion(text)
    playQuestionAdd()
    setInput('')
    inputRef.current?.focus()
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') handleAdd()
  }

  return (
    <div className="h-full overflow-y-auto bg-[#61B7F7] p-4">
      <div className="max-w-2xl mx-auto">

        {/* Ribbon header */}
        <div className="ribbon-arcade mb-5 text-headline-lg w-full">❓ Question Bank</div>

        {/* Add input */}
        <div className="flex gap-3 mb-5">
          <input
            ref={inputRef}
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Type a question and press Enter or Add…"
            className="flex-1 px-4 py-3 rounded-2xl border-2 border-outline-variant bg-white
                       font-bold text-on-surface text-body-lg placeholder:text-outline
                       focus:outline-none focus:border-primary shadow-arcade-inner"
          />
          <button
            onClick={handleAdd}
            disabled={!input.trim()}
            className="btn-arcade px-6 disabled:opacity-40"
          >
            + Add
          </button>
        </div>

        {/* Question list */}
        {questions.length === 0 ? (
          <div className="text-center py-16 text-white/60 font-bold text-body-lg">
            No questions yet. Add one above!
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {questions.map((q, i) => (
              <QuestionCard key={q.id} question={q} index={i} />
            ))}
          </div>
        )}

        {/* Back button */}
        <div className="mt-6">
          <button onClick={() => { playClick(); router.push('/') }} className="btn-arcade w-full">
            ← Back to Board
          </button>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 3: Test questions page**

1. Visit `http://localhost:3000/questions`
2. Type a question, press Enter → card appears
3. Click A+ / A− → font size changes
4. Hover card → delete ✕ appears, click it → card disappears
5. Reload page → questions persist (Zustand persist middleware)

- [ ] **Step 4: Commit**

```bash
git add src/components/questions/QuestionCard.tsx src/app/questions/page.tsx
git commit -m "feat: add questions page with flashcard list and localStorage persistence"
```

---

### Task 13: Sound System (Web Audio API)

**Files:**
- Modify: `src/lib/sounds.ts`

- [ ] **Step 1: Replace stub with Web Audio API synthesised sounds**

```typescript
// src/lib/sounds.ts
import { useGameStore } from '@/store/gameStore'

let ctx: AudioContext | null = null

function getCtx(): AudioContext {
  if (!ctx) ctx = new AudioContext()
  if (ctx.state === 'suspended') ctx.resume()
  return ctx
}

function isMuted() {
  try {
    return useGameStore.getState().sound.muted
  } catch {
    return false
  }
}

function volume() {
  try {
    return useGameStore.getState().sound.volume
  } catch {
    return 0.7
  }
}

function play(buildFn: (ctx: AudioContext, gain: GainNode) => void) {
  if (typeof window === 'undefined') return
  if (isMuted()) return
  try {
    const c = getCtx()
    const master = c.createGain()
    master.gain.value = volume()
    master.connect(c.destination)
    buildFn(c, master)
  } catch {
    // Audio not available — silently ignore
  }
}

// ── Click: short high tick ───────────────────────────────────
export function playClick() {
  play((c, g) => {
    const o = c.createOscillator()
    o.type = 'sine'
    o.frequency.setValueAtTime(880, c.currentTime)
    o.frequency.exponentialRampToValueAtTime(440, c.currentTime + 0.05)
    const eg = c.createGain()
    eg.gain.setValueAtTime(0.25, c.currentTime)
    eg.gain.exponentialRampToValueAtTime(0.001, c.currentTime + 0.08)
    o.connect(eg); eg.connect(g)
    o.start(); o.stop(c.currentTime + 0.08)
  })
}

// ── Ball drop: low thud ──────────────────────────────────────
export function playBallDrop() {
  play((c, g) => {
    const o = c.createOscillator()
    o.type = 'sine'
    o.frequency.setValueAtTime(200, c.currentTime)
    o.frequency.exponentialRampToValueAtTime(60, c.currentTime + 0.3)
    const eg = c.createGain()
    eg.gain.setValueAtTime(0.5, c.currentTime)
    eg.gain.exponentialRampToValueAtTime(0.001, c.currentTime + 0.35)
    o.connect(eg); eg.connect(g)
    o.start(); o.stop(c.currentTime + 0.35)
  })
}

// ── Score reveal: rising arpeggio ────────────────────────────
export function playScoreReveal() {
  play((c, g) => {
    const freqs = [261, 329, 392, 523, 659]
    freqs.forEach((f, i) => {
      const o = c.createOscillator()
      o.type = 'triangle'
      o.frequency.value = f
      const eg = c.createGain()
      const t = c.currentTime + i * 0.09
      eg.gain.setValueAtTime(0, t)
      eg.gain.linearRampToValueAtTime(0.35, t + 0.04)
      eg.gain.exponentialRampToValueAtTime(0.001, t + 0.25)
      o.connect(eg); eg.connect(g)
      o.start(t); o.stop(t + 0.25)
    })
  })
}

// ── Return to board: chime ───────────────────────────────────
export function playReturnToBoard() {
  play((c, g) => {
    const freqs = [659, 523, 392]
    freqs.forEach((f, i) => {
      const o = c.createOscillator()
      o.type = 'sine'
      o.frequency.value = f
      const eg = c.createGain()
      const t = c.currentTime + i * 0.12
      eg.gain.setValueAtTime(0.3, t)
      eg.gain.exponentialRampToValueAtTime(0.001, t + 0.4)
      o.connect(eg); eg.connect(g)
      o.start(t); o.stop(t + 0.4)
    })
  })
}

// ── Question add: pop ────────────────────────────────────────
export function playQuestionAdd() {
  play((c, g) => {
    const o = c.createOscillator()
    o.type = 'sine'
    o.frequency.setValueAtTime(440, c.currentTime)
    o.frequency.exponentialRampToValueAtTime(880, c.currentTime + 0.12)
    const eg = c.createGain()
    eg.gain.setValueAtTime(0.3, c.currentTime)
    eg.gain.exponentialRampToValueAtTime(0.001, c.currentTime + 0.18)
    o.connect(eg); eg.connect(g)
    o.start(); o.stop(c.currentTime + 0.18)
  })
}
```

- [ ] **Step 2: Verify sounds fire**

1. Visit `http://localhost:3000`
2. Click ▶ Play Plinko — hear a click
3. Return to board — hear a chime
4. Open questions page, add a question — hear a pop
5. Mute via header toggle — all sounds silent
6. Adjust volume slider — sounds are louder/softer

- [ ] **Step 3: Commit**

```bash
git add src/lib/sounds.ts
git commit -m "feat: add Web Audio API synthesised sound effects with mute/volume"
```

---

### Task 14: Final Polish + Wiring Check

**Files:**
- Modify: `src/app/layout.tsx` (ensure header doesn't cover board)
- Verify: all pages, transitions, persistence

- [ ] **Step 1: Fix board height to account for header**

The `<main>` wrapper in `layout.tsx` uses `pt-14 h-screen`. Confirm the board fills exactly the available height:

```tsx
// src/app/layout.tsx
<main className="pt-14" style={{ height: 'calc(100vh - 56px)' }}>
  {children}
</main>
```

- [ ] **Step 2: Add ball drop animation on board mount**

In `src/components/board/TeamBox.tsx`, the `useEffect` for mounting already handles this (Task 7 Step 1). Verify balls pour in when you navigate back to the board with existing ball counts.

- [ ] **Step 3: Verify 6-team and 8-team layouts**

1. Go to `/settings`, switch to 6 teams → board shows 3×2 grid
2. Switch to 8 teams → board shows 4×2 grid
3. Switch back to 4 → 2×2 grid

- [ ] **Step 4: Verify localStorage persistence**

1. Play plinko, score some points, return to board
2. Hard-refresh the page (`Ctrl+Shift+R`)
3. Verify: scores persist, team names persist, questions persist

- [ ] **Step 5: Run all tests**

```bash
npm test
```

Expected: all tests PASS.

- [ ] **Step 6: Build check**

```bash
npm run build
```

Expected: build succeeds with no errors.

- [ ] **Step 7: Final commit**

```bash
git add -A
git commit -m "feat: complete self-introduction game — board, plinko, questions, sounds"
```

---

## Self-Review

**Spec coverage check:**
- ✅ Team board with 4/6/8 configurable squares
- ✅ Per-team play button → plinko
- ✅ Plinko uses existing 3d_plinko_extreme.html via iframe
- ✅ postMessage score bridge
- ✅ Return to Board button
- ✅ 3D ball physics (Three.js + cannon-es) with marble textures
- ✅ Ball cap at 50 per team
- ✅ Question page: add, size control (+/−), auto-save to localStorage
- ✅ question_button.gif used as nav button
- ✅ Settings: team count (4/6/8), names, colors, reset
- ✅ Arcade aesthetic (style1/style2 tokens, Plus Jakarta Sans, ribbon headers, glossy buttons)
- ✅ Sound effects: ball drop, score reveal, return chime, question add, click
- ✅ Mute toggle + volume slider in header
- ✅ State persistence via Zustand persist (localStorage)

**Placeholder scan:** No TBD/TODO in any code block. All file paths are exact.

**Type consistency:**
- `dropBalls(count: number)` used consistently in TeamBox + useBallPhysics
- `addScore(teamId, points)` / `addBalls(teamId, count)` consistent between store and PlinkoFrame
- `team.id` (string like `team-1`) used as route param and store key throughout
