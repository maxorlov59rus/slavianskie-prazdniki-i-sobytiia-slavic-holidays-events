--[[
    Модуль «Славянские праздники и события» — клиентский аддон.
    Окно «Праздники Азерота»: активный праздник, жетоны в сумках.
    Протокол: AddonMessage по каналу SLAVIC (см. src/SlavicAddon.h).
      Сервер -> клиент: H|id|active|tokenItem, T|tokenItem|count, D|1
      Клиент -> сервер: REQ
]]

local ADDON_NAME = "Slavic"
local PREFIX = "SLAVIC"

-- Локализация по клиентской локали.
local L = setmetatable({}, { __index = function(_, k) return k end })

do
    -- Все локали клиента 3.3.5: ruRU -> русский, остальные -> английский.
    -- (koKR, frFR, deDE, zhCN, zhTW, esES, esMX, enUS, enGB)
    local isRu = (GetLocale() == "ruRU")

    local RU = {
        title       = "Праздники Азерота",
        subtitle    = "Славянские праздники и события",
        noHoliday   = "Сейчас праздников нет. Заглядывай в даты!",
        holidaysLbl = "Праздники:",
        tokensLbl   = "Твои жетоны:",
        inactive    = "|cff808080не активен|r",
        active      = "|cff00ff00гуляет!|r",
        tradeHint   = "Обмен: 10 жетонов у праздничного NPC (Даларан/Штормград/Оргриммар)",
        chatPrefix  = "[Праздник]",
        helpText    = "/slavic — открыть окно праздников",
        names       = { [1]="Масленица", [2]="Купала", [3]="Коляда" },
        tokenNames  = { [990210]="Скомороший блин", [990211]="Купальский венок", [990212]="Колядная звезда" },
    }

    local EN = {
        title       = "Holidays of Azeroth",
        subtitle    = "Slavic Holidays & Events",
        noHoliday   = "No holidays right now. Check the dates!",
        holidaysLbl = "Holidays:",
        tokensLbl   = "Your tokens:",
        inactive    = "|cff808080inactive|r",
        active      = "|cff00ff00celebrating!|r",
        tradeHint   = "Trade: 10 tokens at a holiday NPC (Dalaran/Stormwind/Orgrimmar)",
        chatPrefix  = "[Holiday]",
        helpText    = "/slavic — open the holidays window",
        names       = { [1]="Maslenitsa", [2]="Kupala", [3]="Kolyada" },
        tokenNames  = { [990210]="Skomorokh Pancake", [990211]="Kupala Wreath", [990212]="Kolyada Star" },
    }

    for k, v in pairs(isRu and RU or EN) do
        L[k] = v
    end
end

local holidays = {} -- id -> {active, tokenItem}
local tokens = {}   -- tokenItem -> count

----------------------------------------------------------------------
-- Окно
----------------------------------------------------------------------

local Win = CreateFrame("Frame", "SlavicWindow", UIParent)
Win:SetSize(360, 260)
Win:SetPoint("CENTER")
Win:SetFrameStrata("HIGH")
Win:SetMovable(true)
Win:EnableMouse(true)
Win:RegisterForDrag("LeftButton")
Win:SetScript("OnDragStart", Win.StartMoving)
Win:SetScript("OnDragStop", Win.StopMovingOrSizing)
Win:Hide()

Win:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
})

local title = Win:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -18)
title:SetText(L.title)

local subtitle = Win:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
subtitle:SetPoint("TOP", title, "BOTTOM", 0, -2)
subtitle:SetText("|cff808080" .. L.subtitle .. "|r")

local closeButton = CreateFrame("Button", nil, Win, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -6, -6)

local body = Win:CreateFontString(nil, "OVERLAY", "GameFontNormal")
body:SetPoint("TOPLEFT", 24, -56)
body:SetWidth(312)
body:SetJustifyH("LEFT")

local function RenderWindow()
    local lines = {}

    local anyActive = false
    for id = 1, 3 do
        local h = holidays[id]
        if h then
            local status = h.active and L.active or L.inactive
            if h.active then anyActive = true end
            table.insert(lines, string.format("%s — %s",
                L.names[id] or id, status))
        end
    end

    if not next(holidays) then
        table.insert(lines, L.noHoliday)
    end

    table.insert(lines, "")
    table.insert(lines, L.tokensLbl)
    local anyTokens = false
    for _, item in ipairs({ 990210, 990211, 990212 }) do
        if tokens[item] and tokens[item] > 0 then
            anyTokens = true
            table.insert(lines, string.format("  • %s — |cffffd100%d|r",
                L.tokenNames[item] or item, tokens[item]))
        end
    end
    if not anyTokens then
        table.insert(lines, "  |cff808080—|r")
    end

    table.insert(lines, "")
    table.insert(lines, "|cff808080" .. L.tradeHint .. "|r")

    body:SetText(table.concat(lines, "\n"))
end

----------------------------------------------------------------------
-- Приём сообщений сервера
----------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == ADDON_NAME then
            if RegisterAddonMessagePrefix then
                RegisterAddonMessagePrefix(PREFIX)
            elseif C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
                C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
            end
        end
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, payload = ...
        if prefix == PREFIX then
            local parts = {}
            for part in string.gmatch(payload or "", "([^|]*)") do
                table.insert(parts, part)
            end

            if parts[1] == "H" then
                local id = tonumber(parts[2])
                if id and id >= 1 and id <= 3 then
                    holidays[id] = {
                        active = (parts[3] == "1"),
                        tokenItem = tonumber(parts[4]) or 0,
                    }
                end
            elseif parts[1] == "T" then
                local item = tonumber(parts[2])
                if item then
                    tokens[item] = tonumber(parts[3]) or 0
                end
            elseif parts[1] == "D" then
                RenderWindow()
                Win:Show()
            end
        end
    end
end)

----------------------------------------------------------------------
-- Слэш-команды
----------------------------------------------------------------------

SLASH_SLAVIC1 = "/slavic"
SLASH_SLAVIC2 = "/праздник"
SlashCmdList["SLAVIC"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "" then
        holidays = {}
        tokens = {}
        SendAddonMessage(PREFIX, "REQ", "WHISPER", UnitName("player"))
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00" .. L.chatPrefix .. "|r " .. L.helpText)
    end
end
