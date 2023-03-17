---
sidebar_position: 3
---

# Accessing SILK

When accessing `Silk` through other scripts, they must first yield until the class has initialized completely before executing any further.

---

### Using scripts

To start using SILK in scripts, the script must first yield until the server reaches the initialized state. To do this, execute the `Silk.Wait` method after retrieving `Silk` normally. This will ensure that the script yields until the server is in a ready state.

##### Sample server script:
```lua
-- || script.server.lua ||

-- Retrieve the Silk class using Silk.Wait
local silk = require(game:GetService('ReplicatedStorage'):WaitForChild('silk')):Wait()

print('Server is ready!')

```

The same principle is also applied to client scripts. When using the `Silk.Wait` method, `LocalScripts` will yield until the client reaches a ready state. 