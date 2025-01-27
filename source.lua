local function LookFor(name, class)
	for i, v in workspace:GetDescendants() do
		if v.Name == name and v:IsA(class) then
			return v
		end
	end
	warn(name.." wasn't found")
end

local function playSound(soundId)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. soundId
	sound.Volume = 3 -- Set volume to max (adjust as needed)
	sound.Parent = game.Workspace -- Parent it to Workspace (or anywhere audible)
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Instances
local TowerData = ReplicatedStorage:WaitForChild("TowerData")
local TeleportersFolder = game:GetService("Workspace"):WaitForChild("Teleporters")
local RestartBrick = LookFor("RestartBrick", "BasePart")
local Winpads = LookFor("WinPads", "Folder") --game.Workspace.Misc.WinPads
local DifficultyChart = LookFor("DifficultyChart", "Model")

-- Find Completed Towers
local completed = {}
local function UpdateCompletedTowers()
    completed = {}
	for i, v in pairs(DifficultyChart:GetDescendants()) do
		if v:IsA("BasePart") and v.Material == Enum.Material.SmoothPlastic and v.Color == Color3.new(0,1,0) then
			table.insert(completed, v.Parent.Name)
		end
	end
end

-- Player stuff
local Player = Players.LocalPlayer
local Character = Player.Character
local RootPart = Character.PrimaryPart

-- Modules
local TowerLibary = require(TowerData.TowerLibrary)
local SC_Towers = TowerLibary.GetSCTowers()

-- Tables
local Boosts = { -- Boost items to use for the tower.
	["Vertical Mobility"] = true,
}


-- While loop
task.spawn(function()
	while task.wait() do
		game.ReplicatedStorage.RequestStatistics.OnClientInvoke = function()
			return Boosts, 2, 0, 0, 0
		end
	end
end)



-- 
task.wait()
while true do
	local count = 0
	UpdateCompletedTowers()
	
	for _, Inst in pairs(TeleportersFolder:GetDescendants()) do
		if Inst:IsA("TouchTransmitter") then
			local Portal = Inst.Parent.Parent.Parent

			local Tower_Name = Portal.Name
			local firstTwo = string.sub(Tower_Name, 1, 2)

			if table.find(completed, Tower_Name) or table.find(SC_Towers, Tower_Name) or (firstTwo ~= "To" and firstTwo ~= "So") then
				warn("Skipped "..Tower_Name)
				continue
			else
				count += 1
				print("Doing: "..Tower_Name)
			end


			Character = Player.Character
			RootPart = Character.PrimaryPart
			firetouchinterest(Inst.Parent, RootPart, 1)
			task.wait()
			firetouchinterest(Inst.Parent, RootPart, 0)

			for _, Inst2 in pairs(Winpads:GetDescendants()) do
				if Inst2:IsA("TouchTransmitter") then
					firetouchinterest(Inst2.Parent, RootPart, 1)
					task.wait()
					firetouchinterest(Inst2.Parent, RootPart, 0)
				end
			end
			task.wait(1)
			firetouchinterest(RestartBrick, RootPart, 1)
			task.wait(1)
			firetouchinterest(RestartBrick, RootPart, 0)

			task.wait(5)
		end
	end
	
	if count == 0 then
		break
	end
end

print("-------------------------------------")
print("--------- TOWERS COMPLETED ----------")
print("-------------------------------------")

playSound(3318726694)
