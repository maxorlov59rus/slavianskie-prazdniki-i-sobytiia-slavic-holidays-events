-- ------------------------------------------------------------
-- Модуль «Славянские праздники и события» (slavic-holidays-events)
-- Миграция БД: счётчики жетонов, праздничные NPC, предметы.
-- База: characters (таблица) + world (NPC/предметы)
-- ------------------------------------------------------------

SET @NPC_MASLENITSA := 990201; -- Скоморох Весельчак
SET @NPC_KUPALA     := 990202; -- Купавка-ведунья
SET @NPC_KOLYADA    := 990203; -- Колядник Старец
SET @TOKEN_MASLENITSA := 990210; -- Скомороший блин
SET @TOKEN_KUPALA     := 990211; -- Купальский венок
SET @TOKEN_KOLYADA    := 990212; -- Колядная звезда
SET @ITEM_HAT    := 990220; -- Колпак Блинный
SET @ITEM_WREATH := 990221; -- Венок Купальский
SET @ITEM_AMULET := 990222; -- Оберег Звёздный
SET @ITEM_MASK   := 990223; -- Маска Медведя
SET @ITEM_FLOWER := 990224; -- Цветок Папоротника
SET @ITEM_BELL   := 990225; -- Бубенец Колядника
SET @ITEM_SVAROG := 990226; -- Оберег Сварожич (награда итогового квеста)
SET @GO_EFFIGY  := 990270; -- Чучело Масленицы (геймобъект)
SET @GO_BONFIRE := 990271; -- Купальский костёр (геймобъект)
SET @GO_TREE    := 990272; -- Колядная ёлка (геймобъект)
SET @GUID_MASLENITSA := 991101; -- Даларан
SET @GUID_KUPALA     := 991102; -- Даларан
SET @GUID_KOLYADA    := 991103; -- Даларан
SET @GUID_MASLENITSA_SW := 991104; -- Штормград
SET @GUID_KUPALA_SW     := 991105; -- Штормград
SET @GUID_KOLYADA_SW    := 991106; -- Штормград
SET @GUID_MASLENITSA_OG := 991107; -- Оргриммар
SET @GUID_KUPALA_OG     := 991108; -- Оргриммар
SET @GUID_KOLYADA_OG    := 991109; -- Оргриммар
SET @GUID_GO_EFFIGY  := 991110; -- ГО: чучело (Даларан)
SET @GUID_GO_BONFIRE := 991111; -- ГО: костёр (Даларан)
SET @GUID_GO_TREE    := 991112; -- ГО: ёлка (Даларан)

