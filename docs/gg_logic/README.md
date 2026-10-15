# Good Games: локальный комплект логики

**Точка входа для следующего агента:** [HANDOFF.md](HANDOFF.md).
Там текущие решения пользователя, ограничения, статус и порядок продолжения.

**Актуальные три варианта с test/prod и +100 в БД:**
[variants/START.md](variants/START.md). Подготовлены отдельные install.sql,
Custom Code и инструкции для каждого варианта; проверены локально.
Ниже сохранено описание предыдущего черновика. Его SQL не применять как
финальную версию с новым бонусным правилом.

Статус: код сохранён локально. 1 октября 2026 добавлена и проверена фиксация
итогов сезонов в отдельной PostgreSQL. Облачные проекты не изменялись.
Дополнения от 1 октября (test/prod, хранение +100 и включение бонуса в MVP/Total,
варианты админки) зафиксированы в [SCOPE_OPTIONS.md](SCOPE_OPTIONS.md).
Текущий RPC-комплект ещё не адаптирован к этим новым требованиям;
описанное ниже исключение +100 — прежнее правило, теперь оно отменено.
В Supabase и облачный FlutterFlow он не отправлялся. Скрипт
[`../gg_rpc_listener/example.sql`](../gg_rpc_listener/example.sql) — предыдущий
неполный пример; для этой итерации использовать файлы из этой папки.

## Что подготовлено

| Место | Готовый код | Задача |
| --- | --- | --- |
| Supabase | [`00_season_tables.sql`](supabase/00_season_tables.sql) | Приватные таблицы сезонов и сохранённых итогов |
| Supabase | [`01_functions.sql`](supabase/01_functions.sql) | 3 публичных RPC: `gg_rankings`, `gg_profile_stats`, `gg_games`; общие функции периода и расчётов |
| Supabase | [`02_notifications.sql`](supabase/02_notifications.sql) | Broadcast `gg:stats` после изменения игры, использованного инвайта или публичных данных игрока |
| Supabase | [`03_indexes.sql`](supabase/03_indexes.sql) | Индексы для постраничной истории и использованных инвайтов; выполнять отдельно после сравнения с существующими |
| Supabase | [`04_finalize_seasons.sql`](supabase/04_finalize_seasons.sql) | Фиксация метрик и мест; повторный запуск не перезаписывает итоги |
| Supabase | [`05_schedule.sql`](supabase/05_schedule.sql) | Закрытие через Supabase Cron раз в час |
| FlutterFlow | [`gg_rankings.dart`](../../lib/custom_code/actions/gg_rankings.dart), [`gg_profile_stats.dart`](../../lib/custom_code/actions/gg_profile_stats.dart), [`gg_games.dart`](../../lib/custom_code/actions/gg_games.dart) | 3 Custom Actions с результатом **JSON** |
| FlutterFlow | [`gg_stats_listener.dart`](../../lib/custom_code/widgets/gg_stats_listener.dart) | Один Custom Widget; подписка, возврат на экран, из фона, переподключение, группировка событий |
| Локальный экран | [`gg_results_panel.dart`](../../lib/custom_code/widgets/gg_results_panel.dart) | Обе вкладки Good Games: рейтинг/подиум и постраничные Meine Games с фильтрами |
| FlutterFlow | [`gg_default_period.dart`](../../lib/custom_code/functions/gg_default_period.dart), [`gg_period_bounds.dart`](../../lib/custom_code/functions/gg_period_bounds.dart), [`gg_games_rows.dart`](../../lib/custom_code/functions/gg_games_rows.dart) | Значение фильтра по умолчанию, локальная совместимость и преобразование ограниченной истории в `GamesRow` |
| FlutterFlow | [`filter_all_games.dart`](flutterflow/functions/filter_all_games.dart), [`games_for_period.dart`](flutterflow/functions/games_for_period.dart) | Необязательные подготовленные замены старых функций для локальных списков; действующие функции пока не тронуты |

Custom Actions, listener, panel и функции зарегистрированы в локальных
index-файлах экспорта. Локальные экраны подключены к RPC, но сами функции
Supabase ещё не применены. Изменения не отправлялись в Supabase или облачный
FlutterFlow.

