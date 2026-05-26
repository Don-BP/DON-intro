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
      <body className="h-screen overflow-hidden bg-background">
        <Header />
        <main className="pt-14 h-full">
          {children}
        </main>
      </body>
    </html>
  )
}
