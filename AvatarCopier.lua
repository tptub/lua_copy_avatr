-- Avatar Copier Script
-- This script will handle both GUI creation and avatar copying logic.

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") -- For potential future use, good to have.
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- For potential events or modules

-- Local Player
local localPlayer = Players.LocalPlayer
if not localPlayer then
	local success, player = pcall(function() return Players.PlayerAdded:Wait() end)
    if success then localPlayer = player else return end -- Stop script if player cannot be determined
end
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- GUI Elements (from previous setup)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AvatarCopierScreenGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "ناسخ مظهر اللاعب"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Name = "PlayerListFrame"
playerListFrame.Size = UDim2.new(1, -20, 0, 280)
playerListFrame.Position = UDim2.new(0, 10, 0, 40)
playerListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
playerListFrame.BorderSizePixel = 1
playerListFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.ScrollBarThickness = 6
playerListFrame.Parent = mainFrame

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 5)
uiPadding.PaddingBottom = UDim.new(0, 5)
uiPadding.PaddingLeft = UDim.new(0, 5)
uiPadding.PaddingRight = UDim.new(0, 5)
uiPadding.Parent = playerListFrame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Name = "PlayerListLayout"
playerListLayout.FillDirection = Enum.FillDirection.Vertical
playerListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Padding = UDim.new(0, 5)
playerListLayout.Parent = playerListFrame

local refreshButton = Instance.new("TextButton")
refreshButton.Name = "RefreshButton"
refreshButton.Size = UDim2.new(0.5, -15, 0, 30)
refreshButton.Position = UDim2.new(0, 10, 1, -40)
refreshButton.BackgroundColor3 = Color3.fromRGB(70, 70, 150)
refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.Text = "تحديث"
refreshButton.Font = Enum.Font.SourceSansBold
refreshButton.TextSize = 16
refreshButton.Parent = mainFrame

local copyButton = Instance.new("TextButton")
copyButton.Name = "CopyButton"
copyButton.Size = UDim2.new(0.5, -15, 0, 30)
copyButton.Position = UDim2.new(0.5, 5, 1, -40)
copyButton.BackgroundColor3 = Color3.fromRGB(70, 150, 70)
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.Text = "نسخ المظهر"
copyButton.Font = Enum.Font.SourceSansBold
copyButton.TextSize = 16
copyButton.Parent = mainFrame

-- Core Logic Variables
local selectedPlayerButton = nil
local selectedTargetPlayer = nil

local DEFAULT_BUTTON_COLOR = Color3.fromRGB(50, 50, 50)
local SELECTED_BUTTON_COLOR = Color3.fromRGB(80, 80, 120)

