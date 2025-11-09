import { useEffect, useState } from 'react'
import Head from 'next/head'
import KPICards from '@/components/KPICards'
import ChartsPanel from '@/components/ChartsPanel'
import RecentPlaysTable from '@/components/RecentPlaysTable'
import LoginForm from '@/components/LoginForm'
import { isAuthenticated, logout } from '@/utils/auth'
import type { DashboardData } from '@/types/dashboard'

export default function Home() {
  const [authenticated, setAuthenticated] = useState(false)
  const [data, setData] = useState<DashboardData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    // 認証チェック
    setAuthenticated(isAuthenticated())
  }, [])

  useEffect(() => {
    if (authenticated) {
      fetchDashboardData()
    }
  }, [authenticated])

  async function fetchDashboardData() {
    try {
      setLoading(true)
      // GitHub Pagesの場合はbasePathを考慮
      const basePath = process.env.NODE_ENV === 'production' ? '/games-dashboard' : ''
      const response = await fetch(`${basePath}/data/dashboard.json`)

      if (!response.ok) {
        throw new Error('Failed to fetch dashboard data')
      }

      const jsonData: DashboardData = await response.json()
      setData(jsonData)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
      console.error('Error fetching dashboard data:', err)
    } finally {
      setLoading(false)
    }
  }

  function handleLogin() {
    setAuthenticated(true)
  }

  function handleLogout() {
    logout()
    setAuthenticated(false)
    setData(null)
  }

  // 未認証の場合はログインフォームを表示
  if (!authenticated) {
    return <LoginForm onLogin={handleLogin} />
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600 dark:text-gray-400">Loading dashboard data...</p>
        </div>
      </div>
    )
  }

  if (error || !data) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="text-center">
          <p className="text-red-500 mb-4">Error: {error || 'No data available'}</p>
          <button
            onClick={fetchDashboardData}
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            Retry
          </button>
        </div>
      </div>
    )
  }

  const lastUpdated = new Date(data.lastUpdated).toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo' })

  return (
    <>
      <Head>
        <title>SKOOTA GAMES Dashboard</title>
        <meta name="description" content="SKOOTA GAMES Intelligence Dashboard" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      <main className="min-h-screen bg-gray-50 dark:bg-gray-900 py-8 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          {/* Header */}
          <div className="mb-8">
            <div className="flex items-center justify-between mb-2">
              <h1 className="text-4xl font-bold text-gray-900 dark:text-white">
                SKOOTA GAMES Dashboard
              </h1>
              <button
                onClick={handleLogout}
                className="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
              >
                ログアウト
              </button>
            </div>
            <p className="text-gray-600 dark:text-gray-400">
              最終更新: {lastUpdated}
            </p>
            <div className="mt-4 flex flex-wrap gap-3">
              <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
                カットシーンスキップ率: {data.cutsceneSkipRate.skipRate}%
              </span>
              {data.excludedDataStats && (
                <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200">
                  除外データ: {data.excludedDataStats.excludedCount.toLocaleString()}件 ({data.excludedDataStats.excludedRate}%)
                </span>
              )}
            </div>
          </div>

          {/* KPI Cards */}
          <KPICards kpi={data.kpi} />

          {/* Charts */}
          <ChartsPanel
            dailyActiveUsers={data.dailyActiveUsers}
            characterDistribution={data.characterDistribution}
            difficultyDistribution={data.difficultyDistribution}
            clearRankDistribution={data.clearRankDistribution}
            languageDistribution={data.languageDistribution}
          />

          {/* Recent Plays Table */}
          <div className="mt-8">
            <RecentPlaysTable plays={data.recentPlays} />
          </div>
        </div>
      </main>
    </>
  )
}
