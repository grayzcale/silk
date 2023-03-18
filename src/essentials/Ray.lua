-- Package: Ray.lua
-- Written for SILK Game Framework by @Wicked_Wlzard
-- API: https://wicked-wlzard.github.io/silk/

local ray = {}

ray.__index = ray

ray.__newindex = function(self, index, value)
	self._parameters[index] = value
end

function ray.__initialize(silk)
	ray.silk = silk
	return ray
end

--[=[
		Create a new [Ray] object using `origin` and `direction`.
		@within Ray
		@tag instantiater
		@param origin Vector3
		@param direction Vector3
		@return Ray
]=]
function ray.new(origin, direction)
	return setmetatable({
		_origin = origin,
		_direction = direction,
		_parameters = RaycastParams.new(),
	}, ray)
end

--[=[
		Equivalent to workspace:Raycast().
		@within Ray
		@return RaycastResult
]=]
function ray:Cast()
	return workspace:Raycast(self._origin, self._direction, self._parameters)
end

--[=[
		Sets the filter type to `Exclude` and applies the filter, then executes [Ray.Cast].
		@within Ray
		@param exclude { Instance }
		@return RaycastResult
]=]
function ray:CastExclude(exclude)
	self.FilterType = Enum.RaycastFilterType.Exclude
	self.FilterDescendantsInstances = exclude
	return self:Cast()
end

--[=[
		Creates a new part to visualize the ray. By default, `color` is a random [Color3] value and `decay` is 7 seconds.
		@within Ray
		@param args {color: Color3?, decay: number?}
]=]
function ray:Visualize(args)
	args = args or {}

	-- Calculate ray length
	local origin, direction = self._origin, self._direction
	local length = ((origin + direction) - origin).Magnitude

	-- Create visualizer part
	local ray = self.silk
		.new("Part", workspace)
		.Name("RayVisualizer")
		.CFrame(CFrame.lookAt(origin, origin + direction) * CFrame.new(0, 0, -length / 2))
		.Size(Vector3.new(0.1, 0.1, length))
		.Transparency(0.3)
		.CanCollide(false)
		.Material(Enum.Material.Neon)
		.Color(args.color or Color3.new(math.random(), math.random(), math.random()))
		.Anchored(true)()

	-- Delete visualizer
	task.delay(args.decay or 7, ray.Destroy, ray)
end

return ray

--[=[
		Raycasting made easier using a custom class.
		
		| Package Attribute | Value |
		| --- | --- |
		| __singleton | false |
		| __domain | shared |

		@class Ray
]=]

--[=[
		To set any of the `RaycastParams`, access it directly from the object and set the value.
		
		```lua
		local ray = Ray.new(...)

		-- Ignore Terrain water
		ray.IgnoreWater = true
		```

		@type Ray Ray
		@within Ray
]=]
