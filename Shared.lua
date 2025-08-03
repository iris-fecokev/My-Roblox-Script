-- Shared.lua
local shared = {}

shared.Settings = {
    FlySpeed = 50,
    JumpPower = 100,
    SpinSpeed = 30,
    TeleportHistory = 0.01, -- 10ms
    KindnessMode = false
}

shared.Assets = {
    Decal = 13077303105,
    SpookySound = 111344038407932,
    Shirt = 18512801325,
    Pants = 107896578601954,
    BodyParts = {
        LeftLeg = 132971777995699,
        RightLeg = 71037238818761,
        Torso = 82534789806334,
        LeftArm = 129913805701008,
        RightArm = 119079173538697
    }
}

shared.CheatDetection = {
    FlyThreshold = 50,
    SpinThreshold = 20,
    SpeedThreshold = 100
}

-- Серверные функции
shared.ServerFunctions = {
    BanPlayer = function(player, reason) end,
    ReportPlayer = function(player, reason) end
}

return shared
