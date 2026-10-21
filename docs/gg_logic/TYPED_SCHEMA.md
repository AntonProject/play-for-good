# Good Games v2: Data Types во FlutterFlow (проект схемы)

Статус: **внедрено 15.10.2026**. Все экраны (профиль, GoodGamesPage с
`gamesUserComp` и окном фильтров, главная `homePageScore`, `energyComp`)
работают на Data Types; JSON-ответы RPC нигде не читаются. Старые JSON-действия
`ggV2*`, JSON-функции и JSON-кэши удалены (`typed_cleanup.dart`).

Правило для привязок: поле состояния / параметра читается через
`ggRankingOrEmpty` / `ggStatsOrEmpty` / `ggGamesOrEmpty` / `ggPlayerOrEmpty`
(`typed_null_safe.dart`) — иначе FF генерирует `!` и первый кадр падает.
Награды в профиле — фиксированные картинки с видимостью по `awardFlags`,
как в строке рейтинга GG.

Цель: ответы RPC `gg_v2_*` приходят JSON, но сразу разбираются в Data Types;
состояние страниц, кэш в App State и привязки виджетов работают только с типами.
SQL и база не меняются. Схема снята с реальных ответов RPC (локальная копия,
15.10.2026).

Правила:

* Разбор JSON → тип — в одном Dart-файле (новые кастомные действия), с явным
  соответствием полей (`good_power` → `goodPower`). Больше нигде JSON не читается.
* Числа очков и денег — `Double` (на сервере `numeric`, бывают дробные); счётчики
  и места — `Integer`. Даты — `DateTime` (UTC).
* Переносятся все поля ответа, включая служебные (`test`, `requested_user_id`,
  `requested_category`, `signup_bonus_migrated`, `legacy_bonus_users_count`,
  `timezone`): схема типа описывает ответ целиком, даже если интерфейс
  поле не показывает.
* Ключ периода остаётся строкой: сезоны приходят из `gg_v2.seasons`.

## Пустые значения

Значения по умолчанию в Data Types не задаются: геттеры FF уже возвращают
`0` / `0.0` / `''` / `false` / пустой список / пустой вложенный тип (enum —
`null`). Наличие значения проверяется парным `has…()` (`hasRank()`,
`hasCurrentUser()`). Проверка нужна там, где `null` с сервера значит другое,
чем 0:

* места — `GgPlayer.rank`, `GgMetric.rank`, `allTimeRank`, `guestRank`:
  `null` = места нет (нет активности, гость) → «-», а не «0»;
* `GgRanking.currentUser`: `null` у гостя;
* `GgPeriod.seasonYear`, `start`, `endExclusive`: `null` у All-Time и месяцев;
* `photoUrl`: `''` → картинка по умолчанию;
* enums `category` / `badge`: `null` при неизвестном значении → бейдж не показывается.

Очки, суммы, количества и флажки бейджей читаются как есть (0 / false).

## Enums

| Enum | Значения | Откуда |
|---|---|---|
| `GgCategory` | `valuable`, `active`, `generous`, `social` | `category`, `awards[].category`, параметр RPC |
| `GgBadge` | `mvp_gold`, `mvp_silver`, `mvp_bronze`, `active_fire`, `map_silver`, `map_bronze` | `awards[].badge` (MAP 1-е место = `active_fire`) |
| `GgLayoutMode` | `current`, `finished` | `layout_mode`: `final` → `finished` (закрытый сезон; `final` — зарезервированное слово Dart) |

Старый enum `Period` остаётся для совместимости, в новых привязках не используется.

## Data Types

### `GgPeriod` — период

| Поле | Тип | JSON |
|---|---|---|
| `key` | String | `key` |
| `label` | String | `label` |
| `seasonYear` | Integer, nullable | `season_year` (null у не-сезонов) |
| `isCompleted` | Boolean | `is_completed` |
| `start` | DateTime, nullable | `period_start` (null у All-Time) |
| `endExclusive` | DateTime, nullable | `period_end_exclusive` |
| `timezone` | String | `timezone` (сейчас всегда `UTC`) |

### `GgAward` — награда за сезон

| Поле | Тип | JSON |
|---|---|---|
| `badge` | `GgBadge` | `badge` |
| `place` | Integer | `place` |
| `category` | `GgCategory` | `category` |
| `season` | String | `season` (ключ сезона) |
| `seasonLabel` | String | `season_label` |
| `seasonYear` | Integer | `season_year` |
| `seasonStart` | DateTime | `period_start` |

### `GgAwardFlags` — какие бейджи есть у игрока

| Поле | Тип | JSON `award_flags.` |
|---|---|---|
| `mvpGold`, `mvpSilver`, `mvpBronze` | Boolean | `mvp_gold`, `mvp_silver`, `mvp_bronze` |
| `activeFire`, `mapSilver`, `mapBronze` | Boolean | `active_fire`, `map_silver`, `map_bronze` |

