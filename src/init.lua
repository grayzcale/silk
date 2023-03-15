-- SILK Game Framework
-- Written by: @Wicked_Wlzard
-- https://wicked-wlzard.github.io/silk/

--[=[
		A singleton class that is shared between all scripts.
		@class Silk
]=]
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

	self._isServer = self.RunService:IsServer()

	-- Handle server-sided initialization
	if self:IsServer() then

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

		-- Wait for network RemoteEvent and create new connection
		self._eventRemote = self.ReplicatedStorage:WaitForChild('__event__')
		self._eventRemote.OnClientEvent:Connect(function(action, ...)
			self._networkActions[action](...)
		end)

		-- Initialize framework on client using config recieved from the server
		self:AppendPackages(config.packageDirectories)
		self:AppendContainers(config.containers)
		self:AppendClasses(config.classes)

	end

	return self
end

--[=[	
		This utility function returns a reference to the main SILK [ModuleScript]. You can use it to easily access the contents of the script. For instance, when adding in *essential* packages to the framework.
		
		##### Adding essential packages:
		```lua
		-- || initializer.server.lua ||

		silk:AppendPackages{

			-- Directly access children of the Silk script
			silk.getScript():WaitForChild('essentials'),
		}
		```

		@within Silk
		@tag utility
]=]
function silk.getScript(): ModuleScript
	return script
end

--[=[
		Built-in implementation of a method-chainable object instantiator. Call itself at the end of the chain to return [Instance].

		:::danger important
		Do not forget to call itself after instantiation to return [Instance] (if needed).
		:::
		
		##### Creating a new object:
		```lua
		local part = silk.new('Part', workspace)
			.Name('NewPart')
			.Anchored(true)()
		```

		@within Silk
		@tag utility
]=]
function silk.new(object: string | Instance, parent: Instance?): self

	-- Instantitate new object and set parent
	object = if typeof(object) == 'string' then Instance.new(object) else object
	object.Parent = parent

	return setmetatable({ _instance = object }, {

		-- Return object Instance when metatable is called
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

--[=[
		This is a custom wrapper function for the `.WaitForChild` method. Use this utility function to simplify your code and avoid redundant chains of consequtive `.WaitForChild` calls.
		
		##### Usage example:
		```lua		
		-- Long, consequtive calls of .WaitForChild...
		A:WaitForChild('B'):WaitForChild('C'):WaitForChild('D')

		-- ...can be simplied to this
		silk.waitFor{ A, 'B', 'C', 'D' }
		```

		@within Silk
		@yields
		@tag utility
]=]
function silk.waitFor(objects: table, timeout: number?): Instance
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
		@tag network
]=]
function silk:FireAllClients(action: string, ...: any): nil
	self._eventRemote:FireAllClients(action, ...)
end

--[=[
		@within Silk
		@tag network
]=]
function silk:FireClient(client: Player, action: string, ...: any): nil
	self._eventRemote:FireClient(client, action, ...)
end

--[=[
		@within Silk
		@tag network
]=]
function silk:FireServer(action: string, ...: any): nil
	self._eventRemote:FireServer(action, ...)
end

--[=[
		@within Silk
		@tag network
]=]
function silk:InvokeServer(action: string, ...: any): ...any
	return self._networkRemote:InvokeServer(action, ...)
end

--[=[
		Register an action to the server to quickly handle commuincation between server and client.

		:::tip
		Use this method in packages that require server and client communication for initialization.
		:::

		@within Silk
		@tag network
]=]
function silk:RegisterAction(action: string, callback: ((...any) -> ...any)): nil
	self._networkActions[action] = callback
end

--[=[
		Remove an existing action from the server.
		@within Silk
		@tag network
]=]
function silk:UnregisterAction(action: string): nil
	self._networkActions[action] = nil
end

--[=[
		Use this method to supply class directories to the framework.
		@within Silk
		@tag initializer
]=]
function silk:AppendClasses(classesDirectories: table): nil

	-- Classes handler
	self.Classes = self.Classes or setmetatable({}, {
		__index = function(_, ...)
			return self:InitClass(...)
		end,
	})

	-- Stop execution for client
	if not self:IsServer() then
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

--[=[
		Use this method to supply container directories to the framework.
		@within Silk
		@tag initializer
]=]
function silk:AppendContainers(containerDirectories: table): nil

	-- Stop execution for client
	if not self:IsServer() then
		self._containers = containerDirectories
		return
	end

	self._containers = self._containers or {}
	for container, directory in pairs(containerDirectories) do
		self._containers[container] = directory
	end
end

--[=[
		Use this method to supply multiple package directories to the framework.
		@within Silk
		@tag initializer
]=]
function silk:AppendPackages(packageDirectories: table): nil

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

--[=[
		Used internally to indicate potential any errors and warnings to output.
		@within Silk
]=]
function silk:Declare(callback: ((msg: string) -> any), msg: string): nil
	callback(`\n\n  [SILK] {msg}\n`)
