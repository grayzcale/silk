-- SILK Framework by @Wicked_Wlzard
-- https://github.com/wicked-wlzard/silk

local client = { _cached = true }

client.__index = function(self, index)
	if index == 'Client' then
		return self._client
	elseif index == 'PlayerGui' then
		return self._playerGui
	end
	return client[index]
end

-- Client initialization method
function client.__initialize__(silk)
	client.silk = silk
	return setmetatable({
		_client = silk.Players.LocalPlayer,
		_playerGui = silk.Players.LocalPlayer:WaitForChild('PlayerGui'),
	}, client)
end

-- Change MouseLock keybind for the user
function client:RebindMouseLock(keys)
	local shiftLockKey = self.silk.waitFor{ self._client.PlayerScripts, 'PlayerModule', 'CameraModule', 'MouseLockController', 'BoundKeys' }
	if not shiftLockKey then
		
		-- Create new StringValue to represent new keybind if it does not exist
		self.silk.new('StringValue', self._client.PlayerScripts.PlayerModule.CameraModule.MouseLockController)
			.Name("BoundKeys")
			.Value(keys)
		return
	end
	shiftLockKey.Value = keys
end

-- Perform appropriate checks and get character
function client:GetCharacter(yield)
	local cli = self._client
	if cli.Character and cli.Character.Parent ~= nil then
		return cli.Character, cli.Character:WaitForChild('Humanoid'), cli.Character:WaitForChild('HumanoidRootPart')
	end
	
	-- Return if yielding for character not specified
	if not yield then return false end
	return cli.CharacterAdded:Wait(), cli.Character:WaitForChild('Humanoid'), cli.Character:WaitForChild('HumanoidRootPart')
end

return client