'use client'
import { Team } from '@/store/gameStore'
import TeamBox from './TeamBox'

interface Props {
  teams: Team[]
  teamCount: 4 | 6 | 8
}

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
