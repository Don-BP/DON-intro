# Self-Introduction Game — Design Spec
**Date:** 2026-05-26

## Overview
A Next.js web app used as a fun self-introduction game for groups. Teams compete by playing a 3D plinko game to earn points, which are visualised as 3D marble balls piling up in each team's box on the main board.

## Architecture
- **Framework:** Next.js 14 (App Router)
- **Styling:** Tailwind CSS (matching style1/style2 arcade aesthetic — Plus Jakarta Sans, glossy 3D buttons, ribbon headers)
- **3D Physics (board):** Three.js r128 + Cannon.js 0.6.2 — one shared scene per board rendering balls in team bins
- **Plinko:** existing `3d_plinko_extreme.html` served from `/public`, embedded via fullscreen iframe
- **Plinko ↔ Next.js bridge:** `postMessage({ type: 'score', points: N })` fired from plinko when ball lands
- **Sound:** Howler.js — ball drop, score pop, return-to-board, question-add SFX; mute toggle + volume slider in header
- **State:** Zustand store (team names, scores, ball counts, team count, sound settings)
- **Persistence:** localStorage (questions list, game state, settings)

## Routes
| Route | Purpose |
|---|---|
| `/` | Main team board |
| `/plinko/[teamId]` | Plinko iframe wrapper |
| `/questions` | Question bank |
| `/settings` | Admin: team count, names, colors, reset |

## Main Board (`/`)
- Full-screen CSS grid of team boxes (2×2, 2×3, or 2×4 depending on team count)
- Each box: bold full-color square (Option A style), team name, score, ▶ Play button
- 3D ball physics scene (Three.js + Cannon.js) renders marble balls piling up inside each team's area
- Ball textures: random marble PNG from `/public/assets/balls/` (marble1–5.png)
- ❓ Question button uses `/public/assets/buttons/question_button.gif`
- ⚙️ Settings gear icon in header corner
- 🔊 Mute toggle + volume slider in header

## Plinko Screen (`/plinko/[teamId]`)
- Fullscreen `<iframe src="/plinko.html">` (copy of 3d_plinko_extreme.html into /public)
- One small edit to plinko HTML: on ball-land event fire `parent.postMessage({ type: 'score', points: N }, '*')`
- Next.js wrapper listens for postMessage, stores score in Zustand
- "Return to Board" button overlaid above iframe (fixed, top-right or bottom)
- Team name shown as overlay banner

## Questions Page (`/questions`)
- Flashcard style: numbered white cards on arcade-blue background
- Top input + "Add" button to add new questions
- Each card: number badge, question text, + / − buttons to adjust font size (stored per-card in localStorage)
- Auto-saves to localStorage on every change
- Back button returns to board

## Settings Page (`/settings`)
- Team count picker: 4 / 6 / 8
- Team name text inputs
- Team color preset picker
- "Reset Scores" button (clears scores + balls)
- "Clear Questions" button

## Sound Effects
- Howler.js manages all audio
- SFX: ball-drop, score-reveal, return-to-board chime, question-add pop
- Persistent mute + volume stored in Zustand / localStorage

## Ball Physics Detail
- After returning from plinko, N balls (where N = points scored) drop into the winning team's bin
- Each ball is a Three.js Sphere with a random marble texture from `/public/assets/balls/`
- Physics: Cannon.js gravity, restitution 0.22, friction 0.55
- Balls persist across sessions (count stored in Zustand + localStorage)
- Ball cap per team: 50 (oldest removed when exceeded to keep perf)
