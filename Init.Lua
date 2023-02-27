--!strict

--- ////////////////////
--- EXAMPLE INIT SCRIPT
--- ////////////////////``

local camera = workspace.CurrentCamera

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Modules = ReplicatedFirst:WaitForChild("Modules")
local VolumetricLib = require(Modules:WaitForChild("VolumetricLib"))

local width = 11
local height = math.round(width / (camera.ViewportSize.X / camera.ViewportSize.Y)) --Scales with aspect ratio roughly correctlyaws

local totalAmount = 5
local totalDepth = 80

local layers = {}
for x = 1, totalAmount do
	table.insert(layers, VolumetricLib.BuildFrustrumLayer({
		width = width;
		height = height;
		depth_studs = (totalDepth / totalAmount) * x;

		density = 0.23;
		light_influence = 1;
	}))
end

game:GetService("RunService").RenderStepped:Connect(function()
	for x, i in layers do
		i:Update()
	end
end)
