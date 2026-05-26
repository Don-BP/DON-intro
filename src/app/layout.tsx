import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Intro Game',
  description: 'Self-introduction team game',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <main>
          {children}
        </main>
      </body>
    </html>
  )
}