### `GgPlayer` — строка рейтинга

| Поле | Тип | JSON |
|---|---|---|
| `userId` | String | `user_id` |
| `rank` | Integer, nullable | `rank` (место в выбранной категории) |
| `score` | Double | `score` (значение выбранной категории) |
| `displayName` | String | `display_name` |
| `firstName`, `surname` | String, nullable | `first_name`, `surname` |
| `photoUrl` | ImagePath, nullable | `photo_url` |
| `goodPower` | Double | `good_power` |
| `gamePower` | Double | `game_power` |
| `invitePower` | Double | `invite_power` |
| `bonusPower` | Double | `bonus_power` (+100 за регистрацию) |
| `gamesCount` | Integer | `games_count` |
| `awards` | List `GgAward` | `awards` |
| `awardFlags` | `GgAwardFlags` | `award_flags` |

### `GgRanking` — ответ `gg_v2_rankings`

| Поле | Тип | JSON |
|---|---|---|
| `requestedPeriod` | String | `requested_period` |
| `requestedCategory` | String | `requested_category` |
| `requestedUserId` | String, nullable | `requested_user_id` |
| `period` | `GgPeriod` | `period` |
| `availablePeriods` | List `GgPeriod` | `available_periods` |
| `category` | `GgCategory` | `category` |
| `layoutMode` | `GgLayoutMode` | `layout_mode` |
| `resultsFinalized` | Boolean | `results_finalized` |
| `awardsSeason` | String, nullable | `awards_season` (сезон, чьи медали показываются) |
| `test` | Boolean | `test` (среда: true — тестовые сборки) |
| `signupBonusMigrated` | Boolean | `signup_bonus_migrated` (+100 считается из журнала) |
| `legacyBonusUsersCount` | Integer | `legacy_bonus_users_count` |
| `topPlayers` | List `GgPlayer` | `top_players` |
| `players` | List `GgPlayer` | `players` (текущая страница) |
| `currentUser` | `GgPlayer`, nullable | `current_user` |
| `guestRank` | Integer, nullable | `guest_rank` |
| `guestPlaces` | `GgGuestPlaces` | `guest_places` (места гостя, профиль) |
| `page`, `pageSize`, `totalCount` | Integer | `pagination.page`, `.page_size`, `.total_count` |
| `hasMore` | Boolean | `pagination.has_more` |
| `totalGoodPower` | Double | `total_good_power` |
| `totalGoodPowerAllTime` | Double | `total_good_power_all_time` |
| `maxGoodPower` | Double | `max_good_power` |

### `GgGuestPlaces` — места гостевых 100 очков (`gg_v2_rankings.guest_places`)

| Поле | Тип | JSON |
|---|---|---|
| `goodPower` | Integer | `good_power` — место 100 очков в периоде |
| `games`, `goodPowerPerGame`, `goodEnergy`, `goodEnergyPerGame`, `sponsoredGames` | Integer | последнее место: игроков с показателем + 1 |
| `allTimeGoodPower` | Integer | `all_time_good_power` — место 100 в All-Time (шапка профиля) |