-- Function to Populate/Refresh Player List
function updatePlayerList()
	print("AvatarCopier: Updating player list...")
	-- Clear existing buttons
	for _, child in ipairs(playerListFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	selectedPlayerButton = nil
	selectedTargetPlayer = nil
	-- Consider resetting copy button state if needed

	local players = Players:GetPlayers()
	for _, player in ipairs(players) do
		if player == localPlayer then -- Optionally skip local player
			-- continue
		end

		local playerButton = Instance.new("TextButton")
		playerButton.Name = "PlayerButton_" .. player.Name
		playerButton.Size = UDim2.new(1, -10, 0, 30) -- Full width of list content area
		playerButton.Text = player.DisplayName
		playerButton.TextColor3 = Color3.fromRGB(220, 220, 220)
		playerButton.BackgroundColor3 = DEFAULT_BUTTON_COLOR
		playerButton.Font = Enum.Font.SourceSans
		playerButton.TextSize = 14
		playerButton.LayoutOrder = #playerListFrame:GetChildren() -- Maintain order
		playerButton.Parent = playerListFrame

		playerButton.MouseButton1Click:Connect(function()
			if selectedPlayerButton then
				selectedPlayerButton.BackgroundColor3 = DEFAULT_BUTTON_COLOR
			end
			playerButton.BackgroundColor3 = SELECTED_BUTTON_COLOR
			selectedPlayerButton = playerButton
			selectedTargetPlayer = player
			print("AvatarCopier: Selected target - " .. player.Name)
		end)
	end
	print("AvatarCopier: Player list updated. Found " .. #players .. " players.")
end

-- Avatar Copying Function
function applyAvatar(targetPlayer)
	if not targetPlayer then
		warn("AvatarCopier: ApplyAvatar called with no targetPlayer.")
		return
	end

	print("AvatarCopier: Attempting to copy avatar from " .. targetPlayer.Name .. " to " .. localPlayer.Name)

	local localCharacter = localPlayer.Character
	local targetCharacter = targetPlayer.Character

	if not localCharacter then
		warn("AvatarCopier: LocalPlayer character not found.")
		return
	end
	if not targetCharacter then
		warn("AvatarCopier: TargetPlayer character (" .. targetPlayer.Name .. ") not found.")
		return
	end

	local localHumanoid = localCharacter:FindFirstChildOfClass("Humanoid")
	local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")

	if not localHumanoid then
		warn("AvatarCopier: LocalPlayer humanoid not found.")
		return
	end
	if not targetHumanoid then
		warn("AvatarCopier: TargetPlayer humanoid (" .. targetPlayer.Name .. ") not found.")
		return
	end

	-- Method 1: HumanoidDescription (Primary)
	local success, result = pcall(function()
		local description = targetHumanoid:GetAppliedDescription()
		localHumanoid:ApplyDescription(description)
	end)

	if success then
		print("AvatarCopier: Successfully applied HumanoidDescription from " .. targetPlayer.Name)
		-- Optional: Respawn character to ensure all changes apply cleanly, though ApplyDescription should handle most.
		-- localPlayer:LoadCharacter()
		return
	else
		warn("AvatarCopier: Failed to apply HumanoidDescription. Error: " .. tostring(result) .. ". Attempting manual copy as fallback.")
	end

	-- Method 2: Manual Copying (Fallback)
	print("AvatarCopier: Starting manual avatar copy...")

	-- Clear Existing Items on LocalPlayer
	for _, item in ipairs(localCharacter:GetChildren()) do
		if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
			item:Destroy()
		end
	end

    -- Manually remove existing body parts that might conflict before cloning new ones
    -- This is tricky; for simplicity, we'll rely on HumanoidDescription or LoadCharacter for major structure.
    -- If HumanoidDescription failed, a full LoadCharacter might be safer than partial manual part replacement.

	-- Copy Body Colors
	local targetBodyColors = targetCharacter:FindFirstChild("Body Colors")
	if targetBodyColors then
		local localBodyColors = localCharacter:FindFirstChild("Body Colors")
		if localBodyColors then localBodyColors:Destroy() end
		targetBodyColors:Clone().Parent = localCharacter
	end

	-- Copy Accessories
	for _, item in ipairs(targetCharacter:GetChildren()) do
		if item:IsA("Accessory") then
			item:Clone().Parent = localCharacter
		end
	end

	-- Copy Clothing
	for _, item in ipairs(targetCharacter:GetChildren()) do
		if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
			item:Clone().Parent = localCharacter
		end
	end

	-- Copy Scales
	local scaleNames = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}
	for _, scaleName in ipairs(scaleNames) do
		local targetScale = targetHumanoid:FindFirstChild(scaleName)
		local localScale = localHumanoid:FindFirstChild(scaleName)
		if targetScale and localScale then
			localScale.Value = targetScale.Value
		end
	end

    -- After manual changes, a character reload is often the most reliable way to ensure visuals update correctly
    -- and the rig is rebuilt properly, especially if body parts themselves were intended to be changed
    -- (which we are mostly avoiding in this simplified manual fallback, focusing on attachments/clothes/scales).
	print("AvatarCopier: Manual copy attempt finished. Forcing character reload for consistency.")
	localPlayer:LoadCharacter()

	print("AvatarCopier: Avatar copy process completed for " .. targetPlayer.Name)
end


-- Connect Buttons
refreshButton.MouseButton1Click:Connect(updatePlayerList)

copyButton.MouseButton1Click:Connect(function()
	if selectedTargetPlayer then
		applyAvatar(selectedTargetPlayer)
	else
		print("AvatarCopier: No target selected. Please select a player from the list.")
        -- Optionally, provide user feedback via a GUI label.
	end
end)

-- Initial Population
updatePlayerList()

-- Handle player joining/leaving to keep list updated (optional enhancement)
Players.PlayerAdded:Connect(function(player)
    -- Small delay to ensure player is fully set up if needed, then refresh
    task.wait(0.5)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function(player)
    -- If the removed player was selected, clear selection
    if selectedTargetPlayer == player then
        if selectedPlayerButton then
            selectedPlayerButton.BackgroundColor3 = DEFAULT_BUTTON_COLOR
        end
        selectedPlayerButton = nil
        selectedTargetPlayer = nil
        print("AvatarCopier: Selected target " .. player.Name .. " left the game.")
    end
    -- Small delay to ensure player is fully removed, then refresh
    task.wait(0.5)
    updatePlayerList()
end)

print("AvatarCopier.lua: Script initialized with GUI and logic.")
print("AvatarCopier: Select a player from the list and click 'Copy Appearance'.")