-- ------------------------------------------------------------
-- 1. Таблица собранных жетонов (статистика для будущих достижений)
-- База: characters
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `character_slavic_tokens` (
  `guid`       INT UNSIGNED NOT NULL COMMENT 'Guid персонажа',
  `item_entry` INT UNSIGNED NOT NULL COMMENT 'Entry жетона',
  `earned`     INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Всего собрано',
  PRIMARY KEY (`guid`, `item_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Славянские праздники: жетоны';

-- ------------------------------------------------------------
-- 2. Предметы: жетоны (quest-предметы, Quality uncommon)
-- База: world
-- ------------------------------------------------------------
DELETE FROM `item_template` WHERE `entry` IN (@TOKEN_MASLENITSA, @TOKEN_KUPALA, @TOKEN_KOLYADA,
  @ITEM_HAT, @ITEM_WREATH, @ITEM_AMULET, @ITEM_MASK, @ITEM_FLOWER, @ITEM_BELL, @ITEM_SVAROG);

INSERT INTO `item_template`
  (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `Flags`,
   `FlagsExtra`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`, `AllowableRace`,
   `ItemLevel`, `RequiredLevel`, `StatsCount`, `stackable`, `ContainerSlots`, `bonding`,
   `description`, `Material`, `sheath`, `RandomProperty`, `RandomSuffix`, `block`, `itemset`,
   `MaxDurability`, `area`, `Map`, `BagFamily`, `TotemCategory`, `socketColor_1`, `socketContent_1`,
   `socketColor_2`, `socketContent_2`, `socketColor_3`, `socketContent_3`, `socketBonus`, `GemProperties`,
   `RequiredDisenchantSkill`, `ArmorDamageModifier`, `Duration`, `ItemLimitCategory`, `HolidayId`,
   `ScriptName`, `DisenchantID`, `FoodType`, `minMoneyLoot`, `maxMoneyLoot`, `flagsCustom`)
VALUES
  (@TOKEN_MASLENITSA, 12, 0, -1, 'Скомороший блин', 30715, 2, 0, 0, 1, 0, 0, 0, -1, -1, 1, 1, 0, 20, 0, 1,
   'Ароматный, с пылу с жару. Скоморохи принимают их охотно.', 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   -1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0),
  (@TOKEN_KUPALA, 12, 0, -1, 'Купальский венок', 33093, 2, 0, 0, 1, 0, 0, 0, -1, -1, 1, 1, 0, 20, 0, 1,
   'Плетённый из полевых трав и огненных цветов.', 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   -1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0),
  (@TOKEN_KOLYADA, 12, 0, -1, 'Колядная звезда', 34422, 2, 0, 0, 1, 0, 0, 0, -1, -1, 1, 1, 0, 20, 0, 1,
   'Серебристая звёздочка на витом шнурке.', 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   -1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0),
  (@ITEM_HAT, 4, 1, -1, 'Колпак Блинный', 35549, 3, 0, 0, 1, 0, 0, 1, -1, -1, 1, 1, 0, 1, 0, 1,
   'Пахнет маслом и весельем. Смотри, не съел бы кто.', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   -1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0),
  (@ITEM_WREATH, 4, 1, -1, 'Венок Купальский', 35593, 3, 0, 0, 1, 0, 0, 1, -1, -1, 1, 1, 0, 1, 0, 1,
   'Тёплый от костров Купальской ночи.', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   -1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0),
  (@ITEM_AMULET, 4, 1, -1, 'Оберег Звёздный', 35585, 3, 0, 0, 1, 0, 0, 1, -1, -1, 1, 1, 0, 1, 0, 1,
   'Звенит тихо, будто поёт колядку.', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   -1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0),
  (@ITEM_MASK, 15, 0, -1, 'Маска Медведя', 30613, 3, 0, 0, 1, 0, 0, 0, -1, -1, 1, 1, 0, 1, 0, 1,
   'Рычать в ней удобно, веселиться — ещё лучше.', 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   -1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0),
  (@ITEM_FLOWER, 15, 0, -1, 'Цветок Папоротника', 30613, 4, 0, 0, 1, 0, 0, 0, -1, -1, 1, 1, 0, 1, 0, 1,
   'Тот самый, что цветёт лишь в Купальскую полночь. Не светится... почти.', 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   -1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0),
  (@ITEM_BELL, 15, 0, -1, 'Бубенец Колядника', 30613, 3, 0, 0, 1, 0, 0, 0, -1, -1, 1, 1, 0, 1, 0, 1,
   'Динь-динь-динь! Коляда пришла!', 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   -1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0),
  (@ITEM_SVAROG, 4, 1, -1, 'Оберег Сварожич', 35585, 4, 0, 0, 1, 0, 0, 1, -1, -1, 1, 1, 0, 1, 0, 1,
   'Солнечный колёсный оберег. Благословение всех трёх праздников.', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   -1, 0, 0, 0, 0, '', 0, 0, 0, 0, 0);

-- ------------------------------------------------------------
-- 3. Праздничные NPC (единый скрипт SlavicNPCScript)
-- База: world
-- ------------------------------------------------------------
DELETE FROM `creature_template` WHERE `entry` IN (@NPC_MASLENITSA, @NPC_KUPALA, @NPC_KOLYADA);
INSERT INTO `creature_template`
  (`entry`, `difficulty_entry_1`, `difficulty_entry_2`, `difficulty_entry_3`, `KillCredit1`, `KillCredit2`,
   `name`, `subname`, `IconName`, `gossip_menu_id`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`,
   `speed_walk`, `speed_run`, `scale`, `rank`, `dmgschool`, `DamageModifier`, `BaseAttackTime`,
   `RangeAttackTime`, `BaseVariance`, `unit_class`, `unit_flags`, `unit_flags2`, `dynamicflags`,
   `family`, `trainer_type`, `trainer_spell`, `trainer_class`, `trainer_race`, `type`, `type_flags`,
   `lootid`, `pickpocketloot`, `skinloot`, `resistance1`, `resistance2`, `resistance3`, `resistance4`,
   `resistance5`, `resistance6`, `spell1`, `spell2`, `spell3`, `spell4`, `PetSpellDataId`, `mingold`,
   `maxgold`, `AIName`, `MovementType`, `InhabitType`, `HoverHeight`, `HealthModifier`, `ManaModifier`,
   `ArmorModifier`, `RacialLeader`, `movementId`, `RegenHealth`, `mechanic_immune_mask`,
   `spell_school_immune_mask`, `flags_extra`, `ScriptName`, `VerifiedBuild`)
VALUES
  (@NPC_MASLENITSA, 0, 0, 0, 0, 0, 'Скоморох Весельчак', 'Гонец Масленицы', NULL, 0, 80, 80, 0, 35, 1,
   1, 1.14286, 1, 0, 0, 1, 2000, 2000, 0, 1, 2, 2048, 2, 0, 0, 0, 0, 0, 7, 138936390, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 1, 25000, 25000, 1, 0, 0, 1, 0, 0, 2,
   'SlavicNPCScript', 0),
  (@NPC_KUPALA, 0, 0, 0, 0, 0, 'Купавка-ведунья', 'Хозяйка Купальской ночи', NULL, 0, 80, 80, 0, 35, 1,
   1, 1.14286, 1, 0, 0, 1, 2000, 2000, 0, 1, 2, 2048, 2, 0, 0, 0, 0, 0, 7, 138936390, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 1, 25000, 25000, 1, 0, 0, 1, 0, 0, 2,
   'SlavicNPCScript', 0),
  (@NPC_KOLYADA, 0, 0, 0, 0, 0, 'Колядник Старец', 'Хранитель Коляды', NULL, 0, 80, 80, 0, 35, 1,
   1, 1.14286, 1, 0, 0, 1, 2000, 2000, 0, 1, 2, 2048, 2, 0, 0, 0, 0, 0, 7, 138936390, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 3, 1, 25000, 25000, 1, 0, 0, 1, 0, 0, 2,
   'SlavicNPCScript', 0);

-- ------------------------------------------------------------
-- 4. Спавны: Даларан (Краеугольный камень), Штормград (близ канала),
--    Оргриммар (Долина Силы). Координаты ориентировочные, поправьте под сервер.
-- База: characters
-- ------------------------------------------------------------
-- npcflag: gossip (1) + questgiver (2) — NPC выдают и принимают квесты.
DELETE FROM `creature` WHERE `guid` IN (@GUID_MASLENITSA, @GUID_KUPALA, @GUID_KOLYADA,
  @GUID_MASLENITSA_SW, @GUID_KUPALA_SW, @GUID_KOLYADA_SW,
  @GUID_MASLENITSA_OG, @GUID_KUPALA_OG, @GUID_KOLYADA_OG);
INSERT INTO `creature` (`guid`, `id1`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`,
  `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`,
  `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`,
  `dynamicflags`, `VerifiedBuild`)
VALUES
  (@GUID_MASLENITSA, @NPC_MASLENITSA, 571, 4395, 4395, 1, 1, 0, 5816.0, 421.0, 215.0, 2.5, 300, 0, 0, 1, 0, 0, 3, 0, 0, 0),
  (@GUID_KUPALA,     @NPC_KUPALA,     571, 4395, 4395, 1, 1, 0, 5824.0, 429.0, 215.0, 2.5, 300, 0, 0, 1, 0, 0, 3, 0, 0, 0),
  (@GUID_KOLYADA,    @NPC_KOLYADA,    571, 4395, 4395, 1, 1, 0, 5812.0, 429.0, 215.0, 2.5, 300, 0, 0, 1, 0, 0, 3, 0, 0, 0),
  (@GUID_MASLENITSA_SW, @NPC_MASLENITSA, 0, 1519, 1519, 1, 1, 0, -8853.0, 663.0, 97.0, 5.4, 300, 0, 0, 1, 0, 0, 3, 0, 0, 0),
  (@GUID_KUPALA_SW,     @NPC_KUPALA,     0, 1519, 1519, 1, 1, 0, -8847.0, 669.0, 97.0, 5.4, 300, 0, 0, 1, 0, 0, 3, 0, 0, 0),
  (@GUID_KOLYADA_SW,    @NPC_KOLYADA,    0, 1519, 1519, 1, 1, 0, -8841.0, 675.0, 97.0, 5.4, 300, 0, 0, 1, 0, 0, 3, 0, 0, 0),
  (@GUID_MASLENITSA_OG, @NPC_MASLENITSA, 1, 1637, 1637, 1, 1, 0, 1622.0, -4369.0, 34.0, 3.0, 300, 0, 0, 1, 0, 0, 3, 0, 0, 0),
  (@GUID_KUPALA_OG,     @NPC_KUPALA,     1, 1637, 1637, 1, 1, 0, 1628.0, -4363.0, 34.0, 3.0, 300, 0, 0, 1, 0, 0, 3, 0, 0, 0),
  (@GUID_KOLYADA_OG,    @NPC_KOLYADA,    1, 1637, 1637, 1, 1, 0, 1634.0, -4357.0, 34.0, 3.0, 300, 0, 0, 1, 0, 0, 3, 0, 0, 0);

-- ------------------------------------------------------------
-- 5. Локализация имён NPC (клиенты enUS/enGB увидят английские имена)
-- База: world
-- ------------------------------------------------------------
DELETE FROM `creature_template_locale` WHERE `entry` IN (@NPC_MASLENITSA, @NPC_KUPALA, @NPC_KOLYADA);
INSERT INTO `creature_template_locale` (`entry`, `locale`, `Name`, `Title`, `VerifiedBuild`)
VALUES
  (@NPC_MASLENITSA, 'enUS', 'Skomorokh the Merry', 'Herald of Maslenitsa', 0),
  (@NPC_MASLENITSA, 'enGB', 'Skomorokh the Merry', 'Herald of Maslenitsa', 0),
  (@NPC_MASLENITSA, 'ruRU', 'Скоморох Весельчак', 'Гонец Масленицы', 0),
  (@NPC_KUPALA, 'enUS', 'Kupavka the Wise', 'Keeper of the Kupala Night', 0),
  (@NPC_KUPALA, 'enGB', 'Kupavka the Wise', 'Keeper of the Kupala Night', 0),
  (@NPC_KUPALA, 'ruRU', 'Купавка-ведунья', 'Хозяйка Купальской ночи', 0),
  (@NPC_KOLYADA, 'enUS', 'Kolyadnik the Elder', 'Warden of Kolyada', 0),
  (@NPC_KOLYADA, 'enGB', 'Kolyadnik the Elder', 'Warden of Kolyada', 0),
  (@NPC_KOLYADA, 'ruRU', 'Колядник Старец', 'Хранитель Коляды', 0);

-- Полная поддержка всех клиентских локалей: не-ruRU получают английские имена.
INSERT INTO `creature_template_locale` (`entry`, `locale`, `Name`, `Title`, `VerifiedBuild`)
SELECT `entry`, t.loc, `Name`, `Title`, 0
FROM `creature_template_locale`
CROSS JOIN (SELECT 'koKR' AS loc UNION SELECT 'frFR' UNION SELECT 'deDE' UNION SELECT 'zhCN'
            UNION SELECT 'zhTW' UNION SELECT 'esES' UNION SELECT 'esMX') t
WHERE `locale` = 'enUS'
  AND `entry` IN (@NPC_MASLENITSA, @NPC_KUPALA, @NPC_KOLYADA);

-- ------------------------------------------------------------
-- 5.5 Квесты: 10 событий для всех классов и рас (990250-990259).
-- Требования: MinLevel 10, RequiredClasses/Races = 0 (любые),
-- SpecialFlags = 1 (повторяемые на время праздника).
-- Жетоны добываются дропом с монстров (см. SlavicPlayerScript).
-- База: world
-- ------------------------------------------------------------
DELETE FROM `quest_template` WHERE `entry` BETWEEN 990250 AND 990260;
DELETE FROM `creature_queststarter` WHERE `quest` BETWEEN 990250 AND 990260;
DELETE FROM `creature_questender` WHERE `quest` BETWEEN 990250 AND 990260;

-- Квесты выдаются и сдаются у соответствующих праздничных NPC.
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
  (@NPC_MASLENITSA, 990250), (@NPC_MASLENITSA, 990251), (@NPC_MASLENITSA, 990252),
  (@NPC_KUPALA, 990253), (@NPC_KUPALA, 990254), (@NPC_KUPALA, 990255),
  (@NPC_KOLYADA, 990256), (@NPC_KOLYADA, 990257), (@NPC_KOLYADA, 990258), (@NPC_KOLYADA, 990259),
  (@NPC_MASLENITSA, 990260), (@NPC_KUPALA, 990260), (@NPC_KOLYADA, 990260);

INSERT INTO `creature_questender` (`id`, `quest`) VALUES
  (@NPC_MASLENITSA, 990250), (@NPC_MASLENITSA, 990251), (@NPC_MASLENITSA, 990252),
  (@NPC_KUPALA, 990253), (@NPC_KUPALA, 990254), (@NPC_KUPALA, 990255),
  (@NPC_KOLYADA, 990256), (@NPC_KOLYADA, 990257), (@NPC_KOLYADA, 990258), (@NPC_KOLYADA, 990259),
  (@NPC_MASLENITSA, 990260), (@NPC_KUPALA, 990260), (@NPC_KOLYADA, 990260);

-- --- Масленица: цепочка Скомороха ---
INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `MaxLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `PrevQuestId`, `NextQuestId`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`, `Title`, `Objectives`, `OfferRewardText`,
   `RequestItemsText`, `EndText`)