Подпись места — функция `ggPlaceLabelOf(place)`: `#12` / `#1.234`, без места `''`
(бейдж строки скрывается, «#0» не показывается).

### `GgMetric` — одна метрика профиля

| Поле | Тип | JSON |
|---|---|---|
| `value` | Double | `stats.<метрика>.value` |
| `rank` | Integer, nullable | `stats.<метрика>.rank` |

### `GgProfileStats` — ответ `gg_v2_profile_stats`

| Поле | Тип | JSON |
|---|---|---|
| `userId` | String | `user_id` |
| `displayName` | String | `display_name` |
| `photoUrl` | ImagePath, nullable | `photo_url` |
| `requestedPeriod` | String | `requested_period` |
| `period` | `GgPeriod` | `period` |
| `availablePeriods` | List `GgPeriod` | `available_periods` |
| `layoutMode` | `GgLayoutMode` | `layout_mode` |
| `resultsFinalized` | Boolean | `results_finalized` |
| `awardsSeason` | String, nullable | `awards_season` |
| `test` | Boolean | `test` (среда: true — тестовые сборки) |
| `signupBonusMigrated` | Boolean | `signup_bonus_migrated` (+100 считается из журнала) |
| `legacyBonusUsersCount` | Integer | `legacy_bonus_users_count` |
| `goodPower` | `GgMetric` | `stats.good_power` |
| `games` | `GgMetric` | `stats.games` |
| `goodPowerPerGame` | `GgMetric` | `stats.good_power_per_game` |
| `goodEnergy` | `GgMetric` | `stats.good_energy` |
| `goodEnergyPerGame` | `GgMetric` | `stats.good_energy_per_game` |
| `sponsoredGames` | `GgMetric` | `stats.sponsored_games` |
| `allTimeRank` | Integer, nullable | `all_time.rank` |
| `allTimeGoodPower` | Double | `all_time.good_power` |
| `allTimeGamesCount` | Integer | `all_time.games_count` |
| `awards` | List `GgAward` | `awards` (все сезоны) |
| `awardFlags` | `GgAwardFlags` | `award_flags` |
| `totalGoodPower` | Double | `total_good_power` |
| `totalGoodPowerAllTime` | Double | `total_good_power_all_time` |

### `GgGamesPage` — ответ `gg_v2_games` (без самих игр)

| Поле | Тип | JSON |
|---|---|---|
| `userId` | String | `user_id` |
| `requestedPeriod` | String | `requested_period` |
| `requestedCategory` | String | `requested_category` |
| `period` | `GgPeriod` | `period` |
| `availablePeriods` | List `GgPeriod` | `available_periods` |
| `category` | `GgCategory` | `category` |
| `layoutMode` | `GgLayoutMode` | `layout_mode` |
| `resultsFinalized` | Boolean | `results_finalized` |
| `awardsSeason` | String, nullable | `awards_season` |
| `page`, `pageSize` | Integer | `pagination.page`, `.page_size` |
| `hasMore` | Boolean | `pagination.has_more` |
| `test` | Boolean | `test` (среда: true — тестовые сборки) |
| `signupBonusMigrated` | Boolean | `signup_bonus_migrated` (+100 считается из журнала) |
| `legacyBonusUsersCount` | Integer | `legacy_bonus_users_count` |

Сами игры — строки таблицы `games` (`to_jsonb(g)`). Их выводят готовые
компоненты `GamesOrgComp` / `GamesUserComp` с параметром типа `GamesRow`
(тип таблицы Supabase, уже известный FF). Поэтому игры хранятся как
`List<GamesRow>` в состоянии страницы, а не отдельным Data Type.

## Кэш в App State (сохраняется на телефоне)

| App State | Тип | Заменяет |
|---|---|---|
| `ggRankingCache` | List `GgRankingEntry` | `ggCacheRanking`, `ggCacheHome`, `ggCacheGuest` |
| `ggStatsCache` | List `GgStatsEntry` | `ggCacheStats`, `ggCacheProfile` |
| `ggGamesCache` | List `GgGamesEntry` | `ggCacheHistory` |

Записи кэша:

| Data Type | Поля |
|---|---|
| `GgRankingEntry` | `key` String, `savedAt` DateTime, `version` Integer, `data` `GgRanking` |
| `GgStatsEntry` | `key` String, `savedAt` DateTime, `version` Integer, `data` `GgProfileStats` |
| `GgGamesEntry` | `key` String, `savedAt` DateTime, `version` Integer, `meta` `GgGamesPage`, `games` List JSON |

* `key` — тот же ключ, что сейчас (период, категория, страница, среда, пользователь).
* `version` — номер схемы. Запись с другим номером не используется (данные
  перезапрашиваются): так изменение Data Type не ломает старый кэш.
* В каждом списке хранятся последние 30 записей.
* Исключение: `GgGamesEntry.games` — строки `games` в JSON, потому что App State
  не умеет сохранять тип `GamesRow`. При чтении они сразу превращаются в
  `List<GamesRow>`; в привязки JSON не попадает.

## Действия

| Новое действие | Возвращает | Заменит |
|---|---|---|
| `ggLoadRanking(period, category, page, pageSize, userId, test)` | `GgRanking` | `ggV2Rankings` |
| `ggLoadProfileStats(userId, period, test)` | `GgProfileStats` | `ggV2ProfileStats` |
| `ggLoadGames(userId, period, category, page, pageSize, test)` | `GgGamesEntry` (meta + игры) | `ggV2Games` |

Функции кэша (чистые, без запросов):

| Функция | Что делает |
|---|---|
| `ggRankingFromCache(cache, key)` → `GgRanking?` | запись по ключу (только текущей версии схемы) |
| `ggRankingToCache(cache, key, data)` → List `GgRankingEntry` | кладёт ответ первым, заменяя тот же ключ; хранит 30 |
| `ggStatsFromCache` / `ggStatsToCache` | то же для `GgProfileStats` |
| `ggGamesFromCache` / `ggGamesToCache` | то же для `GgGamesEntry` |
| `ggGamesOf(entry)` → List `GamesRow` | игры страницы как строки таблицы `games` |

Исходники: `variants/02_rpc/flutterflow/typed/`. Разбор проверен на реальных
ответах RPC: значения совпадают, сохранение в App State и чтение обратно дают
тот же тип.

Старые действия и JSON-кэши остаются, пока все экраны не переведены.

## Порядок

1. Схема: enums, Data Types, поля App State, новые действия, функции кэша.
   Экраны не меняются.
2. Экраны по одному: профиль → GoodGamesPage → главная → Energy.
3. Уборка старых JSON-действий, кэшей и функций — по подтверждению владельца.
