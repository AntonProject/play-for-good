# Вариант 2 — серверные расчёты Good Games / профиля

**Выбран пользователем 12 октября 2026, ориентир 16 часов.** Пока только локальная
подготовка; выбор варианта не является командой на запись в облако.

Для поэтапного старта использовать [deploy/README](deploy/README.md) +
[общий START](../START.md). Полный install.sql подключает триггеры сразу. Подготовлен отдельный
набор `ggV2*`, чтобы не менять ранее созданные `gg*` и старый фронт до выбора.

Порядок внедрения и разрешения — [HANDOFF](../../HANDOFF.md); точные FF actions,
Page State, node keys и JSON-привязки — [NATIVE_BINDINGS](../flutterflow_cli/NATIVE_BINDINGS.md).
Среда создания/чтения игр и инвайтов — [QUERY_MAP](../QUERY_MAP.md).
Перед внедрением учесть [аудит +100](../../BONUS_AUDIT_2026_10_09.md): обязательный
claim после OTP, signup_test в signup UPDATE и проверку среды admin signup.

Пакет включает сохранение результатов заданных сезонов и Cron их закрытия.
Админка редактирования сезонов и автопланирование будущих периодов не включены.

## FF Custom Actions

| Action → JSON | Параметры |
|---|---|
| `ggV2Rankings` | period String, category String, page/pageSize Integer, userId nullable String, test Boolean |
| `ggV2ProfileStats` | userId String, period String, test Boolean |
| `ggV2Games` | userId String, period/category String, page/pageSize Integer, test Boolean |
| Общий `ggClaimSignupBonus` | test Boolean |

Коды находятся в `flutterflow`. RPC один объект JSON: корень не List JSON.
ID нужного пользователя передаётся на вход; сервер возвращает current_user
и профиль отдельно, не нужно искать свой ID в текущей странице рейтинга.

## GoodGamesPage

On Load / On Refresh: `ggV2Rankings('auto','valuable',1,10,currentUserUid,test)`
→ Page State `ggRanking` JSON. У гостя userId=null, не строка guest в SQL.

* Генератор списка: `$.players`; подиум `$.top_players`.
* Имя/фото: `$.display_name` / `$.photo_url` внутри item.
* Значение/место: `$.score` / `$.rank` внутри item.
* Текущий пользователь отдельно: `ggRanking.current_user`.
* Глобальный Total: `ggRanking.total_good_power_all_time`, **не +100**.
* Год/название периода: `ggRanking.period.season_year` / `.label`.
* Медали: `item.awards`; category/place выбирают asset, не текущий rank.
  Все MVP идут перед MAP. В All-Time и месяцах массив содержит все награды,
  в сезонном рейтинге — только выбранного сезона. При смене MVP/MAP не скрывать
  награду другой категории. Генерировать весь массив, не схлопывать через flags.
  Текущий rank 1–3 обозначать цифрой, новые медали только из awards.

Фильтры: `available_periods` → label/key; категории valuable/active.
Selected/applied отдельно; при Apply записать applied, page=1, повторить RPC.
При листании менять page, не терять текущую строку/подium: они включены отдельно.
Старые глобальные игры/инвайты перестают быть источником этих виджетов;
выключение их запросов в FF делать после замены всех соответствующих привязок.

## Meine Games

`ggV2Games(opened/currentUserId,appliedPeriod,appliedCategory,page,10,test)`
→ `ggHistory`. Список `$.games`, следующая страница `$.pagination.has_more`.
`ggGamesRows(ggHistory)` адаптирует к прежним GamesRow карточкам.
Личные очки/место: `ggV2ProfileStats` → `$.stats.good_power.value/rank`.

## UserProfilePage

On Load: `ggV2ProfileStats(ID открытого профиля,'auto',test)` → `ggProfile`.
Header: `$.all_time.good_power/rank`; Stats: `$.stats.*.value/rank`; медали:
`$.awards`. Дата-фильтры из `$.available_periods`. Все +100 на этих привязках
убрать, начисление уже в результате RPC. Гость сохраняет прежний демо-экран.
Профиль всегда показывает все полученные награды закрытых сезонов, независимо
от периода Stats; сначала MVP, затем MAP. Внутри категории новые сезоны первыми.

Punkte per Game по подтверждению пользователя 13 октября сохраняет прежнюю
сумму €nergy: `stats.good_energy.value/rank`, не среднее и не Good Power.
Supporters сохраняет value=1; его прежний social-ранг берётся из
`stats.sponsored_games.rank`, не games.rank. Это не расчёт числа людей.
Организации, посты,
соцсети и их отдельные запросы сохраняются. Соцсети перенести выше вручную.

## Обновление

`GgStatsListener`: width/height=1, refreshKey=userId + test + appliedPeriod +
appliedCategory; onRefresh повторяет нужные RPC. Он вызывает initial refresh,
возврат на страницу, resume/reconnect и Broadcast. Не дублировать initial
запрос в On Load, если его уже выполняет listener.
После завершения своей игры повторить RPC при возврате, не ждать Broadcast.
Другой игрок изменил рейтинг — Broadcast обновит активную страницу; серия
событий объединяется. Ошибка сохраняет предыдущие успешно полученные данные.
Pending выбранный фильтр не применять при фоновом refresh.

## Локальные примеры

* `GgV2ResultsPanel`: tab=2 рейтинг, tab=1 Meine Games, userId, test.
* `GgV2ProfilePanel`: userId, test; пример header/награды/статистика.
* `GgStatsListener`: общий listener этого комплекта (`gg:v2:stats`).

Это исходники для проверки привязок; в FF повторить поведение родными
виджетами. Не импортировать старый сгенерированный профиль с ручным +100.
Home/Energy/админка не переводятся на эти RPC автоматически.

Полная сверка ТЗ и порядок ручного переноса: [RPC_READINESS](RPC_READINESS.md).


## Запуск локального сравнения

Готов отдельный entry point и debug Web-сборка:
[LOCAL_PREVIEW](LOCAL_PREVIEW.md). После установки SQL можно запустить рейтинг,
Meine Games и профиль на новых RPC без переключения облачного FF. Это отдельный
экран проверки логики; native FF остаётся на ручном переносе по NATIVE_BINDINGS.
