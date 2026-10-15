# Привязки к новой вёрстке FF, 13 октября

Свежий код с assets выгружен без записи в облако:
`outputs/ff_current_20261013/`, manifest exported_at=2026-10-13T08:10:24Z.
Проект Players For Good, ID play-for-good-o0lpcq. CLI dry-run позже читает
revision1791878763960. Основные старые lib/pages не перезаписаны этой копией.
Выгрузка является снимком; никакие привязки в ней не изменены этим чатом.

## Что уже есть и что исправить

* GoodGamesPage: новый заголовок, лого, Total, варианты подиума, фильтры, медали.
  Total в обоих user/guest ветках ещё literal **12.560**.
* Period enum уже имеет season_26_27, season_25_26, all_time; state страниц и
  callback фильтров остаются **String**, enum передаётся через `.name`.
  Не требуется менять тип на Enum. Короткие имена принимаются новой SQL/парсером.
* userProfilePage: infoStatsPeriod default **gesamt**; подпись выводит сырой key.
  Stats пока literal100/0/0/1 и места3/5/12/1. New Row показывает две картинки,
  пока без условий; произвольный победитель MVP2/3 ими не покрывается.
* gamesUserComp: фон/паддинг/полоска завязаны на **period==season_25_26**.
  Медали — на rating1/2/3 AND текущую category. Это не сохранённые награды.
  Нужно заменить условия, иначе MVP исчезает в MAP и новый завершённый сезон
  не получает финальное оформление.
* В Generator строки rating=**index+1**; на второй странице снова будет1.
  В новой привязке использовать серверный `row.rank`, не индекс страницы.
* Подиум: значки вариантов добавлены, пока без Visibility. Их текущий/final
  режим отделить от award. Свои/гостевые ветки использовать один RPC JSON.
* Фильтры goodGamesPlayersFilters и userProfileFilters: галочка пока всегда
  alternate/primaryText, нет dirty-color. Confirm callback уже имеется.
* Social Row профиля в текущем снимке остаётся после bio. Перенос в верхнюю
  часть из исходного ТЗ отдельно проверить/сделать вручную, если ещё нужен.

## Проверка совпадающих имён картинок

По raw-параметрам cloud node Image_nzqe916o в gamesUserComp правильная ссылка:
`projects/play-for-good-o0lpcq/assets/pnf9mgo4ojsw/🥈_1.webp`.
В code export она стала `assets/images/_1.webp`; в этом файле сейчас огонь.
Скрин владельца подтверждает разные 🔥/🥉/🥇/🥈_1.webp. Это **коллизия экспортных
имён**, не доказательство неверного выбора картинки в FF. Не заменять cloud
медали огнём по именам из Dart. Для корректного локального визуального теста
понадобятся различимые экспортные имена либо отдельное исправление snapshot;
облачные assets этим чатом не переименовывались/не перезаписывались.
Функции Visibility используют category/place/season, не имя bitmap.

## Actions: загрузить данные один раз и читать их виджетами

Порядок SQL — [iteration1](iteration1/README.md), а не ранние deploy файлы.
После отдельного разрешения на установку сервера/перенос Custom Code:

| Где | Вызов → Page State JSON |
|---|---|
| GoodGamesPage рейтинг | ggV2Rankings(periodPageUser,valuePageUser,pageNumberUsers,limit,currentUserUid/null,Environment.test) → ggRanking |
| Meine Games зарегистрированного | ggV2ProfileStats(currentUserUid,periodPageGame,Environment.test) → ggMyStats |
| Meine Games история | ggV2Games(currentUserUid,periodPageGame,valuePageGame,pageNumberGames,limit,Environment.test) → ggHistory |
| userProfilePage и диалог userProfile | ggV2ProfileStats(page.userId,infoStatsPeriod,Environment.test) → ggProfile |

Guest userId='guest' не отправлять как UUID; рейтинг гостя userId=null,
личный гостевой экран сохраняет прежний flow. У чужого профиля page.userId,
не currentUserUid. Новый JSON уже содержит legacy100 в первом этапе: на Text
не прибавлять100 второй раз. На остальных ещё не переключённых экранах прежняя
формула остаётся до последнего бонусного этапа.

Вызовы выполняются при открытии, подтверждении фильтра, переключении вкладки,
pagination/возврате. GgStatsListener.onRefresh запускает тот же action block.
Loading до успешного JSON, error с сохранением предыдущего результата.
Существующий новый макет остаётся native, панели Custom Widget не импортировать.

## Custom Functions, готовые к копированию / CLI

