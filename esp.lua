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
    "Tree", "Tree?", "Rock", "Car Sign", "Lightpost", "Fence", "Well", "Bush",
    "Workbench", "Metal Rock", "Hallway", "Car", "P:T Car", "Torch", "Bench",
    "City Building", "City Building (interior)", "City Shop", "City Sidewalk",
    "City ground concrete", "Dumpster", "Mailbox", "Fence", "Hivemind Hologram",
    "Garage Sale", "Planks", "Library", "Suburbs Sidewalk", "Traffic Fence",
    "Cave sign 1", "Casino", "FirstFloor", "Second Floor", "Third Floor",
    "Fourth Floor", "Circle Table", "Rug", "Skyscraper", "Homeless Bed",
    "Hotel", "Construction Site", "Troll News Center", "Storage", "Duplicator",
    "Grand Knight", "Shopkeeper", "Basketball", "City Road", "Suburbs Wall",
    "DEADFace", "Derp", "Knife", "Shotgun", "Trollge", "Fire Axe", "Altar",
    "Bill Board", "BANK", "Bleeding eyes Statue", "Hospital", "Foundation",
    "The Gallery", "Sidewalk", "Water Tower", "CHECK ME PLEASE", "Yellow house",
    "Grey House", "1 House", "2 House", "3 House", "House5", "House3", "House2",
    "House 1", "4 House (reworked)", "Blue house", "Brown house", "Dark green house",
    "Green house", "Red house", "Purple house", "Road", "Fency Sidewalk",
    "Zone 3 Border", "Gospel", "Mineshaft", "Illuminati", "Meteor", "ULTRAOPAMOGUS",
    "Barricades", "Taco Terry", "Statue", "Mystery", "Relic", "flood light",
    "The Relic", "Cabe base", "Factory", "Waterfall", "Flower Shop",
    "StarterCharacter", "Garage", "ParkingGarage", "Suburbs Road", "Shop",
    "Park dirt", "Park Fountain", "Gas Station", "trollcart", "City Wall",
    "Tea", "Chair", "CEO Chair", "Paper", "Book", "CEO Desk", "Graveyard",
    "Fancy Sidewalk", "Plank path", "Fence"
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

local function processFolder(folder)
    for _, item in pairs(folder:GetChildren()) do
        if item:IsA("Folder") then -- ищем папки вместо моделей
            processFolder(item)
        end
    end
end

local function processFolderAndCreateBillboards(folder)
    -- Обход папки и создание billboard для каждого объекта внутри
    for _, item in pairs(folder:GetChildren()) do
        if item:IsA("Folder") then
            processFolderAndCreateBillboards(item)
        elseif item:IsA("Model") then
            local name = item.Name
            if not isExcluded(name) then
                local displayText = getOrCreateTextForName(name)
                createBillboardGui(item, displayText)
                table.insert(billboards, item)
            end
        end
    end
end

-- Обработка всей рабочей области
processFolderAndCreateBillboards(workspace)

-- Обработка новых папок и моделей при их появлении
workspace.ChildAdded:Connect(function(child)
    if child:IsA("Folder") then
        processFolderAndCreateBillboards(child)
    elseif child:IsA("Model") then
        local name = child.Name
        if not isExcluded(name) then
            local displayText = getOrCreateTextForName(name)
            createBillboardGui(child, displayText)
            table.insert(billboards, child)
        end
    end
end)

-- Функция для включения/выключения отображения названий
local function toggleNames()
    showNames = not showNames
    if showNames then
        toggleButton.Text = "Выключить Названия"
        for _, folder in ipairs(billboards) do
            local gui = folder:FindFirstChild("ModelNameGui")
            if gui then
                gui.Enabled = true
            end
        end
    else
        toggleButton.Text = "Включить Названия"
        for _, folder in ipairs(billboards) do
            local gui = folder:FindFirstChild("ModelNameGui")
            if gui then
                gui.Enabled = false
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
