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
							-- Direction from target to player
							local direction = (myHRP.Position - hrp.Position).Unit

							-- Position 5 studs away from the target
							local offsetPos = hrp.Position + direction * 5

							-- Move to the offset first
							humanoid:MoveTo(offsetPos)
							humanoid.MoveToFinished:Wait()

							-- Then move to the target
							humanoid:MoveTo(hrp.Position)

							break
						end
					end
				end
			end
		end

		task.wait(0.1)
	end
end)