Каждая в `02_rpc/flutterflow/functions/<имя_файла>.dart` и локальном
`lib/custom_code/functions`. Метаданные параметров записаны в
`flutterflow_cli/custom_code.json`; в FF JSON nullable там, где указано `?`.
RPC пакет теперь **19 определений**: прежние7 + следующие12 функций.
Claim бонуса есть в комплекте, но ещё не подключать к action flow.

| Функция | Параметры FF | Возврат / назначение |
|---|---|---|
| ggPeriodKey | value String? | String: enum.name/alias → серверный key |
| ggPeriodLabel | value String?, response JSON? | String: красивое название, будущие сезоны из available_periods |
| ggTotalPower | response JSON? | Double: глобальный All-Time Total из action JSON |
| ggMetricValue | response JSON?, metric String, allTime Bool | Double: Stats/шапка/score строки |
| ggMetricRank | response JSON?, metric String, allTime Bool | Integer: соответствующий rank;0 если нет места |
| ggIsFinalSeason | ranking JSON? | Boolean: финальный макет только завершённого выбранного сезона |
| ggHasAward | player JSON?, category String, place Integer, season String? | Boolean: сохранённая медаль, независимо от текущего rank/сортировки |
| ggShowCurrentPlace | ranking JSON?, player JSON?, category String, place Integer | Boolean: цифра текущего подиума MVP/MAP1/2/3 |
| ggRowStyle | ranking JSON?, player JSON? | String: final_first/second/third, current_first/second/third, none |
| ggPlayerRow | ranking JSON?, userId String? | JSON: найти строку в players/top_players/current_user;{} если не загружена |
| ggAwards | player JSON?, season String? | List JSON: все/сезонные награды, MVP перед MAP, новые сезоны первыми |
| ggFiltersChanged | selectedPeriod/appliedPeriod/selectedCategory/appliedCategory String? | Boolean: изменён хотя бы один фильтр; известные aliases сравниваются одинаково |

Функции **не запускают запросы к БД и не считают заново все игры**. Они выбирают
число/место/награду из ответа RPC и парсят подписи. Следующую страницу/users вне
загруженного JSON ggPlayerRow не подгружает; для своего игрока вне списка RPC
возвращает current_user. В обычном Generator передавать текущий JSON item сразу.

## Конкретные Text/Stats привязки

| Widget | Function / источник |
|---|---|
| GoodGames Total, оба12.560 | ggTotalPower(ggRanking), формат числа через существующий FF formatter |
| Плашка года | ggRanking.$.period.season_year; год внутри bitmap автоматически не меняется, нужен отдельный Text/asset variant |
| Подпись периода Stats | ggPeriodLabel(infoStatsPeriod,ggProfile) |
| Шапка личного/чужого профиля GP | ggMetricValue(ggProfile,'good_power',true) |
| Rank в шапке | ggMetricRank(ggProfile,'good_power',true) |
| Stats Total Good Power | ggMetricValue(ggProfile,'good_power',false) / ggMetricRank(...,'good_power',false) |
| Stats Punkte per Game | metric **good_energy**, allTime=false: сохраняется сумма €nergy по решению владельца |
| Stats Good Games | metric **games**, allTime=false |
| Stats Supporters | value прежняя1; место metric **sponsored_games**, allTime=false |
| Строка таблицы число/место | ggMetricValue(playerJson,'score',false) / ggMetricRank(playerJson,'score',false) |
| Meine GP/место | ggMyStats Stats good_power; средние good_power_per_game/good_energy_per_game — отдельные metrics |
| Meine список | ggGamesRows(ggHistory) → существующий gamesOrgComp |

На UI rank0 означает **нет места**, скрыть bubble либо вывести «—», не#0.
Общий Total не зависит от фильтра. Личная Stats зависит; шапка профиля All-Time.

## gamesUserComp и медали списка

В component добавить nullable JSON `playerJson` и `rankingJson`; оставить прежние
параметры до завершения перепривязки. Generator: `ggRanking.$.players`, item →
playerJson, root ggRanking → rankingJson. userId=item.user_id; rating=item.rank;
value=ggRanking.category. Именем/фото можно пользоваться прямо из item, без
дополнительного Users Query на каждую строку. Для своей строки — current_user.

