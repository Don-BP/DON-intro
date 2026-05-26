'use client'
import { useEffect, useRef, useState } from 'react'
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
  const [wonPoints, setWonPoints] = useState<{ slot: number; bonus: number; total: number } | null>(null)

  useEffect(() => {
    function onMessage(e: MessageEvent) {
      if (e.data?.type !== 'plinko-score') return
      const slot = Number(e.data.slotPoints ?? e.data.points) || 0
      const bonus = Number(e.data.bonusPoints) || 0
      const total = Number(e.data.total) || slot
      if (total > 0 && !hasScored.current) {
        hasScored.current = true
        addScore(teamId, total)
        addBalls(teamId, total)
        playScoreReveal()
        setWonPoints({ slot, bonus, total })
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
      <iframe
        src="/plinko.html"
        className="absolute inset-0 w-full h-full border-none"
        title="Plinko Game"
        allow="autoplay"
      />

      {/* Team name overlay */}
      <div className="absolute top-4 right-4 z-10 flex items-center gap-2
                      bg-black/50 backdrop-blur-sm rounded-xl px-4 py-2 pointer-events-none">
        <div className="w-3 h-3 rounded-full" style={{ background: team.color }} />
        <span className="font-extrabold text-white uppercase tracking-wide text-sm">
          {team.name}
        </span>
      </div>

      {/* Points won banner */}
      {wonPoints !== null && (
        <div className="absolute inset-x-0 top-1/2 -translate-y-1/2 z-10 flex flex-col items-center gap-2 pointer-events-none">
          <div className="text-white/70 font-extrabold uppercase tracking-widest text-lg"
               style={{ textShadow: '0 2px 8px rgba(0,0,0,0.8)' }}>
            You scored
          </div>
          <div className="font-black text-white leading-none"
               style={{
                 fontSize: 'clamp(80px, 20vw, 200px)',
                 textShadow: '0 0 40px rgba(255,220,0,0.9), 0 4px 0 rgba(0,0,0,0.5)',
                 WebkitTextStroke: '3px rgba(0,0,0,0.3)',
               }}>
            {wonPoints.total}
          </div>
          <div className="text-white/70 font-extrabold uppercase tracking-widest text-lg"
               style={{ textShadow: '0 2px 8px rgba(0,0,0,0.8)' }}>
            {wonPoints.total === 1 ? 'point' : 'points'}
          </div>
          {wonPoints.bonus > 0 && (
            <div className="font-bold text-white/60 text-base uppercase tracking-widest"
                 style={{ textShadow: '0 2px 8px rgba(0,0,0,0.8)' }}>
              {wonPoints.slot} slot + {wonPoints.bonus} party bonus
            </div>
          )}
        </div>
      )}

      {/* Return button */}
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
