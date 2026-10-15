# План текущей итерации / точка продолжения

Обновлено **13 октября 2026**, после свежей вёрстки владельца в FlutterFlow.
Этот план и [FF_BINDINGS_2026_10_13](variants/02_rpc/FF_BINDINGS_2026_10_13.md)
имеют приоритет над ранними инструкциями bonus-first/two categories.

## Решения 14 октября — приоритет над текстом ниже

* SQL в Supabase владелец применяет **сам** в SQL Editor. Агент не пишет в прод
  и не читает прод-БД без отдельного разрешения.
* Даты из ТЗ: 2025/26 = **01.11.2025**–31.08.2026 (не 20.11),
  2026/27 = 01.09.2026–30.06.2027. Дальнейшие сезоны прогнозные: автоплан
  «со следующего дня +10 месяцев», даты правятся в `gg_v2.seasons` или
  `gg_v2.add_season(first_day,last_day)`. Пересечения запрещены триггером.
* Фиксация больше не ждёт +100: закрыть 2025/26 сразу после установки
  (`finalization_enabled=true` + `finalize_season`), после переноса +100 или
  правки дат — `gg_v2.refinalize_season`. Пересчёт сделать до релиза сборки.
* Cron раз в сутки, 00:05 UTC. Listener (02) ставить вместе с релизом новой
  сборки: старой сборке он ничего не даёт, только нагрузка на запись.
* Тестовые фикстуры `ggPreviewData` не используются: проверка на прод-данных
  (test=false). Удалены из пакетов CLI; `push_ui.dart` на них построен и
  перед использованием должен быть переписан на настоящие actions.
* Тестовые игру/инвайт/регистрацию владелец проверит сам позже.
* 14 окт., вечер: `01_install.sql` применён владельцем в prod (precheck чистый:
  gg_v2 не было, test-колонок не было, игр 01–19.11.2025 нет).
* Категории в FF: только MVP и MAP (generous/social убраны из фильтров; SQL их
  держит, не мешает). Иконки строк таблицы — **последний закрытый сезон при любом
  фильтре** (`awards_season`, `gg_v2.last_finalized_season`). Подиум: current —
  `ggShowCurrentPlace`, завершённый сезон — `ggShowFinalPlace`. Профиль — все награды.
* Места: при равных очках выше более поздняя активность в периоде. Гость = 100
  очков и «новее всех» → `guest_rank`. Одна функция места для Home/профиля/GG:
  `ggPlace(ranking)`. Home переводится на ggV2Rankings; период `woche`→`this_week`.
  Изменения SQL после применения — повторный запуск обновлённого `01_install.sql`
  (проверен апгрейд поверх применённой версии). Если 2025/26 уже закрыт —
  `refinalize_season`, чтобы итоги получили новое правило равенства.
* 14 окт.: 2025/26 закрыт в prod владельцем (MVP evilcord/timoor/jcd33,
  MAP player1/evilcord/timoor). **Клиентские +100 убраны сейчас**, бонус на бэке —
  последним этапом. Actions отдают серверные числа; guest_rank сравнивает с
  серверным счётом. Старые getUserRatingScore/totalSumPeriodLichtwatt/totalSumMAX/
  totalSumAVG без +100 — `02_rpc/flutterflow/legacy_no_bonus/`, в CLI как
  `code_only` (только тело, сигнатура FF сохраняется; поиск по ff_key).
  CLI rpc = 27 определений, offline-прогон на снимке прошёл.
* **14 окт. Custom Code перенесён в cloud FF** по команде владельца: 27 определений
  (rpc), FF commit `DfNITw5ZOi0UUiNJGYJ9`; точка отката — предыдущий head
  `cHFs4NMvRwVKaijRjxPw` + снапшоты FF + локальный proto
  `~/.config/pfg-gg-backups/20261013/before-custom-code-20261013-1634.pb`.
  Повторный экспорт после push: все gg* на месте, 4 legacy без +100,
  `flutter analyze lib` — 0 errors. Страницы/привязки не менялись.
