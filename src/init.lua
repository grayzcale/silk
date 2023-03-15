-- SILK Framework v1.0 by @Wicked_Wlzard
-- https://github.com/wicked-wlzard/silk

local silk = {}

silk.__index = function(self, index)
	if self._services[index] then

		-- Return service from cache
		return self:GetService(index)

	elseif rawget(self, '_containers') and self._containers[string.sub(index, 4)] then

		-- Return object-return function for container
		return function(_, ...)
			return self._containers[string.sub(index, 4)]:WaitForChild(...)
		end

	end
	return silk[index]
end

silk.__initialize = function()

	local self = setmetatable({
		_networkActions = {},
		_services = {},
		_initialized = false,
	}, silk)

	-- Initalize cache table for the listed services 
	for _, service in ipairs(require(script:WaitForChild('services'))) do
		self._services[service] = 0
	end

	self._server = self.RunService:IsServer()

	-- Handle server-sided initialization
	if self:Server() then

		-- Create a new action to provide initalization data to client
		self._networkActions.initializeClient = function()
			return {
				packageDirectories = self._packageDirectories,
				containers = self._containers,
				classes = self._classes,
			}
		end

		-- Create a new RemoteFunction to execute network actions
		self._networkRemote = self.new('RemoteFunction', self.ReplicatedStorage).Name('__network__')()
		self._networkRemote.OnServerInvoke = function(client, action, ...)

			-- Make sure server is loaded before running any actions
			while not self._initialized do
				task.wait()
			end

			return self._networkActions[action](client, ...)
		end

		-- Create a new RemoteEvent for extended functionality
		self._eventRemote = self.new('RemoteEvent', self.ReplicatedStorage).Name('__event__')()
		self._eventRemote.OnServerEvent:Connect(function(client, action, ...)

			-- Make sure server is loaded before running any actions
			while not self._initialized do
				task.wait()
			end

			self._networkActions[action](client, ...)
		end)

	else

		-- Wait for, and invoke, server for client initialization configuration
		self._networkRemote = self.ReplicatedStorage:WaitForChild('__network__')
		local config = self._networkRemote:InvokeServer('initializeClient')

		-- Wait for network RemoteEvent
		self._eventRemote = self.ReplicatedStorage:WaitForChild('__event__')

		-- Initialize framework on client using config recieved from the server
		self:AppendPackages(config.packageDirectories)
		self:AppendContainers(config.containers)
		self:AppendClasses(config.classes)

	end

	return self
end

--[=[
		@within Silk
		@yields
		@tag utility
		@param timeout?

		```lua
		silk.waitFor({workspace, 'Baseplate' }, 10)
		```

		This is a custom wrapper function for the `.WaitForChild` method. Use this utility function to simplify your code and avoid long chains of `.WaitForChild` calls.

		```lua		
		-- simplify this
		A:WaitForChild('B'):WaitForChild('C'):WaitForChild('D')

		-- to this
		silk.waitFor{ A, 'B', 'C', 'D' }
		```
]=]
function silk.waitFor(objects: table, timeout: number): Instance
	for _, object in ipairs(objects) do
		if typeof(objects) == 'table' then
			objects = objects[1]
			continue
		end
		objects = objects:WaitForChild(object, timeout)
	end
	return objects
end

--[=[
		@within Silk
		@tag utility
	
		This utility function returns a reference to the primary [Silk] object. You can use it to easily access the contents of the modulescript, for instance, when appending *essential* packages to the framework.
		
		```lua
		silk:AppendPackages{
			silk.getScript():WaitForChild('essentials')
		}
		```
]=]
function silk.getScript(): Script
	return script
end

--[=[
		@within Silk
		Returns `true` if current execution is taking place on the server.
]=]
function silk:Server(): boolean
	return self._server
end

--[=[
		@within Silk
		When Gets a service as `Instance` and stores reference in cache.
]=]
function silk:GetService(service: string): Instance
	if typeof(self._services[service]) == 'number' then
		self._services[service] = game:GetService(service)
	end
	return self._services[service]
end

-- Yield until framework intializer phase is completed
function silk:Wait()
	if self._initialized then return self end
	self._threadsQueue = self._threadsQueue or {}
	table.insert(self._threadsQueue, coroutine.running())
	coroutine.yield()
	return self
end

-- Indicate the end of the intializer phase
function silk:Weave()
	self._initialized = true
	if not self._threadsQueue then return end

	local threads = self._threadsQueue
	self._threadsQueue = nil

	for _, thread in ipairs(threads) do
		coroutine.resume(thread)
	end
end

-- Declare output messages/warns/errors
function silk:Declare(callback, msg)
	msg = string.format("\n\n  [SILK] %s\n", msg)
	if callback == debug.traceback then
		warn(msg)
		return print(debug.traceback())
	end
	callback(msg)
end

-- Built-in implementation of a method-chainable object instantiator
function silk.new(instance, parent)

	-- Instantitate new object and set parent
	instance = if typeof(instance) == 'string' then Instance.new(instance) else instance
	instance.Parent = parent

	return setmetatable({ _instance = instance }, {

		-- Return instance when metatable is called
		__call = function(self) return self._instance end,

		-- Return a function to set property
		__index = function(self, index)
			return function(value)
				self._instance[index] = value
				return self
			end
		end,

	})
end

-- Append packages to the framework
function silk:AppendPackages(packageDirectories)

	-- Packages handler
	self.Packages = self.Packages or setmetatable({}, {
		__index = function(_, ...)
			return self:InitPackage(...)
		end,
	})

	self._packages = self._packages or {}
	self._packageDirectories = self._packageDirectories or {}

	-- Initialize cache table for packages
	for _, directory in ipairs(packageDirectories) do
		for _, package in ipairs(directory:GetChildren()) do
			self._packages[package.Name] = package
		end
		table.insert(self._packageDirectories, directory)
	end

