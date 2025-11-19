'use client'

import { Chart as ChartJS, ArcElement, CategoryScale, LinearScale, PointElement, LineElement, BarElement, Title, Tooltip, Legend } from 'chart.js'
import ChartDataLabels from 'chartjs-plugin-datalabels'
import { Line, Pie, Bar } from 'react-chartjs-2'
import type { DailyActiveUser, PlayerClearRateDistribution, PlayClearRateDistribution, GA4DailyMetric, GA4LanguageDistribution, GA4GuidelineMonthlyStats, PlatformDistribution, CostumeDistribution, PlatformCostumeCross } from '@/types/dashboard'

ChartJS.register(ArcElement, CategoryScale, LinearScale, PointElement, LineElement, BarElement, Title, Tooltip, Legend, ChartDataLabels)

interface ChartsPanelProps {
  dailyActiveUsers: DailyActiveUser[]
  characterDistribution: Record<string, number>
  difficultyDistribution: Record<string, number>
  clearRankDistribution: Record<string, number>
  languageDistribution: Record<string, number>
  playerClearRateDistribution?: PlayerClearRateDistribution
  playClearRateDistribution?: PlayClearRateDistribution
  platformDistribution?: PlatformDistribution[]
  costumeDistribution?: CostumeDistribution[]
  platformCostumeCross?: PlatformCostumeCross[]
  ga4DailyMetrics?: GA4DailyMetric[]
  ga4LanguageDistribution?: GA4LanguageDistribution[]
  ga4GuidelineMonthlyStats?: GA4GuidelineMonthlyStats[]
  ga4DailyMetricsPeriod?: number
}

