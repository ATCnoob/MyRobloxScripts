local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local myHRP = character:WaitForChild("HumanoidRootPart")

-- Toggles
local AutoBoss = false
local AutoFollow = false

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local BossButton = Instance.new("TextButton")
BossButton.Size = UDim2.new(0, 160, 0, 40)
BossButton.Position = UDim2.new(0, 440, 0, -50)
BossButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BossButton.TextColor3 = Color3.new(1, 1, 1)
BossButton.Text = "Auto Boss: OFF"
BossButton.Parent = ScreenGui

local FollowButton = Instance.new("TextButton")
FollowButton.Size = UDim2.new(0, 160, 0, 40)
FollowButton.Position = UDim2.new(0, 600, 0, -50)
FollowButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FollowButton.TextColor3 = Color3.new(1, 1, 1)
FollowButton.Text = "Auto Follow: OFF"
FollowButton.Parent = ScreenGui

--------------------------------------------------
-- Toggle Events
--------------------------------------------------

BossButton.MouseButton1Click:Connect(function()
	AutoBoss = not AutoBoss

	if AutoBoss then
		AutoFollow = false
		FollowButton.Text = "Auto Follow: OFF"
	end

	BossButton.Text = "Auto Boss: " .. (AutoBoss and "ON" or "OFF")
end)

FollowButton.MouseButton1Click:Connect(function()
	AutoFollow = not AutoFollow

	if AutoFollow then
		AutoBoss = false
		BossButton.Text = "Auto Boss: OFF"
	end

	FollowButton.Text = "Auto Follow: " .. (AutoFollow and "ON" or "OFF")
end)

--------------------------------------------------
-- Boss Functions
--------------------------------------------------

local function pressKey(keyName)
	local keyCode = Enum.KeyCode[keyName]
	if not keyCode then
		warn("Invalid key:", keyName)
		return
	end

	VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
	task.wait(0.1)
	VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

-- Spam E
task.spawn(function()
    while true do
        if AutoBoss then
            pressKey("E")
        end
        task.wait(0.1)
    end
end)

-- Spam Space
task.spawn(function()
    while true do
        if AutoBoss then
            pressKey("Space")
        end
        task.wait(0.1)
    end
end)

-- Boss loop
task.spawn(function()
    while true do
        if AutoBoss and character then
			local boss6 = workspace.RefreshPoints.NPC:FindFirstChild("boss6Spawn1")
            local boss8 = workspace.RefreshPoints.NPC:FindFirstChild("boss8Spawn1")
            local boss9 = workspace.RefreshPoints.NPC:FindFirstChild("boss9Spawn1")

            if boss8 then
                character:PivotTo(boss8.CFrame)
            end

            task.wait(2)

            if boss9 then
                character:PivotTo(boss9.CFrame)
            end

			task.wait(2)

			if boss6 then
				character:PivotTo(boss6.CFrame)
			end

            task.wait(2)
        else
            task.wait(1)
        end
    end
end)

--------------------------------------------------
-- Auto Follow Loop
--------------------------------------------------

task.spawn(function()
	while true do
		if AutoFollow and humanoid and myHRP then
			local cache = workspace.RuntimeCache.RuntimeCacheServer:FindFirstChild("CreatureModelCache")

			if cache then
				for _, creature in ipairs(cache:GetChildren()) do
					for _, pet in ipairs(creature:GetChildren()) do
						local hrp = pet:FindFirstChild("HumanoidRootPart")

						if hrp and (hrp.Position - myHRP.Position).Magnitude <= 50 then
							humanoid:MoveTo(hrp.Position)
							humanoid.MoveToFinished:Wait()
							pressKey("W")
							break
						end
					end
				end
			end
		end

		task.wait(1)
	end
end)
