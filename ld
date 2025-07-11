local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 创建ScreenGui作为容器
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MusicPlayerGui"
screenGui.ResetOnSpawn = false -- 确保玩家重生后UI不会消失
screenGui.Parent = playerGui

-- 创建开场图片显示
local splashImage = Instance.new("ImageLabel")
splashImage.Name = "SplashImage"
splashImage.Size = UDim2.new(0.5, 0, 0.5, 0)
splashImage.Position = UDim2.new(0.25, 0, 0.25, 0)
splashImage.Image = "rbxassetid://100076418396520"
splashImage.BackgroundTransparency = 1
splashImage.ScaleType = Enum.ScaleType.Fit
splashImage.Parent = screenGui

-- 开场图片渐变效果
spawn(function()
    for i = 1, 0, -0.05 do
        splashImage.ImageTransparency = i
        wait(0.05)
    end
    wait(5) -- 显示5秒
    for i = 0, 1, 0.05 do
        splashImage.ImageTransparency = i
        wait(0.05)
    end
    splashImage:Destroy()
end)

-- 创建UI元素
local function createUIElement(className, properties)
    local element = Instance.new(className)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

-- 创建左边的大正方形
local bigSquare = createUIElement("Frame", {
    Name = "MusicListFrame",
    Size = UDim2.new(0.2, 0, 0.6, 0),
    Position = UDim2.new(0.05, 0, 0.25, 0),
    BackgroundColor3 = Color3.fromRGB(100, 100, 100),
    BackgroundTransparency = 0.5,
    Parent = screenGui
})

-- 创建可滑动的ScrollingFrame在大正方形内
local scrollFrame = createUIElement("ScrollingFrame", {
    Name = "MusicScrollFrame",
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    CanvasSize = UDim2.new(0, 0, 0, 1000),
    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
    ScrollBarThickness = 8,
    Parent = bigSquare
})

-- 创建控制面板框架
local controlPanel = createUIElement("Frame", {
    Name = "ControlPanel",
    Size = UDim2.new(0.25, 0, 0.5, 0),
    Position = UDim2.new(0.7, 0, 0.25, 0),
    BackgroundColor3 = Color3.fromRGB(70, 70, 70),
    BackgroundTransparency = 0.5,
    Parent = screenGui
})

-- 创建文本框
local textBox = createUIElement("TextBox", {
    Name = "MusicCodeInput",
    Size = UDim2.new(0.8, 0, 0.1, 0),
    Position = UDim2.new(0.1, 0, 0.1, 0),
    PlaceholderText = "输入音乐ID或rbxassetid链接",
    Text = "",
    ClearTextOnFocus = false,
    Parent = controlPanel
})

-- 创建音量滑块
local volumeSlider = createUIElement("TextButton", {
    Name = "VolumeSlider",
    Size = UDim2.new(0.8, 0, 0.05, 0),
    Position = UDim2.new(0.1, 0, 0.25, 0),
    Text = "音量: 50%",
    BackgroundColor3 = Color3.fromRGB(100, 100, 100),
    Parent = controlPanel
})

local volumeSliderBar = createUIElement("Frame", {
    Name = "VolumeSliderBar",
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(0, 120, 215),
    Parent = volumeSlider
})

-- 创建按钮函数
local function createButton(name, text, position, parent)
    return createUIElement("TextButton", {
        Name = name,
        Size = UDim2.new(0.8, 0, 0.1, 0),
        Position = position,
        Text = text,
        BackgroundColor3 = Color3.fromRGB(0, 120, 215),
        Parent = parent
    })
end

-- 创建各种按钮
local playButton = createButton("PlayButton", "播放音乐", UDim2.new(0.1, 0, 0.35, 0), controlPanel)
local stopButton = createButton("StopButton", "停止播放", UDim2.new(0.1, 0, 0.5, 0), controlPanel)
local replayButton = createButton("ReplayButton", "重新播放", UDim2.new(0.1, 0, 0.65, 0), controlPanel)
local speedUpButton = createButton("SpeedUpButton", "加速播放", UDim2.new(0.1, 0, 0.8, 0), controlPanel)
local slowDownButton = createButton("SlowDownButton", "减速播放", UDim2.new(0.1, 0, 0.95, 0), controlPanel)

-- 创建右上角隐藏/显示按钮
local toggleHideButton = createUIElement("TextButton", {
    Name = "ToggleHideButton",
    Size = UDim2.new(0.05, 0, 0.05, 0),
    Position = UDim2.new(0.95, 0, 0.05, 0),
    Text = "隐藏",
    BackgroundColor3 = Color3.fromRGB(0, 120, 215),
    Parent = screenGui
})

-- 创建文字标签
local creditLabel = createUIElement("TextLabel", {
    Name = "CreditLabel",
    Size = UDim2.new(0.25, 0, 0.05, 0),
    Position = UDim2.new(0.7, 0, 0.8, 0),
    Text = "音乐播放器 v2.0 | 由QQ高老八制作",
    Font = Enum.Font.Gotham,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    TextSize = 16,
    Parent = screenGui
})

