# Good Games v2: таблицы и функции в Supabase

Справочник по тому, что добавлено в базу для Good Games v2. Исходники SQL —
`docs/gg_logic/variants/02_rpc/iteration1/`: `01_install.sql` (основа; если
функция определена несколько раз, действует последнее определение),
`02_listener.sql`, `03_schedule.sql`, `04_home_gauge.sql`,
`05_guest_signup_bonus.sql`, `06_sync_names_to_games.sql`.

Общие правила:

* Логика живёт в схеме **`gg_v2`**. Её таблицы и функции закрыты для приложения
  (`anon`/`authenticated` не имеют прав), RLS включён. Приложение работает только
  через функции `public.gg_v2_*` (RPC), которые читают `gg_v2` от имени владельца.
* Edge Functions не используются: всё — функции Postgres, приложение вызывает их
  `supabase.rpc('gg_v2_…', params: {…})` из кастомных действий FlutterFlow и сразу
  разбирает ответ в Data Types ([TYPED_SCHEMA](TYPED_SCHEMA.md)).
* Параметр `p_test` во всех функциях: `false` — прод, `true` — тестовая среда
  (тестовые сборки). Данные сред не смешиваются.
* Время — UTC. Конец периода исключительный (`ends_at` = первый день после
  последнего).

## Изменения в существующих таблицах `public`

| Таблица.поле | Тип | Зачем | Кто пишет |
|---|---|---|---|
| `games.test` | bool, default false | Игра из тестовой сборки. Рейтинги считают только свою среду. Старая прод-сборка поле не шлёт → прод. | PlayPaymentPage при создании игры: `FFDevEnvironmentValues().test` |
| `invites.test` | bool, default false | То же для инвайтов. | Действие `inviteUser` |
| `users.signup_test` | bool, default false | Регистрация из тестовой сборки → бонус в тестовой среде. | `signInAfterOtpVerification` при создании профиля |
| `users.guest_signup_bonus` | int, default 0 | Копия журнала для просмотра/админки: 100 — получил бонус за регистрацию из гостя, 0 — нет. Рейтинги его не читают. | Только сервер (`gg_v2.claim_signup_bonus`). Триггер `gg_v2_users_guest_bonus_guard` не даёт приложению установить или изменить значение |

## Таблицы `gg_v2`

### `gg_v2.seasons` — календарь сезонов

| Поле | Тип | Зачем |
|---|---|---|
| `season_key` (PK) | text | Ключ периода, его передают в RPC (`season_2025_26`, автосозданные: `season_YYYY_MM_DD`). |
| `label` | text | Название для приложения («Saison 2025/26»). |
| `season_year` | int | Год окончания; используется в наградах (`season_year`). |
| `starts_at` | timestamp | Начало, включительно. |
| `ends_at` | timestamp | Конец, исключительно (первый день после сезона). Проверка `ends_at > starts_at`. |

* Сезоны не пересекаются: триггер `seasons_no_overlap` → `gg_v2.check_season_overlap()`.
* Добавить: `select gg_v2.add_season('2027-09-01','2028-06-30');` (последний
  день включительно; ключ и название подставятся сами) или автоматически cron
  (`plan_due_seasons`, длительность — `rollout.season_months`).
* Изменение строки (`label`, даты) сразу видно в RPC. Даты закрытого сезона не
  менять: его итоги уже сохранены.
* Где используется: все RPC (определение периода, `available_periods`), награды,
  закрытие сезонов.

### `gg_v2.season_closures` — какие сезоны закрыты

| Поле | Тип | Зачем |
|---|---|---|
| `season_key` (PK, FK → seasons) | text | Сезон. |
| `test` (PK) | bool | Среда. Сезон закрывается отдельно для прода и для теста. |
| `finalized_at` | timestamptz | Когда сохранены итоги. |

* Пишет `gg_v2.finalize_season`. Наличие строки = итоги сезона заморожены, RPC
  отдают их из `season_results`, а медали в таблице GG берутся из последнего
  закрытого сезона (`last_finalized_season`).

### `gg_v2.season_results` — итоги закрытого сезона

Снимок каждого игрока на момент закрытия. Не меняется при последующих правках
игр (пересчитать можно только `refinalize_season`). Нет FK на `users`: удаление
аккаунта не удаляет итоги.

