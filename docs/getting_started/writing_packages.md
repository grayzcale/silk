---
sidebar_position: 4
---

# Writing Packages

Writing SILK packages is as easy as writing any typical ModuleScript but with extra functionality. Like with ModuleScripts, a package is allowed to return any datatype. However, when returning a table, you can choose to include any extra metadata which will be used internally to provide extra functionality.

By default, SILK contains core packages that are crucial for any typical projects. All of these packages are documented in the API under "Included Packages."

---

### Writing a Data Store Package

This section guides you through an example of writing a minimalistic data store package to save, load, and increment user data.

Structuring the package as a singleton will make sure that it gets intialized **once** whenever it is accessed. To declare a singleton package, set the meta attribute `__singleton` of the table to `true`.

##### Declaring a singleton package:
```lua
-- Declare package to be a singleton
local datastore = { __singleton = true }

return datastore
```
Before writing the necessary functions to save and load data, the package requires access to the Silk singleton class. Using the `__initialize` meta method, you can obtain access to `Silk` object and store it inside the metatable.

##### Converting the package to a metatable:
```lua
local datastore = { __singleton = true }
datastore.__index = datastore

-- Gain access to the singleton class using the __initialize meta method
function datastore.__initialize(silk)

	-- Store Silk inside metatable
	datastore.silk = silk

	local self = setmetatable({
		_datastore = datastore.silk.DataStoreService:GetDataStore('DATA'),
	}, datastore)

	return self
end

return datastore
```

You can then begin writing in the various methods to load, save, and increment data...

##### Complete package script:

:::caution
This is a minimal example that saves and loads data. It does not handle potential errors or edge cases such as when players join the game *before* the `PlayerAdded` connection is created.
:::

```lua
-- || DataStore.lua ||

local datastore = { __singleton = true }
datastore.__index = datastore

-- Write private function to return client key
local function getId(client)
	return `userdata_{client.UserId}`
end

function datastore.__initialize(silk)
	datastore.silk = silk
	
	local self = setmetatable({
		_datastore = datastore.silk.DataStoreService:GetDataStore('DATA'),
	}, datastore)
	
	-- Load data when a new player joins
	self.silk.Players.PlayerAdded:Connect(function(client)
		self:LoadData(client)

		-- Wait 3 seconds and increment coins by 100
		task.delay(3, self.AddCoins, self, client, 100)
	end)

	-- Save data when the player leaves
	self.silk.Players.PlayerRemoving:Connect(function(client)
		self:SaveData(client)
	end)
	
	return self
end

-- Primary data loading method
function datastore:LoadData(client)
	
	-- Get data or set an initial value if it doesn't exist
	local data = self._datastore:GetAsync(getId(client))
	data = data or {coins = 100}
	
	-- Create leaderstats to display coins
	local leaderstats = self.silk.new('Folder', client).Name('leaderstats')()
	self.silk.new('IntValue', leaderstats).Name('Coins').Value(data.coins)
	
	print(`Loaded data for {client.Name}!`)
end

-- Primary method to save data
function datastore:SaveData(client)

	-- Read data from leaderstats
	local data = {coins = client.leaderstats.Coins.Value}

	-- Save data
	self._datastore:SetAsync(getId(client), data)

	print(`Saved data for {client.Name}!`)
end

-- Increments coins in the leaderstats
function datastore:AddCoins(client, amount)
	client.leaderstats.Coins.Value += amount
end

return datastore
```

---

### Using the Package

To use the package, first create a folder somewhere in your project and move the package script inside it. Append the directory of the folder inside your initializer script using `Silk.AppendPackages` and initialize the package using `Silk.InitPackage`, which will execute the `__initialize` meta method.

##### Initializing the package:
```lua
local silk = require(game:GetService('ReplicatedStorage'):WaitForChild('silk'))

silk:AppendPackages{

	-- This folder contains the package 'DataStore'
	silk.ServerStorage:WaitForChild('PrivatePackages'),
}

-- Initialize the package
silk:InitPackage('DataStore')

silk:Weave()

```