* 13 окт., cloud FF по команде владельца (все через CLI, dry-run → apply):
  `dEuMsE7zlabfcUy2lJpK` Clamping scroll на 10 страницах (`scroll_clamp.dart`);
  бэкап-коммит `R4y9nW8NXVos9W4c5xjD` (`snapshot_ui.dart`); привязки GoodGamesPage/
  gamesUserComp/goodGamesPlayersFilters `58Ruiqme2MJr8EdH1Rpw` (`push_bindings.dart`;
  ошибка: одинаковые ключи узлов блока) → исправлено `40RYz73YkULIq4FSJ0zc` +
  rebuild после блока `vT1fhtFa4Y8sF9qQPjjc` (`fix_block_keys.dart`);
  медали под ASCII-именами `nuveM669TOKabK5CTHSL` (`rename_medal_assets.dart`,
  оригиналы из ~/Downloads, байт в байт); ggIsLastPlayer `Qhov2orwBfP99ZbD8ayN`;
  разделитель внутри строки `uVhDpUkAO94rpjbxwPFX` (`row_divider.dart`).
  Далее (13 окт., вечер): строка 77 `SYYKkJGFtTHHeqG34S5W`, линия рядом с полосой
  `s2QKd5plf88WoeVO8hXo`, без линии под последней `C6KcZVoodR64pN5Xz0gp`,
  de_DE формат чисел `SYNvtPRUeVFwPGXxiUNX`, функции ggTopPlayerIds/ggShowMeRow/
  ggHasMore `LeO2ZDCk1FayFMHJP9mW`, GoodGames legacy→RPC (подиум, список, «я»,
  Meine Games, пагинация) `e3RKTAAUXLWQ2s1wYirZ`, один refresh в On Load
  `8uHQyk1EYL0YAuQf5P1C`; профиль (страница+диалог, гость через ggGuest/ggPlace)
  `3towXgPwCLZtkiaJSDXs` + int-период диалога `VjXXlc6QjKFJidVlcXRd`; ggPlace
  (без очков → после всех активных) `dYaWVZ6csNMRM4RZsQWY`; Home место через RPC
  `NTdMtYKWLuxEc1Q3hxXY`; inviteUser/gamesCount с test `AxfgH5Bx5PJy91mIONPS`.
  Workspace `/private/tmp/ff-ai-pfg-ready-20261013` повреждён (SDK вычищен),
  новый — `/private/tmp/ff-ai-pfg-20261013b`.
  13–14 окт.: Good News постранично (10 + догрузка детектором, listener `posts`)
  `YzpcvzbsJBM3Y2YefYuj` (`posts_paging.dart`), кэш сессии внутри ggPostsPage
  `O7t9tphuw7S5esn6qlpE` (`posts_memo.dart`; App State не умеет List<PostsRow> —
  генерирует `RowRow`); подиум из RPC, −6 запросов users
  `ETl1YsfiZfJ5a6gLFJo4` (`podium_from_rpc.dart`); +100 фронт: signup_test +
  claim в signInAfterOtpVerification (code_only, `legacy_env/`), RPC пока
  отозван — вызов молча пропускается; GoodGamesPage одна вёрстка для гостя и
  вошедшего `b4eSF8NBK86un5F0851M` (`merge_guest_goodgames.dart`, бэкап JSON в
  `~/.config/pfg-gg-backups/`). Следующие дубли гостя: PlayPage, PlayPaymentPage.
  14 окт.: GoodGames глобальные условия → всегда (ошибка remove_legacy: глобальные
  списки сведены к своим) + `#,##0.#` `iH7B1giZ7m8xVf2XCaAw`; Home gauge из RPC теми же
  формулами (ggHomeGauge; `max_good_power` в `04_home_gauge.sql`, без него берётся
  top_players[0]) `yIoyr38FOMXuAxF02sfc`; периоды Home = GG + Diese Woche, по
  умолчанию season_26_27 `Q3jWiBjYbSDRTi9v4L1s`; energyComp из profile_stats
  (3 периода) `GCIiop4Q5aQuUqzNV7IN`; EnergyPage одна вёрстка `3hcuwRCiR20keA6cxLLd`;
  HomePage одна вёрстка (Invite гостя → authDialog сохранён) `68E6fb1Hci1dBrHkQfso`;
  Home только мои завершённые игры `RdIG5u6l2zPFCJDU61L6`. Неиспользуемые теперь
  компоненты energyCompGuest, homePageGuestContent не удалены (оставлены).
  PlayPage одна вёрстка `hDSenLWquRuEZC9Rr5XS` (ggMe + listener users; тело Scaffold
  по ключу — childPropertyMap.body перепривязан); PlayPaymentPage оставлена с двумя
  ветками (разная логика оплаты). Шрифты по Figma: GG + профиль `nLXx8qbLxgAziW4YrTrl`
  (`figma_text_styles.dart`), Play/оплата/Energy/Home `dezcJXtDthbdR40f3KJ2`
  (`figma_text_styles_2.dart`); сверка — `tools/figma_text_audit.py` (Figma REST,
  токен в ~/.config/figma/env). Не сверены: профиль (остаток), OrganisationPage
  (429), Good News (динамика); не решены «Good €nergy», «Lichtwatt».
