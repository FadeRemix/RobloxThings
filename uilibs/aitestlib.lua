-- CSGO-Style UI Library
local UILibrary = {}
UILibrary.__index = UILibrary

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Main Library Constructor
function UILibrary:Create(config)
    local self = setmetatable({}, UILibrary)
    
    -- Create main ScreenGui
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = config.Name or "UILibrary"
    self.gui.ResetOnSpawn = false
    self.gui.Parent = playerGui
    
    -- Main window frame
    self.main = Instance.new("Frame")
    self.main.Name = "MainWindow"
    self.main.Size = UDim2.new(0, 600, 0, 400)
    self.main.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    self.main.BorderSizePixel = 0
    self.main.Parent = self.gui
    
    -- Window styling
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.main
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 80)
    stroke.Thickness = 2
    stroke.Parent = self.main
    
    -- Title bar
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Size = UDim2.new(1, 0, 0, 40)
    self.titleBar.BackgroundColor3 = Color3.fromRGB(45, 85, 140)
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.main
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = self.titleBar
    
    -- Title text
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Name or "UI Library"
    title.TextColor3 = Color3.white
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.titleBar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.white
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = self.titleBar
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 4)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        self.gui:Destroy()
    end)
    
    -- Tab container
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Name = "TabContainer"
    self.tabContainer.Size = UDim2.new(1, 0, 0, 35)
    self.tabContainer.Position = UDim2.new(0, 0, 0, 40)
    self.tabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    self.tabContainer.BorderSizePixel = 0
    self.tabContainer.Parent = self.main
    
    -- Content area
    self.contentArea = Instance.new("Frame")
    self.contentArea.Name = "ContentArea"
    self.contentArea.Size = UDim2.new(1, 0, 1, -75)
    self.contentArea.Position = UDim2.new(0, 0, 0, 75)
    self.contentArea.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    self.contentArea.BorderSizePixel = 0
    self.contentArea.Parent = self.main
    
    -- Initialize tabs
    self.tabs = {}
    self.activeTab = nil
    
    -- Make window draggable
    self:MakeDraggable(self.titleBar, self.main)
    
    return self
end

