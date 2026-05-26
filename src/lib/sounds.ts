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