* Включение +100 (владелец, SQL): grant claim → `ensure_signup_bonus` backfill →
  `signup_bonus_migrated=true` → `refinalize_season('season_2025_26', false)`.
* Ждёт владельца: FF Settings → Supabase → **Get Schema** (в схеме FF нет
  games.test/invites.test). Затем `test_env_queries.dart`: 27 запросов +
  2 вставки игр; 9 стримов станут обычными запросами (у стрима 1 фильтр).
* Export-коллизия: FF assets с emoji (🥇/🔥/🥈_1.webp) экспортируются одним
  `_1.webp`; для локальных сборок переименовать assets в FF латиницей.
* Порядок: SQL владельцем → сверка цифр через `lib/gg_v2_preview_main.dart`
  на симуляторе → привязки **сразу в FF** (без дублирования в Dart) → Local Run
  FF → оформление current/final → бейджи social/generous → +100 последним.

## Разрешения

Сейчас разрешены локальная подготовка и чтение FF/Supabase. Владелец спрашивает
о порядке подключения, но ещё не дал отдельную команду агенту на cloud-запись.
Не считать вопрос «что можем сделать в FF?» командой на push/SQL Run.
Не stage/commit/push/deploy/удалять исходники. Существующие dirty changes сохранить.
Не запускать других агентов. Изображения/верстку владелец уже добавил сам.

## Решения

* Выбран RPC вариант, оценка16ч, без админки сезонов.
* Категории пока4: valuable, active, generous, social. Правила новых наград
  generous/social ещё ожидаются; не назначать им MVP/MAP бейджи.
* Сначала read RPC + сквозной test. Потом проверка/привязки оформления.
  Перенос стартовых100 в БД последним.
* До миграции100 actions сохраняют клиентские100 в отображении; SQL ledger
  выключен для scoring. Ранги из чистых игр/использованных инвайтов.
  На привязанном JSON Text второй +100 не добавлять.
* В итоге100 входят в MVP/общий Total один раз, по дате регистрации.
  Топ фиксируется в season_results после завершения периода и сверки начислений.
* Предварительный прошлый топ можно читать сразу через RPC без фиксации.
  Финальные награды пока пусты: first-stage guard не позволяет заморозить MVP
  до миграции100. Для проверки Visibility до этого использовать local fixtures;
  не выдавать provisional rank за настоящую награду в prod.
* Исходные даты25/26:20.11.2025–31.08.2026;26/27:01.09.2026–30.06.2027.
  По последнему уточнению новый сезон начинается на следующий день и длится10
  календарных месяцев: следующий01.07.2027–30.04.2028. Это заменяет ежегодный
  сентябрь–июнь. Автопланирование теперь подготовлено и в RPC, без admin UI.
* Final оформление только выбранного завершённого сезона. Для текущего,
  All-Time и месяцев current оформление. Медали берутся из сохранённых awards.
* Список: сезон только его medals; All-Time/месяцы все. Профиль всегда все.
  MVP перед MAP. MVP1 остаётся, даже когда выбран MAP и пользователь rank5.
  Несколько сезонов отображлять Dynamic Children, не схлопывать в6 bool-флагов.