Для ручной настройки существующих страниц в FF использовать
[FLUTTERFLOW_MANUAL.md](FLUTTERFLOW_MANUAL.md); Dart-страницы не импортировать.
До изменений сохранить commit в FF и создать рабочую ветку, если тариф позволяет.
SQL применять по команде владельца в порядке `00`–`05`. После установки `04`
один раз вызвать `select gg_internal.finalize_due_seasons();` для прошлых сезонов.
Для `05` предварительно включить Supabase Cron.

## Правила расчёта

- `Good Power` = сумма `lichtwatt` завершённых игр + сумма `lichtwatt`
  использованных приглашений. Передающий очки — `inviter_user_id`.
- `Most Active Player` = количество завершённых игр. Текущие разрозненные
  функции считают инвайты для активности по-разному; здесь метрика единая.
  Награды получают первые три места MAP и MVP отдельно друг от друга.
- Во время идущего сезона выдаются только числовые текущие места. Значки и
  кубок берутся из сохранённых итогов закрытого сезона; они не зависят от выбранной
  сейчас категории и одновременно сохраняют, например, MVP-награду у игрока,
  который в MAP занял пятое место.
- `Total Good Power` выбранного периода включает всех текущих пользователей;
  отдельно возвращается `total_good_power_all_time` за всё время.
- Данные All-Time включают все сезоны и записи вне них, в том числе записи
  без даты. Для сезона/месяца записи без даты нельзя однозначно разместить
  в календаре, поэтому они в ограниченный период не входят.
- Стартовые `+100` остаются только в старом отображении, где они уже были.
  В SQL-рейтинг, награды и общий итог они **не входят**. Локальные старые
  функции не менялись.
  Это текущее состояние файлов, а не новое согласованное требование:
  после адаптации бонус должен начисляться в БД один раз и входить в MVP/Total.
- Каждый завершённый сезон фиксируется один раз в `gg_internal.season_results`.
  Изменение/удаление старой игры не меняет закрытые метрики, места и награды.
  All-Time/месяцы остаются актуальными; после исправления источников их сумма
  может отличаться от суммы сохранённых сезонов. История `gg_games` остаётся живой.
- До успешного закрытия сезона наград нет. Cron закрывает сезон и отправляет
  Broadcast открытым экранам. Это не зависит от посещения приложения.
- При равенстве применяется порядок по `user_id`: места последовательные.
  Это повторяет стабильную сортировку существующего списка. Правило собрано
  в `gg_internal.config()` и может быть заменено на `shared` до применения.
- Пустой пользователь имеет 0 очков и `rank = null`; он не занимает место
  в рейтинге и не получает награду.
- Сезон 2025/26: `[2025-11-20, 2026-09-01)`.
  Сезон 2026/27: `[2026-09-01, 2027-07-01)`.
  Последний день входит до `23:59:59.999999`.
- `auto` выбирает последний **начавшийся** из заданных сезонов, даже после
  его окончания. Например, в июле/августе 2027 остаётся 2026/27.
  По подтверждению владельца следующие сезоны ежегодно идут с 1 сентября
  до 30 июня. Ключи/границы и default считаются автоматически;
  `available_periods` каждого RPC содержит динамический список для фильтров.
- Сейчас месяцы считаются по UTC, а поля `game_date`/`used_at` имеют тип
  `timestamp` без часового пояса. Перед применением на живой базе подтвердить
  часовой пояс и исходный смысл этих сохранённых значений. Сезоны используют
  указанные календарные даты.

## Контракт RPC

### `gg_rankings(p_period, p_category, p_page, p_page_size, p_user_id)`

`p_period`: `auto`, `season_2025_26`, `season_2026_27`, `last_month`,
`this_month`, `all_time`. Старые ключи `gesamt`, `saison`, `letzter_monat`,
`dieser_monat` тоже понимаются. `p_category`: `valuable` или `active`.
`p_page_size` — от 1 до 100; для текущего макета 10. `p_user_id` может быть
`null` для гостя.

