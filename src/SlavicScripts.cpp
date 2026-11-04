/*
 * Модуль «Славянские праздники и события»
 * Скрипты: дроп жетонов с монстров, праздничные NPC (gossip), ГМ-команды.
 */

#include "SlavicMgr.h"
#include "SlavicAddon.h"
#include "SlavicStrings.h"

#include "Chat.h"
#include "Config.h"
#include "Log.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "ScriptMgr.h"

// Случайное число 0..9999.
static uint32 SlavicRand10000()
{
    return urand(0, 9999);
}

static char const* SlavicHolidayName(SlavicHoliday id)
{
    SlavicStrings const& str = sSlavicStrings();
    switch (id)
    {
        case SlavicHoliday::Maslenitsa: return str.holMaslenitsa;
        case SlavicHoliday::Kupala:     return str.holKupala;
        case SlavicHoliday::Kolyada:    return str.holKolyada;
        default:                        return "?";
    }
}

// ---------------------------------------------------------------
// Праздничные NPC (единый скрипт на 3 NPC, праздник — по entry).
// ---------------------------------------------------------------
class SlavicNPCScript : public CreatureScript
{
public:
    SlavicNPCScript() : CreatureScript("SlavicNPCScript") {}

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        SlavicStrings const& str = sSlavicStrings();
        SlavicHoliday hol = sSlavicMgr->GetHolidayByNpc(creature->GetEntry());

        ClearGossipMenuFor(player);
        AddGossipItemFor(player, GOSSIP_ICON_CHAT,
            Acore::StringFormat(str.gossipWelcomeFmt, SlavicHolidayName(hol)), 1, 0);
        AddGossipItemFor(player, GOSSIP_ICON_VENDOR, str.gossipTrade, 2, 0);
        AddGossipItemFor(player, GOSSIP_ICON_TALK, str.gossipAbout, 3, 0);
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
        return true;
    }

    bool OnGossipSelect(Player* player, Creature* creature, uint32 sender, uint32 /*action*/) override
    {
        SlavicStrings const& str = sSlavicStrings();
        ClearGossipMenuFor(player);
        ChatHandler handler(player->GetSession());

        switch (sender)
        {
            case 1: // приветствие
                handler.PSendSysMessage("|cff00ff00{}|r {}", str.chatPrefix,
                    Acore::StringFormat(str.gossipWelcomeFmt,
                        SlavicHolidayName(sSlavicMgr->GetHolidayByNpc(creature->GetEntry()))));
                break;

            case 2: // обмен жетонов: 10 жетонов -> 1 праздничный предмет
            {
                SlavicHoliday hol = sSlavicMgr->GetHolidayByNpc(creature->GetEntry());
                uint32 token = sSlavicMgr->GetTokenItem(hol);

                uint32 reward = 0;
                switch (hol)
                {
                    case SlavicHoliday::Maslenitsa: reward = SlavicItemPancakeHat; break;
                    case SlavicHoliday::Kupala:     reward = SlavicItemWreathFlower; break;
                    case SlavicHoliday::Kolyada:    reward = SlavicItemStarAmulet; break;
                    default: break;
                }

                if (!token || !reward || player->GetItemCount(token) < 10)
                {
                    handler.PSendSysMessage("|cff00ff00{}|r {}", str.chatPrefix, str.holidayOff);
                    break;
                }

                player->DestroyItemCount(token, 10, true);
                player->AddItem(reward, 1);
                handler.PSendSysMessage("|cff00ff00{}|r {}", str.chatPrefix,
                    Acore::StringFormat(str.msgTokenDropFmt, reward));
                break;
            }

            case 3: // о празднике
            {
                SlavicHoliday hol = sSlavicMgr->GetHolidayByNpc(creature->GetEntry());
                char const* text = str.aboutKolyada;
                switch (hol)
                {
                    case SlavicHoliday::Maslenitsa: text = str.aboutMaslenitsa; break;
                    case SlavicHoliday::Kupala:     text = str.aboutKupala; break;
                    default: break;
                }
                handler.PSendSysMessage("|cff00ff00{}|r {}", str.chatPrefix, text);
                break;
            }

            default:
                break;
        }

        AddGossipItemFor(player, GOSSIP_ICON_CHAT, str.gossipBack, 100, 0);
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
        return true;
    }
};

