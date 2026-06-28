-- ============================================================
-- FUSION HUB v2.0 MEGA — ПОЛНЫЙ РАБОЧИЙ СКРИПТ
-- ============================================================
-- Этот файл загружается по ссылке:
-- https://raw.githubusercontent.com/TAYFANTOM/FusionHub/main/Main.lua
-- ============================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- 1. КОНФИГУРАЦИЯ ЦВЕТОВ
-- ============================================================
local Colors = {
    Primary = Color3.fromRGB(0, 180, 255),
    Secondary = Color3.fromRGB(100, 100, 255),
    Background = Color3.fromRGB(20, 20, 30),
    Accent = Color3.fromRGB(0, 255, 200),
    Text = Color3.fromRGB(255, 255, 255),
    Danger = Color3.fromRGB(255, 50, 50),
    Success = Color3.fromRGB(50, 255, 50),
    Warning = Color3.fromRGB(255, 200, 0)
}

-- ============================================================
-- 2. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================
local function getCharacter()
    local char = LocalPlayer.Character
    if not char or not char.Parent then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    return char
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getClosestPlayer()
    local root = getRootPart()
    if not root then return nil end
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            if hrp and hrp.Parent then
                local mag = (root.Position - hrp.Position).Magnitude
                if mag < dist then
                    closest, dist = plr, mag
                end
            end
        end
    end
    return closest
end

local function getPlayerByName(name)
    for _, plr in ipairs(Players:GetPlayers()) do
        if string.lower(plr.Name):find(string.lower(name)) then
            return plr
        end
    end
    return nil
end

-- ============================================================
-- 3. БОЕВЫЕ ФУНКЦИИ
-- ============================================================
local function flingPlayer(target)
    if not target or not target.Character then return end
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local root = getRootPart()
    if not targetRoot or not root then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = root.CFrame.LookVector * 500 + Vector3.new(0, 250, 0)
    bv.Parent = targetRoot
    task.wait(0.5)
    bv:Destroy()
end

