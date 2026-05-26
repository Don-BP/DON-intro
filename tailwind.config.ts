import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#3a6a00',
        'primary-container': '#7ed321',
        'on-primary': '#ffffff',
        'on-primary-container': '#2e5600',
        secondary: '#0060ac',
        surface: '#f6fce9',
        'surface-variant': '#dfe5d2',
        'surface-container': '#ebf0dd',
        'surface-container-high': '#e5ebd8',
        'surface-container-low': '#f0f6e3',
        'on-surface': '#181d12',
        'on-surface-variant': '#414a36',
        outline: '#717a64',
        'outline-variant': '#c0cab1',
        background: '#f6fce9',
        'on-background': '#181d12',
        error: '#ba1a1a',
      },
      fontFamily: {
        sans: ['Plus Jakarta Sans', 'sans-serif'],
      },
      fontSize: {
        'display-lg': ['48px', { lineHeight: '1.1', letterSpacing: '-0.02em', fontWeight: '800' }],
        'display-md': ['36px', { lineHeight: '1.2', fontWeight: '800' }],
        'headline-lg': ['28px', { lineHeight: '1.3', fontWeight: '700' }],
        'body-lg': ['18px', { lineHeight: '1.5', fontWeight: '600' }],
        'label-bold': ['14px', { lineHeight: '1', fontWeight: '800' }],
      },
      borderRadius: {
        DEFAULT: '1rem',
        lg: '2rem',
        xl: '3rem',
        full: '9999px',
      },
      boxShadow: {
        'arcade-btn': 'inset 0 6px 8px rgba(255,255,255,0.45), 0 4px 0px #1B5E20, 0 8px 12px rgba(0,0,0,0.2)',
        'arcade-btn-active': 'inset 0 2px 4px rgba(255,255,255,0.3), 0 0px 0px #1B5E20',
        'arcade-card': '0 4px 0 #c0cab1',
        'arcade-inner': 'inset 0 -4px 0px rgba(0,0,0,0.15)',
      },
    },
  },
  plugins: [],
}
export default config
