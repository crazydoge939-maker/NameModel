local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function createBillboardGui(parent, text)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.Adornee = parent
    billboardGui.AlwaysOnTop = true
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.Text = text
    textLabel.TextScaled = true
    textLabel.Parent = billboardGui

    billboardGui.Parent = parent
end

local function getFolderNames()
    local folderNames = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Folder") then
            local name = obj.Name
            folderNames[name] = true
        end
    end
    local namesList = {}
    for name, _ in pairs(folderNames) do
        table.insert(namesList, name)
    end
    return folderNames -- возвращает таблицу с названиями, где ключи - имена папок
end

local folderNames = getFolderNames()

local function attachGuiToModel(model)
    -- Проверяем, есть ли у модели уже GUI
    if not model:FindFirstChild("FolderNameGui") then
        local name = "Default"
        -- Можно выбрать название, например, первое из существующих или оставить по умолчанию
        -- Но тут лучше отображать конкретное название папки, если есть
        -- Для этого нужно получить имя папки, в которой находится модель
        -- Предположим, что модель внутри папки, тогда получим имя папки
        local parentFolder = model.Parent
        if parentFolder and parentFolder:IsA("Folder") then
            name = parentFolder.Name
        end
        createBillboardGui(model, name)
    end
end

local function onCharacterAdded(character)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            attachGuiToModel(part)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(character)
    end)
end)

-- Для существующих игроков и их персонажей при запуске
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

-- Обновление GUI при необходимости (например, при добавлении новых папок)
-- Можно запустить это один раз
