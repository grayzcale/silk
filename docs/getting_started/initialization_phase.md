---
sidebar_position: 2
---

# Initialization Phase

As mentioned in [The SILK Lifecycle](/docs/lifecycle/), the initialization phase is responsible for handling the neccessary dependencies that your project requires.

---

### Initializer Script

To begin, start by creating a single script on the server. Require SILK normally as you would with any typical ModuleScript and type in any necessary configurations. Although the contents of this script will vary with every developer, this script will generally be responsible for declaring the end of the initialization phase to allow other scripts to begin execution. A typical initializer script may look something like the following.

##### Sample initializer script:
```lua
-- || initializer.server.lua ||

-- Path to the SILK ModuleScript
local silk = require(game:GetService('ReplicatedStorage'):WaitForChild('silk'))

-- Adding in containers
silk.AppendPackage{
	silk.ReplicatedStorage:WaitForChild('Assets'),
	silk.ServerStorage:WaitForChild('PrivateAssets'),
}

-- Adding in classes
silk.AppendClasses{ silk.ReplicatedStorage:WaitForChild('Classes') }

-- Adding in packages
silk.AppendPackage{
	silk.getScript():WaitForChild('essentials'),
	silk.ReplicatedStorage:WaitForChild('Packages'),
}

-- Initialization of the Network package and adding in communicators
silk.Packages.Network:AppendCommunicators{ silk.ServerStorage:WaitForChild('Communicators') }

-- Initialization of other singleton packages
silk:InitPackage('DataStorePackage')

-- Complete initialization
silk:Weave()
```

---

### Client Initializer Script

Unlike the server initializer script, providing configuration data to the client is not necessary. When a new client joins the server, this script automatically requests intialization data from the server and makes a seamless copy of singleteon class from the server. As seen above, some data like folders in the ServerStorage will not be replicated over to the client since they are hidden. Generally, this script should be used to load in the necessary assets for the client and initializing any client-sided components.

##### Sample client initializer script:
```lua
-- || initializer.client.lua ||

-- Path to the SILK ModuleScript
local silk = require(game:GetService('ReplicatedStorage'):WaitForChild('silk'))

-- Complete client-sided initialization
silk:Weave()
```