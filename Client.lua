----- КЛИЕНТСКАЯ ЧАСТЬ -----
-- Client.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Загрузка списка администраторов с GitHub
local function LoadAdminList()
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/main/admins.txt")
    end)
    
    if success and response then
        local admins = {}
        for line in response:gmatch("[^\r\n]+") do
            admins[line:lower()] = true
        end
        return admins
    end
    
    return {["yourusername"] = true} -- Fallback
end

local AdminList = LoadAdminList()
local IsAdmin = AdminList[LocalPlayer.Name:lower()] or false

-- Создание перемещаемого интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Inc0muUI_"..tostring(math.random(10000,99999))
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainWindow"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "Добрый Читер v4"
Title.TextColor3 = Color3.fromRGB(200, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Parent = TopBar

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -10, 1, -40)
TabContainer.Position = UDim2.new(0, 5, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Функционал перемещения окна
local dragging = false
local dragStartPos
local startPos

local function UpdatePosition(input)
    local delta = input.Position - dragStartPos
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = input.Position
        startPos = MainFrame.Position
        
        -- Эффект при нажатии
        TweenService:Create(TopBar, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                TweenService:Create(TopBar, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        UpdatePosition(input)
    end
end)

-- Создание вкладок
local Tabs = {}
local CurrentTab

local function CreateTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name.."TabButton"
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(180, 180, 200)
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 12
    tabButton.Size = UDim2.new(0.2, -2, 0, 25)
    tabButton.Position = UDim2.new(#Tabs * 0.2, 0, 0, 30)
    tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    tabButton.BorderSizePixel = 0
    tabButton.Parent = MainFrame
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name.."Content"
    tabContent.Size = UDim2.new(1, 0, 1, -5)
    tabContent.Position = UDim2.new(0, 0, 0, 5)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 5
    tabContent.Visible = false
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    tabContent.Parent = TabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Name = "Layout"
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContent
    
    local tab = {
        Name = name,
        Button = tabButton,
        Content = tabContent,
        Elements = {}
    }
    
    tabButton.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Content.Visible = false
            TweenService:Create(CurrentTab.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 45),
                TextColor3 = Color3.fromRGB(180, 180, 200)
            }:Play()
        end
        
        CurrentTab = tab
        tabContent.Visible = true
        TweenService:Create(tabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 80),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }:Play()
    end)
    
    table.insert(Tabs, tab)
    return tab
end

-- Функции для создания элементов интерфейса
local function AddLabel(tab, text)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab.Content
    label.LayoutOrder = #tab.Elements + 1
    
    table.insert(tab.Elements, label)
    return label
end

local function AddButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Size = UDim2.new(1, -10, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    button.BorderSizePixel = 0
    button.Parent = tab.Content
    button.LayoutOrder = #tab.Elements + 1
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 90)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(90, 90, 110)}):Play()
        wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
        callback()
    end)
    
    table.insert(tab.Elements, button)
    return button
end