// ---------------------------------------------------------------
// ГМ-команды .slavic start/stop/status.
// ---------------------------------------------------------------
class SlavicCommandScript : public CommandScript
{
public:
    SlavicCommandScript() : CommandScript("SlavicCommandScript") {}

    std::vector<ChatCommand> GetCommands() const override
    {
        static std::vector<ChatCommand> slavicSubCommands =
        {
            { "start",  SEC_GAMEMASTER, false, &HandleStartCommand, "" },
            { "stop",   SEC_GAMEMASTER, false, &HandleStopCommand, "" },
            { "status", SEC_PLAYER,     false, &HandleStatusCommand, "" },
        };
        static std::vector<ChatCommand> slavicCommandTable =
        {
            { "slavic", SEC_PLAYER, false, nullptr, "", slavicSubCommands },
        };
        return slavicCommandTable;
    }

    static SlavicHoliday ParseHoliday(std::string const& name)
    {
        if (name == "maslenitsa")
            return SlavicHoliday::Maslenitsa;
        if (name == "kupala")
            return SlavicHoliday::Kupala;
        if (name == "kolyada")
            return SlavicHoliday::Kolyada;
        return SlavicHoliday::None;
    }

    static bool HandleStartCommand(ChatHandler* handler, char const* args)
    {
        SlavicStrings const& str = sSlavicStrings();
        SlavicHoliday hol = ParseHoliday(args ? args : "");

        if (hol == SlavicHoliday::None)
        {
            handler->PSendSysMessage("{}", str.gmUnknown);
            return true;
        }

        sSlavicMgr->StartHolidayManually(hol, sSlavicMgr->GetManualDurationHours());
        handler->PSendSysMessage("{}", Acore::StringFormat(str.gmStartFmt,
            SlavicHolidayName(hol), sSlavicMgr->GetManualDurationHours()));
        return true;
    }

    static bool HandleStopCommand(ChatHandler* handler, char const* args)
    {
        SlavicStrings const& str = sSlavicStrings();
        SlavicHoliday hol = ParseHoliday(args ? args : "");

        if (hol == SlavicHoliday::None)
        {
            handler->PSendSysMessage("{}", str.gmUnknown);
            return true;
        }

        sSlavicMgr->StopHolidayManually(hol);
        handler->PSendSysMessage("{}", Acore::StringFormat(str.gmStopFmt, SlavicHolidayName(hol)));
        return true;
    }

    static bool HandleStatusCommand(ChatHandler* handler, char const* /*args*/)
    {
        handler->PSendSysMessage("{}", Acore::StringFormat(
            sSlavicStrings().gmStatusFmt, sSlavicMgr->GetManualHolidayStatus()));
        return true;
    }
};

// ---------------------------------------------------------------
// Дроп жетонов: с убитого монстра с шансом падает жетон активного праздника.
// ---------------------------------------------------------------
class SlavicPlayerScript : public PlayerScript
{
public:
    SlavicPlayerScript() : PlayerScript("SlavicPlayerScript") {}

    // Аддон-сообщения: "SLAVIC	REQ" -> статус праздников и жетонов.
    bool OnChat(Player* player, uint32 type, uint32 /*lang*/, std::string& msg) override
    {
        if (!sSlavicMgr->IsEnabled() || !player)
            return false;

        if (type == CHAT_MSG_ADDON && msg.rfind("SLAVIC	", 0) == 0)
        {
            SlavicAddon::HandleClientCommand(player, msg.substr(7));
            return true;
        }

        return false;
    }