| Поле | Тип | Зачем |
|---|---|---|
| `season_key`, `test`, `user_id` (PK) | text, bool, uuid | Сезон, среда, игрок. |
| `display_name`, `first_name`, `surname`, `photo_url` | text | Снимок профиля на момент закрытия (запасной вариант, если аккаунт удалён; иначе RPC берут текущие данные из `users`). |
| `good_power` | numeric | Good Power за сезон = `game_power` + `invite_power` + бонус. Категория MVP («valuable»). |
| `game_power` | numeric | Очки за игры (`games.lichtwatt` завершённых игр). |
| `invite_power` | numeric | Очки за использованные инвайты. |
| `games_count` | bigint | Число завершённых игр. Категория MAP («active»). |
| `good_energy` | numeric | Good Energy (категория «generous»). |
| `good_power_per_game`, `good_energy_per_game` | numeric | Средние на игру. |
| `sponsored_games` | bigint | Игры со спонсором (категория «social»). |
| `power_rank`, `games_rank`, `power_per_game_rank`, `energy_rank`, `energy_per_game_rank`, `sponsored_games_rank` | bigint | Места по каждой метрике. Награды: топ‑3 `power_rank` → MVP 1/2/3, топ‑3 `games_rank` → MAP 1/2/3. |

* Пишет `finalize_season` / `refinalize_season`. Читают RPC (рейтинги и
  профиль за закрытый сезон, награды).

### `gg_v2.point_awards` — журнал начислений бонуса +100

| Поле | Тип | Зачем |
|---|---|---|
| `user_id` (PK, FK → users, cascade) | uuid | Кому. |
| `test` (PK) | bool | Среда. |
| `reason` (PK) | text, только `'signup_bonus'` | Причина. Одна строка на пользователя/среду → двойное начисление невозможно. |
| `amount` | numeric, только 100 | Сумма. |
| `awarded_at` | timestamp | Дата регистрации в Auth (не дата запуска скрипта). Попадает в период/сезон по этой дате. |

* Пишет `gg_v2.ensure_signup_bonus` (через `claim_signup_bonus`). Учитывается в
  `good_power`, только когда `rollout.signup_bonus_migrated = true`.
* В проде было 53 строки с датами 2025–2026 (начисление задним числом).
  Решение владельца 14.10.2026: удалить (`07_cleanup.sql`). Дальше журнал
  пополняется только регистрациями из гостя.

### `gg_v2.rollout` — переключатели (одна строка)

| Поле | Default | Зачем |
|---|---|---|
| `singleton` (PK) | true | Гарантирует одну строку. |
| `signup_bonus_migrated` | false | Учитывать `point_awards` в очках. Включено `05_guest_signup_bonus.sql`. |
| `finalization_enabled` | false | Разрешить закрытие сезонов (вручную и cron). Пока выключено — сезоны не закрываются автоматически. |
| `auto_plan_enabled` | true | Cron создаёт следующий сезон, когда текущий закончился. |
| `season_months` | 10 | Длительность автосоздаваемого сезона в месяцах. |

Читается через `gg_v2.config()`.

## Функции для приложения (`public`, вызываются через RPC)

| Функция | Параметры | Возвращает | Где во фронте |
|---|---|---|---|
| `gg_v2_rankings` | `p_period`, `p_category`, `p_page`, `p_page_size`, `p_user_id`, `p_test` | Рейтинг: `top_players`, `players` (страница), `current_user`, `pagination`, `period`, `available_periods`, `total_good_power`, `max_good_power`, `guest_rank`, `results_finalized`, `awards_season` и др. | Действие `ggLoadRanking` → Data Type `GgRanking`: GoodGamesPage, главная (`homePageScore`, шкала `ggHomeGaugeOf`), профиль гостя |
| `gg_v2_profile_stats` | `p_user_id`, `p_period`, `p_test` | Профиль: `stats` (значение и место по каждой метрике), `all_time`, `awards`, `award_flags`, имя/фото, `period`, `available_periods` | Действие `ggLoadProfileStats` → `GgProfileStats`: профиль, окно профиля, GoodGamesPage, `energyComp` |
| `gg_v2_games` | `p_user_id`, `p_period`, `p_category`, `p_page`, `p_page_size`, `p_test` | Игры игрока за период с пагинацией | Действие `ggLoadGames` → `GgGamesEntry` (игры как `GamesRow`): GoodGamesPage |
| `gg_v2_context` | `p_period`, `p_test` | Период, закрыт ли, вклад бонусов/инвайтов, награды по игрокам, `available_periods` | Приложение пока не вызывает (служебная/для админки) |
| `gg_v2_claim_signup_bonus` | `p_test`, `p_from_guest` | `{created, awarded, test}` | `signInAfterOtpVerification` |