VALUES
  (990250, 2, 10, 0, 10, 0, 0, 0, 1, 0, 990251, 5, 100000,
   @TOKEN_MASLENITSA, 10,
   'Прощай, зима!',
   'Соберите 10 Скомороших блинов (дропаются с монстров).',
   'Ах, гость дорогой! Зима уходит — блины печём, веселье гуляем!',
   'Блины-то есть? Соберите 10, угостим всю Даларан!',
   'Молодец! Гуляй, веселье только начинается!');

INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `MaxLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `PrevQuestId`, `NextQuestId`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`, `Title`, `Objectives`, `OfferRewardText`,
   `RequestItemsText`, `EndText`)
VALUES
  (990251, 2, 10, 0, 15, 0, 0, 0, 1, 990250, 990252, 6, 250000,
   @TOKEN_MASLENITSA, 25,
   'Блинные горки',
   'Соберите 25 Скомороших блинов.',
   'Горами блины, рекой мёд! Неси ещё!',
   'Двадцать пять блинов — и гора к тебе!',
   'Вот это улов! Держи награду, заслужил!');

INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `MaxLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `PrevQuestId`, `NextQuestId`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`, `RewItemId1`, `RewItemCount1`,
   `Title`, `Objectives`, `OfferRewardText`, `RequestItemsText`, `EndText`)
