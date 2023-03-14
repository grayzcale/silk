-- SILK Framework by @Wicked_Wlzard
-- https://github.com/wicked-wlzard/silk

local network = { _cached = true }
network.__index = network

-- Network initialization function
function network.__initialize__(silk)
	
	network.silk = silk
	local self = setmetatable({}, network)
	
	-- Register a get-remote action on SILK
	if silk:Server() then
		silk:RegisterAction('Network::GetCommunicator', function(_, ...)
			local comm, rem = table.unpack(...)
			return self._comms[comm].events[rem] or self._comms[comm].functions[rem]
		end)
	end
	
	return self
end

-- Alias for Network.GetCommunicator
function network.__call(self, ...)
	return self:GetCommunicator(...)
end

-- Get communicator
function network:GetCommunicator(comm, rem)
	
	-- Directly return reference to remote if called on server
	if self.silk:Server() then
		return self._comms[comm].events[rem] or self._comms[comm].functions[rem]
	end
	
	-- Recieve reference to remote
	rem = self.silk:InvokeServer('Network::GetCommunicator', comm, rem)
	
	-- Return-metatable for a RemoteFunction
	if rem:IsA('RemoteFunction') then
		return setmetatable({
			InvokeServer = function(_, ...)
				return rem:InvokeServer(...)
			end,
		}, {
			__newindex = function(_, index, callback)
				rem[index] = callback;
			end,
		})
	end
	
	-- Return-metatable for a RemoteEvent
	return {
		FireServer = function(_, ...)
			rem:FireServer(...)
		end,
		OnClientEvent = rem.OnClientEvent,
	}
	
end

-- Append communicators to modulescript
function network:AppendCommunicators(commDirectories)
	
	-- Verify that the method is being called on the server
	if not self.silk:Server() then return end
	
	self._commsContainer = self._commsContainer or self.silk.new('Folder', self.silk.ReplicatedStorage).Name('Communicators')()
	self._comms = self._comms or {}
	
	for _, directory in ipairs(commDirectories) do
		for _, comm in ipairs(directory:GetChildren()) do
			
			-- Return-data for each commuincator
			local commData = require(comm)(self.silk)
			self._comms[comm.Name] = { events = {}, functions = {} }
			
			-- Loop and store the contents of the commuincator data
			for _, remoteType in ipairs({ 'events', 'functions' }) do
				for _, remoteName in ipairs(commData[remoteType].remotes) do
					local remote = self.silk.new(remoteType == 'events' and 'RemoteEvent' or 'RemoteFunction', self._commsContainer).Name('')()
					self._comms[comm.Name][remoteType][remoteName] = remote
				end
			end
			
			-- Handle communicator actions for server
			for eventAction, action in pairs(commData.events.actions) do
				self._comms[comm.Name].events[eventAction].OnServerEvent:Connect(action)
			end
			for functionAction, action in pairs(commData.functions.actions) do
				self._comms[comm.Name].functions[functionAction].OnServerInvoke = action
			end
			
		end
	end 
	
end

return network