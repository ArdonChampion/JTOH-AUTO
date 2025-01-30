print("ARDON JTOH AUTO")
print("VERSION 2.02")

-- SETTINGS
local TELEPORT_AFTER = 300 -- in seconds
local DELAY_BETWEEN_TOWERS = 2 -- in seconds
local SCRIPT_LOADSTRING = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/ArdonChampion/JTOH-AUTO/refs/heads/main/source.lua"))()' -- to chain scripts


-- Utils
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
	sound.Volume = 4 -- Set volume to max (adjust as needed)
	sound.Parent = game.Workspace -- Parent it to Workspace (or anywhere audible)
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

local function TouchPart(part, RootPart)
	local success, _
	local count = 0
	while not success do
		if count >= 1 then
			warn("Touching part went wrong. ")
			task.wait(1)
		end
		success, _ = pcall(function()
			firetouchinterest(part, RootPart, 1)
			task.wait()
			firetouchinterest(part, RootPart, 0)
		end)
	end
	
end

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- Instances
local TowerData = ReplicatedStorage:WaitForChild("TowerData")
local TeleportersFolder = game:GetService("Workspace"):WaitForChild("Teleporters")
local RestartBrick = LookFor("RestartBrick", "BasePart")
local Winpads = LookFor("WinPads", "Folder") --game.Workspace.Misc.WinPads
local DifficultyChart = LookFor("DifficultyChart", "Model")
local UserId = plr.UserId


-- Teleport Related
local JTOHplaces = {
	9070657865, -- ring 1
	9070979698, -- ring 2
	9070980083, -- ring 3
	9070980555, -- ring 4
	9070980846, -- ring 5
	9070981164, -- ring 6
	9070981409, -- ring 7
	9070981722, -- ring 8
	9070982474, -- ring 9
	9070975342, -- paradise atoll
	9071001366, -- zone 2
	9071001563, -- zone 3
	9071001883, -- zone 4
	9071002104, -- zone 5
	9071002463, -- zone 6
	9071002677, -- zone 7
	9071002915, -- zone 8
	9071004505, -- zone 9
}

local function GetPlaceId()
	return game.PlaceId
end

local function GetNextPlaceId(currentId)
	local index = table.find(JTOHplaces, currentId)
	if index then
		if index == #JTOHplaces then
			print("No more places left!")
			return nil
		end
		return JTOHplaces[index + 1]
	end
	error("Place is not in the list: where the hell are you?")
end

local function TeleportPlayer(placeId)
	game:GetService("TeleportService"):TeleportAsync(placeId, UserId)
end

--wrapper
local function TeleportToNextPlace()
	-- Add the script to the queue for auto execution
	local queue = queueonteleport or queue_on_teleport
	queue(SCRIPT_LOADSTRING)

	local currentId = GetPlaceId()
	local nextId = GetNextPlaceId(currentId)
	TeleportPlayer(nextId)
end



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


-- Give Boost Items Loop
task.spawn(function()
	while task.wait() do
		game.ReplicatedStorage.RequestStatistics.OnClientInvoke = function()
			return Boosts, 2, 0, 0, 0
		end
	end
end)


-- Teleport After X minutes, if the boolean is still true
local WillTP = true
task.delay(TELEPORT_AFTER, function()
	if not WillTP then
		return
	end
	TeleportToNextPlace()
end)


-- Main Loop
task.wait()
while true do
	local count = 0
	UpdateCompletedTowers()
	
	for _, Inst in pairs(TeleportersFolder:GetDescendants()) do
		if Inst:IsA("TouchTransmitter") then
			local Portal = Inst.Parent.Parent.Parent

			local Tower_Name = Portal.Name
			local firstTwo = string.sub(Tower_Name, 1, 2)

			if table.find(completed, Tower_Name) or table.find(SC_Towers, Tower_Name) or string.sub(Tower_Name, -1) == ")" or (firstTwo ~= "To" and firstTwo ~= "So") then
				warn("Skipped "..Tower_Name)
				continue
			else
				count += 1
				print("Doing: "..Tower_Name)
			end


			Character = Player.Character
			RootPart = Character.PrimaryPart
			
			TouchPart(Inst.Parent, RootPart)

			for _, Inst2 in pairs(Winpads:GetDescendants()) do
				if Inst2:IsA("TouchTransmitter") then
					TouchPart(Inst2.Parent, RootPart)
				end
			end
			task.wait(1.5)
			TouchPart(RestartBrick, RootPart)

			task.wait(DELAY_BETWEEN_TOWERS)
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


-- set it false to avoid that delay statement
WillTP = false
TeleportToNextPlace()
