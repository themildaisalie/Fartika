--!strict

--- ////////////////////
--- EXAMPLE INIT SCRIPT
--- ////////////////////``

local camera = workspace.CurrentCamera

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Modules = ReplicatedFirst:WaitForChild("Modules")
local VolumetricLib = require(Modules:WaitForChild("VolumetricLib"))

local width = 16
local height = math.round(width / (camera.ViewportSize.X / camera.ViewportSize.Y)) --Scales with aspect ratio roughly correctlyaws

local layerCount = 12
local totalDepth = 120
local volumeDensity = 0.2

local layers = {}
for x = 1, layerCount do
	table.insert(layers, VolumetricLib.BuildFrustrumLayer({
		width = width;
		height = height;
		depth_studs = (totalDepth / layerCount) * x;

		density = math.sqrt(volumeDensity / layerCount); --TODO find equation to get the required density/transparency per layer for all layers to equal volumeDensity
		light_influence = 1;
	}))
end

game:GetService("RunService").RenderStepped:Connect(function()
	for x, i in layers do
		i:Update()
	end
end)
