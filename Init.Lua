--!strict

--- ////////////////////
--- EXAMPLE INIT SCRIPT
--- ////////////////////

local camera = workspace.CurrentCamera

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Modules = ReplicatedFirst:WaitForChild("Modules")
local VolumetricLib = require(Modules:WaitForChild("VolumetricLib"))

local pixelDensity = 80
local width = camera.ViewportSize.X / pixelDensity
local height = width * (camera.ViewportSize.Y / camera.ViewportSize.X)

local totalAmount = 10
local totalDepth = 150

local layers = {}
for x = 1, 6 do
	table.insert(layers, VolumetricLib.BuildFrustrumLayer({
		width = width;
		height = height;
		depth_studs = (totalDepth / totalAmount) * x;

		density = 0.1;
		light_influence = 1;
	}))
end

game:GetService("RunService"):BindToRenderStep("UpdateVolumetricFog", 100, function()
	for x, i in layers do
		i:Update()
	end
end)
