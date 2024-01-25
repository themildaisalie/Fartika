--!strict

--- ////////////////////
--- EXAMPLE INIT SCRIPT
--- ////////////////////``

--ORGINAL MADE BY @DecimalCubed
--MODIFIED BY @TheMildaIsALie

--enjoy poorly made volumetrics :D

--local camera = workspace.CurrentCamera

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Modules = ReplicatedFirst:WaitForChild("Modules")
local VolumetricLib = require(Modules:WaitForChild("VolumetricLib"))

ReplicatedFirst:SetAttribute("UpdateFrustrum", true)
ReplicatedFirst:SetAttribute("SizeModifier", 6)

local width = 9
local height = 9

local layerCount = 12
local totalDepth = 192
local volumeDensity = 0.1

local layers = {}
for x = 1, layerCount do
	task.defer(function()
		table.insert(layers, VolumetricLib.NewBuildFrustrumLayer({
			width = width;
			height = height;
			depth_studs = (totalDepth / layerCount) * x;

			density = math.pow(math.pow(volumeDensity,3) / layerCount, 1/3); --TODO find equatzion to get the required density/transparency per layer for all layers to equal volumeDensity
			light_influence = 1;
		}))
	end)
end



game:GetService("RunService").RenderStepped:Connect(function()
	if ReplicatedFirst:GetAttribute("UpdateFrustrum") == false then return end
	local SizeModifier = ReplicatedFirst:GetAttribute("SizeModifier")
	for _, i in layers do
		i:Update(SizeModifier)
	end
end)