| Иконка / cloud node | Visibility |
|---|---|
| Кубок MVP1 / Image_0vehu90a | ggHasAward(playerJson,'valuable',1,null) |
| Серебро MVP2 / Image_nzqe916o | ggHasAward(playerJson,'valuable',2,null) |
| Бронза MVP3 / Image_htydfn2a | ggHasAward(playerJson,'valuable',3,null) |
| Огонь MAP1 / Image_xxzxnlnx | ggHasAward(playerJson,'active',1,null) |
| Серебряный огонь MAP2 / Image_8c1rk6o5 | ggHasAward(playerJson,'active',2,null) |
| Бронзовый огонь MAP3 / Image_4yiaiipt | ggHasAward(playerJson,'active',3,null) |

Условия независимые: игрок может одновременно иметь MVP и MAP. Их порядок
в Row уже правильный (MVP раньше MAP). Не использовать ELSE IF/выбранную
category для определения medals. RPC **уже фильтрует awards** строк: сезон только
свой, All-Time/оба месяца все сохранённые. Null в season не отменяет серверный
фильтр и не добавляет другие сезоны.

Для нескольких сезонов использовать Dynamic Children по ggAwards(playerJson,null),
а внутри выбрать asset по item.badge/category/place и вывести item.season_year.
Шесть фиксированных Visibility показывают наличие типа, но схлопнут две награды
одного типа из разных сезонов — это не полное отображение всех бейджей клиента.
Профиль всегда Dynamic Children `ggAwards(ggProfile,null)`, без Stats фильтра.
Текущие bitmap профиля содержат2026: для следующих лет потребуется Text/другой
asset, функция не может изменить год, нарисованный на самой картинке.

## Выделение строк

Заменить проверку period==season_25_26 на ggIsFinalSeason(rankingJson).
Само место брать playerJson.rank, независимо от MVP/MAP: это ранг выбранной
категории. Можно использовать ggRowStyle:

* final_first/second/third → существующие Theme first/second/third цвета фона.
* current_first/second/third → нейтральный фон, существующие primary/error/primary30
  цвета левой полоски. Видимость полоски = !ggIsFinalSeason.
* none → обычный фон, без цветной отметки. Паддинг/углы оставить как сверстано,
  но condition брать из final/rank вместо жёсткого названия сезона/index.

Это оформление позиции в выбранном рейтинге. Бейджи в той же строке могут быть
от другого рейтинга, например MVP1 у MAP5: row не выделяется как MAP1, но кубок
остаётся видимым.

## Подиум

Аватары/переходы: `ggRanking.$.top_players[0/1/2]`, порядок на экране2–1–3.
Текущие числа: ggShowCurrentPlace(ggRanking,podiumPlayer,'valuable'/'active',place).
Final trophy/medal/flame: ggIsFinalSeason(ggRanking) AND
ggHasAward(podiumPlayer,category,place,null). Для боковой позиции place2/3,
центра1. Не показывать все альтернативные images одновременно.
Подиум пуст/короче3 — скрыть недостающие места, не подставлять случайного user.
Generous/social пока сохраняются как категории, медальные правила для них
не придуманы: специфичные MVP/MAP текущие маркеры им не подставлять.

## Фильтры / стартовый сезон

Старт periodPageUser/periodPageGame/infoStatsPeriod=auto, category=valuable;
route default periodGames тоже auto. После ответа сохранить `period.key` как
применённый key для radio/dirty. Текущие enum shortnames сравнивать через
ggPeriodKey по обе стороны условия; так season_26_27 и season_2026_27 равны.
Если нужны будущие фильтры без выпуска новой версии — создавать строки из
available_periods вместо фиксированных enum-значений (String states позволяют).

В bottom sheet не менять applied state до Confirm. Dirty:
ggFiltersChanged(periodState,widget.period,valueState,widget.value).
В userProfileFilters category=null с обеих сторон. При true fillColor=чёрный,
iconColor=белый; при false старые цвета. OnConfirm: callback → сохранить period/
category, сбросить pagination=1, перечитать RPC. X/back сохраняет прежний фильтр.

## Проверки и оставшиеся действия

Подготовлено12 функций+3 read actions+адаптер/listener.5 тестов новых привязок
прошли; до них21 тест расчётов/бонусного перехода/среды/scroll — прошёл.
SQL iteration1:6 групп проверок прошли на синтетическом PostgreSQL/PGlite.
Read-only CLI dry-run19 определений прошёл на текущем cloud revision; страницы
не изменились. Это подготовка Custom Code, **не подключение native UI**.

Следом: разрешённая установка SQL, проверка RPC на готовых prod-данных, перенос
Custom Code по CLI после отдельной команды, ручные привязки этих widgets,
проверка фильтров/мест/наград/среды в сборке. Финальные awards пусты до последнего
бонусного этапа/включения фиксации. Уже свёрстанные assets сохранять.
