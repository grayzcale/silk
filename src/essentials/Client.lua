-- Package: Client.lua
-- Written for SILK Game Framework by @Wicked_Wlzard
-- API: https://wicked-wlzard.github.io/silk/

local client = { __singleton = true, __domain = "local" }

client.__index = function(self, index)
	if index == "Client" then
		return self._client
	elseif index == "PlayerGui" then
		return self._playerGui
	end
	return client[index]
end

-- Client initialization meta method
function client.__initialize(silk)
	client.silk = silk
	return setmetatable({
		_client = silk.Players.LocalPlayer,
		_playerGui = silk.Players.LocalPlayer:WaitForChild("PlayerGui"),
	}, client)
end

--[=[
		Change the MouseLock keybind for the client. A complete list of all the keys can be found [here](https://create.roblox.com/docs/reference/engine/enums/KeyCode).
		@within Client
		@param key string
]=]
function client:BindMouseLock(key)
	local shiftLockKey = self.silk.waitFor({
		self._client.PlayerScripts,
		"PlayerModule",
		"CameraModule",
		"MouseLockController",
		"BoundKeys",
	})
	if not shiftLockKey then
		-- Create new StringValue to represent the new keybind if it doesn't exist
		self.silk
			.new("StringValue", self._client.PlayerScripts.PlayerModule.CameraModule.MouseLockController)
			.Name("BoundKeys")
			.Value(key)
		return
	end
	shiftLockKey.Value = key
end

--[=[
		Disable control for the client character.
		@within Client
]=]
function client:DisableControls()
	if not self.controls then
		self.controls = require(self._client.PlayerScripts.PlayerModule):GetControls()
	end
	self.controls:Disable()
end

--[=[
		Re-enable control for the client character.
		@within Client
]=]
function client:EnableControls()
	if not self.controls then
		return
	end
	self.controls:Enable()
end

--[=[
		Performs appropriate checks to see if the client character exists and if it does, returns the character `Model`, `Humanoid`, and the `HumanoidRootPart`. Returns `nil` if the character doesn't exist and `waitFor` isn't set to `true`.
		@within Client
		@yields
		@param waitFor boolean
		@return Model, Humanoid, Part | nil
]=]
function client:GetCharacter(waitFor)
	local cli = self._client
	if cli.Character and cli.Character.Parent ~= nil then
		return cli.Character, cli.Character:WaitForChild("Humanoid"), cli.Character:WaitForChild("HumanoidRootPart")
	end

	-- Return if yielding for character not specified
	if not waitFor then
		return
	end
	return cli.CharacterAdded:Wait(),
		cli.Character:WaitForChild("Humanoid"),
		cli.Character:WaitForChild("HumanoidRootPart")
end

return client

--[=[
		This package contains methods and attributes involved with pure client-sided components.
		
		| Package Attribute | Value |
		| --- | --- |
		| __singleton | true |
		| __domain | local |

		@class Client
]=]

--[=[
		Returns the [Player] object for the client. Equivalent to `game.Players.LocalPlayer`.
		@prop Client Player
		@within Client
]=]

--[=[
		Returns the [PlayerGui] of the client.
		@prop PlayerGui PlayerGui
		@within Client
]=]
