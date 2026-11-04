/*
 * Модуль «Славянские праздники и события»
 * Менеджер: конфигурация, активные праздники, жетоны игроков.
 *
 * Резерв ID контента: 990200-990299 (не пересекается с Archivist: 990001/990101/990102/990105).
 * Единственный источник правды по ID — этот файл; SQL синхронен.
 */

#ifndef SLAVIC_MGR_H
#define SLAVIC_MGR_H

#include "Common.h"
#include "ObjectGuid.h"

#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

// ---------------------------------------------------------------
// Централизованные ID кастомного контента модуля (диапазон 990200+).
// ---------------------------------------------------------------
inline constexpr uint32 SlavicNpcMaslenitsa = 990201; // Скоморох Весельчак
inline constexpr uint32 SlavicNpcKupala     = 990202; // Купавка-ведунья
inline constexpr uint32 SlavicNpcKolyada    = 990203; // Колядник Старец
inline constexpr uint32 SlavicTokenMaslenitsa = 990210; // Скомороший блин
inline constexpr uint32 SlavicTokenKupala     = 990211; // Купальский венок
inline constexpr uint32 SlavicTokenKolyada    = 990212; // Колядная звезда

// Предметы-награды (косметика, без боевой силы).
inline constexpr uint32 SlavicItemPancakeHat   = 990220; // Колпак Блинный (Масленица)
inline constexpr uint32 SlavicItemWreathFlower = 990221; // Венок Купальский
inline constexpr uint32 SlavicItemStarAmulet   = 990222; // Оберег Звёздный
inline constexpr uint32 SlavicItemBearMask     = 990223; // Маска Медведя (Масленица)
inline constexpr uint32 SlavicItemFireFlower   = 990224; // Цветок Папоротника (Купала)
inline constexpr uint32 SlavicItemBellSmall    = 990225; // Бубенец Колядника (Коляда)
inline constexpr uint32 SlavicItemSvarogAmulet = 990226; // Оберег Сварожич (итоговый квест)

// Геймобъекты-украшения (диапазон 990270+).
inline constexpr uint32 SlavicGoEffigy  = 990270; // Чучело Масленицы
inline constexpr uint32 SlavicGoBonfire = 990271; // Купальский костёр
inline constexpr uint32 SlavicGoTree    = 990272; // Колядная ёлка

//.guid спавнов (creature.guid, не entry!). Диапазон 991100+ (у Archivist — 991001).
inline constexpr uint32 SlavicGuidMaslenitsa = 991101; // Даларан
inline constexpr uint32 SlavicGuidKupala     = 991102; // Даларан
inline constexpr uint32 SlavicGuidKolyada    = 991103; // Даларан
inline constexpr uint32 SlavicGuidMaslenitsaSW = 991104; // Штормград
inline constexpr uint32 SlavicGuidKupalaSW     = 991105; // Штормград
inline constexpr uint32 SlavicGuidKolyadaSW    = 991106; // Штормград
inline constexpr uint32 SlavicGuidMaslenitsaOG = 991107; // Оргриммар
inline constexpr uint32 SlavicGuidKupalaOG     = 991108; // Оргриммар
inline constexpr uint32 SlavicGuidKolyadaOG    = 991109; // Оргриммар
inline constexpr uint32 SlavicGuidGoEffigy  = 991110; // ГО: чучело (Даларан)
inline constexpr uint32 SlavicGuidGoBonfire = 991111; // ГО: костёр (Даларан)
inline constexpr uint32 SlavicGuidGoTree    = 991112; // ГО: ёлка (Даларан)

// ---------------------------------------------------------------
// Праздники.
// ---------------------------------------------------------------
enum class SlavicHoliday : uint8
{
    None = 0,
    Maslenitsa = 1, // Масленица
    Kupala     = 2, // Купала
    Kolyada    = 3, // Коляда
};

// Описание праздника: диапазон дат (MM-DD), жетон, NPC.
struct SlavicHolidayInfo
{
    SlavicHoliday id = SlavicHoliday::None;
    std::string startDate; // "MM-DD"
    std::string endDate;   // "MM-DD" (включительно)
    uint32 tokenItem = 0;  // жетон праздника
    uint32 npcEntry = 0;   // праздничный NPC
};

// Счётчики жетонов игрока (для будущей статистики/достижений).
struct SlavicPlayerData
{
    ObjectGuid::LowType guid = 0;
    std::unordered_map<uint32, uint32> tokensEarned; // itemEntry -> всего собрано
};

class SlavicMgr
{
public:
    static SlavicMgr* instance();

    // Конфигурация (mod_slavic.conf).
    void LoadConfig();
    bool IsEnabled() const { return _enabled; }
    uint32 GetTokenDropChance() const { return _tokenDropChance; }
    uint32 GetTokenDropMinLevel() const { return _tokenDropMinLevel; }
    uint32 GetXpBonusPercent() const { return _xpBonusPercent; }
    uint32 GetRepBonusPercent() const { return _repBonusPercent; }

    // Праздники: конфиг даты + активность.
    std::vector<SlavicHolidayInfo> const& GetHolidays() const { return _holidays; }

    // Активен ли какой-нибудь праздник сейчас (для бонусов).
    bool IsAnyHolidayActive() const;

    // Активен ли праздник сейчас (учитывает даты конфига и ручной запуск).
    bool IsHolidayActive(SlavicHoliday id) const;

    // Какой праздник активен по NPC entry (для gossip) / по жетону.
    SlavicHoliday GetHolidayByNpc(uint32 npcEntry) const;
    SlavicHoliday GetHolidayByToken(uint32 itemEntry) const;
    uint32 GetTokenItem(SlavicHoliday id) const;

    // Ручной запуск ГМ-командой (.slavic start <имя>) на N часов.
    void StartHolidayManually(SlavicHoliday id, uint32 hours);
    void StopHolidayManually(SlavicHoliday id);
    std::string GetManualHolidayStatus() const;
    uint32 GetManualDurationHours() const { return _manualDurationHours; }

private:
    SlavicMgr() = default;

    bool _enabled = true;
    uint32 _tokenDropChance = 3000; // из 10000
    uint32 _tokenDropMinLevel = 10;
    uint32 _manualDurationHours = 24;
    uint32 _xpBonusPercent = 0;  // бонус опыта в праздники (0 = выкл)
    uint32 _repBonusPercent = 0; // бонус репутации в праздники (0 = выкл)

    std::vector<SlavicHolidayInfo> _holidays;

    // Ручной запуск: праздник -> метка времени окончания (0 = нет).
    std::unordered_map<uint32, time_t> _manualUntil;
    mutable std::mutex _mutex;
};

#define sSlavicMgr SlavicMgr::instance()

#endif // SLAVIC_MGR_H
