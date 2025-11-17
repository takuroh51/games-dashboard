import type { KPI } from '@/types/dashboard'

interface KPICardsProps {
  kpi: KPI
}

export default function KPICards({ kpi }: KPICardsProps) {
  const cards = [
    {
      title: '総ユーザー数',
      value: kpi.totalUsers.toLocaleString(),
      icon: '👥',
      color: 'bg-blue-500'
    },
    {
      title: '総起動回数',
      value: kpi.totalLaunches.toLocaleString(),
      icon: '🚀',
      color: 'bg-green-500'
    },
    {
      title: '総プレイ回数',
      value: kpi.totalPlays.toLocaleString(),
      icon: '🎮',
      color: 'bg-purple-500'
    },
    {
      title: '平均スコア',
      value: kpi.averageScore.toLocaleString(),
      icon: '⭐',
      color: 'bg-yellow-500'
    }
  ]

  return (
    <div>
      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {cards.map((card, index) => (
          <div
            key={index}
            className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700"
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-500 dark:text-gray-400 mb-1">
                  {card.title}
                </p>
                <p className="text-3xl font-bold text-gray-900 dark:text-white">
                  {card.value}
                </p>
              </div>
              <div className={`${card.color} w-12 h-12 rounded-full flex items-center justify-center text-2xl`}>
                {card.icon}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
