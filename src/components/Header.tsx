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
      <Link href="/" className="font-extrabold text-primary drop-shadow-[0_2px_0_rgba(0,0,0,0.15)]
                                 text-xl leading-none">
        🎮 INTRO GAME
      </Link>

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
