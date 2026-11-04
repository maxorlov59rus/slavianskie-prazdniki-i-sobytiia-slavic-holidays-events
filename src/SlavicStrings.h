/*
 * Модуль «Славянские праздники и события»
 * Локализация строк (ru/en), выбор через Slavic.Locale.
 */

#ifndef SLAVIC_STRINGS_H
#define SLAVIC_STRINGS_H

#include "Define.h"

struct SlavicStrings
{
    char const* chatPrefix;
    char const* gossipWelcomeFmt;   // {} — название праздника
    char const* gossipTrade;
    char const* gossipAbout;
    char const* gossipBack;
    char const* aboutMaslenitsa;
    char const* aboutKupala;
    char const* aboutKolyada;
    char const* holidayOff;
    char const* msgTokenDropFmt;    // {} — название жетона
    char const* tokenMaslenitsa;
    char const* tokenKupala;
    char const* tokenKolyada;
    char const* gmStartFmt;         // {} — имя праздника, {} — часы
    char const* gmStopFmt;          // {} — имя праздника
    char const* gmStatusFmt;        // {} — статус
    char const* gmUnknown;
    char const* goUseFmt; // {} — название праздника
    char const* holMaslenitsa;
    char const* holKupala;
    char const* holKolyada;
};

SlavicStrings const& sSlavicStrings();
void SlavicLoadLocale();

#endif // SLAVIC_STRINGS_H