VALUES
  (990252, 2, 10, 0, 20, 0, 0, 0, 1, 990251, 0, 7, 500000,
   @TOKEN_MASLENITSA, 40, @ITEM_HAT, 1,
   'Взятие снежной крепости',
   'Соберите 40 Скомороших блинов.',
   'Крепость взяли, Масленицу встретили! Тебе — почётный колпак!',
   'Сорок блинов для штурма снежной крепости!',
   'Тепло одет — весело гулять! Носи с гордостью!');

-- --- Купала: цепочка Купавки ---
INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `MaxLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `PrevQuestId`, `NextQuestId`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`, `Title`, `Objectives`, `OfferRewardText`,
   `RequestItemsText`, `EndText`)
VALUES
  (990253, 2, 10, 0, 10, 0, 0, 0, 1, 0, 990254, 5, 100000,
   @TOKEN_KUPALA, 10,
   'Огни Купалы',
   'Соберите 10 Купальских венков (дропаются с монстров).',
   'Ночь коротка, огни высоки! Помоги собрать венки!',
   'Десять венков — и прыгнем через костёр!',
   'Прыжок удался, удача с тобой!');

INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `MaxLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `PrevQuestId`, `NextQuestId`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`, `Title`, `Objectives`, `OfferRewardText`,
   `RequestItemsText`, `EndText`)