```json
{
  "period": {"key":"season_2026_27","label":"Saison 2026/27","season_year":2027,
    "period_start":"2026-09-01T00:00:00","period_end_exclusive":"2027-07-01T00:00:00"},
  "category":"valuable",
  "total_good_power":12560,
  "total_good_power_all_time":18000,
  "top_players":[{"user_id":"...","rank":1,"score":2630,"good_power":2630,
    "games_count":12,"display_name":"Player","photo_url":"...",
    "award_flags":{"mvp_gold":true,"mvp_silver":false,"mvp_bronze":false,
      "active_fire":false,"map_silver":false,"map_bronze":false}}],
  "players":[{"user_id":"...","rank":1,"score":2630}],
  "current_user":{"user_id":"...","rank":45,"score":1441},
  "pagination":{"page":1,"page_size":10,"total_count":61,"has_more":true}
}
```

Это схема полей, а числа и ID — иллюстрация. Объекты `players`, `top_players`
и `current_user` имеют один и тот же полный набор полей. `players` ограничен
размером страницы; `top_players` всегда максимум 3; `current_user` — один
пользователь, даже если его нет в этой странице списка. Поле `rank`
соответствует выбранной категории. `awards` содержит награды всех закрытых
сезонов с `season_year`, `category`, `place`, `badge`. `award_flags` объединяет
их типы; для отдельных значков с годом использовать массив `awards`.
Награды не зависят от выбранного периода. `available_periods` — список периодов.

### `gg_profile_stats(p_user_id, p_period)`

Возвращает JSON одного открытого профиля, без списка других игроков.

```json
{
  "user_id":"...","period":{"key":"season_2026_27","season_year":2027},
  "all_time":{"good_power":1200,"rank":3,"games_count":10},
  "stats":{
    "good_power":{"value":200,"rank":2},
    "games":{"value":5,"rank":3},
    "good_power_per_game":{"value":40,"rank":4},
    "good_energy":{"value":300,"rank":6},
    "good_energy_per_game":{"value":60,"rank":5},
    "sponsored_games":{"value":1,"rank":8}
  },
  "awards":[{"season":"season_2025_26","category":"valuable","place":1,"badge":"mvp_gold"}],
  "award_flags":{"mvp_gold":true,"mvp_silver":false,"mvp_bronze":false,
    "active_fire":false,"map_silver":false,"map_bronze":false}
}
```

### `gg_games(p_user_id, p_period, p_category, p_page, p_page_size)`

Возвращает JSON с `games` (максимум `p_page_size` готовых строк `games`) и
`pagination.has_more`. Сортировка `valuable`: LW по убыванию, потом дата.
Сортировка `active`: новые игры первыми. Преобразование `ggGamesRows(JSON)`
позволяет передать ограниченный список существующему `GamesOrgCompWidget`
без переписывания его интерфейса. `gg_games` читает только игры открытого
пользователя. Инвайты показываются в рейтинге/статистике, но не как игры.

Для живых периодов сервер агрегирует игры/инвайты и считает места SQL-окнами.
Закрытые сезоны/награды читаются из таблицы итогов. PostgREST передаёт только JSON.
Закрытие атомарно, защищено блокировкой от параллельных запусков и доступно
только владельцу БД/расписанию. Клиент не может записывать итоги.

## Подключение во FlutterFlow

### GoodGamesPage

Текущий файл экспорта: [`good_games_page_widget.dart`](../../lib/pages/good_games_page/good_games_page_widget.dart).
`tab == 2` — Good Heart Games, `tab == 1` — Meine Games. Обе вкладки локально
отображаются виджетом [`GgResultsPanel`](../../lib/custom_code/widgets/gg_results_panel.dart).
Гостю доступен рейтинг; личная история игр доступна вошедшему в аккаунт.

1. Page State: `periodPageUser`, `periodPageGame` → `auto` по умолчанию;
   `valuePageUser`, `valuePageGame` → `valuable`;
   `rankingData`, `gamesData`, `myStatsData` → JSON nullable;
   `pageNumberGames` → 1.
2. При ручной настройке FF сделать Page Action Block `reloadGoodGames`:
   при `tab == 2` вызывает только
   `ggRankings(periodPageUser,valuePageUser,1,10,currentUserUid/null)`;
   при `tab == 1` для зарегистрированного — `ggGames(currentUserUid,
   periodPageGame,valuePageGame,pageNumberGames,10)` и
   `ggProfileStats(currentUserUid,periodPageGame)`.
