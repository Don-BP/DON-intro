'use client'
import { Question } from '@/store/gameStore'
import { useGameStore } from '@/store/gameStore'

interface Props {
  question: Question
  index: number
}

export default function QuestionCard({ question, index }: Props) {
  const { removeQuestion, updateQuestionSize } = useGameStore()

  return (
    <div className="card-arcade flex items-start gap-3 p-4 group">
      <div className="flex-shrink-0 w-8 h-8 rounded-xl bg-surface-container-low border-2 border-outline-variant
                      flex items-center justify-center font-extrabold text-sm text-on-surface-variant">
        {index + 1}
      </div>

      <p className="flex-1 font-bold text-on-surface leading-snug break-words"
         style={{ fontSize: question.fontSize }}>
        {question.text}
      </p>

      <div className="flex flex-col gap-1 flex-shrink-0">
        <div className="flex gap-1">
          <button
            onClick={() => updateQuestionSize(question.id, 2)}
            className="w-7 h-7 rounded-lg bg-surface-container border border-outline-variant
                       font-extrabold text-on-surface-variant hover:bg-primary hover:text-on-primary
                       transition-colors text-sm flex items-center justify-center"
            title="Increase size"
          >
            A+
          </button>
          <button
            onClick={() => updateQuestionSize(question.id, -2)}
            className="w-7 h-7 rounded-lg bg-surface-container border border-outline-variant
                       font-extrabold text-on-surface-variant hover:bg-surface-container-high
                       transition-colors text-xs flex items-center justify-center"
            title="Decrease size"
          >
            A−
          </button>
        </div>
        <button
          onClick={() => removeQuestion(question.id)}
          className="w-7 h-7 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity
                     bg-[#ffebee] text-error hover:bg-error hover:text-white text-xs
                     flex items-center justify-center"
          title="Delete"
        >
          ✕
        </button>
      </div>
    </div>
  )
}
