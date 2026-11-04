/*
 * Модуль «Славянские праздники и события»
 * Реализация протокола аддона.
 */

#include "SlavicAddon.h"
#include "SlavicMgr.h"
#include "SlavicStrings.h"

#include "Player.h"

#include <sstream>

namespace
{
    void SendRaw(Player* player, std::string const& payload)
    {
        if (!player || !player->GetSession())
            return;
        player->SendAddonMessage(SlavicAddon::AddonPrefix, payload, CHAT_MSG_WHISPER, player->GetGUID());
    }

    char const* TokenNameFor(uint32 tokenItem)
    {
        SlavicStrings const& str = sSlavicStrings();
        switch (tokenItem)
        {
            case SlavicTokenMaslenitsa: return str.tokenMaslenitsa;
            case SlavicTokenKupala:     return str.tokenKupala;
            case SlavicTokenKolyada:    return str.tokenKolyada;
            default:                    return "?";
        }
    }
}

namespace SlavicAddon
{
    void SendStatus(Player* player)
    {
        if (!player)
            return;

        SlavicStrings const& str = sSlavicStrings();

        // Статус каждого праздника: H|<id>|<active 0/1>|<tokenItem>.
        for (SlavicHolidayInfo const& h : sSlavicMgr->GetHolidays())
        {
            std::ostringstream holiday;
            holiday << "H|" << static_cast<uint32>(h.id)
                    << '|' << (sSlavicMgr->IsHolidayActive(h.id) ? 1 : 0)
                    << '|' << h.tokenItem;
            SendRaw(player, holiday.str());
        }

        // Количество жетонов в сумках игрока.
        for (SlavicHolidayInfo const& h : sSlavicMgr->GetHolidays())
        {
            std::ostringstream tokens;
            tokens << "T|" << h.tokenItem << '|' << player->GetItemCount(h.tokenItem);
            SendRaw(player, tokens.str());
        }

        SendRaw(player, "D|1");
    }

    void HandleClientCommand(Player* player, std::string const& payload)
    {
        if (!player || payload.empty())
            return;

        if (payload == "REQ")
        {
            SendStatus(player);
        }
    }
}