-- Tab Creation
function UILibrary:Tab(name)
    local tab = {}
    
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.Position = UDim2.new(0, #self.tabs * 100, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.BorderSizePixel = 0
    tabButton.Parent = self.tabContainer
    
    -- Tab content frame
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 6
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    tabContent.Visible = false
    tabContent.Parent = self.contentArea
    
    -- Content layout
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = tabContent
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = tabContent
    
    -- Tab object methods
    tab.content = tabContent
    tab.button = tabButton
    tab.elementCount = 0
    
    -- Toggle Tab
    function tab:Toggle(text, callback)
        self.elementCount = self.elementCount + 1
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = "Toggle_" .. text
        toggleFrame.Size = UDim2.new(1, 0, 0, 30)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.LayoutOrder = self.elementCount
        toggleFrame.Parent = self.content
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 4)
        toggleCorner.Parent = toggleFrame
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, -60, 1, 0)
        toggleLabel.Position = UDim2.new(0, 10, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = text
        toggleLabel.TextColor3 = Color3.white
        toggleLabel.TextSize = 14
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 40, 0, 20)
        toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        toggleButton.Text = ""
        toggleButton.BorderSizePixel = 0
        toggleButton.Parent = toggleFrame
        
        local toggleBtnCorner = Instance.new("UICorner")
        toggleBtnCorner.CornerRadius = UDim.new(0, 10)
        toggleBtnCorner.Parent = toggleButton
        
        local toggleIndicator = Instance.new("Frame")
        toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
        toggleIndicator.Position = UDim2.new(0, 2, 0, 2)
        toggleIndicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        toggleIndicator.BorderSizePixel = 0
        toggleIndicator.Parent = toggleButton
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(0, 8)
        indicatorCorner.Parent = toggleIndicator
        
        local toggled = false
        
        toggleButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            
            if toggled then
                TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 130, 50)}):Play()
                TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0, 2)}):Play()
            else
                TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
                TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
            end
            
            if callback then
                callback(toggled)
            end
        end)
    end
    
    -- Button
    function tab:Button(text, callback)
        self.elementCount = self.elementCount + 1
        
        local button = Instance.new("TextButton")
        button.Name = "Button_" .. text
        button.Size = UDim2.new(1, 0, 0, 35)
        button.BackgroundColor3 = Color3.fromRGB(60, 100, 160)
        button.Text = text
        button.TextColor3 = Color3.white
        button.TextSize = 14
        button.Font = Enum.Font.GothamSemibold
        button.BorderSizePixel = 0
        button.LayoutOrder = self.elementCount
        button.Parent = self.content
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 120, 180)}):Play()
            wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 100, 160)}):Play()
            
            if callback then
                callback()
            end
        end)
    end
    
    -- Slider
    function tab:Slider(text, default, callback)
        self.elementCount = self.elementCount + 1
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = "Slider_" .. text
        sliderFrame.Size = UDim2.new(1, 0, 0, 50)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.LayoutOrder = self.elementCount
        sliderFrame.Parent = self.content
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 4)
        sliderCorner.Parent = sliderFrame
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Size = UDim2.new(0.7, 0, 0, 20)
        sliderLabel.Position = UDim2.new(0, 10, 0, 5)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = text
        sliderLabel.TextColor3 = Color3.white
        sliderLabel.TextSize = 14
        sliderLabel.Font = Enum.Font.Gotham
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, -10, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.GothamSemibold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = sliderFrame
        
        local sliderTrack = Instance.new("Frame")
        sliderTrack.Size = UDim2.new(1, -20, 0, 4)
        sliderTrack.Position = UDim2.new(0, 10, 1, -15)
        sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        sliderTrack.BorderSizePixel = 0
        sliderTrack.Parent = sliderFrame
        
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(0, 2)
        trackCorner.Parent = sliderTrack
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(default / 100, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderTrack
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = sliderFill
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 12, 0, 12)
        sliderButton.Position = UDim2.new(default / 100, -6, 0.5, -6)
        sliderButton.BackgroundColor3 = Color3.white
        sliderButton.Text = ""
        sliderButton.BorderSizePixel = 0
        sliderButton.Parent = sliderTrack
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = sliderButton
        
        local dragging = false
        local currentValue = default
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = Players.LocalPlayer:GetMouse()
                local relative = math.clamp((mouse.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                currentValue = math.floor(relative * 100)
                
                valueLabel.Text = tostring(currentValue)
                sliderFill.Size = UDim2.new(relative, 0, 1, 0)
                sliderButton.Position = UDim2.new(relative, -6, 0.5, -6)
                
                if callback then
                    callback(currentValue)
                end
            end
        end)
    end
    
    -- Dropdown
    function tab:Dropdown(text, options, callback)
        self.elementCount = self.elementCount + 1
        
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = "Dropdown_" .. text
        dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.LayoutOrder = self.elementCount
        dropdownFrame.Parent = self.content
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 4)
        dropdownCorner.Parent = dropdownFrame
        
        local dropdownLabel = Instance.new("TextLabel")
        dropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
        dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
        dropdownLabel.BackgroundTransparency = 1
        dropdownLabel.Text = text
        dropdownLabel.TextColor3 = Color3.white
        dropdownLabel.TextSize = 14
        dropdownLabel.Font = Enum.Font.Gotham
        dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        dropdownLabel.Parent = dropdownFrame
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(0.5, -10, 0, 25)
        dropdownButton.Position = UDim2.new(0.5, 0, 0, 5)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        dropdownButton.Text = options[1] .. " ▼"
        dropdownButton.TextColor3 = Color3.white
        dropdownButton.TextSize = 12
        dropdownButton.Font = Enum.Font.Gotham
        dropdownButton.BorderSizePixel = 0
        dropdownButton.Parent = dropdownFrame
        
        local dropBtnCorner = Instance.new("UICorner")
        dropBtnCorner.CornerRadius = UDim.new(0, 4)
        dropBtnCorner.Parent = dropdownButton
        
        local optionsFrame = Instance.new("Frame")
        optionsFrame.Size = UDim2.new(0.5, -10, 0, #options * 25)
        optionsFrame.Position = UDim2.new(0.5, 0, 0, 35)
        optionsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        optionsFrame.BorderSizePixel = 0
        optionsFrame.Visible = false
        optionsFrame.ZIndex = 10
        optionsFrame.Parent = dropdownFrame
        
        local optionsCorner = Instance.new("UICorner")
        optionsCorner.CornerRadius = UDim.new(0, 4)
        optionsCorner.Parent = optionsFrame
        
        local optionsLayout = Instance.new("UIListLayout")
        optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optionsLayout.Parent = optionsFrame
        
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 25)
            optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            optionButton.Text = option
            optionButton.TextColor3 = Color3.white
            optionButton.TextSize = 12
            optionButton.Font = Enum.Font.Gotham
            optionButton.BorderSizePixel = 0
            optionButton.LayoutOrder = i
            optionButton.Parent = optionsFrame
            
            optionButton.MouseButton1Click:Connect(function()
                dropdownButton.Text = option .. " ▼"
                optionsFrame.Visible = false
                dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
                
                if callback then
                    callback(option)
                end
            end)
            
            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
            end)
            
            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            end)
        end
        
        dropdownButton.MouseButton1Click:Connect(function()
            optionsFrame.Visible = not optionsFrame.Visible
            if optionsFrame.Visible then
                dropdownFrame.Size = UDim2.new(1, 0, 0, 35 + (#options * 25))
            else
                dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            end
        end)
    end
    
    -- Label
    function tab:Label(text)
        self.elementCount = self.elementCount + 1
        
        local label = Instance.new("TextLabel")
        label.Name = "Label_" .. text
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(150, 150, 200)
        label.TextSize = 16
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.LayoutOrder = self.elementCount
        label.Parent = self.content
    end
    
    -- Color Picker
    function tab:ColorPicker(text, defaultColor, callback)
        self.elementCount = self.elementCount + 1
        
        local colorFrame = Instance.new("Frame")
        colorFrame.Name = "ColorPicker_" .. text
        colorFrame.Size = UDim2.new(1, 0, 0, 35)
        colorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        colorFrame.BorderSizePixel = 0
        colorFrame.LayoutOrder = self.elementCount
        colorFrame.Parent = self.content
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 4)
        colorCorner.Parent = colorFrame
        
        local colorLabel = Instance.new("TextLabel")
        colorLabel.Size = UDim2.new(1, -50, 1, 0)
        colorLabel.Position = UDim2.new(0, 10, 0, 0)
        colorLabel.BackgroundTransparency = 1
        colorLabel.Text = text
        colorLabel.TextColor3 = Color3.white
        colorLabel.TextSize = 14
        colorLabel.Font = Enum.Font.Gotham
        colorLabel.TextXAlignment = Enum.TextXAlignment.Left
        colorLabel.Parent = colorFrame
        
        local colorPreview = Instance.new("Frame")
        colorPreview.Size = UDim2.new(0, 30, 0, 25)
        colorPreview.Position = UDim2.new(1, -40, 0, 5)
        colorPreview.BackgroundColor3 = defaultColor
        colorPreview.BorderSizePixel = 0
        colorPreview.Parent = colorFrame
        
        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 4)
        previewCorner.Parent = colorPreview
        
        local colorButton = Instance.new("TextButton")
        colorButton.Size = UDim2.new(1, 0, 1, 0)
        colorButton.BackgroundTransparency = 1
        colorButton.Text = ""
        colorButton.Parent = colorPreview
        
        colorButton.MouseButton1Click:Connect(function()
            -- Simple color picker (cycling through preset colors)
            local colors = {
                Color3.fromRGB(255, 255, 255),
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(0, 0, 255),
                Color3.fromRGB(255, 255, 0),
                Color3.fromRGB(255, 0, 255),
                Color3.fromRGB(0, 255, 255)
            }
            
            local currentIndex = 1
            for i, color in ipairs(colors) do
                if colorPreview.BackgroundColor3 == color then
                    currentIndex = i
                    break
                end
            end
            
            local nextIndex = (currentIndex % #colors) + 1
            local newColor = colors[nextIndex]
            colorPreview.BackgroundColor3 = newColor
            
            if callback then
                callback(newColor)
            end
        end)
    end
    
    -- Tab switching logic
    tabButton.MouseButton1Click:Connect(function()
        -- Hide all tabs
        for _, tabData in pairs(self.tabs) do
            tabData.content.Visible = false
            tabData.button.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            tabData.button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        
        -- Show this tab
        tabContent.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(70, 110, 170)
        tabButton.TextColor3 = Color3.white
        
        self.activeTab = tab
    end)
    
    -- Add to tabs list
    self.tabs[name] = tab
    
    -- Make first tab active
    if #self.tabs == 1 then
        tabButton.MouseButton1Click()
    end
    
    return tab
end

-- Make window draggable
function UILibrary:MakeDraggable(dragHandle, window)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

return UILibrary
