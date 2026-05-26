'use client'
import { useRouter } from 'next/navigation'
import { useGameStore, TEAM_COLOR_PRESETS } from '@/store/gameStore'

export default function SettingsPage() {
  const router = useRouter()
  const { teams, teamCount, setTeamCount, updateTeam, resetScores, clearQuestions } = useGameStore()

  return (
    <div className="h-full overflow-y-auto bg-[#61B7F7] p-6">
      <div className="max-w-lg mx-auto">

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

        {/* Reset */}
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

        <button onClick={() => router.push('/')} className="btn-arcade w-full mt-2">
          ← Back to Board
        </button>
      </div>
    </div>
  )
}
