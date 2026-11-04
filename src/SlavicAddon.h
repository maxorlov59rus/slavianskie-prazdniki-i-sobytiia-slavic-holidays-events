/*
 * Модуль «Славянские праздники и события»
 * Серверный протокол для клиентского аддона (AddonMessage, канал "SLAVIC").
 *
 * Формат сообщений:
 *   Сервер -> клиент:
 *     H|<activeId 0-3>|<tokenItem>|<start MM-DD>|<end MM-DD> — статус праздника
 *     T|<tokenItem>|<bagCount>                               — количество жетона в сумках
 *     D|1                                                    — конец передачи
 *
 *   Клиент -> сервер:
 *     REQ — запрос статуса (открывает окно аддона)
 */

#ifndef SLAVIC_ADDON_H
#define SLAVIC_ADDON_H

#include "ObjectGuid.h"

#include <string>

class Player;

namespace SlavicAddon
{
    constexpr char const* AddonPrefix = "SLAVIC";

    // Отправка статуса праздников и жетонов игроку.
    void SendStatus(Player* player);

    // Обработка клиентской команды ("REQ").
    void HandleClientCommand(Player* player, std::string const& payload);
}

#endif // SLAVIC_ADDON_H