VALUES
  (990254, 2, 10, 0, 15, 0, 0, 0, 1, 990253, 990255, 6, 250000,
   @TOKEN_KUPALA, 25,
   'Плетение венков',
   'Соберите 25 Купальских венков.',
   'Трава целебная, вода живая — плетём дальше!',
   'Двадцать пять венков для большого хоровода!',
   'Хоровод закружил! Держи, заслужил!');

INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `MaxLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `PrevQuestId`, `NextQuestId`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`, `RewItemId1`, `RewItemCount1`,
   `Title`, `Objectives`, `OfferRewardText`, `RequestItemsText`, `EndText`)
VALUES
  (990255, 2, 10, 0, 20, 0, 0, 0, 1, 990254, 0, 7, 500000,
   @TOKEN_KUPALA, 40, @ITEM_FLOWER, 1,
   'Поиск папоротника',
   'Соберите 40 Купальских венков.',
   'Полночь близка... Кто найдёт цветок папоротника — тому богатство и чудо!',
   'Сорок венков — след к папоротникову цвету!',
   'Цветок твой! Только никому не рассказывай до рассвета!');

-- --- Коляда: цепочка Колядника (4 квеста, переход через Новый год) ---
INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `MaxLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `PrevQuestId`, `NextQuestId`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`, `Title`, `Objectives`, `OfferRewardText`,
   `RequestItemsText`, `EndText`)
VALUES
  (990256, 2, 10, 0, 10, 0, 0, 0, 1, 0, 990257, 5, 100000,
   @TOKEN_KOLYADA, 10,
   'Коляда пришла!',
   'Соберите 10 Колядных звёзд (дропаются с монстров).',
   'Коляда на пороге! Звёзды-то собираем?',
   'Десять звёзд на витых шнурках — жду!',
   'Славно! Гуляй на празднике!');

INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `MaxLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `PrevQuestId`, `NextQuestId`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`, `Title`, `Objectives`, `OfferRewardText`,
   `RequestItemsText`, `EndText`)
VALUES
  (990257, 2, 10, 0, 15, 0, 0, 0, 1, 990256, 990258, 6, 250000,
   @TOKEN_KOLYADA, 25,
   'Колядки по домам',
   'Соберите 25 Колядных звёзд.',
   'Колядовать ходим, звёздочки дарим!',
   'Двадцать пять звёзд — и щедрости не занимать!',
   'Счастья вам, хозяин! Держи гостинец!');

INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `MaxLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `PrevQuestId`, `NextQuestId`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`, `RewItemId1`, `RewItemCount1`,
   `Title`, `Objectives`, `OfferRewardText`, `RequestItemsText`, `EndText`)
VALUES
  (990258, 2, 10, 0, 20, 0, 0, 0, 1, 990257, 990259, 7, 500000,
   @TOKEN_KOLYADA, 40, @ITEM_BELL, 1,
   'Ряженые в масках',
   'Соберите 40 Колядных звёзд.',
   'Маски надеты, бубенцы звенят! Носи бубенец Колядника!',
   'Сорок звёзд — рядиться пора!',
   'Звени, бубенец, до самой Коляды!');

INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `MaxLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `PrevQuestId`, `NextQuestId`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`, `Title`, `Objectives`, `OfferRewardText`,
   `RequestItemsText`, `EndText`)
VALUES
  (990259, 2, 10, 0, 25, 0, 0, 0, 1, 990258, 0, 8, 750000,
   @TOKEN_KOLYADA, 50,
   'Зимнее солнцестояние',
   'Соберите 50 Колядных звёзд.',
   'Вот и солнце повернуло к лету! Зимнее солнцестояние миновало!',
   'Пятьдесят звёзд — солнце на лето повернёт!',
   'Славный праздник вышел! Слава Коляде!');

-- ------------------------------------------------------------
-- 5.6 Итоговый квест «Венец праздников» (990260): жетоны всех трёх
--     праздников, награда — Оберег Сварожич (990226).
-- ------------------------------------------------------------
INSERT INTO `quest_template`
  (`entry`, `Method`, `MinLevel`, `QuestLevel`, `RequiredClasses`, `RequiredRaces`,
   `QuestFlags`, `SpecialFlags`, `RewXPId`, `RewOrReqMoney`,
   `RequiredItemId1`, `RequiredItemCount1`,
   `RequiredItemId2`, `RequiredItemCount2`,
   `RequiredItemId3`, `RequiredItemCount3`,
   `RewItemId1`, `RewItemCount1`,
   `Title`, `Objectives`, `OfferRewardText`, `RequestItemsText`, `EndText`)
VALUES
  (990260, 2, 10, 25, 0, 0, 0, 1, 8, 1000000,
   @TOKEN_MASLENITSA, 10,
   @TOKEN_KUPALA, 10,
   @TOKEN_KOLYADA, 10,
   @ITEM_SVAROG, 1,
   'Венец праздников',
   'Соберите по 10 жетонов каждого праздника: блины, венки и звёзды.',
   'Блины, венки и звёзды — все три праздника в одном обереге!',
   'Все три жетона: блин, венок и звезда — собрал?',
   'Да будет благословение Свароже с тобой, искатель праздников!');

