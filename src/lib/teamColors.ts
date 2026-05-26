export interface TeamColorDef {
  hex: string
  gradient: string
  shadow: string
  buttonGrad: string
  buttonShadow: string
  ballHex: number
  ballSpec: number
}

export const TEAM_COLORS: Record<string, TeamColorDef> = {
  '#3a6a00': {
    hex: '#3a6a00',
    gradient: 'linear-gradient(160deg, #7ed321 0%, #3a6a00 100%)',
    shadow: '#2e5600',
    buttonGrad: 'linear-gradient(180deg,#64DD17,#33691E)',
    buttonShadow: '#1B5E20',
    ballHex: 0x81c784,
    ballSpec: 0xe8f5e9,
  },
  '#0060ac': {
    hex: '#0060ac',
    gradient: 'linear-gradient(160deg, #42A5F5 0%, #0060ac 100%)',
    shadow: '#004d8a',
    buttonGrad: 'linear-gradient(180deg,#42A5F5,#0060ac)',
    buttonShadow: '#004d8a',
    ballHex: 0x64b5f6,
    ballSpec: 0xe3f2fd,
  },
  '#a000bf': {
    hex: '#a000bf',
    gradient: 'linear-gradient(160deg, #CE93D8 0%, #a000bf 100%)',
    shadow: '#7b0092',
    buttonGrad: 'linear-gradient(180deg,#CE93D8,#a000bf)',
    buttonShadow: '#7b0092',
    ballHex: 0xce93d8,
    ballSpec: 0xf3e5f5,
  },
  '#b71c1c': {
    hex: '#b71c1c',
    gradient: 'linear-gradient(160deg, #EF5350 0%, #b71c1c 100%)',
    shadow: '#7f0000',
    buttonGrad: 'linear-gradient(180deg,#EF5350,#b71c1c)',
    buttonShadow: '#7f0000',
    ballHex: 0xef9a9a,
    ballSpec: 0xffebee,
  },
  '#e65100': {
    hex: '#e65100',
    gradient: 'linear-gradient(160deg, #FFA726 0%, #e65100 100%)',
    shadow: '#bf360c',
    buttonGrad: 'linear-gradient(180deg,#FFA726,#e65100)',
    buttonShadow: '#bf360c',
    ballHex: 0xffb74d,
    ballSpec: 0xfff3e0,
  },
  '#00695c': {
    hex: '#00695c',
    gradient: 'linear-gradient(160deg, #4DB6AC 0%, #00695c 100%)',
    shadow: '#004d40',
    buttonGrad: 'linear-gradient(180deg,#4DB6AC,#00695c)',
    buttonShadow: '#004d40',
    ballHex: 0x80cbc4,
    ballSpec: 0xe0f2f1,
  },
  '#4527a0': {
    hex: '#4527a0',
    gradient: 'linear-gradient(160deg, #7E57C2 0%, #4527a0 100%)',
    shadow: '#311b92',
    buttonGrad: 'linear-gradient(180deg,#7E57C2,#4527a0)',
    buttonShadow: '#311b92',
    ballHex: 0xb39ddb,
    ballSpec: 0xede7f6,
  },
  '#1565c0': {
    hex: '#1565c0',
    gradient: 'linear-gradient(160deg, #5C9CE6 0%, #1565c0 100%)',
    shadow: '#0d47a1',
    buttonGrad: 'linear-gradient(180deg,#5C9CE6,#1565c0)',
    buttonShadow: '#0d47a1',
    ballHex: 0x90caf9,
    ballSpec: 0xe3f2fd,
  },
}

export function getTeamColor(hex: string): TeamColorDef {
  return TEAM_COLORS[hex] ?? TEAM_COLORS['#3a6a00']
}
