-- Bracket UI Library v1.0
local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function MakeDraggable(frame, dragButton)
    local dragging = false
    local dragStart, startPos
    dragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    dragButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Library:CreateWindow(title, size)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Name = "BracketUI"
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, size.X, 0, size.Y)
    main.Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    MakeDraggable(main, titleBar)
    
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Size = UDim2.new(1, 0, 0, 30)
    tabsContainer.Position = UDim2.new(0, 0, 0, 35)
    tabsContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tabsContainer.BorderSizePixel = 0
    tabsContainer.Parent = main
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -65)
    content.Position = UDim2.new(0, 0, 0, 65)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    local window = {
        _gui = screenGui,
        _frame = main,
        _content = content,
        _tabs = {},
        _tabButtons = {},
        _activeTab = nil
    }
    
    function window:CreateTab(name)
        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = content
        
        local tab = {
            _content = tabContent,
            _objects = {}
        }
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Parent = tabsContainer
        
        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(window._tabButtons) do
                v.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            for _, v in pairs(window._tabs) do
                v._content.Visible = false
            end
            tabContent.Visible = true
        end)
        
        table.insert(window._tabButtons, btn)
        table.insert(window._tabs, tab)
        
        if not window._activeTab then
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabContent.Visible = true
            window._activeTab = tab
        end
        
        function tab:CreateSection(title)
            local section = Instance.new("TextLabel")
            section.Size = UDim2.new(1, -20, 0, 25)
            section.Position = UDim2.new(0, 10, 0, #tab._objects * 35 + 5)
            section.BackgroundTransparency = 1
            section.Text = title
            section.TextColor3 = Color3.fromRGB(150, 150, 150)
            section.TextSize = 13
            section.Font = Enum.Font.GothamBold
            section.TextXAlignment = Enum.TextXAlignment.Left
            section.Parent = tabContent
            table.insert(tab._objects, section)
            return section
        end
        
        function tab:CreateButton(label, callback)
            local btnObj = Instance.new("TextButton")
            btnObj.Size = UDim2.new(1, -20, 0, 30)
            btnObj.Position = UDim2.new(0, 10, 0, #tab._objects * 35 + 5)
            btnObj.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            btnObj.BackgroundTransparency = 0.2
            btnObj.BorderSizePixel = 0
            btnObj.Text = label
            btnObj.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnObj.TextSize = 14
            btnObj.Font = Enum.Font.Gotham
            btnObj.Parent = tabContent
            
            local cornerBtn = Instance.new("UICorner")
            cornerBtn.CornerRadius = UDim.new(0, 4)
            cornerBtn.Parent = btnObj
            
            btnObj.MouseButton1Click:Connect(callback)
            btnObj.MouseEnter:Connect(function()
                TweenService:Create(btnObj, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
            end)
            btnObj.MouseLeave:Connect(function()
                TweenService:Create(btnObj, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
            end)
            
            table.insert(tab._objects, btnObj)
            return btnObj
        end
        
        function tab:CreateToggle(label, default, callback)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 30)
            container.Position = UDim2.new(0, 10, 0, #tab._objects * 35 + 5)
            container.BackgroundTransparency = 1
            container.Parent = tabContent
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            lbl.TextSize = 14
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = container
            
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 50, 0, 25)
            toggleBtn.Position = UDim2.new(1, -55, 0, 2.5)
            toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 65)
            toggleBtn.BorderSizePixel = 0
            toggleBtn.Text = default and "ON" or "OFF"
            toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleBtn.TextSize = 12
            toggleBtn.Font = Enum.Font.GothamBold
            toggleBtn.Parent = container
            
            local cornerTog = Instance.new("UICorner")
            cornerTog.CornerRadius = UDim.new(0, 4)
            cornerTog.Parent = toggleBtn
            
            local state = default
            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                toggleBtn.Text = state and "ON" or "OFF"
                toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 65)
                callback(state)
            end)
            
            table.insert(tab._objects, container)
            return toggleBtn
        end
        
        function tab:CreateSlider(label, min, max, default, callback)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 50)
            container.Position = UDim2.new(0, 10, 0, #tab._objects * 35 + 5)
            container.BackgroundTransparency = 1
            container.Parent = tabContent
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.7, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = label .. ": " .. tostring(default)
            lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            lbl.TextSize = 14
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = container
            
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(1, 0, 0, 6)
            slider.Position = UDim2.new(0, 0, 0, 35)
            slider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            slider.BorderSizePixel = 0
            slider.Parent = container
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            fill.BorderSizePixel = 0
            fill.Parent = slider
            
            local sliderBtn = Instance.new("TextButton")
            sliderBtn.Size = UDim2.new(0, 16, 0, 16)
            sliderBtn.Position = UDim2.new((default - min) / (max - min), -8, 0, -5)
            sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderBtn.BorderSizePixel = 0
            sliderBtn.Text = ""
            sliderBtn.Parent = slider
            
            local cornerBtn = Instance.new("UICorner")
            cornerBtn.CornerRadius = UDim.new(1, 0)
            cornerBtn.Parent = sliderBtn
            
            local dragging = false
            sliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            sliderBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                    local val = min + (max - min) * pos
                    val = math.round(val)
                    fill.Size = UDim2.new(pos, 0, 1, 0)
                    sliderBtn.Position = UDim2.new(pos, -8, 0, -5)
                    lbl.Text = label .. ": " .. tostring(val)
                    callback(val)
                end
            end)
            
            table.insert(tab._objects, container)
            return slider
        end
        
        function tab:CreateInput(label, placeholder, callback)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 35)
            container.Position = UDim2.new(0, 10, 0, #tab._objects * 35 + 5)
            container.BackgroundTransparency = 1
            container.Parent = tabContent
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.3, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            lbl.TextSize = 14
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = container
            
            local input = Instance.new("TextBox")
            input.Size = UDim2.new(0.65, 0, 1, 0)
            input.Position = UDim2.new(0.35, 0, 0, 0)
            input.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            input.BorderSizePixel = 0
            input.Text = ""
            input.PlaceholderText = placeholder
            input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            input.TextColor3 = Color3.fromRGB(255, 255, 255)
            input.TextSize = 14
            input.Font = Enum.Font.Gotham
            input.Parent = container
            
            local cornerInp = Instance.new("UICorner")
            cornerInp.CornerRadius = UDim.new(0, 4)
            cornerInp.Parent = input
            
            input.FocusLost:Connect(function()
                callback(input.Text)
            end)
            
            table.insert(tab._objects, container)
            return input
        end
        
        return tab
    end
    
    return window
end

return Library
