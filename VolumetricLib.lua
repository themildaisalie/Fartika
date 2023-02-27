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
	FrustrumLayer: {
		[Vector3]: {
			Instance: Attachment & {
				ParticleEmitter: ParticleEmitter
			};
			RelativeCFrame: CFrame;
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

function VolumetricLib.BuildFrustrumLayer(config: FrustrumConfig): FrustumLayer --Constructor
	local fov = camera.FieldOfView
	local camera_position = camera.CFrame.Position
	
	local viewport_offset = (camera.ViewportSize / Vector2.new(config.width, config.height)) * 0.25
	
	--Get size for particles
	local aspect_ratio = (camera.ViewportSize.X / camera.ViewportSize.Y) / (config.width / config.height)
	local particle_squish = -(aspect_ratio - 1)
	local particle_size = ((math.atan(fov) * config.depth_studs) / config.height) * 1.11

	local frustrum_instances = {}

	for x = 1, config.width do
		for y = 1, config.height do
			local unit_ray = camera:ViewportPointToRay(((camera.ViewportSize.X / config.width) * x) - viewport_offset.X, ((camera.ViewportSize.Y / config.height) * y) - viewport_offset.Y)
			
			local depth_multi = 1 / camera.CFrame.LookVector:Dot(unit_ray.Direction)
			
			local origin = unit_ray.Origin + (unit_ray.Direction * config.depth_studs * depth_multi)
			local world_cframe = CFrame.lookAt(origin, camera_position)

			local attachment = Instance.new("Attachment"); do
				attachment.WorldCFrame = world_cframe
				attachment.Parent = workspace.Terrain
			end

			local particle = Instance.new("ParticleEmitter"); do
				particle.Enabled = false
				particle:Emit(1)
				particle.Size = NumberSequence.new(particle_size, particle_size)
				particle.Transparency = NumberSequence.new(1 - config.density, 1 - config.density)
				particle.Squash = NumberSequence.new(particle_squish, particle_squish)
				particle.TimeScale = 0
				particle.LightInfluence = config.light_influence
				particle.LockedToPart = true
				particle.Texture = "http://www.roblox.com/asset/?id=1195495135"
				particle.Parent = attachment
			end

			frustrum_instances[Vector3.new(y, x, 0)] = {
				Instance = attachment;
				RelativeCFrame = camera.CFrame:ToObjectSpace(world_cframe);
			}
		end
	end

	local self = setmetatable({FrustrumLayer = frustrum_instances}, FrustrumLayer) :: any

	return self
end

function FrustrumLayer.Update(self: FrustumLayer)
	for x, i in self.FrustrumLayer do
		i.Instance.WorldCFrame = camera.CFrame * i.RelativeCFrame
	end
end

--- << Generics

--- << Connect

--- < Public config > ---

--- < Public variables > ---


return VolumetricLib