3. Добавить `GgStatsListener` один раз на страницу (1×1 px).
   `onRefresh` → `reloadGoodGames`; `refreshKey` объединяет `tab`, период,
   категорию, номер страницы, `currentUserUid`, `FFAppState.refreshDate`.
   При первом открытии и изменениях listener запускает нужные RPC.
4. Перед записью результата в Page State сравнивать `requested_period`,
   `requested_category`, `requested_user_id`/`user_id`, номер страницы и
   активную вкладку с текущим Page State. Если во время запроса фильтр
   поменялся, старый ответ пропускается; listener запустит следующий.
5. `rankingData.period.label` показывает выбранный сезон; год золотой
   плашки — `rankingData.period.season_year`. `rankingData.total_good_power`
   — итог выбранного периода; для постоянного All-Time итога есть отдельный
   `total_good_power_all_time`.
6. Подиум: `$.top_players[0..2]`. Список: `$.players` с `rank`,
   `display_name`, `photo_url`, `score`. Нижняя строка текущего игрока —
   `$.current_user`, только если его ID отсутствует в `players` и `rank != null`.
   Заменить вызовы `ratingUsersIds`, `ratingUsersPerUser`,
   `getUserRatingScore` и запрос пользователя на каждой строке на поля JSON.
   Локальный `GgResultsPanel` уже строит строки по JSON; существующему
   `GamesUserCompWidget` для такого же подключения понадобятся параметры
   `score`, `displayName`, `photoUrl`, `awardFlags`.
7. Meine Games: существующий список `GamesOrgCompWidget` получает
   `ggGamesRows(gamesData)`; стрелки меняют `pageNumberGames`,
   `pagination.has_more` управляет кнопкой Next. Статистические карточки
   получают значения/места из `myStatsData.stats`.
8. При смене периода/категории сбрасывать `pageNumberGames = 1`.
   Вызов полного потока всех `games` и `invites` для расчётов удалить из
   GoodGamesPage **после** переноса всех зависимых привязок.

### Фильтр GoodGamesPlayersFiltersWidget

Текущий файл: [`good_games_players_filters_widget.dart`](../../lib/components/dialogs/good_games_players_filters/good_games_players_filters_widget.dart).
Этот один компонент вызывается и из Meisterschaft, и из Meine Games.

- Категории: только `valuable` — Most Valuable Player,
  `active` — Most Active Player. Опции Generous/Social убрать в этом UI;
  глобальные enum-значения для других экранов не удалять.
- Периоды: `season_2026_27`, `season_2025_26`, `last_month`, `this_month`,
  `all_time` с названиями дизайна. При открытии фильтра передать выбранные
  значения; при подтверждении обновить только после изменения.
- Кнопка подтверждения: если черновой период **или** категория отличается
  от открытых значений, `fillColor = Colors.black` и
  `iconColor = Colors.white`; если нет — текущие спокойные цвета.
- В профиле использовать этот же компонент с опцией `showCategory=false`
  или отдельную компактную форму периода, сохранив ту же проверку кнопки.

### UserProfilePage

Текущий файл: [`user_profile_page_widget.dart`](../../lib/pages/user_profile_page/user_profile_page_widget.dart).
Локальная страница читает карточки профиля через `ggProfileStats`; два старых
глобальных потока завершённых игр для рейтингов заменены пустым локальным
потоком. Запрос игр профиля для организаций сохранён. Добавлены listener,
выбор периода и текстовые награды; соцсети перемещены в верх профиля.
Обновлённые графические assets владелец добавит отдельно.

- Page State: `profilePeriod = auto`, `profileStatsData JSON nullable`.
  `GgStatsListener.refreshKey` содержит ID **открытого** профиля, период,
  `refreshDate`; callback → `ggProfileStats(widget.userId,profilePeriod)`.
- В четырёх строках `UserProfileInfoStatsRowWidget`:

  | Строка | Значение | Место |
  | --- | --- | --- |
  | Total Good Power | `$.stats.good_power.value` | `$.stats.good_power.rank` |
  | Punkte per Game | `$.stats.good_energy.value` для сохранения существующей формулы; `$.stats.good_power_per_game.value` если отдельно согласовано исправление смысла строки | соответственно `good_energy.rank` / `good_power_per_game.rank` |
  | Good Games | `$.stats.games.value` | `$.stats.games.rank` |
  | Supporters | пока текущее отображение `1`; готовая замена при согласовании — `$.stats.sponsored_games.value` | `$.stats.sponsored_games.rank` |

