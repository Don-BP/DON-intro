'use client'
import { useRef, useCallback } from 'react'

export function useBallPhysics(
  _containerRef: React.RefObject<HTMLDivElement>,
  _opts: { ballHex: number; ballSpec: number }
) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const dropBalls = useCallback((_count: number) => {}, [])
  return { canvasRef, dropBalls }
}
