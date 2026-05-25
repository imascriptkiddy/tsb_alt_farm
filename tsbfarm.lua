local MAIN_ACCOUNT_NAME = getgenv().mainName
local ALT_ACCOUNTS = getgenv().altNames

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local AUTO_SPAWN_POSITION = Vector3.new(-2.13, 433.86, 576.61)

local connections = {}

local function setGlobalSpawn(pos)
    game:SetAttribute(MAIN_ACCOUNT_NAME .. "_SharedSpawn", pos)
end

local function getGlobalSpawn()
    return game:GetAttribute(MAIN_ACCOUNT_NAME .. "_SharedSpawn")
end

_G.AltResetDelay = 4.0
_G.FarmActive = true 

if LocalPlayer.Name == MAIN_ACCOUNT_NAME then
    _G.SavedSpawnPoint = AUTO_SPAWN_POSITION
    setGlobalSpawn(AUTO_SPAWN_POSITION)
end

local function isAltAccount(playerName)
    return table.find(ALT_ACCOUNTS, playerName) ~= nil
end

local function safeTeleport(character, position)
    local hrp = character:WaitForChild("HumanoidRootPart", 10)
    if hrp then
        hrp.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
        hrp.Anchored = true
        task.wait(0.5)
        hrp.Anchored = false
    end
end

local function handleAltReset(char)
    local sharedPos = getGlobalSpawn()
    if sharedPos then
        safeTeleport(char, sharedPos)
    end
    
    local humanoid = char:WaitForChild("Humanoid", 10)
    task.wait(_G.AltResetDelay)
    if humanoid and humanoid.Health > 0 then
        humanoid.Health = 0
    end
end

if LocalPlayer.Character then
    local sharedPos = getGlobalSpawn() or _G.SavedSpawnPoint
    if sharedPos then
        safeTeleport(LocalPlayer.Character, sharedPos)
    end
    
    if isAltAccount(LocalPlayer.Name) then
        task.spawn(function()
            handleAltReset(LocalPlayer.Character)
        end)
    end
end

local mainCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
    if LocalPlayer.Name == MAIN_ACCOUNT_NAME and _G.SavedSpawnPoint then
        safeTeleport(char, _G.SavedSpawnPoint)
    end
end)
table.insert(connections, mainCharConn)

if isAltAccount(LocalPlayer.Name) then
    local altCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
        handleAltReset(char)
    end)
    table.insert(connections, altCharConn)
end

local loopConn = RunService.Heartbeat:Connect(function()
    if isAltAccount(LocalPlayer.Name) then
        local mainPlayer = Players:FindFirstChild(MAIN_ACCOUNT_NAME)
        if mainPlayer and mainPlayer.Character and LocalPlayer.Character then
            local mainHRP = mainPlayer.Character:FindFirstChild("HumanoidRootPart")
            local altHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local altHum = LocalPlayer.Character:FindFirstChild("Humanoid")
            
            if mainHRP and altHRP and altHum and altHum.Health > 0 then
                altHRP.CFrame = mainHRP.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0)
                altHRP.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)
table.insert(connections, loopConn)

