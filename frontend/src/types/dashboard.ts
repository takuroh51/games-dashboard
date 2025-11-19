export interface DashboardData {
  lastUpdated: string;
  kpi: KPI;
  dailyActiveUsers: DailyActiveUser[];
  characterDistribution: Record<string, number>;
  difficultyDistribution: Record<string, number>;
  clearRankDistribution: Record<string, number>;
  languageDistribution: Record<string, number>;
  cutsceneSkipRate: CutsceneSkipRate;
  excludedDataStats?: ExcludedDataStats;
  recentPlays: RecentPlay[];
  songPlaysByDifficulty: SongPlayByDifficulty[];
  playerClearRateDistribution?: PlayerClearRateDistribution;
  playClearRateDistribution?: PlayClearRateDistribution;
  platformDistribution?: PlatformDistribution[];
  costumeDistribution?: CostumeDistribution[];
  platformCostumeCross?: PlatformCostumeCross[];
  ga4?: GA4Data;
}

export interface KPI {
  totalUsers: number;
  totalLaunches: number;
  totalPlays: number;
  averageScore: number;
}

export interface DailyActiveUser {
  date: string;
  users: number;
}

export interface CutsceneSkipRate {
  totalStart: number;
  totalSkip: number;
  skipRate: number;
}

export interface ExcludedDataStats {
  totalCount: number;
  excludedCount: number;
  excludedRate: number;
}

export interface RecentPlay {
  timestamp: string;
  character: string;
  difficulty: string;
  score: number;
  clearRank: string;
  clearType: string;
}

export interface SongPlayByDifficulty {
  songId: string;
  easy: number;
  normal: number;
  hard: number;
  total: number;
}

export interface PlayerClearRateDistribution {
  distribution: Record<string, number>;
  stats: {
    mean: number;
    median: number;
    totalPlayers: number;
  };
}

export interface PlayClearRateDistribution {
  distribution: Record<string, number>;
  stats: {
    mean: number;
    median: number;
    totalPlays: number;
  };
}

export interface GA4Data {
  overallMetrics: GA4OverallMetrics;
  dailyMetrics: GA4DailyMetric[];
  languageDistribution: GA4LanguageDistribution[];
  guidelineMonthlyStats: GA4GuidelineMonthlyStats[];
  dailyMetricsPeriod?: number;
}

export interface GA4OverallMetrics {
  totalPageViews: number;
  totalUsers: number;
  todayPageViews: number;
}

export interface GA4DailyMetric {
  date: string;
  pageViews: number;
  activeUsers: number;
}

export interface GA4LanguageDistribution {
  language: string;
  pageViews: number;
  activeUsers: number;
}

export interface GA4GuidelineMonthlyStats {
  month: string;
  ja?: number;
  en?: number;
  ko?: number;
  'zh-hans'?: number;
  'zh-hant'?: number;
  fr?: number;
  es?: number;
  pt?: number;
  ru?: number;
}

export interface PlatformDistribution {
  platform: string;
  plays: number;
  users: number;
}

export interface CostumeDistribution {
  costume: string;
  plays: number;
}

export interface PlatformCostumeCross {
  platform: string;
  total: number;
  [costume: string]: number | string;
}
