'use strict';

// YouTube Data API v3 — no SDK needed, just fetch
const YOUTUBE_API_BASE = 'https://www.googleapis.com/youtube/v3';

// In-memory cache: key → { data, expiresAt }
const _cache = new Map();
const CACHE_TTL_MS = 6 * 60 * 60 * 1000; // 6 hours

// Body area → Turkish search query mapping
const AREA_QUERIES = {
  neck:           'boyun ağrısı egzersizleri fizyoterapi',
  left_shoulder:  'omuz ağrısı egzersizleri fizyoterapi',
  right_shoulder: 'omuz ağrısı egzersizleri fizyoterapi',
  upper_back:     'üst sırt ağrısı egzersizleri fizyoterapi',
  lower_back:     'bel ağrısı egzersizleri fizyoterapi',
  hip:            'kalça ağrısı egzersizleri fizyoterapi',
  left_knee:      'diz ağrısı egzersizleri fizyoterapi',
  right_knee:     'diz ağrısı egzersizleri fizyoterapi',
  left_elbow:     'dirsek ağrısı egzersizleri fizyoterapi',
  right_elbow:    'dirsek ağrısı egzersizleri fizyoterapi',
  left_wrist:     'bilek ağrısı egzersizleri fizyoterapi',
  right_wrist:    'bilek ağrısı egzersizleri fizyoterapi',
  left_ankle:     'ayak bileği egzersizleri fizyoterapi',
  right_ankle:    'ayak bileği egzersizleri fizyoterapi',
  core:           'karın core egzersizleri fizyoterapi',
};

/**
 * Search YouTube for physiotherapy exercise videos.
 * Returns max 6 results, cached for 6 hours.
 *
 * @param {string} bodyArea   - e.g. 'right_shoulder'
 * @param {string} [query]    - optional custom search query
 * @returns {Promise<Array>}  - array of video objects
 */
async function searchVideos(bodyArea, query) {
  const searchQuery = query ?? AREA_QUERIES[bodyArea] ?? `${bodyArea} egzersiz fizyoterapi`;
  const cacheKey = searchQuery;

  // Return cached result if fresh
  const cached = _cache.get(cacheKey);
  if (cached && Date.now() < cached.expiresAt) {
    return cached.data;
  }

  const params = new URLSearchParams({
    part: 'snippet',
    q: searchQuery,
    type: 'video',
    videoCategoryId: '17', // Sports
    maxResults: '6',
    relevanceLanguage: 'tr',
    regionCode: 'TR',
    safeSearch: 'strict',
    key: process.env.YOUTUBE_API_KEY,
  });

  const searchUrl = `${YOUTUBE_API_BASE}/search?${params}`;
  const searchRes = await fetch(searchUrl);
  if (!searchRes.ok) {
    const err = await searchRes.text();
    throw new Error(`YouTube search failed: ${searchRes.status} ${err}`);
  }
  const searchData = await searchRes.json();

  if (!searchData.items?.length) return [];

  // Fetch video durations in a second call (contentDetails)
  const videoIds = searchData.items.map((i) => i.id.videoId).join(',');
  const detailParams = new URLSearchParams({
    part: 'contentDetails,statistics',
    id: videoIds,
    key: process.env.YOUTUBE_API_KEY,
  });
  const detailRes = await fetch(`${YOUTUBE_API_BASE}/videos?${detailParams}`);
  const detailData = detailRes.ok ? await detailRes.json() : { items: [] };

  const detailMap = {};
  for (const item of detailData.items ?? []) {
    detailMap[item.id] = {
      duration: _parseDuration(item.contentDetails?.duration),
      viewCount: item.statistics?.viewCount ?? '0',
    };
  }

  const videos = searchData.items.map((item) => {
    const vid = item.id.videoId;
    const snippet = item.snippet;
    const detail = detailMap[vid] ?? {};
    return {
      videoId: vid,
      title: snippet.title,
      channelTitle: snippet.channelTitle,
      thumbnailUrl: snippet.thumbnails?.medium?.url ??
                    snippet.thumbnails?.default?.url ?? '',
      duration: detail.duration ?? '--:--',
      viewCount: detail.viewCount ?? '0',
      publishedAt: snippet.publishedAt,
    };
  });

  _cache.set(cacheKey, { data: videos, expiresAt: Date.now() + CACHE_TTL_MS });
  return videos;
}

/** Convert ISO 8601 duration (PT4M13S) to MM:SS */
function _parseDuration(iso) {
  if (!iso) return '--:--';
  const match = iso.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/);
  if (!match) return '--:--';
  const h = parseInt(match[1] ?? '0');
  const m = parseInt(match[2] ?? '0');
  const s = parseInt(match[3] ?? '0');
  if (h > 0) return `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  return `${m}:${String(s).padStart(2, '0')}`;
}

/**
 * Search YouTube for multiple exercise names (from AI output).
 * Returns up to 2 videos per exercise, total max 6.
 *
 * @param {string[]} exerciseNames - e.g. ['Sarkaç egzersizleri', 'Sleeper stretch']
 * @returns {Promise<Array>}
 */
async function searchVideosByExercises(exerciseNames) {
  const names = exerciseNames.slice(0, 4); // max 4 exercises to stay within quota
  const results = [];

  for (const name of names) {
    const query = `${name} fizyoterapi türkçe nasıl yapılır`;
    const cacheKey = `ex:${query}`;

    const cached = _cache.get(cacheKey);
    if (cached && Date.now() < cached.expiresAt) {
      results.push(...cached.data.slice(0, 2));
      continue;
    }

    try {
      const params = new URLSearchParams({
        part: 'snippet',
        q: query,
        type: 'video',
        maxResults: '2',
        relevanceLanguage: 'tr',
        regionCode: 'TR',
        safeSearch: 'strict',
        key: process.env.YOUTUBE_API_KEY,
      });

      const searchRes = await fetch(`${YOUTUBE_API_BASE}/search?${params}`);
      if (!searchRes.ok) continue;
      const searchData = await searchRes.json();
      if (!searchData.items?.length) continue;

      const videoIds = searchData.items.map((i) => i.id.videoId).join(',');
      const detailParams = new URLSearchParams({
        part: 'contentDetails,statistics',
        id: videoIds,
        key: process.env.YOUTUBE_API_KEY,
      });
      const detailRes = await fetch(`${YOUTUBE_API_BASE}/videos?${detailParams}`);
      const detailData = detailRes.ok ? await detailRes.json() : { items: [] };

      const detailMap = {};
      for (const item of detailData.items ?? []) {
        detailMap[item.id] = {
          duration: _parseDuration(item.contentDetails?.duration),
          viewCount: item.statistics?.viewCount ?? '0',
        };
      }

      const videos = searchData.items.map((item) => {
        const vid = item.id.videoId;
        const snippet = item.snippet;
        const detail = detailMap[vid] ?? {};
        return {
          videoId: vid,
          title: snippet.title,
          channelTitle: snippet.channelTitle,
          thumbnailUrl: snippet.thumbnails?.medium?.url ?? snippet.thumbnails?.default?.url ?? '',
          duration: detail.duration ?? '--:--',
          viewCount: detail.viewCount ?? '0',
          publishedAt: snippet.publishedAt,
          exerciseName: name,
        };
      });

      _cache.set(cacheKey, { data: videos, expiresAt: Date.now() + CACHE_TTL_MS });
      results.push(...videos.slice(0, 2));

      if (results.length >= 6) break;
    } catch (_) {
      // skip failed exercise search, continue with next
    }
  }

  return results.slice(0, 6);
}

module.exports = { searchVideos, searchVideosByExercises };
