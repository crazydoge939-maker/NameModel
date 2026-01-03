local Players = game:GetService("Players")
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

-- Получаем все папки в Workspace
local Workspace = game:GetService("Workspace")
local folderNames = {}

for _, obj in pairs(Workspace:GetChildren()) do
	if obj:IsA("Folder") then
		table.insert(folderNames, obj.Name)
	end
end

-- Создаем текстовые элементы для каждого названия папки
for _, folderName in pairs(folderNames) do
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 30)
	label.BackgroundTransparency = 1
	label.Text = folderName
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.SourceSans
	label.TextScaled = true
	label.Parent = listScrollingFrame
end
