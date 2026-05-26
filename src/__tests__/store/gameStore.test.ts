import { useGameStore } from '@/store/gameStore'

beforeEach(() => {
  useGameStore.setState(useGameStore.getInitialState())
})

describe('team management', () => {
  it('initialises with 4 teams', () => {
    const { teams } = useGameStore.getState()
    expect(teams).toHaveLength(4)
  })

  it('setTeamCount(6) rebuilds teams array to 6 entries', () => {
    useGameStore.getState().setTeamCount(6)
    expect(useGameStore.getState().teams).toHaveLength(6)
  })

  it('setTeamCount(8) rebuilds teams array to 8 entries', () => {
    useGameStore.getState().setTeamCount(8)
    expect(useGameStore.getState().teams).toHaveLength(8)
  })

  it('updateTeam changes name and preserves score', () => {
    const id = useGameStore.getState().teams[0].id
    useGameStore.getState().addScore(id, 5)
    useGameStore.getState().updateTeam(id, { name: 'Dragons' })
    const team = useGameStore.getState().teams.find(t => t.id === id)!
    expect(team.name).toBe('Dragons')
    expect(team.score).toBe(5)
  })
})

describe('scoring', () => {
  it('addScore increments team score', () => {
    const id = useGameStore.getState().teams[1].id
    useGameStore.getState().addScore(id, 10)
    useGameStore.getState().addScore(id, 5)
    const team = useGameStore.getState().teams.find(t => t.id === id)!
    expect(team.score).toBe(15)
  })

  it('addBalls increments ballCount and clamps at 50', () => {
    const id = useGameStore.getState().teams[0].id
    useGameStore.getState().addBalls(id, 60)
    const team = useGameStore.getState().teams.find(t => t.id === id)!
    expect(team.ballCount).toBe(50)
  })

  it('resetScores zeros score and ballCount on all teams', () => {
    const teams = useGameStore.getState().teams
    teams.forEach(t => {
      useGameStore.getState().addScore(t.id, 20)
      useGameStore.getState().addBalls(t.id, 5)
    })
    useGameStore.getState().resetScores()
    useGameStore.getState().teams.forEach(t => {
      expect(t.score).toBe(0)
      expect(t.ballCount).toBe(0)
    })
  })
})

describe('questions', () => {
  it('addQuestion appends to list', () => {
    useGameStore.getState().addQuestion('What is your name?')
    expect(useGameStore.getState().questions).toHaveLength(1)
    expect(useGameStore.getState().questions[0].text).toBe('What is your name?')
  })

  it('removeQuestion removes by id', () => {
    useGameStore.getState().addQuestion('Q1')
    useGameStore.getState().addQuestion('Q2')
    const id = useGameStore.getState().questions[0].id
    useGameStore.getState().removeQuestion(id)
    expect(useGameStore.getState().questions).toHaveLength(1)
    expect(useGameStore.getState().questions[0].text).toBe('Q2')
  })

  it('updateQuestionSize clamps between 12 and 48', () => {
    useGameStore.getState().addQuestion('Q')
    const id = useGameStore.getState().questions[0].id
    useGameStore.getState().updateQuestionSize(id, 100)
    expect(useGameStore.getState().questions[0].fontSize).toBe(48)
    useGameStore.getState().updateQuestionSize(id, -200)
    expect(useGameStore.getState().questions[0].fontSize).toBe(12)
  })
})
