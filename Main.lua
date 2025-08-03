-- Main.lua
if _G.UniversalScriptLoaded then return end
_G.UniversalScriptLoaded = true

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

-- Конфигурация ассетов
local ASSET_IDS = {
    13077303105,     -- Декал
    111344038407932,     -- Spooky Scary Skeletons
    18512801325,    -- Classic T-Shirt
    107896578601954,-- Classic Pants
    132971777995699,-- Left Leg
    71037238818761, -- Right Leg
    82534789806334, -- Torso
    129913805701008,-- Left Arm
    119079173538697 -- Right Arm
}

-- Создание интерфейса загрузки
local function createLoadingScreen()
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "AssetLoaderGui"
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.ZIndex = 10
    frame.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 0.1, 0)
    label.Position = UDim2.new(0.3, 0, 0.45, 0)
    label.BackgroundTransparency = 1
    label.Text = "Загрузка ассетов: 0/"..#ASSET_IDS
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 24
    label.ZIndex = 11
    label.Parent = frame
    
    -- Предварительное создание интерфейса скрипта (скрытого)
    local scriptGui = Instance.new("ScreenGui")
    scriptGui.Name = "UniversalScriptGUI"
    scriptGui.Enabled = false
    scriptGui.Parent = player:WaitForChild("PlayerGui")

    return {
        gui = gui,
        frame = frame,
        label = label,
        scriptGui = scriptGui
    }
end

-- Загрузка модулей
local function loadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    
    if not success then
        warn("Ошибка загрузки модуля: "..url.."\n"..result)
        return nil
    end
    return result
end

-- Основной поток
if RunService:IsClient() then
    local loadingScreen = createLoadingScreen()
    
    -- Прогресс загрузки
    local totalAssets = #ASSET_IDS
    local loadedAssets = 0
    
    local function updateProgress()
        loadedAssets += 1
        loadingScreen.label.Text = string.format("Загрузка ассетов: %d/%d", loadedAssets, totalAssets)
    end
    
    -- Предзагрузка ассетов
    ContentProvider:PreloadAsync(ASSET_IDS, updateProgress)
    
    -- Задержка перед скрытием
    wait(1)
    
    -- Плавное исчезновение
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad)
    local tween = TweenService:Create(loadingScreen.frame, tweenInfo, {BackgroundTransparency = 1})
    tween:Play()
    
    -- Активация интерфейса скрипта
    tween.Completed:Connect(function()
        loadingScreen.gui:Destroy()
        loadingScreen.scriptGui.Enabled = true
    end)
end

-- Загрузка модулей
local shared = loadModule("https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/v2/Shared.lua")

if RunService:IsServer() then
    local server = loadModule("https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/v2/Server.lua")
    if server then server.init(shared) end
end

if RunService:IsClient() then
    local client = loadModule("https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/v2/Client.lua")
    if client then client.init(shared, loadingScreen.scriptGui) end
end