end

--[=[
		Returns the container Instance for `container`.
		@within Silk
]=]
function silk:GetContainer(container: string): Instance
	return self._containers[container]
end

--[=[
		Gets a Roblox service as an [Instance] and caches it internally. This method is called internally whenever a service is attempted to be retrieved via `silk.<Service>`.
		@within Silk
]=]
function silk:GetService(service: string): Instance
	if typeof(self._services[service]) == 'number' then
		self._services[service] = game:GetService(service)
	end
	return self._services[service]
end

--[=[
		This method is called internally whenever a class is referenced `silk.Classes.<Class>`. This method can be used directly to intialize any class if needed.
		@within Silk
]=]
-- Initialize class
function silk:InitClass(class: string): any

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

--[=[
		This method is called internally whenever a package is referenced `silk.Packages.<Package>`.
		
		:::tip
		Use this method to intialize any singleton packages during the initializer phase.
		:::

		@within Silk
]=]
function silk:InitPackage(package: Package): any

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

--[=[
		Returns `true` if the current execution is taking place on the server.
		@within Silk
]=]
function silk:IsServer(): boolean
	return self._isServer
end

--[=[
		Yields until the initialization phase is completed, i.e. [Silk] should be accessed this way for all scripts except the initializer scripts. See [Silk.Weave] for more information.
		@within Silk
		@yields
]=]
function silk:Wait(): Silk
	if self._initialized then return self end
	self._threadsQueue = self._threadsQueue or {}
	table.insert(self._threadsQueue, coroutine.running())
	coroutine.yield()
	return self
end

--[=[
		Marks the end of the initialization phase and resumes execution for all scripts yielding with [Silk.Wait]. Use this method inside of a single initializer script and call it at the end of the phase when all the initializations are complete. See below for more details.
		
		##### Sample initializer script
		```lua
		-- || initializer.server.lua ||

		local silk = require(...)
		
		-- Perform initializations
		silk:AppendPackages{ ... }
		silk:AppendContainers{ ... }
		silk:AppendClasses{ ... }
		silk.Packages.Network:AppendCommunicators{ ... }
		
		-- Finally, call Silk.Weave to mark the end of the initialization phase
		silk:Weave()
		```

		@within Silk
]=]
function silk:Weave(): nil
	self._initialized = true
	if not self._threadsQueue then return end

	local threads = self._threadsQueue
	self._threadsQueue = nil

	for _, thread in ipairs(threads) do
		coroutine.resume(thread)
	end
end

return silk.__initialize()

--[=[
		A container is any [Instance] (usually a [Folder]) that contains a specific collection of objects as its children. Containers can be added to the framework using [Silk.AppendContainers] during the initializer phase.

		##### Adding containers:
		```lua
		-- || initializer.server.lua ||

		silk:AppendContainers{

			-- Supply a folder 'Assets' as a container with the name 'Asset'
			Asset = silk.ReplicatedStorage:WaitForChild('Assets'),
		}
		```

		You can access a container by executing `Silk.Get<ContainerName>(object: Instance) -> nil` as a method of the framework. See below for more details.

		##### Accessing objects inside containers:
		```lua
		-- A container named 'Asset'
		local asset = silk:GetAsset('Model'):Clone()
		```
		
		Other container methods:
		- [Silk.AppendContainers]
		- [Silk.GetContainer]

		@type Container Instance
		@within Silk
]=]

--[=[
		Roblox service as an [Instance].
		
		##### Getting a service:
		```lua
		-- Directly access any service from Silk
		local replicatedStorage = silk.ReplicatedStorage
		```

		:::caution Limitation
		You may recieve an error while trying to get some services. This is because the service may not exist in the current list of services. To fix this, open the [ModuleScript] `services` and manually type it in.
		:::

		@type Service Instance
		@within Silk
]=]

--[=[		
		A Package is a normal Roblox [ModuleScript] that can return any datatype. SILK conveniently provides a number of pre-written packages known as *essentials*. Navigate to "Included Packages" to view a complete list.

		---

		### Implementation

		Since a Package is just a [ModuleScript], the implementation of one gives flexibility for developers to adapt their Package best suited to their needs. The most common implementation of a Package, however, is shown below.

		##### Typical implementation of a Package:
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

		@class Package
]=]
--[=[
		An optional meta attribute that can be included in any package. If set to true, a cached reference to the package is returned whenever the package is referenced.

		:::info
		If [Package.__initialize] is also provided, the return value recieved after calling this method is cached instead.
		:::

		@prop __singleton boolean
		@within Package
]=]
--[=[
		An optional meta function that can be included in any package. The typical usecase for this is when `silk` is needed to perform futher intiailizations inside the package and to provide a simple, non-desrutive way for the package to access the main class.

		:::danger yielding
		[Package.__initialize] should be treated like a normal metamethod. Therefore, any thread yielding functions inside of the method will result in an error.
		:::

		@function __initialize
		@param silk Silk
		@return any
		@within Package
]=]