    void OnCreatureKill(Player* player, Creature* victim) override
    {
        if (!sSlavicMgr->IsEnabled() || !player || !victim)
            return;

        if (victim->GetLevel() < sSlavicMgr->GetTokenDropMinLevel())
            return;

        SlavicStrings const& str = sSlavicStrings();

        // Проверяем все праздники: активен -> возможен дроп его жетона.
        for (SlavicHolidayInfo const& h : sSlavicMgr->GetHolidays())
        {
            if (!sSlavicMgr->IsHolidayActive(h.id))
                continue;

            if (SlavicRand10000() >= sSlavicMgr->GetTokenDropChance())
                continue;

            player->AddItem(h.tokenItem, 1);
            ChatHandler(player->GetSession()).PSendSysMessage("|cff00ff00{}|r {}",
                str.chatPrefix, Acore::StringFormat(str.msgTokenDropFmt,
                    h.tokenItem == SlavicTokenMaslenitsa ? str.tokenMaslenitsa :
                    h.tokenItem == SlavicTokenKupala ? str.tokenKupala : str.tokenKolyada));
            break; // один жетон за убийство
        }
    }
};

// ---------------------------------------------------------------
// Праздничные бонусы: опыт и репутация в активные дни праздников.
// ---------------------------------------------------------------
class SlavicBonusScript : public PlayerScript
{
public:
    SlavicBonusScript() : PlayerScript("SlavicBonusScript") {}

    void OnGiveXP(Player* player, uint32& amount, Unit* /*victim*/) override
    {
        if (sSlavicMgr->IsEnabled() && sSlavicMgr->IsAnyHolidayActive() && amount)
            amount += amount * sSlavicMgr->GetXpBonusPercent() / 100;
    }
    // Бонус репутации (Slavic.Bonus.RepPercent) зарезервирован в конфиге;
    // подключается после уточнения сигнатуры хука репутации в вашей ветке AC.
};

// ---------------------------------------------------------------
// Геймобъекты-украшения: костёр, чучело, ёлка (gossip-подсказки).
// ---------------------------------------------------------------
class SlavicGoScript : public GameObjectScript
{
public:
    SlavicGoScript() : GameObjectScript("SlavicGoScript") {}

    bool OnGossipHello(Player* player, GameObject* go) override
    {
        SlavicStrings const& str = sSlavicStrings();
        SlavicHoliday hol = SlavicHoliday::None;
        switch (go->GetEntry())
        {
            case SlavicGoEffigy:  hol = SlavicHoliday::Maslenitsa; break;
            case SlavicGoBonfire: hol = SlavicHoliday::Kupala; break;
            case SlavicGoTree:    hol = SlavicHoliday::Kolyada; break;
            default: break;
        }

        ClearGossipMenuFor(player);
        if (hol == SlavicHoliday::None || !sSlavicMgr->IsHolidayActive(hol))
        {
            SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, go->GetGUID());
            return true;
        }

        // В активный праздник ГО даёт «веселящий» косметический бафф-заглушку (текст).
        ChatHandler(player->GetSession()).PSendSysMessage("|cff00ff00{}|r {}",
            str.chatPrefix, Acore::StringFormat(str.goUseFmt, SlavicHolidayName(hol)));
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, go->GetGUID());
        return true;
    }
};

// ---------------------------------------------------------------
// WorldScript: загрузка конфига и локали.
// ---------------------------------------------------------------
class SlavicWorldScript : public WorldScript
{
public:
    SlavicWorldScript() : WorldScript("SlavicWorldScript") {}

    void OnBeforeConfigLoad(bool /*reload*/) override
    {
        sSlavicMgr->LoadConfig();
        SlavicLoadLocale();
    }
};

// Точка входа модуля (вызывается ядром AC).
void AddSlavicScripts()
{
    new SlavicPlayerScript();
    new SlavicNPCScript();
    new SlavicGoScript();
    new SlavicCommandScript();
    new SlavicWorldScript();
}
