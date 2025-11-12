'use client'

import { Chart as ChartJS, ArcElement, CategoryScale, LinearScale, PointElement, LineElement, BarElement, Title, Tooltip, Legend } from 'chart.js'
import ChartDataLabels from 'chartjs-plugin-datalabels'
import { Line, Pie, Bar } from 'react-chartjs-2'
import type { DailyActiveUser, PlayerClearRateDistribution, PlayClearRateDistribution } from '@/types/dashboard'

ChartJS.register(ArcElement, CategoryScale, LinearScale, PointElement, LineElement, BarElement, Title, Tooltip, Legend, ChartDataLabels)

interface ChartsPanelProps {
  dailyActiveUsers: DailyActiveUser[]
  characterDistribution: Record<string, number>
  difficultyDistribution: Record<string, number>
  clearRankDistribution: Record<string, number>
  languageDistribution: Record<string, number>
  playerClearRateDistribution?: PlayerClearRateDistribution
  playClearRateDistribution?: PlayClearRateDistribution
}

export default function ChartsPanel({
  dailyActiveUsers,
  characterDistribution,
  difficultyDistribution,
  clearRankDistribution,
  languageDistribution,
  playerClearRateDistribution,
  playClearRateDistribution
}: ChartsPanelProps) {
  // 日別アクティブユーザー数（折れ線グラフ）
  const dailyActiveUsersData = {
    labels: dailyActiveUsers.map(d => d.date),
    datasets: [
      {
        label: 'アクティブユーザー数',
        data: dailyActiveUsers.map(d => d.users),
        borderColor: 'rgb(59, 130, 246)',
        backgroundColor: 'rgba(59, 130, 246, 0.5)',
        tension: 0.3
      }
    ]
  }

  // キャラクター別プレイ回数（円グラフ）
  const characterData = {
    labels: Object.keys(characterDistribution),
    datasets: [
      {
        label: 'プレイ回数',
        data: Object.values(characterDistribution),
        backgroundColor: [
          'rgba(255, 99, 132, 0.8)',
          'rgba(54, 162, 235, 0.8)',
          'rgba(255, 206, 86, 0.8)',
          'rgba(75, 192, 192, 0.8)',
          'rgba(153, 102, 255, 0.8)',
        ]
      }
    ]
  }

  // 難易度別プレイ回数（棒グラフ）
  const difficultyData = {
    labels: Object.keys(difficultyDistribution),
    datasets: [
      {
        label: 'プレイ回数',
        data: Object.values(difficultyDistribution),
        backgroundColor: 'rgba(147, 51, 234, 0.8)'
      }
    ]
  }

  // クリアランク分布（棒グラフ）
  const clearRankData = {
    labels: Object.keys(clearRankDistribution),
    datasets: [
      {
        label: 'クリア回数',
        data: Object.values(clearRankDistribution),
        backgroundColor: 'rgba(34, 197, 94, 0.8)'
      }
    ]
  }

  // 言語分布（円グラフ）
  const languageData = {
    labels: Object.keys(languageDistribution),
    datasets: [
      {
        label: 'ユーザー数',
        data: Object.values(languageDistribution),
        backgroundColor: [
          'rgba(239, 68, 68, 0.8)',
          'rgba(59, 130, 246, 0.8)',
          'rgba(16, 185, 129, 0.8)',
          'rgba(245, 158, 11, 0.8)',
        ]
      }
    ]
  }

  // プレイヤークリアレート分布（横棒グラフ）
  const clearRateDistData = playerClearRateDistribution ? {
    labels: Object.keys(playerClearRateDistribution.distribution),
    datasets: [
      {
        label: 'プレイヤー数',
        data: Object.values(playerClearRateDistribution.distribution),
        backgroundColor: 'rgba(99, 102, 241, 0.8)', // Indigo
        borderColor: 'rgba(99, 102, 241, 1)',
        borderWidth: 1
      }
    ]
  } : null

  // プレイ別クリアレート分布（横棒グラフ）
  const playClearRateDistData = playClearRateDistribution ? {
    labels: Object.keys(playClearRateDistribution.distribution),
    datasets: [
      {
        label: 'プレイ回数',
        data: Object.values(playClearRateDistribution.distribution),
        backgroundColor: 'rgba(236, 72, 153, 0.8)', // Pink
        borderColor: 'rgba(236, 72, 153, 1)',
        borderWidth: 1
      }
    ]
  } : null

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: true,
    plugins: {
      legend: {
        position: 'top' as const,
      },
      datalabels: {
        display: false // デフォルトではラベルを非表示
      }
    }
  }

  return (
    <div className="space-y-8">
      {/* 日別アクティブユーザー数 */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700">
        <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
          日別アクティブユーザー数
        </h2>
        <div className="h-80">
          <Line data={dailyActiveUsersData} options={{ ...chartOptions, maintainAspectRatio: false }} />
        </div>
      </div>

      {/* 2列グリッド */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* キャラクター別プレイ回数 */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700">
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            キャラクター別プレイ回数
          </h2>
          <div className="h-80 flex items-center justify-center">
            <Pie data={characterData} options={chartOptions} />
          </div>
        </div>

        {/* 言語分布 */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700">
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            言語分布
          </h2>
          <div className="h-80 flex items-center justify-center">
            <Pie data={languageData} options={chartOptions} />
          </div>
        </div>

        {/* 難易度別プレイ回数 */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700">
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            難易度別プレイ回数
          </h2>
          <div className="h-80">
            <Bar data={difficultyData} options={{ ...chartOptions, maintainAspectRatio: false }} />
          </div>
        </div>

        {/* クリアランク分布 */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700">
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            クリアランク分布
          </h2>
          <div className="h-80">
            <Bar data={clearRankData} options={{ ...chartOptions, maintainAspectRatio: false }} />
          </div>
        </div>

        {/* プレイヤークリアレート分布 */}
        {clearRateDistData && playerClearRateDistribution && (
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                プレイヤークリアレート分布（clearType）
              </h2>
              <div className="text-sm text-gray-600 dark:text-gray-400">
                平均: {playerClearRateDistribution.stats.mean}% | 中央値: {playerClearRateDistribution.stats.median}%
              </div>
            </div>
            <div className="text-xs text-gray-500 dark:text-gray-400 mb-2">
              プレイヤーごとの成功率（Clear/FullCombo/Perfectを成功とカウント）
            </div>
            <div className="h-80">
              <Bar
                data={clearRateDistData}
                options={{
                  ...chartOptions,
                  maintainAspectRatio: false,
                  indexAxis: 'y' // 横棒グラフ
                }}
              />
            </div>
          </div>
        )}

        {/* プレイ別クリアレート分布 */}
        {playClearRateDistData && playClearRateDistribution && (
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                プレイ別クリアレート分布（clearRate）
              </h2>
              <div className="text-sm text-gray-600 dark:text-gray-400">
                平均: {playClearRateDistribution.stats.mean}% | 中央値: {playClearRateDistribution.stats.median}%
              </div>
            </div>
            <div className="text-xs text-gray-500 dark:text-gray-400 mb-2">
              各プレイでの楽曲達成率（0-100%）
            </div>
            <div className="h-80">
              <Bar
                data={playClearRateDistData}
                options={{
                  ...chartOptions,
                  maintainAspectRatio: false,
                  indexAxis: 'y', // 横棒グラフ
                  plugins: {
                    ...chartOptions.plugins,
                    datalabels: {
                      display: true,
                      anchor: 'end',
                      align: (context: any) => {
                        // 大きい値（10%以上）は内側、小さい値は外側に表示
                        const value = context.dataset.data[context.dataIndex] as number
                        const total = playClearRateDistribution.stats.totalPlays
                        const percentage = (value / total) * 100
                        return percentage > 10 ? 'start' : 'end'
                      },
                      formatter: (value: number) => {
                        const total = playClearRateDistribution.stats.totalPlays
                        const percentage = ((value / total) * 100).toFixed(1)
                        return `${value.toLocaleString()}回 (${percentage}%)`
                      },
                      color: (context: any) => {
                        // 内側表示の場合は白、外側は濃いグレー
                        const value = context.dataset.data[context.dataIndex] as number
                        const total = playClearRateDistribution.stats.totalPlays
                        const percentage = (value / total) * 100
                        return percentage > 10 ? '#ffffff' : '#374151'
                      },
                      font: {
                        size: 11,
                        weight: 'bold'
                      }
                    }
                  }
                }}
              />
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