-- ------------------------------------------------------------
-- 5.7 Геймобъекты-украшения: чучело Масленицы, купальский костёр, колядная ёлка.
--     type=10 (GOOBER, скриптовый), ScriptName=SlavicGoScript.
-- База: world
-- ------------------------------------------------------------
DELETE FROM `gameobject_template` WHERE `entry` IN (@GO_EFFIGY, @GO_BONFIRE, @GO_TREE);
INSERT INTO `gameobject_template`
  (`entry`, `type`, `displayId`, `name`, `IconName`, `castStackCaption`, `gooberTriggernr`,
   `size`, `Data0`, `Data1`, `Data2`, `Data3`, `Data4`, `Data5`, `Data6`, `Data7`, `Data8`,
   `Data9`, `Data10`, `Data11`, `Data12`, `Data13`, `Data14`, `Data15`, `Data16`, `Data17`,
   `Data18`, `Data19`, `Data20`, `Data21`, `Data22`, `Data23`, `AIName`, `ScriptName`,
   `WORLDsafeInteractIDs`, `VerifiedBuild`)
VALUES
  (@GO_EFFIGY, 10, 2791, 'Чучело Масленицы', '', '', 0, 1.6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 'SlavicGoScript', '', 0),
  (@GO_BONFIRE, 10, 2790, 'Купальский костёр', '', '', 0, 1.8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 'SlavicGoScript', '', 0),
  (@GO_TREE, 10, 2789, 'Колядная ёлка', '', '', 0, 1.5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 'SlavicGoScript', '', 0);

