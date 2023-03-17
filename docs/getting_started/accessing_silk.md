---
sidebar_position: 3
---

# Accessing SILK

Generally, when accessing Silk through other scripts, the script should yield until the class has initialized completely before performing any further executions.

---

### Using scripts

To start using SILK in scripts, the script must first yield until the server reaches the initialized state. To do this, execute the `Silk.Wait` method after retrieving Silk normally. This will ensure that the script yields until SILK is in a ready state.

##### Sample server script:
```lua
-- || script.server.lua ||

-- Retrieve the Silk class using Silk.Wait
local silk = require(game:GetService('ReplicatedStorage'):WaitForChild('silk')):Wait()

print('Server is ready!')

```

The same principle is applied to client localscripts. When using the `Silk.Wait` method, localscripts will yield until the client reaches a ready state. 