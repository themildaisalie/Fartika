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

type FrustumLayer = {
	FrustrumContainer: BasePart & {
		Attachment & {
			ParticleEmitter: ParticleEmitter;
		}
	};
	Update: (self: FrustumLayer) -> ();
}

type FrustrumConfig = {
	width: number;
	height: number;
	depth_studs: number;
	
	density: number;
	light_influence: number;
}

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

	local container_part = Instance.new("Part"); do
		container_part.Anchored = true
		container_part.CanCollide = false
		container_part.CanQuery = false
		container_part.CanTouch = false
		container_part.Transparency = 1
		container_part.Size = Vector3.zero
		container_part.Parent = camera
	end

	for x = 1, config.width do
		for y = 1, config.height do
			local unit_ray = camera:ViewportPointToRay(((camera.ViewportSize.X / config.width) * x) - viewport_offset.X, ((camera.ViewportSize.Y / config.height) * y) - viewport_offset.Y)
			
			local depth_multi = 1 / camera.CFrame.LookVector:Dot(unit_ray.Direction)
			
			local origin = unit_ray.Origin + (unit_ray.Direction * config.depth_studs * depth_multi)

			local attachment = Instance.new("Attachment"); do
				attachment.Position = camera.CFrame:PointToObjectSpace(origin) --Must be set after as it is parented to a part, this is temporary
				attachment.Parent = container_part
			end

			local particle = Instance.new("ParticleEmitter"); do
				particle.Enabled = false
				particle:Emit(1)
				particle.Size = NumberSequence.new(particle_size, particle_size)
				particle.Transparency = NumberSequence.new(1 - config.density, 1 - config.density)
				particle.Squash = NumberSequence.new(-particle_squish, -particle_squish)
				particle.TimeScale = 0
				particle.LightInfluence = config.light_influence
				particle.LockedToPart = true
				particle.Texture = "http://www.roblox.com/asset/?id=1195495135"
				particle.Parent = attachment
			end
		end
	end

	local self = setmetatable({FrustrumContainer = container_part}, FrustrumLayer) :: any

	return self
end

function FrustrumLayer.Update(self: FrustumLayer)
	--TODO update aspect ratio and stuff
	self.FrustrumContainer.CFrame = camera.CFrame
end

--- << Generics

--- << Connect

--- < Public config > ---

--- < Public variables > ---


return VolumetricLib