local function AddSlider(tab, text, min, max, start, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 60)
    container.BackgroundTransparency = 1
    container.Parent = tab.Content
    container.LayoutOrder = #tab.Elements + 1
    
    local label = Instance.new("TextLabel")
    label.Text = text..": "..start
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 30)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = container
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((start - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Size = UDim2.new(0, 20, 0, 20)
    sliderHandle.Position = UDim2.new((start - min) / (max - min), -10, 0.5, -10)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    sliderHandle.Text = ""
    sliderHandle.ZIndex = 2
    sliderHandle.Parent = sliderTrack
    
    local dragging = false
    local function updateSlider(input)
        local pos = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderHandle.Position = UDim2.new(pos, -10, 0.5, -10)
        label.Text = text..": "..value
        callback(value)
    end
    
    sliderHandle.MouseButton1Down:Connect(function()
        dragging = true
        TweenService:Create(sliderHandle, TweenInfo.new(0.1), {Size = UDim2.new(0, 24, 0, 24)}):Play()
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            TweenService:Create(sliderHandle, TweenInfo.new(0.1), {Size = UDim2.new(0, 20, 0, 20)}):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    sliderTrack.MouseButton1Down:Connect(function(input)
        updateSlider(input)
    end)
    
    table.insert(tab.Elements, container)
    return container
end

-- Создание вкладок
local mainTab = CreateTab("Основное")
local kindnessTab = CreateTab("Доброта")
local cleanupTab = CreateTab("Безопасность")
local adminTab

if IsAdmin then
    adminTab = CreateTab("⚡ Админ")
end

-- Функция дезинфекции
local function Cleanup()
    ScreenGui:Destroy()
    for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
        pcall(function() v:Disable() end)
    end
    setfenv(1, {})
end

-- Локальные функции персонажа
local WalkSpeed = 16
local JumpPower = 50
local IsFlying = false

-- Обновление скорости при изменении персонажа
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    char.Humanoid.WalkSpeed = WalkSpeed
    char.Humanoid.JumpPower = JumpPower
end)

-- Основные функции
AddSlider(mainTab, "Скорость", 16, 500, 16, function(v)
    WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

AddSlider(mainTab, "Прыжок", 50, 500, 50, function(v)
    JumpPower = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)

AddButton(mainTab, "Спамить декалами", function()
    ReplicatedStorage.ServerEvents:FireServer("ApplyDecals", 1365169983)
end)

AddButton(mainTab, "Летать (Вкл/Выкл)", function()
    IsFlying = not IsFlying
    if IsFlying then
        -- Реализация полета
        AddLabel(mainTab, "Режим полета активирован (Пробел - вверх, Ctrl - вниз)")
    else
        AddLabel(mainTab, "Режим полета деактивирован")
    end
end)

-- Режим Доброты
AddButton(kindnessTab, "Бан читеров", function()
    if IsAdmin then
        ReplicatedStorage.ServerEvents:FireServer("BanCheaters")
    else
        AddLabel(kindnessTab, "Ошибка: Требуются права администратора")
    end
end)

AddButton(kindnessTab, "Spooky Scary Skeletons", function()
    ReplicatedStorage.ServerEvents:FireServer("PlaySound", 3469045940)
end)

-- Система безопасности
AddLabel(cleanupTab, "Функции очистки:")
AddButton(cleanupTab, "Мягкая очистка", Cleanup)
AddButton(cleanupTab, "Полная дезинфекция", function()
    Cleanup()
    ReplicatedStorage.ServerEvents:FireServer("SelfDestruct")
    setfenv(1, {})
end)

local statusLabel = AddLabel(cleanupTab, "Статус: "..(IsAdmin and "⚡ Администратор" or "Игрок"))

-- Функции администратора
if IsAdmin then
    AddButton(adminTab, "Обновить список админов", function()
        AdminList = LoadAdminList()
        IsAdmin = AdminList[LocalPlayer.Name:lower()] or false
        statusLabel.Text = "Статус: "..(IsAdmin and "⚡ Администратор" or "Игрок")
    end)
    
    AddButton(adminTab, "Внедрить сервер", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/iris-fecokev/My-Roblox-Script/main/Server.lua", true))()
    end)
    
    AddButton(adminTab, "Применить декалы", function()
        ReplicatedStorage.ServerEvents:FireServer("ApplyDecals", 1365169983)
    end)
    
    AddButton(adminTab, "Проиграть звук", function()
        ReplicatedStorage.ServerEvents:FireServer("PlaySound", 3469045940)
    end)
end

-- Кнопка закрытия
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Активация первой вкладки
if #Tabs > 0 then
    Tabs[1].Button:SetAttribute("Pressed", true)
    Tabs[1].Content.Visible = true
    Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Tabs[1].Button.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- Анимация появления
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.3), {
    Size = UDim2.new(0, 400, 0, 500),
    Position = UDim2.new(0.5, -200, 0.5, -250)
}):Play()