-- Спавны ГО в Даларане.
DELETE FROM `gameobject` WHERE `guid` IN (@GUID_GO_EFFIGY, @GUID_GO_BONFIRE, @GUID_GO_TREE);
INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`,
  `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`,
  `rotation3`, `spawntimesecs`, `animprogress`, `state`, `VerifiedBuild`)
VALUES
  (@GUID_GO_EFFIGY,  @GO_EFFIGY,  571, 4395, 4395, 1, 1, 5810.0, 417.0, 215.0, 2.5, 0, 0, 0, 1, 300, 0, 1, 0),
  (@GUID_GO_BONFIRE, @GO_BONFIRE, 571, 4395, 4395, 1, 1, 5830.0, 433.0, 215.0, 2.5, 0, 0, 0, 1, 300, 0, 1, 0),
  (@GUID_GO_TREE,    @GO_TREE,    571, 4395, 4395, 1, 1, 5808.0, 433.0, 215.0, 2.5, 0, 0, 0, 1, 300, 0, 1, 0);

-- ------------------------------------------------------------
-- 5.8 Локализация квестов и предметов для клиентов enUS/enGB.
--     ruRU-тексты уже в quest_template (базовые), дублируем и их.
-- База: world
-- ------------------------------------------------------------
DELETE FROM `quest_template_locale` WHERE `ID` BETWEEN 990250 AND 990260;
INSERT INTO `quest_template_locale` (`ID`, `locale`, `Title`, `Details`, `Objectives`,
  `OfferRewardText`, `RequestItemsText`, `EndText`, `VerifiedBuild`)
VALUES
  (990250, 'enUS', 'Farewell, Winter!', 'Winter is leaving — pancakes for everyone!', 'Collect 10 Skomorokh Pancakes (dropped by monsters).', 'Ah, dear guest! Winter departs — we bake and we feast!', 'Got the pancakes? Bring 10!', 'Well done! The fun begins!', 0),
  (990250, 'enGB', 'Farewell, Winter!', 'Winter is leaving — pancakes for everyone!', 'Collect 10 Skomorokh Pancakes (dropped by monsters).', 'Ah, dear guest! Winter departs — we bake and we feast!', 'Got the pancakes? Bring 10!', 'Well done! The fun begins!', 0),
  (990250, 'ruRU', 'Прощай, зима!', 'Зима уходит — блины всем!', 'Соберите 10 Скомороших блинов (дропаются с монстров).', 'Ах, гость дорогой! Зима уходит — блины печём, веселье гуляем!', 'Блины-то есть? Соберите 10, угостим всю Даларан!', 'Молодец! Гуляй, веселье только начинается!', 0),
  (990256, 'enUS', 'Kolyada Has Come!', 'Kolyada is at the doorstep!', 'Collect 10 Kolyada Stars (dropped by monsters).', 'We are gathering stars!', 'Ten stars on twisted strings — waiting!', 'Splendid! Enjoy the holiday!', 0),
  (990256, 'enGB', 'Kolyada Has Come!', 'Kolyada is at the doorstep!', 'Collect 10 Kolyada Stars (dropped by monsters).', 'We are gathering stars!', 'Ten stars on twisted strings — waiting!', 'Splendid! Enjoy the holiday!', 0),
  (990256, 'ruRU', 'Коляда пришла!', 'Коляда на пороге!', 'Соберите 10 Колядных звёзд (дропаются с монстров).', 'Коляда на пороге! Звёзды-то собираем?', 'Десять звёзд на витых шнурках — жду!', 'Славно! Гуляй на празднике!', 0),
  (990260, 'enUS', 'Crown of Holidays', 'Three holidays in one amulet!', 'Collect 10 tokens of each holiday: pancakes, wreaths and stars.', 'Pancakes, wreaths and stars — three holidays in one amulet!', 'All three tokens: pancake, wreath and star — got them?', 'May Svarozhich bless you, seeker of holidays!', 0),
  (990260, 'enGB', 'Crown of Holidays', 'Three holidays in one amulet!', 'Collect 10 tokens of each holiday: pancakes, wreaths and stars.', 'Pancakes, wreaths and stars — three holidays in one amulet!', 'All three tokens: pancake, wreath and star — got them?', 'May Svarozhich bless you, seeker of holidays!', 0),
  (990260, 'ruRU', 'Венец праздников', 'Три праздника в одном обереге!', 'Соберите по 10 жетонов каждого праздника: блины, венки и звёзды.', 'Блины, венки и звёзды — все три праздника в одном обереге!', 'Все три жетона: блин, венок и звезда — собрал?', 'Да будет благословение Свароже с тобой, искатель праздников!', 0);

-- enUS-строки для остальных квестов (перед копированием в прочие локали).
INSERT INTO `quest_template_locale` (`ID`, `locale`, `Title`, `Details`, `Objectives`,
  `OfferRewardText`, `RequestItemsText`, `EndText`, `VerifiedBuild`)
VALUES
  (990251, 'enUS', 'Pancake Hills', 'Mountains of pancakes, rivers of honey!', 'Collect 25 Skomorokh Pancakes.', 'More! Bring more!', 'Twenty five pancakes — and the mountain is yours!', 'What a haul! You earned it!', 0),
  (990252, 'enUS', 'Storming the Snow Fortress', 'The fortress is taken — the feast begins!', 'Collect 40 Skomorokh Pancakes.', 'The fortress fell! Take this honorary hat!', 'Forty pancakes for the snow fortress assault!', 'Dressed warm — party hard! Wear it with pride!', 0),
  (990254, 'enUS', 'Weaving Wreaths', 'Healing herbs, living water!', 'Collect 25 Kupala Wreaths.', 'The round dance is spinning! Well earned!', 'Twenty five wreaths for the great round dance!', 'Take this, you deserve it!', 0),
  (990255, 'enUS', 'Seeking the Fern Flower', 'Midnight is close... who finds the fern flower finds fortune!', 'Collect 40 Kupala Wreaths.', 'The flower is yours! Tell no one until dawn!', 'Forty wreaths — the trail to the fern bloom!', 'The flower is yours! Tell no one until dawn!', 0),
  (990257, 'enUS', 'Carols Door to Door', 'We go caroling, giving away stars!', 'Collect 25 Kolyada Stars.', 'Happiness to you, master! Take a treat!', 'Twenty five stars — generosity guaranteed!', 'Happiness to you, master! Take a treat!', 0),
  (990258, 'enUS', 'Mummers in Masks', 'Masks on, bells ringing!', 'Collect 40 Kolyada Stars.', 'Masks on, bells ringing! Wear the Kolyadnik bell!', 'Forty stars — time to dress up!', 'Ring, little bell, until Kolyada comes!', 0),
  (990259, 'enUS', 'Winter Solstice', 'The sun has turned toward summer!', 'Collect 50 Kolyada Stars.', 'A splendid holiday! Glory to Kolyada!', 'Fifty stars — the sun turns to summer!', 'A splendid holiday! Glory to Kolyada!', 0);

-- Полная поддержка всех клиентских локалей для квестов: не-ruRU получают английские тексты.
-- (Охватываем все 11 квестов — enUS-строки для остальных добавим ниже перед копированием.)
INSERT INTO `quest_template_locale` (`ID`, `locale`, `Title`, `Details`, `Objectives`,
  `OfferRewardText`, `RequestItemsText`, `EndText`, `VerifiedBuild`)
SELECT `ID`, t.loc, `Title`, `Details`, `Objectives`, `OfferRewardText`, `RequestItemsText`, `EndText`, 0
FROM `quest_template_locale`
CROSS JOIN (SELECT 'koKR' AS loc UNION SELECT 'frFR' UNION SELECT 'deDE' UNION SELECT 'zhCN'
            UNION SELECT 'zhTW' UNION SELECT 'esES' UNION SELECT 'esMX') t
WHERE `locale` = 'enUS'
  AND `ID` BETWEEN 990250 AND 990260;

DELETE FROM `item_template_locale` WHERE `entry` IN (@ITEM_HAT, @ITEM_WREATH, @ITEM_AMULET,
  @ITEM_MASK, @ITEM_FLOWER, @ITEM_BELL, @ITEM_SVAROG,
  @TOKEN_MASLENITSA, @TOKEN_KUPALA, @TOKEN_KOLYADA);
INSERT INTO `item_template_locale` (`entry`, `locale`, `Name`, `Description`, `VerifiedBuild`)
VALUES
  (@TOKEN_MASLENITSA, 'enUS', 'Skomorokh Pancake', 'Hot and fresh. Skomorokhs accept them gladly.', 0),
  (@TOKEN_MASLENITSA, 'enGB', 'Skomorokh Pancake', 'Hot and fresh. Skomorokhs accept them gladly.', 0),
  (@TOKEN_MASLENITSA, 'ruRU', 'Скомороший блин', 'Ароматный, с пылу с жару. Скоморохи принимают их охотно.', 0),
  (@TOKEN_KUPALA, 'enUS', 'Kupala Wreath', 'Woven from field herbs and fiery flowers.', 0),
  (@TOKEN_KUPALA, 'enGB', 'Kupala Wreath', 'Woven from field herbs and fiery flowers.', 0),
  (@TOKEN_KUPALA, 'ruRU', 'Купальский венок', 'Плетённый из полевых трав и огненных цветов.', 0),
  (@TOKEN_KOLYADA, 'enUS', 'Kolyada Star', 'A silver star on a twisted string.', 0),
  (@TOKEN_KOLYADA, 'enGB', 'Kolyada Star', 'A silver star on a twisted string.', 0),
  (@TOKEN_KOLYADA, 'ruRU', 'Колядная звезда', 'Серебристая звёздочка на витом шнурке.', 0),
  (@ITEM_HAT, 'enUS', 'Pancake Hat', 'Smells of butter and merriment.', 0),
  (@ITEM_HAT, 'enGB', 'Pancake Hat', 'Smells of butter and merriment.', 0),
  (@ITEM_HAT, 'ruRU', 'Колпак Блинный', 'Пахнет маслом и весельем. Смотри, не съел бы кто.', 0),
  (@ITEM_WREATH, 'enUS', 'Kupala Wreath Crown', 'Warm from the fires of the Kupala night.', 0),
  (@ITEM_WREATH, 'enGB', 'Kupala Wreath Crown', 'Warm from the fires of the Kupala night.', 0),
  (@ITEM_WREATH, 'ruRU', 'Венок Купальский', 'Тёплый от костров Купальской ночи.', 0),
  (@ITEM_AMULET, 'enUS', 'Star Amulet', 'Rings softly, as if singing a carol.', 0),
  (@ITEM_AMULET, 'enGB', 'Star Amulet', 'Rings softly, as if singing a carol.', 0),
  (@ITEM_AMULET, 'ruRU', 'Оберег Звёздный', 'Звенит тихо, будто поёт колядку.', 0),
  (@ITEM_MASK, 'enUS', 'Bear Mask', 'Roaring is easy, fun is easier.', 0),
  (@ITEM_MASK, 'enGB', 'Bear Mask', 'Roaring is easy, fun is easier.', 0),
  (@ITEM_MASK, 'ruRU', 'Маска Медведя', 'Рычать в ней удобно, веселиться — ещё лучше.', 0),
  (@ITEM_FLOWER, 'enUS', 'Fern Flower', 'The one that blooms only at Kupala midnight.', 0),
  (@ITEM_FLOWER, 'enGB', 'Fern Flower', 'The one that blooms only at Kupala midnight.', 0),
  (@ITEM_FLOWER, 'ruRU', 'Цветок Папоротника', 'Тот самый, что цветёт лишь в Купальскую полночь. Не светится... почти.', 0),
  (@ITEM_BELL, 'enUS', 'Kolyadnik Bell', 'Ding-ding-ding! Kolyada has come!', 0),
  (@ITEM_BELL, 'enGB', 'Kolyadnik Bell', 'Ding-ding-ding! Kolyada has come!', 0),
  (@ITEM_BELL, 'ruRU', 'Бубенец Колядника', 'Динь-динь-динь! Коляда пришла!', 0),
  (@ITEM_SVAROG, 'enUS', 'Svarozhich Amulet', 'Solar wheel amulet. Blessing of all three holidays.', 0),
  (@ITEM_SVAROG, 'enGB', 'Svarozhich Amulet', 'Solar wheel amulet. Blessing of all three holidays.', 0),
  (@ITEM_SVAROG, 'ruRU', 'Оберег Сварожич', 'Солнечный колёсный оберег. Благословение всех трёх праздников.', 0);

-- Полная поддержка всех клиентских локалей 3.3.5: не-ruRU локали получают
-- английский текст (fallback); администратор может переопределить любой язык.
-- Локали 3.3.5: enUS, enGB, koKR, frFR, deDE, zhCN, zhTW, esES, esMX, ruRU.
INSERT INTO `item_template_locale` (`entry`, `locale`, `Name`, `Description`, `VerifiedBuild`)
SELECT `entry`, t.loc, `Name`, `Description`, 0
FROM `item_template_locale`
CROSS JOIN (SELECT 'koKR' AS loc UNION SELECT 'frFR' UNION SELECT 'deDE' UNION SELECT 'zhCN'
            UNION SELECT 'zhTW' UNION SELECT 'esES' UNION SELECT 'esMX') t
WHERE `locale` = 'enUS'
  AND `entry` IN (@TOKEN_MASLENITSA, @TOKEN_KUPALA, @TOKEN_KOLYADA,
    @ITEM_HAT, @ITEM_WREATH, @ITEM_AMULET, @ITEM_MASK, @ITEM_FLOWER, @ITEM_BELL, @ITEM_SVAROG);

SELECT 'Миграция Славянских праздников применена: 3 NPC (990201-990203, 9 спавнов: Даларан/Штормград/Оргриммар), 10 предметов (990210-990212, 990220-990226), 11 квестов (990250-990260), 3 ГО (990270-990272), таблица character_slavic_tokens' AS status;
