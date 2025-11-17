import { useEffect, useState } from 'react'
import Head from 'next/head'
import KPICards from '@/components/KPICards'
import ChartsPanel from '@/components/ChartsPanel'
import RecentPlaysTable from '@/components/RecentPlaysTable'
import SongPlaysByDifficultyTable from '@/components/SongPlaysByDifficultyTable'
import LoginForm from '@/components/LoginForm'
import { isAuthenticated, logout } from '@/utils/auth'
import type { DashboardData } from '@/types/dashboard'

export default function Home() {
  const [authenticated, setAuthenticated] = useState(false)
  const [data, setData] = useState<DashboardData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [updateMessage, setUpdateMessage] = useState<string | null>(null)

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
      setUpdateMessage(null)
      // GitHub Pagesの場合はbasePathを考慮
      const basePath = process.env.NODE_ENV === 'production' ? '/games-dashboard' : ''
      // キャッシュバスティング: タイムスタンプを追加して常に最新データを取得
      const cacheBuster = `?t=${Date.now()}`
      const response = await fetch(`${basePath}/data/dashboard.json${cacheBuster}`, {
        cache: 'no-store',
        headers: {
          'Cache-Control': 'no-cache'
        }
      })

      if (!response.ok) {
        throw new Error('Failed to fetch dashboard data')
      }

      const jsonData: DashboardData = await response.json()
      const oldTime = data?.lastUpdated
      setData(jsonData)
      setError(null)

      // 更新完了メッセージを表示
      if (oldTime && oldTime !== jsonData.lastUpdated) {
        setUpdateMessage('✅ 新しいデータを取得しました')
      } else {
        setUpdateMessage('ℹ️ 最新のデータを確認しました（更新なし）')
      }
      setTimeout(() => setUpdateMessage(null), 3000)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
      console.error('Error fetching dashboard data:', err)
      setUpdateMessage('❌ データ取得に失敗しました')
      setTimeout(() => setUpdateMessage(null), 3000)
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

  // UTC時刻を日本時間（UTC+9）に変換して表示
  const utcDate = new Date(data.lastUpdated)
  const jstDate = new Date(utcDate.getTime() + 9 * 60 * 60 * 1000)
  const lastUpdated = jstDate.toLocaleString('ja-JP').replace(/\//g, '/').replace(/\s/g, ' ')

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
            <div className="flex items-center gap-3 flex-wrap">
              <p className="text-gray-600 dark:text-gray-400">
                最終更新: {lastUpdated}
              </p>
              <button
                onClick={fetchDashboardData}
                disabled={loading}
                className="px-3 py-1 text-sm font-medium text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 border border-blue-300 dark:border-blue-600 rounded-lg hover:bg-blue-50 dark:hover:bg-blue-900/30 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
              >
                {loading && (
                  <svg className="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                  </svg>
                )}
                {loading ? '更新中...' : '更新'}
              </button>
              {updateMessage && (
                <span className="text-sm font-medium text-green-600 dark:text-green-400 animate-fade-in">
                  {updateMessage}
                </span>
              )}
            </div>
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
            playerClearRateDistribution={data.playerClearRateDistribution}
            playClearRateDistribution={data.playClearRateDistribution}
            ga4DailyMetrics={data.ga4?.dailyMetrics}
            ga4LanguageDistribution={data.ga4?.languageDistribution}
            ga4GuidelineMonthlyStats={data.ga4?.guidelineMonthlyStats}
            ga4DailyMetricsPeriod={data.ga4?.dailyMetricsPeriod}
          />

          {/* Recent Plays Table */}
          <div className="mt-8">
            <RecentPlaysTable plays={data.recentPlays} />
          </div>

          {/* Song Plays by Difficulty Table */}
          <div className="mt-8">
            <SongPlaysByDifficultyTable songPlays={data.songPlaysByDifficulty} />
          </div>
        </div>
      </main>
    </>
  )
}