-- 音乐播放相关变量
local currentSound -- 当前播放的音乐实例
local playedMusicList = {} -- 播放过的音乐列表
local isHidden = false -- 界面是否隐藏
local defaultVolume = 0.5 -- 默认音量

-- 使元素可拖动的函数
local function makeDraggable(element)
    local dragging = false
    local dragInput, dragStart, startPos
    
    element.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = element.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    element.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- 为UI元素添加拖动功能
makeDraggable(bigSquare)
makeDraggable(controlPanel)

-- 音量控制功能
local function updateVolume(volume)
    defaultVolume = math.clamp(volume, 0, 1)
    volumeSlider.Text = "音量: " .. math.floor(defaultVolume * 100) .. "%"
    volumeSliderBar.Size = UDim2.new(defaultVolume, 0, 1, 0)
    
    if currentSound then
        currentSound.Volume = defaultVolume
    end
end

-- 音量滑块交互
volumeSlider.MouseButton1Down:Connect(function()
    local connection
    connection = game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local xPos = (input.Position.X - volumeSlider.AbsolutePosition.X) / volumeSlider.AbsoluteSize.X
            updateVolume(math.clamp(xPos, 0, 1))
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            connection:Disconnect()
        end
    end)
end)

-- 播放音乐函数
local function playMusic(soundId)
    local soundService = game:GetService("SoundService")
    
    -- 停止当前音乐
    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
    end
    
    -- 创建新音乐实例
    currentSound = Instance.new("Sound")
    currentSound.SoundId = soundId
    currentSound.Volume = defaultVolume
    currentSound.Looped = true
    currentSound.Parent = soundService
    
    -- 尝试播放音乐
    local success, err = pcall(function()
        currentSound:Play()
    end)
    
    if not success then
        warn("播放音乐失败: " .. err)
        if currentSound then
            currentSound:Destroy()
            currentSound = nil
        end
        return false
    end
    
    return true
end

-- 添加音乐到历史记录
local function addToHistory(soundId)
    -- 检查是否已经存在
    for _, item in ipairs(playedMusicList) do
        if item.soundId == soundId then
            return -- 已经存在则不重复添加
        end
    end
    
    local musicInfo = {
        soundId = soundId,
        label = createUIElement("TextButton", {
            Size = UDim2.new(0.95, 0, 0, 30),
            Position = UDim2.new(0.025, 0, 0, #playedMusicList * 35),
            Text = "音乐ID: " .. string.match(soundId, "%d+") or soundId,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            BackgroundColor3 = Color3.fromRGB(80, 80, 80),
            Parent = scrollFrame
        })
    }
    
    -- 更新滚动区域大小
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #playedMusicList * 35 + 40)
    
    -- 点击历史记录重新播放
    musicInfo.label.MouseButton1Click:Connect(function()
        textBox.Text = string.match(soundId, "%d+") or soundId
        playMusic(soundId)
    end)
    
    table.insert(playedMusicList, musicInfo)
end

-- 播放按钮点击事件
playButton.MouseButton1Click:Connect(function()
    local inputCode = textBox.Text
    if inputCode == "" then return end
    
    -- 格式化soundId
    if not string.find(inputCode, "rbxassetid://") then
        inputCode = "rbxassetid://" .. inputCode
    end
    
    if playMusic(inputCode) then
        addToHistory(inputCode)
    else
        textBox.Text = "无效的音乐ID"
    end
end)

-- 停止按钮点击事件
stopButton.MouseButton1Click:Connect(function()
    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
        currentSound = nil
    end
end)

-- 重新播放按钮点击事件
replayButton.MouseButton1Click:Connect(function()
    if currentSound then
        local currentSoundId = currentSound.SoundId
        currentSound:Stop()
        currentSound:Destroy()
        playMusic(currentSoundId)
    end
end)

-- 加速按钮点击事件
speedUpButton.MouseButton1Click:Connect(function()
    if currentSound then
        currentSound.Pitch = math.min(currentSound.Pitch + 0.2, 2)
    end
end)

-- 减速按钮点击事件
slowDownButton.MouseButton1Click:Connect(function()
    if currentSound then
        currentSound.Pitch = math.max(currentSound.Pitch - 0.2, 0.2)
    end
end)

-- 隐藏/显示按钮点击事件
toggleHideButton.MouseButton1Click:Connect(function()
    isHidden = not isHidden
    
    if isHidden then
        -- 隐藏主界面
        controlPanel.Visible = false
        bigSquare.Visible = false
        creditLabel.Visible = false
        toggleHideButton.Text = "显示"
    else
        -- 显示主界面
        controlPanel.Visible = true
        bigSquare.Visible = true
        creditLabel.Visible = true
        toggleHideButton.Text = "隐藏"
    end
end)

-- 初始化音量
updateVolume(defaultVolume)

-- 玩家重生时重置UI位置（可选）
player.CharacterAdded:Connect(function()
    -- 可以在这里重置UI位置到默认位置
    bigSquare.Position = UDim2.new(0.05, 0, 0.25, 0)
    controlPanel.Position = UDim2.new(0.7, 0, 0.25, 0)
    toggleHideButton.Position = UDim2.new(0.95, 0, 0.05, 0)
end)
