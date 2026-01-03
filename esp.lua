local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToggleNamesGui"
screenGui.Parent = playerGui

-- Создаем перемещаемую кнопку
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Включить Названия"
toggleButton.Parent = screenGui

local showNames = false -- по умолчанию выключены

local nameToTextMap = {} -- таблица для хранения текста для каждого уникального имени
local billboards = {} -- таблица для хранения созданных BillboardGui
local excludeNames = { 
	"Tree", 
	"Rock", 
	"Car Sign",
	"Lightpost",
	"Fence",
	"Well",
	"Bush",
} -- список названий, которые не показываем

local function isExcluded(name)
    for _, excluded in ipairs(excludeNames) do
        if name == excluded then
            return true
        end
    end
    return false
end

local function createBillboardGui(model, text)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ModelNameGui"
    billboardGui.Adornee = model:FindFirstChildWhichIsA("BasePart")
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = model

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboardGui
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
end

local function getOrCreateTextForName(name)
    if nameToTextMap[name] then
        return nameToTextMap[name]
    end
    local text = name
    nameToTextMap[name] = text
    return text
end

local function processModel(model)
    local name = model.Name
    -- Проверяем, исключена ли модель
    if isExcluded(name) then
        return
    end
    local displayText = getOrCreateTextForName(name)
    createBillboardGui(model, displayText)
    table.insert(billboards, model)
end

local function processFolder(folder)
    for _, item in pairs(folder:GetChildren()) do
        if item:IsA("Model") then
            processModel(item)
        elseif item:IsA("Folder") then
            processFolder(item)
        end
    end
end

-- Обработка всей рабочей области
processFolder(workspace)

-- Обработка новых моделей и папок при их появлении
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") then
        processModel(child)
    elseif child:IsA("Folder") then
        processFolder(child)
    end
end)

-- Функция для включения/выключения отображения названий
local function toggleNames()
    showNames = not showNames
    if showNames then
        toggleButton.Text = "Выключить Названия"
        for _, model in ipairs(billboards) do
            if model:FindFirstChild("ModelNameGui") then
                -- Проверяем, не исключена ли модель
                if not isExcluded(model.Name) then
                    model.ModelNameGui.Enabled = true
                end
            end
        end
    else
        toggleButton.Text = "Включить Названия"
        for _, model in ipairs(billboards) do
            if model:FindFirstChild("ModelNameGui") then
                model.ModelNameGui.Enabled = false
            end
        end
    end
end

toggleButton.MouseButton1Click:Connect(toggleNames)

-- Сделаем кнопку перемещаемой
local dragging = false
local dragInput, dragStart, startPos

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = toggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

local function onInputChanged(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        toggleButton.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end

toggleButton.InputBegan:Connect(onInputBegan)
toggleButton.InputChanged:Connect(onInputChanged)
