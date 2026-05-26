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