* Profile Punkte per Game сохраняет **сумму €nergy**. Supporters value=1 пока
  старый placeholder; его rank=sponsored_games. Шапка профиля All-Time;
  Stats — выбранный фильтр. Общий Total Good Power All-Time при любом фильтре.

## Сделано локально

- [x] Свежий экспорт cloud FF с используемыми assets:
  `/Users/a123/a123-dev/portfolio-projects/play_for_good/outputs/ff_current_20261013`.
  Export13:10 по времени владельца; старый основной checkout не перезаписан.
- [x] Чтение новых страниц/компонентов и read-only raw asset node.
  Постоянные UI snapshots: `docs/gg_logic/ff_audit_20261013`.
- [x] iteration1 SQL: новая schema/таблицы/RPC/4categories/env/calendar/rollout.
  Готовый `variants/02_rpc/iteration1/01_install.sql`, затем опциональные
  `02_listener.sql`, `03_schedule.sql`. Новая установка без bonus backfill,
  claim grants, бизнес-триггеров/Cron/фиксации.
- [x]3 read actions и12 функций native bindings. Параметры/возвраты в
  `variants/flutterflow_cli/custom_code.json`; код в
  `variants/02_rpc/flutterflow/functions` и локальном lib/custom_code/functions.
- [x] Временное сохранение100 в JSON actions, исходные цифры server_*.
- [x] Локальные games/invites env-чтения всех найденных экранов/диалогов/admin,
  запись games.test/invites.test при создании, getters с default false.
  Cloud UI эти фильтры ещё не получил.
- [x] SQL тесты:6 групп на synthetic PostgreSQL/PGlite прошли, включая позднюю
  фиксацию после включения бонуса только внутри тестовой БД.
- [x] Flutter:21 предыдущий тест +5 новых native bindings прошли.
  Анализ12 функций — без замечаний. Scoped native analyze —0 ошибок,
  warnings/info в экспортированных страницах остаются.
- [x] Live-read CLI dry-run19 определений на revision1791878763960:
  native pages unchanged, cloud push не выполнен.

## Продолжать в этом порядке

### 1. Подключение нового сервера по команде владельца

- [ ] Перед live SQL сверить schema/RLS/триггеры/timezone, существующие gg_v2
  объекты и права установки. Не заменять старые финансовые/Auth функции этим
  пакетом. Сохранить проверяемый исходный deploy state.
- [ ] Применить **iteration1/01_install.sql** через SQL Editor или согласованный
  инструмент. Не применять старые02_backfill/03_finalize/full install.
- [ ] Read-only RPC проверка на существующем prod: оба сезона, All-Time,
  месяцы,4categories, свой/чужой профиль, pagination. p_test=false.
  Сервер возвращает сырые очки, prepared actions дополнительно сохраняют legacy100.
- [ ] Индексы отдельно после EXPLAIN/проверки существующих.
- [ ] По отдельной согласованной активации listener SQL02 и Cron SQL03.
  Cron планирует календарь сейчас, finalization guard остаётся выключенным.

### 2. Custom Code в FF и привязки готового UI

- [ ] Сохранить текущий FF Commit/при возможности рабочую ветку. Получить target
  project/branch ID и backup commit ID до CLI --apply; рабочая копия должна
  содержать свежую вёрстку владельца.
- [ ] Перенести19 подготовленных определений через `prepare.sh rpc` сначала
  fresh dry-run, затем разрешённый --apply. Claim не подключать пока к signup.
- [ ] JSON Page States ggRanking/ggMyStats/ggHistory/ggProfile; OnLoad/Confirm/
  listener/возврат вызывают общие refresh callbacks. Test=Environment.test.
- [ ] Перепривязать Total/очки/места/подписи к action JSON через функции;
  убрать дополнительный+100 только на уже перепривязанном Text.
- [ ] gamesUserComp: JSON playerJson/rankingJson, rating=row.rank, userId=row.user_id;
  medals Visibility=ggHasAward, background/current stripe по ggIsFinalSeason/
  ggRowStyle. Пагинация не использует index+1 в качестве общего места.
