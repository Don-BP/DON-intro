import type { Metadata } from 'next'
import './globals.css'
import Header from '@/components/Header'

export const metadata: Metadata = {
  title: 'Intro Game',
  description: 'Self-introduction team game',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-background">
        <Header />
        <main className="pt-14" style={{ height: 'calc(100vh - 56px)' }}>
          {children}
        </main>
      </body>
    </html>
  )
}