local function killPlayer(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChild("Humanoid")
    if hum then hum.Health = 0 end
end

local function freezePlayer(target, duration)
    duration = duration or 5
    if not target or not target.Character then return end
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = targetRoot
        task.wait(duration)
        bv:Destroy()
    end
end

local function explodePlayer(target)
    if not target or not target.Character then return end
    for _, part in ipairs(target.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.new(
                math.random(-1000, 1000),
                math.random(500, 2000),
                math.random(-1000, 1000)
            )
            bv.Parent = part
            task.wait(0.1)
            bv:Destroy()
        end
    end
end

local function teleportToPlayer(target)
    if not target or not target.Character then return end
    local root = getRootPart()
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if root and targetRoot then
        root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
    end
end

local function bringPlayer(target)
    if not target or not target.Character then return end
    local root = getRootPart()
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if root and targetRoot then
        targetRoot.CFrame = root.CFrame + Vector3.new(0, 3, 0)
    end
end

-- ============================================================
-- 4. ПЕРЕМЕННЫЕ СОСТОЯНИЯ
-- ============================================================
local noclipEnabled = false
local flyEnabled = false
local flySpeed = 50
local espEnabled = false
local espObjects = {}
local antiDeathEnabled = false
local infiniteJumpEnabled = false
local fullBrightEnabled = false
local autoClickEnabled = false
local autoClickDelay = 0.1
local loopFlingActive = false
local loopFlingTarget = nil

-- ============================================================
-- 5. ФУНКЦИИ ДЛЯ ВКЛЮЧЕНИЯ/ВЫКЛЮЧЕНИЯ
-- ============================================================
local function toggleNoclip(state)
    noclipEnabled = state
    task.spawn(function()
        while noclipEnabled do
            local char = getCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

local function toggleFly(state)
    flyEnabled = state
    task.spawn(function()
        local bodyVelocity = nil
        while flyEnabled do
            local root = getRootPart()
            if root then
                if not bodyVelocity then
                    bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bodyVelocity.Parent = root
                end
                local direction = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
                if direction.Magnitude > 0 then
                    direction = direction.Unit * flySpeed
                end
                bodyVelocity.Velocity = direction
            else
                if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
            end
            task.wait(0.05)
        end
        if bodyVelocity then bodyVelocity:Destroy() end
    end)
end

local function toggleESP(state)
    espEnabled = state
    if state then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bill = Instance.new("BillboardGui")
                    bill.Name = "FusionESP"
                    bill.Size = UDim2.new(0, 200, 0, 50)
                    bill.Adornee = hrp
                    bill.AlwaysOnTop = true
                    bill.Parent = hrp
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = plr.Name .. " ❤ " .. tostring(plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health or 100)
                    label.TextColor3 = Colors.Danger
                    label.TextScaled = true
                    label.Parent = bill
                    table.insert(espObjects, bill)
                end
            end
        end
    else
        for _, obj in ipairs(espObjects) do
            pcall(function() obj:Destroy() end)
        end
        espObjects = {}
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "FusionESP" then
                pcall(function() v:Destroy() end)
            end
        end
    end
end

local function toggleAntiDeath(state)
    antiDeathEnabled = state
    task.spawn(function()
        while antiDeathEnabled do
            local hum = getHumanoid()
            if hum and hum.Health <= 0 then
                hum.Health = 100
            end
            task.wait(0.2)
        end
    end)
end

local function toggleInfiniteJump(state)
    infiniteJumpEnabled = state
    local hum = getHumanoid()
    if hum then
        hum.JumpPower = state and 1000 or 50
    end
end

local function toggleFullBright(state)
    fullBrightEnabled = state
    if state then
        game.Lighting.Brightness = 2
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        game.Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        game.Lighting.GlobalShadows = false
    else
        game.Lighting.Brightness = 0.5
        game.Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        game.Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        game.Lighting.GlobalShadows = true
    end
end

local function toggleAutoClick(state)
    autoClickEnabled = state
    task.spawn(function()
        while autoClickEnabled do
            mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
            task.wait(autoClickDelay)
            mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
            task.wait(autoClickDelay)
        end
    end)
end

local function loopFling(target)
    loopFlingActive = true
    loopFlingTarget = target
    task.spawn(function()
        while loopFlingActive and loopFlingTarget and loopFlingTarget.Character do
            local root = getRootPart()
            local targetRoot = loopFlingTarget.Character:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Velocity = (targetRoot.Position - root.Position).Unit * 300 + Vector3.new(0, 100, 0)
                bv.Parent = targetRoot
                task.wait(0.05)
                bv:Destroy()
            end
            task.wait()
        end
    end)
end

-- ============================================================
-- 6. СОЗДАНИЕ GUI
-- ============================================================
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FusionHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Градиентный фон
    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 20, 1, 20)
    Glow.Position = UDim2.new(0, -10, 0, -10)
    Glow.BackgroundColor3 = Colors.Primary
    Glow.BackgroundTransparency = 0.85
    Glow.BorderSizePixel = 0
    Glow.Parent = MainFrame
    
    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(0, 20)
    GlowCorner.Parent = Glow
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Заголовок
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Colors.Primary
    TitleBar.BackgroundTransparency = 0.3
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -80, 1, 0)
    TitleText.Position = UDim2.new(0, 20, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "FUSION HUB v2.0 MEGA"
    TitleText.TextColor3 = Colors.Text
    TitleText.TextSize = 20
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Кнопка закрытия
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Colors.Danger
    CloseBtn.TextSize = 22
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Контейнер вкладок
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, 0, 0, 35)
    TabsContainer.Position = UDim2.new(0, 0, 0, 40)
    TabsContainer.BackgroundColor3 = Colors.Background
    TabsContainer.BackgroundTransparency = 0.5
    TabsContainer.BorderSizePixel = 0
    TabsContainer.Parent = MainFrame
    
    -- Контент
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, -75)
    Content.Position = UDim2.new(0, 0, 0, 75)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame
    
    -- Командная строка
    local CmdBar = Instance.new("TextBox")
    CmdBar.Size = UDim2.new(0.9, 0, 0, 30)
    CmdBar.Position = UDim2.new(0.05, 0, 1, -40)
    CmdBar.BackgroundColor3 = Colors.Background
    CmdBar.BackgroundTransparency = 0.2
    CmdBar.BorderSizePixel = 0
    CmdBar.TextColor3 = Colors.Text
    CmdBar.PlaceholderText = "Введите команду (fly, noclip, esp, speed 50, goto Name)..."
    CmdBar.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    CmdBar.TextSize = 14
    CmdBar.Font = Enum.Font.Gotham
    CmdBar.ClearTextOnFocus = false
    CmdBar.Parent = MainFrame
    
    local CmdCorner = Instance.new("UICorner")
    CmdCorner.CornerRadius = UDim.new(0, 8)
    CmdCorner.Parent = CmdBar
    
    -- Переменные для вкладок
    local Tabs = {}
    local TabButtons = {}
    local ActiveTab = nil
    
    -- Функция создания вкладки
    local function CreateTab(name)
        local TabContent = Instance.new("Frame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = Content
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 100, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Colors.Text
        TabBtn.TextSize = 14
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Parent = TabsContainer
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, btn in pairs(TabButtons) do
                btn.TextColor3 = Colors.Text
                btn.BackgroundTransparency = 1
            end
            TabBtn.TextColor3 = Colors.Primary
            TabBtn.BackgroundTransparency = 0.2
            for _, tab in pairs(Tabs) do
                tab.Content.Visible = false
            end
            TabContent.Visible = true
        end)
        
        table.insert(TabButtons, TabBtn)
        local Tab = {
            Content = TabContent,
            Objects = {},
            Button = TabBtn
        }
        table.insert(Tabs, Tab)
        
        if not ActiveTab then
            TabBtn.TextColor3 = Colors.Primary
            TabBtn.BackgroundTransparency = 0.2
            TabContent.Visible = true
            ActiveTab = Tab
        end
        
        -- Методы для вкладки
        function Tab:CreateSection(title)
            local Section = Instance.new("TextLabel")
            Section.Size = UDim2.new(1, -20, 0, 25)
            Section.Position = UDim2.new(0, 10, 0, #Tab.Objects * 35 + 5)
            Section.BackgroundTransparency = 1
            Section.Text = title
            Section.TextColor3 = Colors.Secondary
            Section.TextSize = 13
            Section.Font = Enum.Font.GothamBold
            Section.TextXAlignment = Enum.TextXAlignment.Left
            Section.Parent = TabContent
            table.insert(Tab.Objects, Section)
            return Section
        end
        
        function Tab:CreateButton(label, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -20, 0, 32)
            Btn.Position = UDim2.new(0, 10, 0, #Tab.Objects * 35 + 5)
            Btn.BackgroundColor3 = Colors.Primary
            Btn.BackgroundTransparency = 0.2
            Btn.BorderSizePixel = 0
            Btn.Text = label
            Btn.TextColor3 = Colors.Text
            Btn.TextSize = 14
            Btn.Font = Enum.Font.Gotham
            Btn.Parent = TabContent
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Btn
            
            Btn.MouseButton1Click:Connect(callback)
            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
            end)
            
            table.insert(Tab.Objects, Btn)
            return Btn
        end
        
        function Tab:CreateToggle(label, default, callback)
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -20, 0, 30)
            Container.Position = UDim2.new(0, 10, 0, #Tab.Objects * 35 + 5)
            Container.BackgroundTransparency = 1
            Container.Parent = TabContent
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = label
            Label.TextColor3 = Colors.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Container
            
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(0, 60, 0, 25)
            ToggleBtn.Position = UDim2.new(1, -65, 0, 2.5)
            ToggleBtn.BackgroundColor3 = default and Colors.Success or Colors.Danger
            ToggleBtn.BorderSizePixel = 0
            ToggleBtn.Text = default and "ON" or "OFF"
            ToggleBtn.TextColor3 = Colors.Text
            ToggleBtn.TextSize = 12
            ToggleBtn.Font = Enum.Font.GothamBold
            ToggleBtn.Parent = Container
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 4)
            ToggleCorner.Parent = ToggleBtn
            
            local State = default
            ToggleBtn.MouseButton1Click:Connect(function()
                State = not State
                ToggleBtn.Text = State and "ON" or "OFF"
                ToggleBtn.BackgroundColor3 = State and Colors.Success or Colors.Danger
                callback(State)
            end)
            
            table.insert(Tab.Objects, Container)
            return ToggleBtn
        end
        
        function Tab:CreateSlider(label, min, max, default, callback)
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -20, 0, 50)
            Container.Position = UDim2.new(0, 10, 0, #Tab.Objects * 35 + 5)
            Container.BackgroundTransparency = 1
            Container.Parent = TabContent
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 0, 20)
            Label.BackgroundTransparency = 1
            Label.Text = label .. ": " .. tostring(default)
            Label.TextColor3 = Colors.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Container
            
            local Slider = Instance.new("Frame")
            Slider.Size = UDim2.new(1, 0, 0, 6)
            Slider.Position = UDim2.new(0, 0, 0, 35)
            Slider.BackgroundColor3 = Colors.Background
            Slider.BackgroundTransparency = 0.3
            Slider.BorderSizePixel = 0
            Slider.Parent = Container
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Colors.Primary
            Fill.BorderSizePixel = 0
            Fill.Parent = Slider
            
            local SliderBtn = Instance.new("TextButton")
            SliderBtn.Size = UDim2.new(0, 16, 0, 16)
            SliderBtn.Position = UDim2.new((default - min) / (max - min), -8, 0, -5)
            SliderBtn.BackgroundColor3 = Colors.Text
            SliderBtn.BorderSizePixel = 0
            SliderBtn.Text = ""
            SliderBtn.Parent = Slider
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(1, 0)
            BtnCorner.Parent = SliderBtn
            
            local Dragging = false
            SliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                end
            end)
            SliderBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local Pos = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
                    local Val = min + (max - min) * Pos
                    Val = math.round(Val)
                    Fill.Size = UDim2.new(Pos, 0, 1, 0)
                    SliderBtn.Position = UDim2.new(Pos, -8, 0, -5)
                    Label.Text = label .. ": " .. tostring(Val)
                    callback(Val)
                end
            end)
            
            table.insert(Tab.Objects, Container)
            return Slider
        end
        
        function Tab:CreateInput(label, placeholder, callback)
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -20, 0, 35)
            Container.Position = UDim2.new(0, 10, 0, #Tab.Objects * 35 + 5)
            Container.BackgroundTransparency = 1
            Container.Parent = TabContent
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.3, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = label
            Label.TextColor3 = Colors.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Container
            
            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(0.65, 0, 1, 0)
            Input.Position = UDim2.new(0.35, 0, 0, 0)
            Input.BackgroundColor3 = Colors.Background
            Input.BackgroundTransparency = 0.2
            Input.BorderSizePixel = 0
            Input.Text = ""
            Input.PlaceholderText = placeholder
            Input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            Input.TextColor3 = Colors.Text
            Input.TextSize = 14
            Input.Font = Enum.Font.Gotham
            Input.Parent = Container
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 4)
            InputCorner.Parent = Input
            
            Input.FocusLost:Connect(function()
                callback(Input.Text)
            end)
            
            table.insert(Tab.Objects, Container)
            return Input
        end
        
        return Tab
    end
    
    -- ============================================================
    -- 7. СОЗДАНИЕ ВСЕХ ВКЛАДОК
    -- ============================================================
    local CombatTab = CreateTab("⚔ Бой")
    local MovementTab = CreateTab("🏃 Движ")
    local VisualTab = CreateTab("👁 Визуал")
    local PlayerTab = CreateTab("👤 Игроки")
    local ServerTab = CreateTab("🌐 Сервер")
    local MiscTab = CreateTab("🛠 Разное")
    
    -- ============================================================
    -- 8. ЗАПОЛНЕНИЕ ВКЛАДКИ "БОЙ"
    -- ============================================================
    CombatTab:CreateSection("🎯 Атака")
    CombatTab:CreateButton("💥 Флинг ближайшего", function()
        local target = getClosestPlayer()
        if target then flingPlayer(target) end
    end)
    CombatTab:CreateButton("🔥 Бесконечный флинг", function()
        local target = getClosestPlayer()
        if target then loopFling(target) end
    end)
    CombatTab:CreateButton("⏹ Остановить флинг", function()
        loopFlingActive = false
        loopFlingTarget = nil
    end)
    CombatTab:CreateButton("💀 Убить ближайшего", function()
        local target = getClosestPlayer()
        if target then killPlayer(target) end
    end)
    CombatTab:CreateButton("🧊 Заморозить (5с)", function()
        local target = getClosestPlayer()
        if target then freezePlayer(target, 5) end
    end)
    CombatTab:CreateButton("💥 Взорвать игрока", function()
        local target = getClosestPlayer()
        if target then explodePlayer(target) end
    end)
    
    -- ============================================================
    -- 9. ЗАПОЛНЕНИЕ ВКЛАДКИ "ДВИЖЕНИЕ"
    -- ============================================================
    MovementTab:CreateSection("🚀 Режимы")
    MovementTab:CreateToggle("Ноклип", false, function(state)
        toggleNoclip(state)
    end)
    MovementTab:CreateToggle("Полёт (WASD+Space+Shift)", false, function(state)
        toggleFly(state)
    end)
    MovementTab:CreateSlider("Скорость полёта", 10, 200, 50, function(val)
        flySpeed = val
    end)
    MovementTab:CreateToggle("Бесконечный прыжок", false, function(state)
        toggleInfiniteJump(state)
    end)
    
    MovementTab:CreateSection("🏃 Настройки")
    MovementTab:CreateSlider("Скорость ходьбы", 0, 100, 16, function(val)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = val end
    end)
    MovementTab:CreateSlider("Сила прыжка", 0, 250, 50, function(val)
        local hum = getHumanoid()
        if hum then hum.JumpPower = val end
    end)
    MovementTab:CreateSlider("Гравитация", -200, 500, 196.2, function(val)
        workspace.Gravity = val
    end)
    MovementTab:CreateButton("🔄 Сбросить настройки", function()
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        workspace.Gravity = 196.2
        flySpeed = 50
    end)
    
    -- ============================================================
    -- 10. ЗАПОЛНЕНИЕ ВКЛАДКИ "ВИЗУАЛ"
    -- ============================================================
    VisualTab:CreateSection("👁 Визуальные эффекты")
    VisualTab:CreateToggle("ESP (имена и здоровье)", false, function(state)
        toggleESP(state)
    end)
    VisualTab:CreateButton("🔄 Обновить ESP", function()
        toggleESP(false)
        task.wait(0.5)
        toggleESP(true)
    end)
    VisualTab:CreateToggle("Полная яркость", false, function(state)
        toggleFullBright(state)
    end)
    VisualTab:CreateButton("☀ День", function()
        game.Lighting.TimeOfDay = "12:00:00"
    end)
    VisualTab:CreateButton("🌙 Ночь", function()
        game.Lighting.TimeOfDay = "00:00:00"
    end)
    
    -- ============================================================
    -- 11. ЗАПОЛНЕНИЕ ВКЛАДКИ "ИГРОКИ"
    -- ============================================================
    PlayerTab:CreateSection("🎯 Телепортация")
    PlayerTab:CreateButton("📦 К ближайшему", function()
        local target = getClosestPlayer()
        if target then teleportToPlayer(target) end
    end)
    PlayerTab:CreateInput("Имя игрока", "Введите имя", function(text)
        local target = getPlayerByName(text)
        if target then teleportToPlayer(target) end
    end)
    PlayerTab:CreateButton("🌀 Притянуть к себе", function()
        local target = getClosestPlayer()
        if target then bringPlayer(target) end
    end)
    
    -- ============================================================
    -- 12. ЗАПОЛНЕНИЕ ВКЛАДКИ "СЕРВЕР"
    -- ============================================================
    ServerTab:CreateSection("🌐 Управление сервером")
    ServerTab:CreateButton("🔄 Режоин", function()
        TeleportService:Teleport(game.PlaceId)
    end)
    ServerTab:CreateButton("🔄 Хоп сервера", function()
        local servers = {}
        local success, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
        end)
        if success and data and data.data then
            for _, v in ipairs(data.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
            if #servers > 0 then                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
            end
        end
    end)
    ServerTab:CreateButton("📋 ID сервера", function()
        local clip = syn and syn.set_clipboard or setclipboard or toclipboard
        if clip then clip(game.JobId) end
        print("JobId скопирован: " .. game.JobId)
    end)
    ServerTab:CreateButton("📋 ID игры", function()
        local clip = syn and syn.set_clipboard or setclipboard or toclipboard
        if clip then clip(game.PlaceId) end
        print("PlaceId скопирован: " .. game.PlaceId)
    end)
    ServerTab:CreateButton("🗑 Сброс персонажа", function()
        local char = getCharacter()
        if char then char:BreakJoints() end
    end)
    
    -- ============================================================
    -- 13. ЗАПОЛНЕНИЕ ВКЛАДКИ "РАЗНОЕ"
    -- ============================================================
    MiscTab:CreateSection("🛡 Защита")
    MiscTab:CreateToggle("Анти-смерть", false, function(state)
        toggleAntiDeath(state)
    end)
    MiscTab:CreateToggle("Автоклик (ЛКМ)", false, function(state)
        toggleAutoClick(state)
    end)
    MiscTab:CreateSlider("Задержка клика (с)", 0.01, 1, 0.1, function(val)
        autoClickDelay = val
    end)
    MiscTab:CreateButton("💤 Анти-AFK", function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        print("Анти-AFK включен")
    end)
    MiscTab:CreateButton("🗑 Очистить чат", function()
        local chat = game:GetService("Chat")
        if chat then chat:Clear() end
    end)
    
    -- ============================================================
    -- 14. ОБРАБОТЧИК КОМАНДНОЙ СТРОКИ
    -- ============================================================
    CmdBar.FocusLost:Connect(function(enterPressed)
        if enterPressed and CmdBar.Text ~= "" then
            local cmd = CmdBar.Text
            CmdBar.Text = ""
            
            if cmd == "fly" then
                toggleFly(not flyEnabled)
            elseif cmd == "noclip" then
                toggleNoclip(not noclipEnabled)
            elseif cmd == "esp" then
                toggleESP(not espEnabled)
            elseif cmd:match("^speed%s+(%d+)$") then
                local val = tonumber(cmd:match("^speed%s+(%d+)$"))
                if val then
                    local hum = getHumanoid()
                    if hum then hum.WalkSpeed = val end
                end
            elseif cmd:match("^jump%s+(%d+)$") then
                local val = tonumber(cmd:match("^jump%s+(%d+)$"))
                if val then
                    local hum = getHumanoid()
                    if hum then hum.JumpPower = val end
                end
            elseif cmd:match("^gravity%s+(%-?%d+)$") then
                local val = tonumber(cmd:match("^gravity%s+(%-?%d+)$"))
                if val then workspace.Gravity = val end
            elseif cmd:match("^goto%s+(.+)$") then
                local name = cmd:match("^goto%s+(.+)$")
                local target = getPlayerByName(name)
                if target then teleportToPlayer(target) end
            elseif cmd == "kill" then
                local target = getClosestPlayer()
                if target then killPlayer(target) end
            elseif cmd == "fling" then
                local target = getClosestPlayer()
                if target then flingPlayer(target) end
            elseif cmd == "freeze" then
                local target = getClosestPlayer()
                if target then freezePlayer(target, 5) end
            elseif cmd == "reset" then
                local char = getCharacter()
                if char then char:BreakJoints() end
            else
                print("[FUSION HUB] Неизвестная команда: " .. cmd)
            end
        end
    end)
    
    -- ============================================================
    -- 15. ПЕРЕТАСКИВАНИЕ ОКНА
    -- ============================================================
    local dragging = false
    local dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return ScreenGui
end

-- ============================================================
-- 16. ЗАПУСК
-- ============================================================
local success, err = pcall(CreateUI)
if success then
    print("✅ FUSION HUB v2.0 MEGA загружен!")
    print("📌 Все функции в одном месте — наслаждайся!")
else
    warn("❌ Ошибка загрузки FUSION HUB:", err)
end
