'use client'
import { useState, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { useGameStore } from '@/store/gameStore'
import QuestionCard from '@/components/questions/QuestionCard'
import { playQuestionAdd, playClick } from '@/lib/sounds'

export default function QuestionsPage() {
  const router = useRouter()
  const [input, setInput] = useState('')
  const [twoCol, setTwoCol] = useState(false)
  const inputRef = useRef<HTMLInputElement>(null)
  const { questions, addQuestion } = useGameStore()

  const handleAdd = () => {
    const text = input.trim()
    if (!text) return
    addQuestion(text)
    playQuestionAdd()
    setInput('')
    inputRef.current?.focus()
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') handleAdd()
  }

  return (
    <div className="h-full overflow-y-auto bg-[#61B7F7] p-4">

      <div className="ribbon-arcade mb-4 text-headline-lg w-full">❓ Question Bank</div>

      {/* Full-width input bar */}
      <div className="flex gap-3 mb-4">
        <button
          onClick={() => setTwoCol(c => !c)}
          className={`px-4 py-3 rounded-2xl font-extrabold text-sm uppercase tracking-wide border-2 transition-all
                      ${twoCol
                        ? 'bg-primary text-on-primary border-primary'
                        : 'bg-white text-on-surface-variant border-outline-variant hover:bg-surface-container'}`}
          title="Toggle 2-column layout"
        >
          ⊞ {twoCol ? '2 Col' : '1 Col'}
        </button>
        <input
          ref={inputRef}
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Type a question and press Enter or Add…"
          className="flex-1 px-4 py-3 rounded-2xl border-2 border-outline-variant bg-white
                     font-bold text-on-surface text-body-lg placeholder:text-outline
                     focus:outline-none focus:border-primary shadow-arcade-inner"
        />
        <button
          onClick={handleAdd}
          disabled={!input.trim()}
          className="btn-arcade px-6 disabled:opacity-40"
        >
          + Add
        </button>
      </div>

      {questions.length === 0 ? (
        <div className="text-center py-16 text-white/60 font-bold text-body-lg">
          No questions yet. Add one above!
        </div>
      ) : (
        <div className={twoCol ? 'grid grid-cols-2 gap-3' : 'flex flex-col gap-3'}>
          {questions.map((q, i) => (
            <QuestionCard key={q.id} question={q} index={i} />
          ))}
        </div>
      )}

      <div className="mt-6">
        <button onClick={() => { playClick(); router.push('/') }} className="btn-arcade w-full">
          ← Back to Board
        </button>
      </div>
    </div>
  )
}
