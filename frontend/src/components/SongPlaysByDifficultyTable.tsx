import type { SongPlayByDifficulty } from '@/types/dashboard'

interface SongPlaysByDifficultyTableProps {
  songPlays: SongPlayByDifficulty[]
}

export default function SongPlaysByDifficultyTable({ songPlays }: SongPlaysByDifficultyTableProps) {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 border border-gray-200 dark:border-gray-700">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
          楽曲別プレイ人数（難易度別）
        </h2>
        <span className="text-sm text-gray-600 dark:text-gray-400">
          全 {songPlays.length} 曲
        </span>
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead className="bg-gray-50 dark:bg-gray-900">
            <tr>
              <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">
                楽曲ID
              </th>
              <th className="px-6 py-4 text-right text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">
                Easy
              </th>
              <th className="px-6 py-4 text-right text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">
                Normal
              </th>
              <th className="px-6 py-4 text-right text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">
                Hard
              </th>
              <th className="px-6 py-4 text-right text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">
                合計
              </th>
            </tr>
          </thead>
          <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            {songPlays.map((song, index) => {
              // 新曲を強調表示（合計プレイ人数が20人以下）
              const isNewSong = song.total <= 20
              return (
                <tr
                  key={index}
                  className={`hover:bg-gray-50 dark:hover:bg-gray-700 ${
                    isNewSong ? 'bg-yellow-50 dark:bg-yellow-900/20' : ''
                  }`}
                >
                  <td className="px-6 py-5 whitespace-nowrap text-base font-medium text-gray-900 dark:text-gray-100">
                    {song.songId}
                    {isNewSong && <span className="ml-2 text-xs bg-yellow-200 dark:bg-yellow-800 text-yellow-800 dark:text-yellow-200 px-2 py-1 rounded">NEW</span>}
                  </td>
                  <td className="px-6 py-5 whitespace-nowrap text-base text-right text-gray-900 dark:text-gray-100">
                    {song.easy.toLocaleString()}
                  </td>
                  <td className="px-6 py-5 whitespace-nowrap text-base text-right text-gray-900 dark:text-gray-100">
                    {song.normal.toLocaleString()}
                  </td>
                  <td className="px-6 py-5 whitespace-nowrap text-base text-right text-gray-900 dark:text-gray-100">
                    {song.hard.toLocaleString()}
                  </td>
                  <td className="px-6 py-5 whitespace-nowrap text-base text-right font-semibold text-gray-900 dark:text-gray-100">
                    {song.total.toLocaleString()}
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  )
}
