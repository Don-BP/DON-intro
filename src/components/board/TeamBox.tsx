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

export default function TeamBox({ team }: Props) {
  const router = useRouter()
  const containerRef = useRef<HTMLDivElement>(null)
  const colorDef = getTeamColor(team.color)
  const prevBallCount = useRef(team.ballCount)
  const { canvasRef, dropBalls } = useBallPhysics(containerRef, {
    ballHex: colorDef.ballHex,
    ballSpec: colorDef.ballSpec,
  })

  useEffect(() => {
    const diff = team.ballCount - prevBallCount.current
    if (diff > 0) {
      dropBalls(diff)
      playBallDrop()
    }
    prevBallCount.current = team.ballCount
  }, [team.ballCount, dropBalls])

  useEffect(() => {
    if (team.ballCount > 0) {
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

      {/* Physics canvas */}
      <canvas
        ref={canvasRef}
        className="absolute inset-0 w-full h-full pointer-events-none"
        style={{ zIndex: 1 }}
      />

      {/* Team content */}
      <div className="relative z-10 flex flex-col items-center justify-between h-full p-4
                      text-white" style={{ textShadow: '0 2px 6px rgba(0,0,0,0.5)' }}>
        <div className="font-extrabold uppercase tracking-widest text-sm opacity-90 mt-1">
          {team.name}
        </div>

        <div className="font-black text-6xl leading-none drop-shadow-[0_4px_8px_rgba(0,0,0,0.4)]">
          {team.score}
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
