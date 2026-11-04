/*
 * Модуль «Славянские праздники и события»
 * Таблицы строк RU/EN.
 */

#include "SlavicStrings.h"

#include "Config.h"
#include "Log.h"

#include <algorithm>

namespace
{
    SlavicStrings const RussianStrings
    {
        "[Праздник]",
        "— {} гуляет в Даларане! Обменяй жетоны на памятные безделушки!",
        "Обменять жетоны",
        "Расскажи о празднике",
        "Назад",
        "Масленица — проводы зимы! Убивай монстров и собирай Скоморошие блины, "
            "затем обменяй их у меня на праздничные колпаки и маски. Гуляй, веселись!",
        "Купала — ночь огней и венков! Собирай Купальские венки с поверженных врагов "
            "и обменяй их на венок и цветок папоротника. Ищи чудеса в полночь!",
        "Коляда — время звёзд и колядок! Собирай Колядные звёзды "
            "и обменяй их на оберег и бубенец. Слава зимнему солнцу!",
        "Праздник сейчас не активен. Заглядывай в даты из конфига!",
        "Вы получили: {}!",
        "Скомороший блин",
        "Купальский венок",
        "Колядная звезда",
        "Праздник {} запущен принудительно на {} ч.",
        "Праздник {} остановлен.",
        "Статус ручных запусков: {}",
        "Неизвестный праздник. Доступно: maslenitsa, kupala, kolyada.",
        "Празднуешь {}! Гуляй, веселись!",
        "Масленица",
        "Купала",
        "Коляда",
    };

    SlavicStrings const EnglishStrings
    {
        "[Holiday]",
        "— {} is celebrated in Dalaran! Exchange tokens for festive trinkets!",
        "Exchange tokens",
        "Tell me about the holiday",
        "Back",
        "Maslenitsa — farewell to winter! Slay monsters to gather Skomorokh Pancakes, "
            "then trade them for festive hats and masks. Have fun!",
        "Kupala — the night of fires and wreaths! Gather Kupala Wreaths from fallen foes "
            "and trade them for a wreath and a fern flower. Seek wonders at midnight!",
        "Kolyada — the time of stars and carols! Gather Kolyada Stars "
            "and trade them for an amulet and a jingle bell. Glory to the winter sun!",
        "The holiday is not active right now. Check the config dates!",
        "You received: {}!",
        "Skomorokh Pancake",
        "Kupala Wreath",
        "Kolyada Star",
        "Holiday {} force-started for {} hours.",
        "Holiday {} stopped.",
        "Manual runs status: {}",
        "Unknown holiday. Available: maslenitsa, kupala, kolyada.",
        "Celebrating {}! Have fun!",
        "Maslenitsa",
        "Kupala",
        "Kolyada",
    };

    SlavicStrings const* s_current = &RussianStrings;
}

SlavicStrings const& sSlavicStrings()
{
    return *s_current;
}

void SlavicLoadLocale()
{
    std::string locale = sConfigMgr->GetOption<std::string>("Slavic.Locale", "ru");
    std::transform(locale.begin(), locale.end(), locale.begin(), ::tolower);
    s_current = (locale == "en" || locale == "english") ? &EnglishStrings : &RussianStrings;
    LOG_INFO("module.slavic", "Slavic: locale set to '{}'", s_current == &EnglishStrings ? "en" : "ru");
}