end

-- Return package from framework
function silk:InitPackage(package)

	-- Make sure package exists
	if not self._packages[package] then
		self:Declare(error, 'Package Error: Package \"'..package..'\" does not exist')
	end

	-- Verify if the package exists in cache
	if typeof(self._packages[package]) == 'Instance' then

		local loadedPackage = require(self._packages[package])

		-- Check if package is a singleton and execute package __initialize method
		if typeof(loadedPackage) == 'table' then
			local singleton = loadedPackage.__singleton			
			if loadedPackage.__initialize then
				loadedPackage = loadedPackage.__initialize(self)
			end
			if singleton then
				self._packages[package] = loadedPackage
			end
		end

		return loadedPackage
	end

	-- Return cached package
	return self._packages[package]
end

-- Append containers to the framework
function silk:AppendContainers(containerDirectories)

	-- Stop execution for client
	if not self:Server() then
		self._containers = containerDirectories
		return
	end

	self._containers = self._containers or {}
	for container, directory in pairs(containerDirectories) do
		self._containers[container] = directory
	end
end

-- Get reference to a container
function silk:GetContainer(container)
	return self._containers[container]
end

-- Append classes to the framework
function silk:AppendClasses(classesDirectories)

	-- Classes handler
	self.Classes = self.Classes or setmetatable({}, {
		__index = function(_, ...)
			return self:InitClass(...)
		end,
	})

	-- Stop execution for client
	if not self:Server() then
		self._classes = classesDirectories
		return
	end

	self._classes = self._classes or {}
	for _, directory in pairs(classesDirectories) do
		for _, class in ipairs(directory:GetChildren()) do
			self._classes[class.Name] = class
		end
	end
end

-- Initialize class
function silk:InitClass(class)

	-- Make sure class exists
	if not self._classes[class] then
		self:Declare(error, 'Class Error: Class \"'..class..'\" does not exist')
	end

	-- Prepare and return class
	class = require(self._classes[class])
	if typeof(class) == 'table' and class.__initialize then
		class = class.__initialize(self)
	end

	return class
end

-- Insert a new network action
function silk:RegisterAction(action, callback)
	self._networkActions[action] = callback
end

-- Remove network action
function silk:UnregisterAction(action)
	self._networkActions[action] = nil
end

-- Wrapper methods for internal network remotes
function silk:InvokeServer(...) return self._networkRemote:InvokeServer(...) end
function silk:FireServer(...) self._eventRemote:FireServer(...) end
function silk:FireClient(...) self._eventRemote:FireClient(...) end
function silk:FireAllClients(...) self._eventRemote:FireAllClients(...) end

return silk.__initialize()

--[=[
		@class Silk
		A singleton class that is shared between all scripts running on the same server or client in the session.
]=]
--[=[
		@type Service Instance
		@within Silk

		Default Roblox service as an [Instance].

		---
		
		#### Getting a [Service]:
		```lua
		local replicatedStorage = silk.ReplicatedStorage
		```

		:::caution Limitation
		You may recieve an error while trying to get some services, this is because the list of services is currently incomplete. To fix this, open the modulescript `services` and manually add it in.
		:::
]=]

--[=[
		@class Package
		
		A Package is a normal Roblox [ModuleScript] that can return any datatype.

		---

		### Implementation

		Since a Package is just a [ModuleScript], the implementation allows for flexibility for developers to create all kinds of Packages best suited to their needs. The most common implementation of a Package, however, is shown below.

		##### Common implementation of a Package:
		```lua
		--|| Package.lua ||
		
		local package = {}
		package.__index = package
		
		-- Optionally indicate that the package is a singleton
		package.__singleton = true
		
		-- This is called whenever this package is referenced or once if the package is a singleton
		-- Conveniently access silk to perform further intialization
		package.__initialize = function(silk)

			-- Store silk within the package for future use
			package.silk = silk
			
			-- This is the value that is returned during runtime
			-- If the package is a singleton, this return value is cached internally
			return package
		end

		function package.new()
			return setmetatable({}, package)
		end
		
		-- If a package has package.__initialize, the method is called and that value is returned instead during runtime
		return package
		```

		---

		### Management
		
		All packages should be added in using the [Silk.AppendPackages] method during the *initializer phase*.

		:::tip Storing Packages
		When storing package, place them in a secure location alongside all your other packages. For example, a folder containing all your *shared* packages.
		:::

		##### Adding in packages through the initializer script:
		```lua
		--|| initializer.server.lua ||

		silk:AppendPackages{

			-- Directory that contains all the packages
			game.ReplicatedStorage.Packages,
		}
		```

		---

		### Usage

		##### Initialize and return contents of package:
		```lua
		-- Can be accessed immediately after a package is added
		local package = silk.Packages.Package
		```

		Alternatively, when intialization for singleton packages is required during the initializer phase, instead of initializing the package directly using `silk.Packages.Package`, use [Silk.InitPackage].

		##### Intializing a package directly:
		```lua
		-- Initialize the package directly, executing package.__intialize if it exists
		silk:InitPackage('Package')
		```
]=]
--[=[
		@prop __singleton boolean
		@within Package

		An optional meta attribute that can be included in any package. If set to true, a cached reference to the package is returned whenever the package is referenced.

		:::info
		If [Package.__initialize] is also provided, the return value recieved after calling this method is cached instead.
		:::	
]=]
--[=[
		@function __initialize
		@param silk Silk
		@return any
		@within Package

		An optional meta function that can be included in any package. The typical usecase for this is when `silk` is needed to perform futher intiailizations inside the package and to provide a simple, non-desrutive way for the package to access the main class.
]=]