local function buildUI()
    if CoreGui:FindFirstChild("DirectFarmUI") then CoreGui.DirectFarmUI:Destroy() end

    local colors = {
        bg = Color3.fromRGB(15, 15, 20),
        accent = Color3.fromRGB(255, 0, 50),
        text = Color3.fromRGB(240, 240, 240),
        active = Color3.fromRGB(0, 255, 120)
    }

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "DirectFarmUI"
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 220, 0, 140)
    MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = colors.bg
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 10)
    
    local NeonBorder = Instance.new("Frame", MainFrame)
    NeonBorder.Size = UDim2.new(1, 4, 1, 4)
    NeonBorder.Position = UDim2.new(0, -2, 0, -2)
    NeonBorder.BackgroundColor3 = (LocalPlayer.Name == MAIN_ACCOUNT_NAME) and colors.active or colors.accent
    NeonBorder.ZIndex = 0
    Instance.new("UICorner", NeonBorder).CornerRadius = UDim.new(0, 11)

    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Header.BorderSizePixel = 0
    Header.ZIndex = 2
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 10)

    local HeaderHide = Instance.new("Frame", Header)
    HeaderHide.Size = UDim2.new(1, 0, 0, 10)
    HeaderHide.Position = UDim2.new(0, 0, 1, -10)
    HeaderHide.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    HeaderHide.BorderSizePixel = 0
    HeaderHide.ZIndex = 1

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(0.8, 0, 1, 0)
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.TextColor3 = (LocalPlayer.Name == MAIN_ACCOUNT_NAME) and colors.active or colors.accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3
    Title.BackgroundTransparency = 1

    local StatusDot = Instance.new("Frame", Header)
    StatusDot.Size = UDim2.new(0, 8, 0, 8)
    StatusDot.Position = UDim2.new(0.9, 0, 0.5, -4)
    StatusDot.BackgroundColor3 = (LocalPlayer.Name == MAIN_ACCOUNT_NAME) and colors.active or colors.accent
    StatusDot.ZIndex = 3
    local DotCorner = Instance.new("UICorner", StatusDot)
    DotCorner.CornerRadius = UDim.new(1, 0)

    if LocalPlayer.Name == MAIN_ACCOUNT_NAME then
        Title.Text = "MAIN PANEL"

        local ToggleBtn = Instance.new("TextButton", MainFrame)
        ToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
        ToggleBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
        ToggleBtn.Text = "Skill 4: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        ToggleBtn.TextColor3 = colors.active
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.TextSize = 15
        ToggleBtn.AutoButtonColor = false
        ToggleBtn.ZIndex = 2
        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
        
        local BtnBorder = Instance.new("UIStroke", ToggleBtn)
        BtnBorder.Color = colors.active
        BtnBorder.Thickness = 1
        BtnBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        ToggleBtn.MouseButton1Click:Connect(function()
            _G.FarmActive = not _G.FarmActive
            local targetColor = _G.FarmActive and colors.active or colors.accent
            local targetText = _G.FarmActive and "Skill 4: ON" or "Skill 4: OFF"
            
            ToggleBtn.Text = targetText
            TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {TextColor3 = targetColor}):Play()
            TweenService:Create(BtnBorder, TweenInfo.new(0.3), {Color = targetColor}):Play()
            TweenService:Create(Title, TweenInfo.new(0.3), {TextColor3 = targetColor}):Play()
            TweenService:Create(NeonBorder, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(StatusDot, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
            
            if _G.FarmActive then
                task.spawn(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Four, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Four, false, game)
                end)
            end
        end)

    elseif isAltAccount(LocalPlayer.Name) then
        Title.Text = "ALT PANEL"
        
        local TimeLabel = Instance.new("TextLabel", MainFrame)
        TimeLabel.Size = UDim2.new(0.5, 0, 0, 30)
        TimeLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
        TimeLabel.Text = "Reset Time:"
        TimeLabel.TextColor3 = colors.text
        TimeLabel.Font = Enum.Font.Gotham
        TimeLabel.TextSize = 13
        TimeLabel.BackgroundTransparency = 1
        TimeLabel.TextXAlignment = Enum.TextXAlignment.Left

        local TimeBox = Instance.new("TextBox", MainFrame)
        TimeBox.Size = UDim2.new(0.35, 0, 0, 30)
        TimeBox.Position = UDim2.new(0.55, 0, 0.35, 0)
        TimeBox.Text = tostring(_G.AltResetDelay)
        TimeBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TimeBox.TextColor3 = colors.accent
        TimeBox.Font = Enum.Font.GothamBold
        TimeBox.TextSize = 14
        Instance.new("UICorner", TimeBox).CornerRadius = UDim.new(0, 5)
        
        local BoxBorder = Instance.new("UIStroke", TimeBox)
        BoxBorder.Color = colors.accent
        BoxBorder.Thickness = 1
        BoxBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        local Desc = Instance.new("TextLabel", MainFrame)
        Desc.Size = UDim2.new(0.9, 0, 0, 30)
        Desc.Position = UDim2.new(0.05, 0, 0.65, 0)
        Desc.Text = "(Left CTRL to Close)"
        Desc.TextColor3 = Color3.fromRGB(130, 130, 130)
        Desc.Font = Enum.Font.Gotham
        Desc.TextSize = 11
        Desc.BackgroundTransparency = 1
        
        TimeBox.FocusLost:Connect(function()
            local num = tonumber(TimeBox.Text)
            if num then 
                _G.AltResetDelay = num 
                TweenService:Create(TimeBox, TweenInfo.new(0.2), {TextColor3 = colors.active}):Play()
                task.wait(0.4)
                TweenService:Create(TimeBox, TweenInfo.new(0.2), {TextColor3 = colors.accent}):Play()
            else 
                TimeBox.Text = tostring(_G.AltResetDelay) 
            end
        end)
    end
end

if LocalPlayer.Name == MAIN_ACCOUNT_NAME then
    buildUI()
    
    local function watchAltDeath(altPlayer)
        local conn1 = altPlayer.CharacterAdded:Connect(function(altChar)
            local humanoid = altChar:WaitForChild("Humanoid", 10)
            if humanoid then
                local conn2 = humanoid.Died:Connect(function()
                    if not _G.FarmActive then return end
                    
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Four, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Four, false, game)
                    
                    task.wait(1)
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.Health = 0
                    end
                end)
                table.insert(connections, conn2)
            end
        end)
        table.insert(connections, conn1)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if isAltAccount(player.Name) then watchAltDeath(player) end
    end
    local pAddConn = Players.PlayerAdded:Connect(function(player)
        if isAltAccount(player.Name) then watchAltDeath(player) end
    end)
    table.insert(connections, pAddConn)
elseif isAltAccount(LocalPlayer.Name) then
    buildUI()
end

local closeConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        _G.FarmActive = false
        if CoreGui:FindFirstChild("DirectFarmUI") then
            CoreGui.DirectFarmUI:Destroy()
        end
        for _, conn in ipairs(connections) do
            if conn then conn:Disconnect() end
        end
        script:Destroy()
    end
end)
table.insert(connections, closeConn)

print("Script successfully loaded!")
-- Smart Anti-AFK for Alt Farming (No Movement)
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- إلغاء كود الطرد عند الخمول بدون تحريك الشخصية
if LocalPlayer then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        print("Anti-AFK: Bypassed kick signal safely!")
    end)
end

print("Anti-AFK successfully working")