- [ ] Подиум top_players; current цифры через ggShowCurrentPlace; final medals
  через final condition+saved awards. Оба user/guest UI читают один ranking JSON.
- [ ] Profile all medals Dynamic Children ggAwards(ggProfile,null), независимо
  от Stats. У всех бейджей нужны category/place/год; текущий fixed bitmap2026
  не становится2027 от изменения JSON. Проверить размещение social icons.
- [ ] Filters: ggPeriodLabel, ggPeriodKey для enum.name aliases; draft/applied
  states отдельно; dirty black/white confirm через ggFiltersChanged.
  Defaults auto/valuable, route periodGames тоже auto.
- [ ] Будущие сезоны без обновления приложения: строить варианты из
  available_periods, а не новых Enum values. Стейты уже String.
- [ ] После проверки всех потребителей отключить глобальные games/invites
  запросы GoodGames/Stats; сохранить users/bio/posts и отдельную историю игр
  организаций открытого пользователя с test. Удалять старые блоки/параметры
  только с явной командой владельца, если это потребуется.
- [ ] Остальные найденные game/invite чтения/создания фильтровать test по QUERY_MAP.

### 3. Проверка владельцем

- [ ] Сравнить preview target `lib/gg_v2_preview_main.dart` и актуальный FF
  Local Run с одним user/периодом/**prod**. Синтетические тесты не заменяют
  реальный RPC/FF проход. Старые формулы/месячные/+100 ошибки могут давать отличия.
- [ ] Отображение medals проверить сначала synthetic JSON/закрытием test
  фикстур локально; готовый prod прошлый топ пока preliminary, не frozen award.
- [ ] После подключений проверить собственную игру/возврат и изменение ранга
  после чужой игры, reconnect/resume, errors,0rank, empty/pagination и фильтры.
- [ ] Создание test игры — позже отдельный сценарий: game.test должен совпасть
  с metadata.stripe_mode/is_live_payment связанных transactions. В самой
  transactions нет test-колонки, дополнительную не добавляли.
- [ ] Перед test приглашениями проверить global email dedup/unique constraints
  InviteUser и live Auth trigger. Новый row.test сохраняется, но registration
  matching сервера требует отдельной проверки, нельзя объявлять его готовым.

### 4. Стартовые100, финальная фиксация

- [ ] Выбрать/проверить происхождение среды старых регистраций и admin create
  уже подтверждённого аккаунта. Auth создаёт users до OTP: только AFTER INSERT
  недостаточно, нужен claim после подтверждения/готового профиля.
- [ ] Backfill подтверждённых аккаунтов по согласованному правилу; один ledger
  бонус по auth.created_at, не игра/инвайт и без увеличения старых balances.
- [ ] Подключить signup env+claim, RLS/idempotency checks, перевести100 на сервер;
  `signup_bonus_migrated=true` выключит временную клиентскую прибавку новых actions.
  В остальных старых экранах тоже убрать соответствующие виртуальные100.
- [ ] Сверить изменившийся по датам MVP/Total, затем разрешить finalization
  и сохранить результаты завершённых сезонов. Только после этого real awards
  начнут проходить новые Visibility условия; Cron дальше фиксирует их один раз.
- [ ] Реальный тест регистрации/повторного входа/переустановки и итогов,
  обновить HANDOFF фактическими cloud версиями/результатами.

## Известные ограничения, которые не потерять

* FF originals medals разные и корректны. При export emoji 🔥/🥈/🥉_1.webp
  нормализуются в `_1.webp`; фактический файл в snapshot сейчас огонь. Не
  исправлять cloud asset-selection по этому имени. Proof raw node сохранён.
* Старые клиенты не фильтруют новые test games. Default false сохраняет прежние
  prod записи/INSERT, но не скрывает будущие test строки из старых SELECT.
  Сейчас проверяем чтение уже существующего prod, без создания test games.
* Основной main.dart/старые gg_* Custom Widget вставки — прошлые черновики.
  Готовая RPC сборка пока отдельный preview target, не native cloud flow.
* План не разрешает серверные/cloud записи. Следующий агент обязан сначала
  проверить последнюю явную команду владельца, а не выполнять unchecked steps.
