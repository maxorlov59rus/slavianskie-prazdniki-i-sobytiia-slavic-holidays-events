# Модуль «Славянские праздники и события» (Slavic Holidays & Events)

Сезонные ивенты для [AzerothCore](https://www.azerothcore.org/) на основе славянского фольклора: Масленица, Купала, Коляда. WoW 3.3.5.

## Праздники

| Праздник | Даты (по умолчанию) | NPC | Жетон |
| :--- | :--- | :--- | :--- |
| 🥞 Масленица | 02-24 … 03-02 | Скоморох Весельчак (990201) | Скомороший блин (990210) |
| 🔥 Купала | 07-04 … 07-10 | Купавка-ведунья (990202) | Купальский венок (990211) |
| ⭐ Коляда | 12-25 … 01-07 | Колядник Старец (990203) | Колядная звезда (990212) |

## Расстановка NPC

Каждый из трёх NPC стоит в трёх локациях (гвиды 991101–991109):

| Локация | Map | Координаты (ориентировочные) |
| :--- | :--- | :--- |
| Даларан, Краеугольный камень | 571 | 5816/5824/5812, 421–429, 215 |
| Штормград, близ канала | 0 | -8853/-8847/-8841, 663–675, 97 |
| Оргриммар, Долина Силы | 1 | 1622/1628/1634, -4369…-4357, 34 |

Координаты ориентировочные — скорректируйте под свой сервер командой `.npc info` / `.go xyz`.

## Квесты (11 событий, все классы и расы)

Квесты 990250–990260, `RequiredClasses`/`RequiredRaces` = любые, минимальный уровень 10, повторяемые. Выдаются и сдаются у праздничных NPC (questgiver-флаг). Требуют жетоны (дроп с монстров).

| # | Квест | Праздник | Цель | Награда |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Прощай, зима! (990250) | Масленица | 10 блинов | деньги + опыт |
| 2 | Блинные горки (990251) | Масленица | 25 блинов | деньги + опыт |
| 3 | Взятие снежной крепости (990252) | Масленица | 40 блинов | **Колпак Блинный** |
| 4 | Огни Купалы (990253) | Купала | 10 венков | деньги + опыт |
| 5 | Плетение венков (990254) | Купала | 25 венков | деньги + опыт |
| 6 | Поиск папоротника (990255) | Купала | 40 венков | **Цветок Папоротника** |
| 7 | Коляда пришла! (990256) | Коляда | 10 звёзд | деньги + опыт |
| 8 | Колядки по домам (990257) | Коляда | 25 звёзд | деньги + опыт |
| 9 | Ряженые в масках (990258) | Коляда | 40 звёзд | **Бубенец Колядника** |
| 10 | Зимнее солнцестояние (990259) | Коляда | 50 звёзд | де��ьги + опыт |
| 11 | Венец праздников (990260) | Все | по 10 жетонов каждого | **Оберег Сварожич** |

Цепочки: Масленица 990250→990251→990252, Купала 990253→990254→990255, Коляда 990256→990257→990258→990259. Итоговый квест 990260 сдаётся любому из трёх NPC.

## Механика

- В активные даты праздника убитые монстры (уровень ≥ `Slavic.TokenDropMinLevel`) с шансом `Slavic.TokenDropChance` роняют **жетон праздника**.
- У праздничного NPC (Даларан, Штормград, Оргриммар) жетоны обмениваются на **косметические награды** (10 жетонов → предмет). Модуль не даёт боевой силы.
- **Геймобъекты-украшения в Даларане:** Чучело Масленицы (990270), Купальский костёр (990271), Колядная ёлка (990272) — при взаимодействии в активный праздник шлют праздничное приветствие.
- **Бонусы праздников:** `Slavic.Bonus.XpPercent` / `Slavic.Bonus.RepPercent` — прибавка к опыту/репутации в активные даты (по умолчанию 0 = выключено; включите, если сервер не против лёгкой прокачки).
- **ГМ-команды:** `.slavic start <maslenitsa|kupala|kolyada>` — принудительный запуск на `Slavic.GMStartDuration` часов; `.slavic stop <имя>`; `.slavic status`.
- Даты настраиваются в конфиге (формат `MM-DD`), поддерживается переход через Новый год (Коляда: 12-25 → 01-07).

## Клиентский аддон «Праздники Азерота»

Аддон для клиента 3.3.5 (папку `addon/Slavic` скопировать в `Interface/AddOns/`):

- **Открытие:** `/slavic` (или `/праздник`).
- Показывает статус всех трёх праздников (гуляет / не активен) и количество жетонов в сумках.
- Протокол: AddonMessage, канал `SLAVIC` — клиент шлёт `REQ`, сервер отвечает `H|id|active|token` ×3, `T|token|count` ×3, `D|1`.
- Локализация окна — по клиентской локали (`ruRU`/прочие), как в Архивариусе.
- Игроки без аддона получают те же данные через чат (gossip NPC, уведомления о дропе).

## Установка

1. Склонируйте модуль в `modules/` ядра:
   ```bash
   git clone <url> modules/slavic-holidays-events
   ```
2. Пересоберите мир: `cd build && cmake ../ -DSCRIPTS=1 -DMODULES=1 && make -j$(nproc)`
3. Примените SQL: таблица `character_slavic_tokens` — в базу `characters`; остальное (NPC, предметы, локали) — в `world`.
4. Скопируйте конфиг: `cp conf/mod_slavic.conf.dist env/dist/etc/mod_slavic.conf`
5. Перезапустите `worldserver`.

## Конфигурация

| Параметр | По умолчанию | Описание |
| :--- | :--- | :--- |
| `Slavic.Enable` | 1 | Включение модуля |
| `Slavic.Locale` | ru | Язык сообщений: `ru` / `en` |
| `Slavic.TokenDropChance` | 3000 | Шанс дропа жетона (из 10000) |
| `Slavic.TokenDropMinLevel` | 10 | Мин. уровень монстра для дропа |
| `Slavic.Maslenitsa.Start/End` | 02-24 / 03-02 | Даты Масленицы |
| `Slavic.Kupala.Start/End` | 07-04 / 07-10 | Даты Купалы |
| `Slavic.Kolyada.Start/End` | 12-25 / 01-07 | Даты Коляды |
| `Slavic.GMStartDuration` | 24 | Длительность ручного запуска (часы) |
| `Slavic.Bonus.XpPercent` | 0 | Бонус опыта в праздники (%) |
| `Slavic.Bonus.RepPercent` | 0 | Бонус репутации в праздники (%) |

## ID контента (резервирование)

Диапазон **990200–990299** (не пересекается с модулем Archivist: 990001, 990101, 990102, 990105). Гвиды спавнов — **991101+** (Archivist использует 991001).

| Сущность | ID |
| :--- | :--- |
| NPC Скоморох / Купавка / Колядник | 990201 / 990202 / 990203 |
| Жетоны (блин / венок / звезда) | 990210 / 990211 / 990212 |
| Награды (колпак, венок, оберег, маска, цветок, бубенец, оберег Сварожич) | 990220–990226 |
| Квесты | 990250–990260 |
| Геймобъекты (чучело / костёр / ёлка) | 990270 / 990271 / 990272 |
| Гвиды спавнов (NPC: Даларан/Штормград/Оргриммар) | 991101–991109 |
| Гвиды спавнов (ГО: Даларан) | 991110–991112 |

Все ID объявлены в одном месте — `src/SlavicMgr.h`; SQL-миграция синхронна и идемпотентна (DELETE перед INSERT).

## Структура

```
slavic-holidays-events/
├── src/
│   ├── SlavicMgr.h/.cpp        # Менеджер: конфиг, даты, активность праздников
│   ├── SlavicAddon.h/.cpp      # Серверный протокол аддона (канал SLAVIC)
│   ├── SlavicStrings.h/.cpp    # Локализация RU/EN
│   └── SlavicScripts.cpp       # Дроп жетонов, NPC-gossip, ГО, .slavic-команды
├── addon/Slavic/               # Клиентский аддон «Праздники Азерота» (3.3.5)
│   ├── Slavic.toc
│   └── Slavic.lua              # Окно: активные праздники, жетоны
├── data/sql/db-world/
│   └── slavic_holidays.sql     # Таблица жетонов, NPC, предметы, квесты, ГО, локали
├── conf/
│   └── mod_slavic.conf.dist    # Конфигурация
└── CMakeLists.txt
```

---

# Slavic Holidays & Events Module (English)

Seasonal events for [AzerothCore](https://www.azerothcore.org/) based on Slavic folklore: Maslenitsa, Kupala, Kolyada. WoW 3.3.5.

## Holidays

| Holiday | Default dates | NPC | Token |
| :--- | :--- | :--- | :--- |
| 🥞 Maslenitsa | 02-24 … 03-02 | Skomorokh the Merry (990201) | Skomorokh Pancake (990210) |
| 🔥 Kupala | 07-04 … 07-10 | Kupavka the Wise (990202) | Kupala Wreath (990211) |
| ⭐ Kolyada | 12-25 … 01-07 | Kolyadnik the Elder (990203) | Kolyada Star (990212) |

## Mechanics

- While a holiday is active, slain monsters (level ≥ `Slavic.TokenDropMinLevel`) drop the **holiday token** with chance `Slavic.TokenDropChance`.
- Trade 10 tokens at a holiday NPC (Dalaran, Stormwind, Orgrimmar) for **cosmetic rewards** — the module grants no combat power.
- **Decoration gameobjects in Dalaran:** Maslenitsa Effigy (990270), Kupala Bonfire (990271), Kolyada Tree (990272).
- **Holiday bonuses:** `Slavic.Bonus.XpPercent` — XP gain during active holidays (0 = off by default).
- **GM commands:** `.slavic start <maslenitsa|kupala|kolyada>`, `.slavic stop <name>`, `.slavic status`.
- Dates are configured in `MM-DD` format; New Year wraparound is supported (Kolyada: 12-25 → 01-07).

## Quests (11 events, all classes and races)

Quests 990250–990260: any class/race, min level 10, repeatable, token objectives.

| # | Quest | Holiday | Objective | Reward |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Farewell, Winter! (990250) | Maslenitsa | 10 pancakes | gold + XP |
| 2 | Pancake Hills (990251) | Maslenitsa | 25 pancakes | gold + XP |
| 3 | Storming the Snow Fortress (990252) | Maslenitsa | 40 pancakes | **Pancake Hat** |
| 4 | Fires of Kupala (990253) | Kupala | 10 wreaths | gold + XP |
| 5 | Weaving Wreaths (990254) | Kupala | 25 wreaths | gold + XP |
| 6 | Seeking the Fern Flower (990255) | Kupala | 40 wreaths | **Fern Flower** |
| 7 | Kolyada Has Come! (990256) | Kolyada | 10 stars | gold + XP |
| 8 | Carols Door to Door (990257) | Kolyada | 25 stars | gold + XP |
| 9 | Mummers in Masks (990258) | Kolyada | 40 stars | **Kolyadnik Bell** |
| 10 | Winter Solstice (990259) | Kolyada | 50 stars | gold + XP |
| 11 | Crown of Holidays (990260) | All | 10 tokens of each | **Svarozhich Amulet** |

## Client addon "Holidays of Azeroth"

Copy `addon/Slavic` to `Interface/AddOns/`. Open with `/slavic`. Shows holiday status and your tokens (addon channel `SLAVIC`). Localized for all client locales.

## Localization (all client locales)

- **Server** — `Slavic.Locale` (ru/en) for chat messages, gossip, GM replies (`src/SlavicStrings.h/.cpp`).
- **Database** — `creature_template_locale`, `item_template_locale`, `quest_template_locale`: ruRU gets Russian, **every other client locale** (enUS, enGB, koKR, frFR, deDE, zhCN, zhTW, esES, esMX) gets English text. Admins can override any language directly in the locale tables.
- **Client addon** — Russian for `ruRU`, English for all other locales.

## Installation

1. Clone into `modules/`:
   ```bash
   git clone <url> modules/slavic-holidays-events
   ```
2. Rebuild: `cd build && cmake ../ -DSCRIPTS=1 -DMODULES=1 && make -j$(nproc)`
3. Apply SQL: `character_slavic_tokens` → `characters` DB; the rest → `world` DB.
4. Copy config: `cp conf/mod_slavic.conf.dist env/dist/etc/mod_slavic.conf`
5. Restart `worldserver`.

## Configuration

| Option | Default | Description |
| :--- | :--- | :--- |
| `Slavic.Enable` | 1 | Enable the module |
| `Slavic.Locale` | ru | Server message language: `ru` / `en` |
| `Slavic.TokenDropChance` | 3000 | Token drop chance (out of 10000) |
| `Slavic.TokenDropMinLevel` | 10 | Min monster level for token drops |
| `Slavic.Maslenitsa.Start/End` | 02-24 / 03-02 | Maslenitsa dates |
| `Slavic.Kupala.Start/End` | 07-04 / 07-10 | Kupala dates |
| `Slavic.Kolyada.Start/End` | 12-25 / 01-07 | Kolyada dates |
| `Slavic.GMStartDuration` | 24 | Manual start duration (hours) |
| `Slavic.Bonus.XpPercent` | 0 | XP bonus during holidays (%) |
| `Slavic.Bonus.RepPercent` | 0 | Reputation bonus (reserved) |

## Content ID reservation

Range **990200–990299** (no overlap with the Archivist module: 990001, 990101, 990102, 990105). Spawn guids **991101+**.

| Entity | IDs |
| :--- | :--- |
| NPCs (Skomorokh / Kupavka / Kolyadnik) | 990201 / 990202 / 990203 |
| Tokens (pancake / wreath / star) | 990210 / 990211 / 990212 |
| Rewards | 990220–990226 |
| Quests | 990250–990260 |
| Gameobjects (effigy / bonfire / tree) | 990270–990272 |
| Spawn guids (NPC) | 991101–991109 |
| Spawn guids (gameobjects) | 991110–991112 |