export default function ChartsPanel({
  dailyActiveUsers,
  characterDistribution,
  difficultyDistribution,
  clearRankDistribution,
  languageDistribution,
  playerClearRateDistribution,
  playClearRateDistribution,
  platformDistribution,
  costumeDistribution,
  platformCostumeCross,
  ga4DailyMetrics,
  ga4LanguageDistribution,
  ga4GuidelineMonthlyStats,
  ga4DailyMetricsPeriod
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

  // GA4 日別アクセス推移（折れ線グラフ）
  const ga4DailyData = ga4DailyMetrics ? {
    labels: ga4DailyMetrics.map(d => d.date),
    datasets: [
      {
        label: 'ページビュー',
        data: ga4DailyMetrics.map(d => d.pageViews),
        borderColor: 'rgb(79, 70, 229)', // Indigo
        backgroundColor: 'rgba(79, 70, 229, 0.5)',
        yAxisID: 'y',
        tension: 0.3
      },
      {
        label: 'アクティブユーザー',
        data: ga4DailyMetrics.map(d => d.activeUsers),
        borderColor: 'rgb(6, 182, 212)', // Cyan
        backgroundColor: 'rgba(6, 182, 212, 0.5)',
        yAxisID: 'y',
        tension: 0.3
      }
    ]
  } : null

  // GA4 言語別アクセス分布（円グラフ - 上位9言語）
  const ga4LanguageData = ga4LanguageDistribution ? {
    labels: ga4LanguageDistribution.slice(0, 9).map(d => d.language),
    datasets: [
      {
        label: 'ページビュー',
        data: ga4LanguageDistribution.slice(0, 9).map(d => d.pageViews),
        backgroundColor: [
          'rgba(239, 68, 68, 0.8)',   // Red
          'rgba(59, 130, 246, 0.8)',   // Blue
          'rgba(16, 185, 129, 0.8)',   // Green
          'rgba(245, 158, 11, 0.8)',   // Amber
          'rgba(139, 92, 246, 0.8)',   // Violet
          'rgba(236, 72, 153, 0.8)',   // Pink
          'rgba(14, 165, 233, 0.8)',   // Sky
          'rgba(168, 85, 247, 0.8)',   // Purple
          'rgba(34, 197, 94, 0.8)',    // Green
        ]
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

      {/* ガイドラインページ月別言語別アクセス統計 */}
      {ga4GuidelineMonthlyStats && ga4GuidelineMonthlyStats.length > 0 && (
        <div className="mt-8">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
            📖 ガイドラインページ アクセス統計
          </h2>
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700">
            <h3 className="text-xl font-bold mb-4 text-gray-900 dark:text-white">
              月別言語別アクセス数
            </h3>
            <div className="overflow-x-auto">
              <table className="min-w-full text-sm text-gray-900 dark:text-white">
                <thead className="bg-gray-100 dark:bg-gray-700">
                  <tr>
                    <th className="px-4 py-2 text-left font-semibold">月</th>
                    <th className="px-4 py-2 text-right font-semibold">日本語</th>
                    <th className="px-4 py-2 text-right font-semibold">英語</th>
                    <th className="px-4 py-2 text-right font-semibold">韓国語</th>
                    <th className="px-4 py-2 text-right font-semibold">簡体中国語</th>
                    <th className="px-4 py-2 text-right font-semibold">繁体中国語</th>
                    <th className="px-4 py-2 text-right font-semibold">フランス語</th>
                    <th className="px-4 py-2 text-right font-semibold">スペイン語</th>
                    <th className="px-4 py-2 text-right font-semibold">ポルトガル語</th>
                    <th className="px-4 py-2 text-right font-semibold">ロシア語</th>
                    <th className="px-4 py-2 text-right font-semibold">合計</th>
                  </tr>
                </thead>
                <tbody>
                  {ga4GuidelineMonthlyStats.map((stat, index) => {
                    const total = (stat.ja || 0) + (stat.en || 0) + (stat.ko || 0) +
                                 (stat['zh-hans'] || 0) + (stat['zh-hant'] || 0) +
                                 (stat.fr || 0) + (stat.es || 0) + (stat.pt || 0) + (stat.ru || 0)
                    return (
                      <tr key={index} className="border-b border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-750">
                        <td className="px-4 py-2 font-medium">{stat.month}</td>
                        <td className="px-4 py-2 text-right">{stat.ja || '-'}</td>
                        <td className="px-4 py-2 text-right">{stat.en || '-'}</td>
                        <td className="px-4 py-2 text-right">{stat.ko || '-'}</td>
                        <td className="px-4 py-2 text-right">{stat['zh-hans'] || '-'}</td>
                        <td className="px-4 py-2 text-right">{stat['zh-hant'] || '-'}</td>
                        <td className="px-4 py-2 text-right">{stat.fr || '-'}</td>
                        <td className="px-4 py-2 text-right">{stat.es || '-'}</td>
                        <td className="px-4 py-2 text-right">{stat.pt || '-'}</td>
                        <td className="px-4 py-2 text-right">{stat.ru || '-'}</td>
                        <td className="px-4 py-2 text-right font-bold">{total}</td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Platform統計 */}
      {platformDistribution && platformDistribution.length > 0 && (
        <div className="mb-8">
          <h3 className="text-xl font-bold mb-4 text-gray-900 dark:text-white flex items-center">
            <span className="mr-2">💻</span> Platform別統計
          </h3>
          <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-md">
            <div className="overflow-x-auto">
              <table className="min-w-full text-sm text-gray-900 dark:text-white">
                <thead className="bg-gray-100 dark:bg-gray-700">
                  <tr>
                    <th className="px-4 py-2 text-left font-semibold">Platform</th>
                    <th className="px-4 py-2 text-right font-semibold">プレイ回数</th>
                    <th className="px-4 py-2 text-right font-semibold">ユーザー数</th>
                  </tr>
                </thead>
                <tbody>
                  {platformDistribution.map((item, index) => (
                    <tr key={index} className="border-b border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-750">
                      <td className="px-4 py-2 font-medium">{item.platform}</td>
                      <td className="px-4 py-2 text-right">{item.plays.toLocaleString()}</td>
                      <td className="px-4 py-2 text-right">{item.users.toLocaleString()}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Costume統計 */}
      {costumeDistribution && costumeDistribution.length > 0 && (
        <div className="mb-8">
          <h3 className="text-xl font-bold mb-4 text-gray-900 dark:text-white flex items-center">
            <span className="mr-2">👗</span> Costume別プレイ回数（Top 20）
          </h3>
          <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-md">
            <Bar
              data={{
                labels: costumeDistribution.map(item => item.costume),
                datasets: [
                  {
                    label: 'プレイ回数',
                    data: costumeDistribution.map(item => item.plays),
                    backgroundColor: 'rgba(236, 72, 153, 0.7)',
                    borderColor: 'rgb(236, 72, 153)',
                    borderWidth: 1
                  }
                ]
              }}
              options={{
                indexAxis: 'y' as const,
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                  legend: {
                    display: false
                  },
                  datalabels: {
                    display: false
                  }
                },
                scales: {
                  x: {
                    beginAtZero: true
                  }
                }
              }}
              height={costumeDistribution.length * 30}
            />
          </div>
        </div>
      )}

      {/* Platform × Costume クロス集計 */}
      {platformCostumeCross && platformCostumeCross.length > 0 && (
        <div className="mb-8">
          <h3 className="text-xl font-bold mb-4 text-gray-900 dark:text-white flex items-center">
            <span className="mr-2">🔀</span> Platform × Costume クロス集計
          </h3>
          <div className="bg-white dark:bg-gray-800 rounded-lg p-6 shadow-md">
            <div className="overflow-x-auto">
              <table className="min-w-full text-sm text-gray-900 dark:text-white">
                <thead className="bg-gray-100 dark:bg-gray-700">
                  <tr>
                    <th className="px-4 py-2 text-left font-semibold">Platform</th>
                    {/* 全てのコスチューム名を抽出 */}
                    {(() => {
                      const allCostumes = new Set<string>()
                      platformCostumeCross.forEach(row => {
                        Object.keys(row).forEach(key => {
                          if (key !== 'platform' && key !== 'total') {
                            allCostumes.add(key)
                          }
                        })
                      })
                      return Array.from(allCostumes).map(costume => (
                        <th key={costume} className="px-4 py-2 text-right font-semibold text-xs">
                          {costume}
                        </th>
                      ))
                    })()}
                    <th className="px-4 py-2 text-right font-semibold bg-blue-100 dark:bg-blue-900">合計</th>
                  </tr>
                </thead>
                <tbody>
                  {platformCostumeCross.map((row, index) => {
                    const allCostumes = new Set<string>()
                    platformCostumeCross.forEach(r => {
                      Object.keys(r).forEach(key => {
                        if (key !== 'platform' && key !== 'total') {
                          allCostumes.add(key)
                        }
                      })
                    })
                    return (
                      <tr key={index} className="border-b border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-750">
                        <td className="px-4 py-2 font-medium">{row.platform}</td>
                        {Array.from(allCostumes).map(costume => (
                          <td key={costume} className="px-4 py-2 text-right">
                            {(row[costume] as number) || '-'}
                          </td>
                        ))}
                        <td className="px-4 py-2 text-right font-bold bg-blue-50 dark:bg-blue-950">
                          {row.total}
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

    </div>
  )
}
