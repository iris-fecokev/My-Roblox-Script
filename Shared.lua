--[[
-= ТЕСТОВЫЙ СКРИПТ V3.0 =-
Внимание: Использование читов нарушает правила Roblox
]]

-- Модульная часть (Shared.lua)
local Shared = {}
Shared.AdminListURL = "https://raw.githubusercontent.com/yourusername/adminlist/main/admins.txt"
Shared.DecalID = 1365169983
Shared.Settings = {
    Theme = "Dark",
    BetaFeatures = false
}
Shared.AdminCommands = {
    "KickAllCheaters",
    "ServerLock",
    "InvisibleMode"
}

function Shared.FetchAdmins()
    -- Заглушка для реального запроса к GitHub
    return {"TrustedPlayer1", "SuperAdmin1337", "ModeratorX"}
end

function Shared.ApplyTheme(gui, theme)
    local colors = theme == "Dark" and {
        Background = Color3.fromRGB(30, 30, 40),
        Foreground = Color3.fromRGB(55, 55, 70),
        Text = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(100, 70, 200)
    } or {
        Background = Color3.fromRGB(240, 240, 245),
        Foreground = Color3.fromRGB(200, 200, 210),
        Text = Color3.fromRGB(40, 40, 50),
        Accent = Color3.fromRGB(80, 120, 220)
    }
    
    gui.BackgroundColor3 = colors.Background
    for _, child in ipairs(gui:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextColor3 = colors.Text
        elseif child:IsA("Frame") then
            child.BackgroundColor3 = colors.Foreground
        end
    end
end

return Shared
