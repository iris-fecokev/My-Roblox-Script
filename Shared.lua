-- Shared.lua
local Shared = {}

Shared.AdminListURL = "https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/main/admins.txt"
Shared.DecalID = 1365169983
Shared.Settings = {
    Theme = "Dark",
    BetaFeatures = false,
    DebugMode = false,
    ServerLock = false
}
Shared.AdminCommands = {
    "KickAllCheaters",
    "ServerLock",
    "InvisibleMode",
    "TeleportToPlayer",
    "ForceFieldAll",
    "PlayAnimationForAll"
}
Shared.AnimationIDs = {
    R6 = "109922779269237",
    R15 = "113868344382851"
}

function Shared.FetchAdmins()
    local success, result = pcall(function()
        return game:HttpGet(Shared.AdminListURL)
    end)
    if success then
        local admins = {}
        for name in result:gmatch("%S+") do
            table.insert(admins, name)
        end
        return admins
    else
        warn("Failed to fetch admin list: "..result)
        return {"ExampleAdmin1", "ExampleAdmin2"}
    end
end

function Shared.ApplyTheme(gui, theme)
    local colors = theme == "Dark" and {
        Background = Color3.fromRGB(25, 25, 35),
        Foreground = Color3.fromRGB(40, 40, 55),
        Text = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(120, 80, 220)
    } or {
        Background = Color3.fromRGB(230, 230, 240),
        Foreground = Color3.fromRGB(210, 210, 220),
        Text = Color3.fromRGB(30, 30, 40),
        Accent = Color3.fromRGB(80, 140, 240)
    }
    
    gui.BackgroundColor3 = colors.Background
    for _, child in ipairs(gui:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextColor3 = colors.Text
            child.BackgroundColor3 = colors.Foreground
        elseif child:IsA("Frame") or child:IsA("ScrollingFrame") then
            child.BackgroundColor3 = colors.Foreground
        elseif child:IsA("TextBox") then
            child.BackgroundColor3 = colors.Background
        end
    end
end

-- Функция для проверки возможности запуска серверной части
function Shared.CanRunServer()
    if game:GetService("RunService"):IsStudio() then
        return true
    end
    
    -- Попытка получить доступ к серверным функциям
    local success, _ = pcall(function()
        return game:GetService("ServerScriptService"):GetChildren()
    end)
    return success
end

return Shared
