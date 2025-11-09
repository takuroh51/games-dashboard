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
