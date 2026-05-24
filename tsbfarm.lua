-- =================================================================
-- إعدادات الحسابات الأساسية (ضع الأسماء الحقيقية هنا)
local MAIN_ACCOUNT_NAME = "ضع_اسم_حساب_المين_هنا"
local ALT_ACCOUNTS = {
    "الآلت_الأول",
    "الآلت_الثاني",
    "الآلت_الثالث",
}
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- مشاركة الإحداثيات عبر السيرفر لكي يراها الآلت
local function setGlobalSpawn(pos)
    game:SetAttribute(MAIN_ACCOUNT_NAME .. "_SharedSpawn", pos)
end

local function getGlobalSpawn()
    return game:GetAttribute(MAIN_ACCOUNT_NAME .. "_SharedSpawn")
end

_G.AltResetDelay = 4.0 -- وقت رست الآلت الافتراضي (الحين صار دقيق 100%)
_G.FarmActive = false  -- وضع الفارم للمين

local function isAltAccount(playerName)
    return table.find(ALT_ACCOUNTS, playerName) ~= nil
end

-- [1] نظام الـ Custom Spawnpoint الآمن (يطبق على المين والآلت)
local function safeTeleport(character, position)
    local hrp = character:WaitForChild("HumanoidRootPart", 10)
    if hrp then
        hrp.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
        hrp.Anchored = true
        task.wait(0.5)
        hrp.Anchored = false
    end
end

-- ريسبون المين
LocalPlayer.CharacterAdded:Connect(function(char)
    if LocalPlayer.Name == MAIN_ACCOUNT_NAME and _G.SavedSpawnPoint then
        safeTeleport(char, _G.SavedSpawnPoint)
    end
end)

-- ريسبون الآلت + بدء عداد الرست بدقة من نقطة الصفر
if isAltAccount(LocalPlayer.Name) then
    LocalPlayer.CharacterAdded:Connect(function(char)
        -- 1. ينتقل للـ Custom Spawnpoint أول ما يرسبن إذا المين حدد مكان
        local sharedPos = getGlobalSpawn()
        if sharedPos then
            safeTeleport(char, sharedPos)
        end
        
        -- 2. يبدأ يحسب وقت الرست الحقيقي من الحين (مستحيل يرست فوراً)
        local humanoid = char:WaitForChild("Humanoid", 10)
        task.wait(_G.AltResetDelay)
        if humanoid and humanoid.Health > 0 then
            humanoid.Health = 0
        end
    end)
end

-- [2] الـ LoopGoto الأمامي (لاصق قدام المين وهو عايش)
RunService.Heartbeat:Connect(function()
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

-- [3] واجهة التحكم (UI)
local function buildUI()
    if CoreGui:FindFirstChild("DirectFarmUI") then CoreGui.DirectFarmUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "DirectFarmUI"

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 260, 0, 240)
    MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.Active = true
    MainFrame.Draggable = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 15
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

    if LocalPlayer.Name == MAIN_ACCOUNT_NAME then
        Title.Text = "لوحة الـ MAIN الرئيسي"

        local ToggleBtn = Instance.new("TextButton", MainFrame)
        ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
        ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
        ToggleBtn.Text = "تفعيل ضرب مهارة 4: مـعـطّـل"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        ToggleBtn.TextColor3 = Color3.new(1,1,1)
        ToggleBtn.Font = Enum.Font.SourceSansBold

        ToggleBtn.MouseButton1Click:Connect(function()
            _G.FarmActive = not _G.FarmActive
            if _G.FarmActive then
                ToggleBtn.Text = "تفعيل ضرب مهارة 4: شـغّـال"
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
            else
                ToggleBtn.Text = "تفعيل ضرب مهارة 4: مـعـطّـل"
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            end
        end)

        local SpawnBtn = Instance.new("TextButton", MainFrame)
        SpawnBtn.Size = UDim2.new(0.9, 0, 0, 40)
        SpawnBtn.Position = UDim2.new(0.05, 0, 0.42, 0)
        SpawnBtn.Text = "تحديد موقع الريسبون (للكل)"
        SpawnBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        SpawnBtn.TextColor3 = Color3.new(1,1,1)
        
        SpawnBtn.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = LocalPlayer.Character.HumanoidRootPart.Position
                _G.SavedSpawnPoint = pos
                setGlobalSpawn(pos) -- إرسال الإحداثيات للآلتس
                SpawnBtn.Text = "تم حفظ الموقع للكل ✔"
                task.wait(1.5)
                SpawnBtn.Text = "تحديد موقع الريسبون (للكل)"
            end
        end)

    elseif isAltAccount(LocalPlayer.Name) then
        Title.Text = "لوحة الـ ALT الفرعي"
        
        local TimeLabel = Instance.new("TextLabel", MainFrame)
        TimeLabel.Size = UDim2.new(0.5, 0, 0, 40)
        TimeLabel.Position = UDim2.new(0.05, 0, 0.3, 0)
        TimeLabel.Text = "وقت رست الحساب:"
        TimeLabel.TextColor3 = Color3.new(1,1,1)
        TimeLabel.BackgroundTransparency = 1
        TimeLabel.TextSize = 14

        local TimeBox = Instance.new("TextBox", MainFrame)
        TimeBox.Size = UDim2.new(0.35, 0, 0, 40)
        TimeBox.Position = UDim2.new(0.55, 0, 0.3, 0)
        TimeBox.Text = tostring(_G.AltResetDelay)
        TimeBox.BackgroundColor3 = Color3.fromRGB(50,50,55)
        TimeBox.TextColor3 = Color3.new(0,1,0)
        TimeBox.TextSize = 14
        
        TimeBox.FocusLost:Connect(function()
            local num = tonumber(TimeBox.Text)
            if num then _G.AltResetDelay = num else TimeBox.Text = tostring(_G.AltResetDelay) end
        end)
    end
end

-- [4] منطق الربط الحقيقي (المين يضرب عند موت الآلت)
if LocalPlayer.Name == MAIN_ACCOUNT_NAME then
    buildUI()
    
    local function watchAltDeath(altPlayer)
        altPlayer.CharacterAdded:Connect(function(altChar)
            local humanoid = altChar:WaitForChild("Humanoid", 10)
            if humanoid then
                humanoid.Died:Connect(function()
                    if not _G.FarmActive then return end
                    
                    -- ضرب المهارة 4 فوراً عند رست المين
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Four, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Four, false, game)
                    
                    -- رست للمين بعد ثانية واحدة
                    task.wait(1)
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.Health = 0
                    end
                end)
            end
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if isAltAccount(player.Name) then watchAltDeath(player) end
    end
    Players.PlayerAdded:Connect(function(player)
        if isAltAccount(player.Name) then watchAltDeath(player) end
    end)
elseif isAltAccount(LocalPlayer.Name) then
    buildUI()
end
