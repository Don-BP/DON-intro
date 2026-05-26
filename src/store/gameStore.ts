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
