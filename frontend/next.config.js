/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  images: {
    unoptimized: true,
  },
  // GitHub Pages用: リポジトリ名をbasePathに設定
  // 例: https://username.github.io/games-dashboard/
  basePath: process.env.NODE_ENV === 'production' ? '/games-dashboard' : '',
  assetPrefix: process.env.NODE_ENV === 'production' ? '/games-dashboard' : '',
}

module.exports = nextConfig