- Верхняя шапка и карточка Good Power профиля сохраняют старое отображение
  `+100`. `rank`, подиум и общий серверный итог бонус не учитывают. Гостевой
  экран `guest` оставить с
  существующим `100`, без `ggProfileStats`.
- Значки рядом с именем/в профиле: `$.award_flags.mvp_gold`,
  `mvp_silver`, `mvp_bronze`, `active_fire`, `map_silver`, `map_bronze`.
  MVP и MAP рассчитываются независимо, у одного игрока могут быть несколько
  значков. Для отдельных годов строить список по `$.awards`, используя
  `season_year`, `category`, `place`, `badge`. Текущие места показываются
  числом до закрытия сезона.
- Перенести существующий блок соцсетей в верхнюю часть профиля по дизайну;
  ссылки менять не нужно. В экспортированном профиле есть повторённые ветки
  интерфейса, каждую активную ветку обновить; отдельно проверить
  [`диалог профиля`](../../lib/components/dialogs/user_profile/user_profile_widget.dart),
  если он используется навигацией.

## Надёжность обновления

`gg_stats_listener.dart` повторно читает данные при первом показе,
Broadcast от БД, смене фильтра, Back, возвращении из фона и переподключении.
Первые чтения и повторная подписка могут давать лишний, но небольшой запрос.
Пока вызов выполняется, новые сигналы помечаются, а затем выполняется
одно дополнительное чтение. При ошибке не подставлять 0 вместо старого
валидного ответа; показать ошибку и дать повторить.

В `FinishPage` текущее обновление `refreshDate` происходит до подтверждения,
что асинхронное начисление завершено. Broadcast после фактической записи
игры/инвайта возвращает актуальные очки и место. Если подтверждение
начисления доступно в клиентском потоке, после него можно дополнительно
обновить `refreshDate` существующим App Action Block.

Домашняя страница, Energy и административные экраны продолжают использовать
старые потоки. Не удалять общий запрос `games` в них, пока не перенесены
их конкретные виджеты. Эта итерация ограничена двумя вкладками Good Games
и профилем. Списки реальных игр/инвайтов остаются отдельными запросами,
но `gg_games` уже ограничивает историю Meine Games по периоду и странице.

## Проверка

- 1 октября 2026 [check_sql.py](tests/check_sql.py) прошёл в отдельной PostgreSQL
  16 с `--bulk-count 1000`: календарные границы, запрет раннего закрытия,
  повторные запуски, сохранность мест/наград после изменения игр,
  живой All-Time, обе категории, RLS, пагинация, новые аккаунты после закрытия,
  rollback итогов/уведомления и запрет записи итогов из клиентских ролей.
- Предыдущая версия без таблиц итогов была проверена на 100 005 играх.
  Повтор этого объёма для новой версии остановился из-за нехватки места
  на диске; массовая проверка новой версии не завершена.
- [logic_test.dart](tests/logic_test.dart) и [listener_test.dart](tests/listener_test.dart)
  дали 9 успешных тестов в отдельном harness. Анализ новых функций/панели
  не выявил ошибок; у панели остались предупреждение о неиспользуемой
  pagination и два уведомления о deprecated value у DropdownButtonFormField.
  Полная сборка экспортированного приложения не подтверждена.
- [05_schedule.sql](supabase/05_schedule.sql) подготовлен по документации
  [Supabase Cron](https://supabase.com/docs/guides/cron/quickstart).
  В тестовой базе проверены вызываемые функции, сам pg_cron не установлен.
  Job и историю запусков проверить при применении в Supabase.
- Перед применением подтвердить календарный часовой пояс, сверить результаты
  с проектными данными и проверить индексы/план запросов.
- SQL готов к рассмотрению, но не запускался в реальном Supabase. UI-параметры
  и Action Blocks в облачном FF не менялись. Изображения значков и новая
  иллюстрация добавляются владельцем.
