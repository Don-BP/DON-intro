import PlinkoFrame from '@/components/plinko/PlinkoFrame'

interface Props {
  params: { teamId: string }
}

export default function PlinkoPage({ params }: Props) {
  return (
    <div className="h-full w-full overflow-hidden">
      <PlinkoFrame teamId={params.teamId} />
    </div>
  )
}