Значения `p_period`: `auto` (текущий сезон), `all_time`, `this_week`,
`this_month`, `last_month`, ключ сезона из `seasons`; старые ключи приложения
(`season_26_27`, `gesamt`, `woche`, …) переводятся автоматически.
`p_category`: `valuable` (MVP, Good Power), `active` (MAP, игры), `generous`
(энергия), `social` (спонсорские игры). При равенстве очков выше тот, у кого
активность позже (`tie_policy: sequential`).

## Внутренние функции `gg_v2`

| Функция | Что делает | Кто вызывает |
|---|---|---|
| `score_sets(period, test)` | Считает по `games`/`invites`/`point_awards` очки, игры, энергию и места всех игроков за период. Сердце расчёта. | RPC рейтинга/профиля/игр, закрытие сезона |
| `player_payload(score, category, awards)` | Собирает JSON игрока для ответа. | RPC |
| `category_key(category)` | Нормализует категорию. | RPC |
| `award_flags(awards)` | Флаги бейджей (`mvp_gold`, `active_fire`, …) из списка наград. | RPC |
| `period_info(period, now)` | Разбирает ключ периода: границы, название, завершён ли. | Все |
| `season_periods(now)`, `available_periods()` | Список сезонов для приложения. | RPC |
| `context(period, test)` | Данные для `public.gg_v2_context`. | RPC |
| `config()` | Переключатели из `rollout` + `timezone`, `tie_policy`. | Все |
| `is_finalized(season, test)`, `last_finalized_season(test)` | Закрыт ли сезон; последний закрытый (для медалей в таблице). | RPC |
| `registered_users_count()` | Число зарегистрированных. | RPC |
| `add_season(first_day, last_day, label, key)` | Добавить сезон. | Владелец / будущая админка |
| `plan_due_seasons(now)` | Создать следующий сезон, если текущий закончился (`auto_plan_enabled`). | `finalize_due_seasons` |
| `finalize_season(season, test, now)` | Закрыть закончившийся сезон: записать `season_results` и `season_closures`. Требует `finalization_enabled`. | Владелец, cron |
| `refinalize_season(season, test, now)` | Пересчитать итоги уже закрытого сезона. | Владелец вручную |
| `finalize_due_seasons(now)` | Ежедневная задача: `plan_due_seasons` + закрыть все закончившиеся сезоны в обеих средах. | Cron `gg-v2-close-seasons`, 00:05 UTC |
| `ensure_signup_bonus(user, test)` | Записать +100 в журнал (дата = регистрация в Auth, только подтверждённый email). | `claim_signup_bonus` |
| `claim_signup_bonus(test, from_guest)` | +100, только если `from_guest`, аккаунт создан < 24 ч назад; ставит `users.guest_signup_bonus = 100`. | `public.gg_v2_claim_signup_bonus` |
| `bonus_on_profile()` | Старый вариант (бонус всем при создании профиля). Триггер не создан, не используется. | — |

### Триггерные функции

| Триггер | Таблица | Функция | Что делает |
|---|---|---|---|
| `gg_v2_games_changed`, `gg_v2_invites_changed`, `gg_v2_users_changed`, `gg_v2_posts_changed`, `gg_v2_bonus_changed`, `gg_v2_seasons_changed` | `games`, `invites`, `users`, `posts`, `point_awards`, `seasons` | `notify_changed()` | Шлёт в Realtime-канал `gg:v2:stats` событие с именем таблицы. Виджет `GgStatsListener` на экранах перезапрашивает данные (видимый экран — через 0,5 с, остальные — при возврате). |
| `seasons_no_overlap` | `gg_v2.seasons` | `check_season_overlap()` | Запрещает пересечение сезонов. |
| `gg_v2_users_guest_bonus_guard` | `users` | `users_guest_bonus_guard()` | Не даёт приложению менять `guest_signup_bonus`. |

### Существующие функции, изменённые для v2

* `public.sync_user_names_across_tables()` (`06_sync_names_to_games.sql`): при
  переименовании пишет в `games` ник → `user_name`, имя → `user_display_name`
  (как при оплате игры). Остальное без изменений.
* `public.sync_organization_names_across_tables()` не менялась: названия
  организаций в `games` — снимок на момент оплаты; приложение показывает текущее
  `organization.title` по `organization_id` (функция FF `ggOrgTitle`).

## Cron

`select cron.schedule('gg-v2-close-seasons','5 0 * * *', $$select gg_v2.finalize_due_seasons();$$);`
— проверить: `select jobname, schedule, active from cron.job;`, история —
Integrations → Cron → History.

## Решения 14.10.2026

* Начисления задним числом в `point_awards` и тестовые сезоны
  `season_2023_24_test`, `season_2024_25_test` удаляются `07_cleanup.sql`
  (выполняет владелец).
