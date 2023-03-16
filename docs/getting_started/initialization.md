---
sidebar_position: 2
---

# The Initialization Phase

---

### Project Structure

While a SILK project can be structured in any way, the following project structure provides an idea of a typical, minimalistic approach.

##### Ideal project structure:

```
Project
│
├─ ServerScriptService
│	├─ initializer.server.lua 
│	└─ server.lua
│
├─ ReplicatedStorage
│	└─ silk
│		└─ ...
│
└─ StarterPlayer
	└─ StarterPlayerScripts
		├─ initializer.client.lua
		└─ client.lua
```

---

### Initializer Scripts

To begin, start by creating a single initializer script on the server. This script will be responsible for making sure the neccessary dependancy packages, containers, etc. are included in the framework in order for all the other scripts to begin execution.