local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Создаем основную панель GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FolderHierarchyGui"
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 500)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
mainFrame.BackgroundTransparency = 0.2
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Структура папок"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextScaled = true
titleLabel.Parent = mainFrame

local listScrollingFrame = Instance.new("ScrollingFrame")
listScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
listScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
listScrollingFrame.BackgroundTransparency = 1
listScrollingFrame.ScrollBarThickness = 6
listScrollingFrame.Parent = mainFrame

local uiLayout = Instance.new("UIListLayout")
uiLayout.Parent = listScrollingFrame
uiLayout.SortOrder = Enum.SortOrder.Name

-- Таблица для хранения состояния папок
local folderStates = {} -- key: folder, value: table { isOpen = bool, button = GuiObject, panel = GuiObject }

-- Создаем панель для отображения содержимого папки, включая вложенные папки
local function createFolderPanel(folder, indentLevel)
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 400, 0, 300)
	panel.Position = UDim2.new(0, 320 + indentLevel * 10, 0, 0)
	panel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	panel.BorderSizePixel = 1
	panel.Visible = false
	panel.Parent = screenGui

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 30)
	header.BackgroundTransparency = 1
	header.Text = folder.Name
	header.TextColor3 = Color3.new(1, 1, 1)
	header.Font = Enum.Font.SourceSansBold
	header.TextScaled = true
	header.Parent = panel

	local contentContainer = Instance.new("ScrollingFrame")
	contentContainer.Size = UDim2.new(1, 0, 1, -30)
	contentContainer.Position = UDim2.new(0, 0, 0, 30)
	contentContainer.BackgroundTransparency = 1
	contentContainer.ScrollBarThickness = 6
	contentContainer.Parent = panel

	local function populateContent()
		-- Очищаем содержимое
		for _, child in pairs(contentContainer:GetChildren()) do
			if child ~= contentContainer then
				child:Destroy()
			end
		end

		local yOffset = 0

		-- Создаем список для папок и элементов
		local children = folder:GetChildren()

		-- Создаем таблицу для подсчета имен элементов, чтобы отображать их количество
		local nameCounts = {}
		for _, child in ipairs(children) do
			if not child:IsA("Folder") then
				local name = child.Name
				nameCounts[name] = (nameCounts[name] or 0) + 1
			end
		end

		-- Обрабатываем элементы
		for _, child in ipairs(children) do
			if child:IsA("Folder") then
				-- Создаем кнопку для папки
				local folderButton = Instance.new("TextButton")
				folderButton.Size = UDim2.new(1, -20, 0, 25)
				folderButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
				folderButton.TextColor3 = Color3.new(1, 1, 1)
				folderButton.Font = Enum.Font.SourceSansBold
				folderButton.TextScaled = true
				folderButton.Text = child.Name
				folderButton.Position = UDim2.new(0, 10 + indentLevel * 10, 0, yOffset)
				folderButton.Parent = contentContainer

				-- Создаем вложенный панель для этой папки
				local nestedPanel = createFolderPanel(child, indentLevel + 1)

				-- Изначально скрываем вложенную папку
				nestedPanel.Visible = false

				-- Обработчик клика по папке
				folderButton.MouseButton1Click:Connect(function()
					nestedPanel.Visible = not nestedPanel.Visible
				end)

				yOffset = yOffset + 25
			else
				local count = nameCounts[child.Name]
				local displayText = "- " .. child.Name
				if count and count > 1 then
					displayText = displayText .. " [" .. count .. "]"
				end
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, -20, 0, 20)
				label.Position = UDim2.new(0, 10 + indentLevel * 10, 0, yOffset)
				label.BackgroundTransparency = 1
				label.Text = displayText
				label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
				label.Font = Enum.Font.SourceSans
				label.TextScaled = true
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = contentContainer
				yOffset = yOffset + 20
			end
		end
		contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset)
	end

	populateContent()

	return panel
end

local function createFolderButton(folder, parentContainer, indentLevel)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 25)
	button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSansBold
	button.TextScaled = true
	button.Text = folder.Name
	button.Position = UDim2.new(0, 10 * indentLevel, 0, 0)
	button.Parent = parentContainer

	-- Создаем панель для папки
	local folderPanel = createFolderPanel(folder, indentLevel)

	folderStates[folder] = {
		isOpen = false,
		button = button,
		panel = folderPanel,
	}

	-- Обработчик клика
	button.MouseButton1Click:Connect(function()
		local state = folderStates[folder]
		if not state.isOpen then
			-- Открываем
			state.isOpen = true
			state.panel.Visible = true
		else
			-- Закрываем
			state.isOpen = false
			state.panel.Visible = false
		end
	end)
end

local function updateFolderStructure()
	-- Собираем все папки в Workspace
	local workspaceFolders = {}
	for _, obj in ipairs(game.Workspace:GetChildren()) do
		if obj:IsA("Folder") then
			table.insert(workspaceFolders, obj)
		end
	end

	-- Создаем кнопки для новых папок
	for _, folder in ipairs(workspaceFolders) do
		if not folderStates[folder] then
			createFolderButton(folder, listScrollingFrame, 0)
		end
	end
end

-- Обновляем структуру
while true do
	updateFolderStructure()
	wait(1)
end
