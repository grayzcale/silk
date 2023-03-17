-- Package: Network.lua 
-- Written for SILK Game Framework by @Wicked_Wlzard
-- API: https://wicked-wlzard.github.io/silk/

local network = { __singleton = true }
network.__index = network

-- Network initialization function
function network.__initialize(silk)
	
	network.silk = silk
	local self = setmetatable({}, network)
	
	-- Register a get-remote action on SILK
	if silk:IsServer() then
		silk:RegisterAction('Network::GetCommunicator', function(_, ...)
			local comm, rem = ...
			return self._comms[comm].events[rem] or self._comms[comm].functions[rem]
		end)
	end
	
	return self
end


-- Alias for Network.GetCommunicator
function network.__call(self, ...)
	return self:GetCommunicator(...)
end

--[=[
		Use this method to add communicators during the initialization phase.
		@within Network
		@param commDirectories {Folder}
]=]
function network:AppendCommunicators(commDirectories)
	
	-- Verify that the method is being called on the server
	if not self.silk:IsServer() then return end
	
	self._commsContainer = self._commsContainer or self.silk.new('Folder', self.silk.ReplicatedStorage).Name('Communicators')()
	self._comms = self._comms or {}
	
	for _, directory in ipairs(commDirectories) do
		for _, comm in ipairs(directory:GetChildren()) do
			
			-- Return-data for each commuincator
			local commData = require(comm)(self.silk)
			self._comms[comm.Name] = { events = {}, functions = {} }
			
			-- Loop and store the contents of the commuincator data
			for _, remoteType in ipairs({ 'events', 'functions' }) do

				-- Make sure events and functions are supplied
				if not commData[remoteType] then
					continue
				end

				-- No remotes have been supplied; decalre error
				if not commData[remoteType].remotes then
					self.silk:Declare(error, `Network Error: Communicator "{comm}" was given {remoteType} but was not supplied with remotes`)
				end

				for _, remoteName in ipairs(commData[remoteType].remotes) do
					local remote = self.silk.new(remoteType == 'events' and 'RemoteEvent' or 'RemoteFunction', self._commsContainer).Name('')()
					self._comms[comm.Name][remoteType][remoteName] = remote
				end
			end
			
			-- Handle communicator actions for events
			if commData.events and commData.events.actions then
				for eventAction, action in pairs(commData.events.actions) do
					self._comms[comm.Name].events[eventAction].OnServerEvent:Connect(action)
				end
			end

			-- Handle communicator actions for functions
			if commData.functions and commData.functions.actions then
				for functionAction, action in pairs(commData.functions.actions) do
					self._comms[comm.Name].functions[functionAction].OnServerInvoke = action
				end
			end
			
		end
	end
end

--[=[
		Using the communicator and remote name, you can obtain access to the remote. If called by the server, a [RemoteEvent] or [RemoteFunction] is returned directly. For clients however, instead of returning the remote Instance directly, only the remote methods are exposed through a table.
		
		Communicators can also be obtained by calling the Network package directly with the same parameters.

		##### Getting a communicator by calling the package
		```lua
		local remote = network{ <Communicator>, <Remote> }
		```

		@within Network
		@param ... {communicator: string, remote: string}
		@return NetworkRemote
]=]
function network:GetCommunicator(...)

	local comm, rem = table.unpack(...)
	
	-- Directly return reference to remote if called on server
	if self.silk:IsServer() then
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

return network

--[=[
		A package written for easy server and client communication.

		| Package Attribute | Value |
		| --- | --- |
		| __singleton | true |
		| __domain | shared |

		---

		### Communicators

		Communicators can be used to configure and setup communication between the server and client.

		To create commuincators, insert a new private [Folder] anywhere inside your project and name it "Communicators." To create a new commuincator, insert a new [ModuleScript] inside the folder and name the script, for example "Coins" or "Shop." This will be the name of the communicator.

		##### Communicator script format:
		```lua
		return {
			
			-- Configuration for RemoteEvents
			events = {

				-- List of events
				remotes = {
					'Event'
				},

				-- List of actions for the events
				actions = {

					-- An action that is triggered whenever the remote is fired by the client
					Event = function(client)
						print(`This remote was fired by {client.Name}!`)
					end,
				},
			},
			
			-- Configuration for RemoteFunctions
			functions = {
				
				-- List of functions
				remotes = {
					'Function'
				},

				-- List of actions for the functions
				actions = {

					-- An action that is triggered whenever the remote is invoked by the client
					Event = function(client)
						return `{client.Name} invoked this remote!`
					end,
				},

			}
	
		}
		```

		:::caution Naming Remotes
		When naming remotes, make sure to avoid having remotes with the same name.
		:::

		---

		### Adding Communicators

		Communicators can be added in using the initializer script. Add the communicators in using the `Network.AppendCommunicators` method.

		##### Adding communicators during the initialization phase:
		```lua
		-- || initializer.server.lua ||

		silk.Packages.Network:AppendCommunicators{ 
			silk.ServerStorage:WaitForChild('Communicators'),
		}
		```

		---

		### Accessing Communicators

		To access a communicator, use the method [Network.GetCommunicator] or call the package itself.

		##### Accessing a communicator
		```lua
		-- Retrieve the Network package
		local network = silk.Packages.Network

		-- Similar to using Network.GetCommunicator
		local remote = network.Communicator{ <Communicator>, <Remote> }

		```

		@class Network
]=]