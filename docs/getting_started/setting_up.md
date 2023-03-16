---
sidebar_position: 1
---

# Setting Up

---

### Installation

Go to [GitHub Releases](https://github.com/wicked-wlzard/silk/releases) and download the attached *.rbxm* file from the latest release. Alternatively, download the source code and move the src folder to anywhere inside your project then rename it to *silk*.

---

### Project Structure

A project can typically be structured in any way preferred by the developer. The following structure shows a minimalistic example of what an ideal project structure might look like. 

##### Ideal project structure:

```
Project
│
├─ ServerScriptService
│	├─ initializer.server.lua 
│	└─ script.server.lua
│
├─ ReplicatedStorage
│	└─ silk
│		└─ ...
│
└─ StarterPlayer
	└─ StarterPlayerScripts
		├─ initializer.client.lua
		└─ script.client.lua
```