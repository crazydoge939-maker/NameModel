local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Создаем основную панель GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FolderListGui"
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 400)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Папки в игре"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextScaled = true
titleLabel.Parent = frame

local listScrollingFrame = Instance.new("ScrollingFrame")
listScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
listScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
listScrollingFrame.BackgroundTransparency = 1
listScrollingFrame.ScrollBarThickness = 6
listScrollingFrame.Parent = frame

local uiLayout = Instance.new("UIListLayout")
uiLayout.Parent = listScrollingFrame
uiLayout.SortOrder = Enum.SortOrder.Name

-- Функция для обновления содержимого папки
local function updateFolderContents(folder, container)
    -- Очищаем старое содержимое
    for _, child in pairs(container:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    -- Получаем объекты внутри папки
    local objectsInside = folder:GetChildren()
    local yOffset = 0
    for _, obj in pairs(objectsInside) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 5, 0, yOffset)
        label.BackgroundTransparency = 1
        label.Text = obj.Name
        label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        label.Font = Enum.Font.SourceSans
        label.TextScaled = true
        label.Parent = container
        yOffset = yOffset + 22
    end
    -- Обновляем размер для скролла
    container.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Основная функция обновления всех папок
local function updateAllFolders()
    -- Очищаем список папок
    for _, child in pairs(listScrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local Workspace = game:GetService("Workspace")
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") then
            -- Создаем рамку для каждой папки
            local folderFrame = Instance.new("Frame")
            folderFrame.Size = UDim2.new(1, -10, 0, 50)
            folderFrame.BackgroundTransparency = 1
            folderFrame.Parent = listScrollingFrame

            -- Название папки
            local folderLabel = Instance.new("TextLabel")
            folderLabel.Size = UDim2.new(1, 0, 0, 20)
            folderLabel.BackgroundTransparency = 1
            folderLabel.Text = "Папка: " .. obj.Name
            folderLabel.TextColor3 = Color3.new(1, 1, 0)
            folderLabel.Font = Enum.Font.SourceSansBold
            folderLabel.TextScaled = true
            folderLabel.Parent = folderFrame

            -- Контейнер для содержимого
            local contentContainer = Instance.new("ScrollingFrame")
            contentContainer.Size = UDim2.new(1, 0, 1, -20)
            contentContainer.Position = UDim2.new(0, 0, 0, 20)
            contentContainer.BackgroundTransparency = 1
            contentContainer.ScrollBarThickness = 4
            contentContainer.Parent = folderFrame

            -- Обновляем содержимое папки
            updateFolderContents(obj, contentContainer)
        end
    end
end

-- Постоянное обновление каждую секунду
while true do
    updateAllFolders()
    wait(1)
end
