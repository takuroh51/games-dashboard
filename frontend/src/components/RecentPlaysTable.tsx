import { useState } from 'react'
import type { RecentPlay } from '@/types/dashboard'

interface RecentPlaysTableProps {
  plays: RecentPlay[]
}

export default function RecentPlaysTable({ plays }: RecentPlaysTableProps) {
  const [viewMode, setViewMode] = useState<'initial' | 'paginated'>('initial')
  const [currentPage, setCurrentPage] = useState(1)

  const INITIAL_DISPLAY = 10
  const ITEMS_PER_PAGE = 100

  // 表示するデータを計算
  const displayPlays = viewMode === 'initial'
    ? plays.slice(0, INITIAL_DISPLAY)
    : plays.slice((currentPage - 1) * ITEMS_PER_PAGE, currentPage * ITEMS_PER_PAGE)

  const totalPages = Math.ceil(plays.length / ITEMS_PER_PAGE)

  const handleShowMore = () => {
    setViewMode('paginated')
    setCurrentPage(1)
  }

  const handleBackToInitial = () => {
    setViewMode('initial')
    setCurrentPage(1)
  }

  const handlePrevPage = () => {
    if (currentPage > 1) {
      setCurrentPage(currentPage - 1)
    }
  }

  const handleNextPage = () => {
    if (currentPage < totalPages) {
      setCurrentPage(currentPage + 1)
    }
  }

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
          最近のプレイ記録
        </h2>
        <span className="text-sm text-gray-500 dark:text-gray-400">
          全{plays.length}件
        </span>
      </div>

      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead className="bg-gray-50 dark:bg-gray-900">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                日時
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                キャラクター
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                難易度
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                スコア
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                ランク
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                結果
              </th>
            </tr>
          </thead>
          <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            {displayPlays.map((play, index) => (
              <tr key={index} className="hover:bg-gray-50 dark:hover:bg-gray-700">
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                  {formatTimestamp(play.timestamp)}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                  {play.character}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                  {play.difficulty}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-gray-100">
                  {play.score.toLocaleString()}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getRankColor(play.clearRank)}`}>
                    {play.clearRank}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                  {play.clearType}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* 初期表示モード: もっと見るボタン */}
      {viewMode === 'initial' && plays.length > INITIAL_DISPLAY && (
        <div className="mt-4 flex justify-center">
          <button
            onClick={handleShowMore}
            className="px-6 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium"
          >
            もっと見る（全{plays.length}件）
          </button>
        </div>
      )}

      {/* ページネーションモード */}
      {viewMode === 'paginated' && (
        <div className="mt-4 flex flex-col sm:flex-row justify-between items-center gap-4">
          {/* 最初に戻るボタン */}
          <button
            onClick={handleBackToInitial}
            className="px-4 py-2 text-sm bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
          >
            最初に戻る
          </button>

          {/* ページネーションコントロール */}
          <div className="flex items-center gap-2">
            <button
              onClick={handlePrevPage}
              disabled={currentPage === 1}
              className={`px-4 py-2 rounded ${
                currentPage === 1
                  ? 'bg-gray-100 dark:bg-gray-800 text-gray-400 dark:text-gray-600 cursor-not-allowed'
                  : 'bg-indigo-600 text-white hover:bg-indigo-700 transition-colors'
              }`}
            >
              前へ
            </button>

            <span className="px-4 py-2 text-sm text-gray-700 dark:text-gray-300">
              {currentPage} / {totalPages} ページ
            </span>

            <button
              onClick={handleNextPage}
              disabled={currentPage === totalPages}
              className={`px-4 py-2 rounded ${
                currentPage === totalPages
                  ? 'bg-gray-100 dark:bg-gray-800 text-gray-400 dark:text-gray-600 cursor-not-allowed'
                  : 'bg-indigo-600 text-white hover:bg-indigo-700 transition-colors'
              }`}
            >
              次へ
            </button>
          </div>

          <div className="text-sm text-gray-500 dark:text-gray-400">
            {(currentPage - 1) * ITEMS_PER_PAGE + 1} - {Math.min(currentPage * ITEMS_PER_PAGE, plays.length)} 件目
          </div>
        </div>
      )}
    </div>
  )
}

function formatTimestamp(timestamp: string): string {
  // YYYY-MM-DD-HH-MM-SS-MS形式をYYYY/MM/DD HH:MMに変換
  const parts = timestamp.split('-')
  if (parts.length >= 5) {
    return `${parts[0]}/${parts[1]}/${parts[2]} ${parts[3]}:${parts[4]}`
  }
  return timestamp
}

function getRankColor(rank: string): string {
  const colors: Record<string, string> = {
    'S': 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200',
    'A': 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
    'B': 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200',
    'C': 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200',
  }
  return colors[rank] || 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200'
}
