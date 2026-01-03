local Workspace = game:GetService("Workspace")
local StarterPlayer = game:GetService("StarterPlayer")
local player = game.Players.LocalPlayer

-- Функция для создания GUI над моделью
local function createBillboardGui(parent, text)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.Adornee = parent
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboardGui
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true

    billboardGui.Parent = parent
end

-- Получаем все папки в Workspace
local function getFolderNames()
    local folderNames = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") then
            table.insert(folderNames, obj.Name)
        end
    end
    return folderNames
end

-- Создаем GUI для каждой папки
local function displayFolderNames()
    local folderNames = getFolderNames()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") then
            -- Создаем GUI над каждой папкой
            createBillboardGui(obj, obj.Name)
        end
    end
end

displayFolderNames()
