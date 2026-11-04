/*
 * Модуль «Славянские праздники и события»
 * Реализация менеджера.
 */

#include "SlavicMgr.h"

#include "Config.h"
#include "Log.h"

#include <algorithm>
#include <cstdio>
#include <ctime>

SlavicMgr* SlavicMgr::instance()
{
    static SlavicMgr instance;
    return &instance;
}

void SlavicMgr::LoadConfig()
{
    _enabled = sConfigMgr->GetOption<bool>("Slavic.Enable", true);
    _tokenDropChance = sConfigMgr->GetOption<uint32>("Slavic.TokenDropChance", 3000);
    _tokenDropChance = std::min(_tokenDropChance, 10000u);
    _tokenDropMinLevel = sConfigMgr->GetOption<uint32>("Slavic.TokenDropMinLevel", 10);
    _manualDurationHours = sConfigMgr->GetOption<uint32>("Slavic.GMStartDuration", 24);
    _xpBonusPercent = sConfigMgr->GetOption<uint32>("Slavic.Bonus.XpPercent", 0);
    _repBonusPercent = sConfigMgr->GetOption<uint32>("Slavic.Bonus.RepPercent", 0);

    _holidays.clear();
    _holidays.push_back({ SlavicHoliday::Maslenitsa,
        sConfigMgr->GetOption<std::string>("Slavic.Maslenitsa.Start", "02-24"),
        sConfigMgr->GetOption<std::string>("Slavic.Maslenitsa.End", "03-02"),
        SlavicTokenMaslenitsa, SlavicNpcMaslenitsa });
    _holidays.push_back({ SlavicHoliday::Kupala,
        sConfigMgr->GetOption<std::string>("Slavic.Kupala.Start", "07-04"),
        sConfigMgr->GetOption<std::string>("Slavic.Kupala.End", "07-10"),
        SlavicTokenKupala, SlavicNpcKupala });
    _holidays.push_back({ SlavicHoliday::Kolyada,
        sConfigMgr->GetOption<std::string>("Slavic.Kolyada.Start", "12-25"),
        sConfigMgr->GetOption<std::string>("Slavic.Kolyada.End", "01-07"),
        SlavicTokenKolyada, SlavicNpcKolyada });

    LOG_INFO("module.slavic", "Slavic: config loaded ({} holidays)", _holidays.size());
}

bool SlavicMgr::IsHolidayActive(SlavicHoliday id) const
{
    if (!_enabled)
        return false;

    {
        std::lock_guard<std::mutex> lock(_mutex);
        auto it = _manualUntil.find(static_cast<uint32>(id));
        if (it != _manualUntil.end() && it->second > 0)
            return std::time(nullptr) < it->second;
    }

    // Проверка диапазона дат из конфига (формат MM-DD).
    time_t now = std::time(nullptr);
    std::tm localNow = *std::localtime(&now); // NOLINT(concurrency-mt-unsafe)
    char buf[6]{};
    std::snprintf(buf, sizeof(buf), "%02d-%02d", localNow.tm_mon + 1, localNow.tm_mday);
    std::string today(buf);

    std::lock_guard<std::mutex> lock(_mutex);
    for (SlavicHolidayInfo const& h : _holidays)
    {
        if (h.id != id)
            continue;

        // Поддержка перехода через Новый год (12-25 -> 01-07).
        if (std::string(h.startDate) <= std::string(h.endDate))
            return (today >= h.startDate && today <= h.endDate);
        return (today >= h.startDate || today <= h.endDate);
    }

    return false;
}

bool SlavicMgr::IsAnyHolidayActive() const
{
    for (SlavicHolidayInfo const& h : _holidays)
        if (IsHolidayActive(h.id))
            return true;
    return false;
}

SlavicHoliday SlavicMgr::GetHolidayByNpc(uint32 npcEntry) const
{
    std::lock_guard<std::mutex> lock(_mutex);
    for (SlavicHolidayInfo const& h : _holidays)
        if (h.npcEntry == npcEntry)
            return h.id;
    return SlavicHoliday::None;
}

SlavicHoliday SlavicMgr::GetHolidayByToken(uint32 itemEntry) const
{
    std::lock_guard<std::mutex> lock(_mutex);
    for (SlavicHolidayInfo const& h : _holidays)
        if (h.tokenItem == itemEntry)
            return h.id;
    return SlavicHoliday::None;
}

uint32 SlavicMgr::GetTokenItem(SlavicHoliday id) const
{
    std::lock_guard<std::mutex> lock(_mutex);
    for (SlavicHolidayInfo const& h : _holidays)
        if (h.id == id)
            return h.tokenItem;
    return 0;
}

void SlavicMgr::StartHolidayManually(SlavicHoliday id, uint32 hours)
{
    std::lock_guard<std::mutex> lock(_mutex);
    _manualUntil[static_cast<uint32>(id)] = std::time(nullptr) + hours * 3600;
    LOG_INFO("module.slavic", "Slavic: holiday {} manually started for {} hours",
        static_cast<uint32>(id), hours);
}

void SlavicMgr::StopHolidayManually(SlavicHoliday id)
{
    std::lock_guard<std::mutex> lock(_mutex);
    _manualUntil[static_cast<uint32>(id)] = 0;
}

std::string SlavicMgr::GetManualHolidayStatus() const
{
    std::lock_guard<std::mutex> lock(_mutex);
    std::string result;
    time_t now = std::time(nullptr);
    for (auto const& [id, until] : _manualUntil)
        if (until > now)
            result += " " + std::to_string(id) + "(" + std::to_string(until - now) + "s)";
    return result.empty() ? "none" : result;
}
