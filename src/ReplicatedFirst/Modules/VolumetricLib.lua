--!strict

local VolumetricLib = {}

--- < Services > ---

--- << Roblox

--- << Luau

--- < Private variables > ---

local camera = workspace.CurrentCamera

--- < Private functions > ---

--- < VolumetricLib global functions > ---

local FrustrumLayer = {}
FrustrumLayer.__index = FrustrumLayer

local JUMBLE = Random.new()

type FrustumLayer = {
	FrustrumContainer: BasePart & {
		Attachment & {
			ParticleEmitter: ParticleEmitter;
		}
	};
	particle_size : number;
	Update: (self: FrustumLayer, SizeModifer: number) -> ();
}

type FrustrumConfig = {
	width: number;
	height: number;
	depth_studs: number;
	
	density: number;
	light_influence: number;
}
--[[
function CalculateParticleSquash(target_ratio: number): (number, number) --Gets the new size and squash of a particle
	local squash = math.sqrt(target_ratio) - 1
	
	local diff = 1 / (1 + squash)
	
	return squash,  diff
end

function VolumetricLib.BuildFrustrumLayer(config: FrustrumConfig): FrustumLayer --Constructor
	local fov = camera.FieldOfView
	local camera_position = camera.CFrame.Position
	
	local viewport_offset = (camera.ViewportSize / Vector2.new(config.width, config.height)) * 0.5
	
	--Get size for particles
	local ratio = (camera.ViewportSize.X / camera.ViewportSize.Y) / (config.width / config.height)
	local particle_squish, size_multi = CalculateParticleSquash(ratio)
	
	local magic_multi = 1 + (0.1 / config.depth_studs) --This accounts for gaps, perfectly?? somehow???
	local particle_size = (((math.tan(math.rad(fov * 0.5)) * config.depth_studs) / config.height) / size_multi) * magic_multi
	
	--particle_size*=2

	local container_part = Instance.new("Part"); do
		container_part.Anchored = true
		container_part.CanCollide = false
		container_part.CanQuery = false
		container_part.CanTouch = false
		container_part.Transparency = 1
		container_part.Size = Vector3.zero
		container_part.Parent = camera
	end

	local attachment = Instance.new("Attachment"); do

		attachment.Parent = container_part
	end

	local particle = Instance.new("ParticleEmitter"); do
		particle.Enabled = false
		particle.LockedToPart = false
		particle.Size = NumberSequence.new(particle_size, particle_size)
		particle.Transparency = NumberSequence.new(1 - config.density, 1 - config.density)
		particle.Squash = NumberSequence.new(-particle_squish, -particle_squish)
		particle.TimeScale = 0
		particle.LightInfluence = config.light_influence
		particle.Texture = "http://www.roblox.com/asset/?id=1195495135"
		particle.Parent = attachment
	end
	
	local centercframe = CFrame.new(0,0,0)
	
	--
	for x = 1, config.width do
		for y = 1, config.height do
			local unit_ray = camera:ViewportPointToRay(((camera.ViewportSize.X / config.width) * x) - viewport_offset.X, ((camera.ViewportSize.Y / config.height) * y) - viewport_offset.Y)
			
			local depth_multi = 1 / camera.CFrame.LookVector:Dot(unit_ray.Direction)
			

			
			
			local origin = unit_ray.Origin + (unit_ray.Direction * config.depth_studs * depth_multi)

			attachment.CFrame = CFrame.new(origin) --Must be set after as it is parented to a part, this is temporary
			particle:Emit(1)
			task.wait()

			
		end
		--task.wait(0)
	end
	
	particle.LockedToPart = true

	local self = setmetatable({FrustrumContainer = container_part}, FrustrumLayer) :: any

	return self
end
]]

function VolumetricLib.NewBuildFrustrumLayer(config: FrustrumConfig) : FrustumLayer --Constructor
	--Get size for particles


	--local magic_multi = 1 + (0.1 / config.depth_studs) --[dexa]This accounts for gaps, perfectly?? somehow???
	local particle_size = math.sin(0 + 1/config.width) * config.depth_studs

	
	
	local particle_squish = 0

	local container_part = Instance.new("Part"); do
		container_part.Anchored = true
		container_part.CanCollide = false
		container_part.CanQuery = false
		container_part.CanTouch = false
		container_part.Transparency = 1
		container_part.Size = Vector3.zero
		container_part.Parent = camera
	end

	local attachment = Instance.new("Attachment"); do

		attachment.Parent = container_part
	end

	local particle = Instance.new("ParticleEmitter"); do
		particle.Enabled = false
		particle.LockedToPart = false
		particle.Size = NumberSequence.new(particle_size, particle_size)
		particle.Transparency = NumberSequence.new(1 - config.density, 1 - config.density)
		particle.Squash = NumberSequence.new(particle_squish,particle_squish)
		particle.TimeScale = 0
		particle.LightInfluence = config.light_influence
		particle.Texture = "http://www.roblox.com/asset/?id=16082904523"
		particle.Parent = attachment
	end

	--local centercframe = CFrame.new(0,0,0) * CFrame.Angles(0,math.pi/2,0)


	for x = 0, config.width-1 do
		for y = 1, config.height do
			
			local devia = math.sin( math.rad( (y / config.height + 1 ) ) * 180 ) --vertical deviation

			local calcX = math.sin( math.rad( (x / config.width - 1 )  ) * 180 ) * devia -- x

			local calcY = math.cos( math.rad( (y / config.height + 1 ) ) * 180 ) 		   -- y

			local calcZ = math.cos( math.rad( (x / config.width - 1 )  ) * 180 ) * devia -- z

			local calcVec = Vector3.new(calcX, calcY, calcZ) * config.depth_studs + JUMBLE:NextUnitVector()*0.001
			
			
			attachment.Position = calcVec --Must be set after as it is parented to a part, this is temporary
			particle:Emit(1)
			task.wait()


		end
		--task.wait(0)
	end

	particle.LockedToPart = true

	local self : FrustumLayer = setmetatable({FrustrumContainer = container_part ,particle_size = particle_size}, FrustrumLayer) :: any
	
	return self
end


function FrustrumLayer.Update(self: FrustumLayer, Modifier)
	--TODO update aspect ratio and stuff
	self.FrustrumContainer:FindFirstChildOfClass("Attachment"):FindFirstChildOfClass("ParticleEmitter").Size = NumberSequence.new(self.particle_size * Modifier) --quite possibly inefficent, but like idrc,
	self.FrustrumContainer.CFrame = camera.CFrame * CFrame.Angles(0,math.pi/2,0)
end

--- << Generics

--- << Connect

--- < Public config > ---

--- < Public variables > ---

return VolumetricLib
