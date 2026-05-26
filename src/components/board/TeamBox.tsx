'use client'
import { useRef, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Team } from '@/store/gameStore'
import { getTeamColor } from '@/lib/teamColors'
import { useBallPhysics } from '@/hooks/useBallPhysics'
import { playClick, playBallDrop } from '@/lib/sounds'

interface Props {
  team: Team
}

// Persists each team's rendered ball count across navigation (survives component unmount).
const lastRenderedCounts = new Map<string, number>()

export default function TeamBox({ team }: Props) {
  const router = useRouter()
  const containerRef = useRef<HTMLDivElement>(null)
  const colorDef = getTeamColor(team.color)

  // How many balls were visible the last time this team box unmounted (0 = first visit).
  const prevRendered = lastRenderedCounts.get(team.id) ?? 0
  const prevBallCount = useRef(prevRendered)

  // Always reflects the latest ballCount so the unmount cleanup captures it correctly.
  const countRef = useRef(team.ballCount)
  countRef.current = team.ballCount

  const { canvasRef, dropBalls, placeBalls } = useBallPhysics(containerRef, {
    ballHex: colorDef.ballHex,
    ballSpec: colorDef.ballSpec,
  })

  // On mount: restore already-seen balls at rest; drop only newly won ones from the top.
  useEffect(() => {
    const existing = prevRendered
    const newBalls = team.ballCount - prevRendered
    if (existing > 0) placeBalls(existing)
    if (newBalls > 0) {
      dropBalls(newBalls)
      playBallDrop()
    }
    // Sync prevBallCount so the drop effect below sees diff = 0 on this same mount.
    prevBallCount.current = team.ballCount
  // placeBalls/dropBalls are stable callbacks; this intentionally runs once on mount.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [placeBalls])

  // Drop balls added while this component is already mounted.
  useEffect(() => {
    const diff = team.ballCount - prevBallCount.current
    if (diff > 0) {
      dropBalls(diff)
      playBallDrop()
    }
    prevBallCount.current = team.ballCount
  }, [team.ballCount, dropBalls])

  // Save the rendered count so the next mount knows what's already been shown.
  useEffect(() => {
    return () => {
      lastRenderedCounts.set(team.id, countRef.current)
    }
  }, [team.id])

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

      {/* Physics canvas */}
      <canvas
        ref={canvasRef}
        className="absolute inset-0 w-full h-full pointer-events-none"
        style={{ zIndex: 1 }}
      />

      {/* Team content */}
      <div className="relative z-10 flex flex-col items-center justify-between h-full p-4
                      text-white" style={{ textShadow: '0 2px 6px rgba(0,0,0,0.5)' }}>

        {/* Top row: name left, score right */}
        <div className="flex items-start justify-between w-full">
          <div className="font-extrabold uppercase tracking-widest text-sm opacity-90">
            {team.name}
          </div>
          <div className="font-black text-7xl leading-none drop-shadow-[0_4px_8px_rgba(0,0,0,0.4)]">
            {team.score}
          </div>
        </div>

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
