-- Package: Math.lua
-- Written for SILK Game Framework by @Wicked_Wlzard
-- API: https://wicked-wlzard.github.io/silk/

local mathP = {}
mathP.__index = mathP

function mathP.__initialize(silk)
	mathP.silk = silk
	return silk
end

--[=[
		Returns a function with an input parameter, which returns an output within the given bounds.
		
		```lua
		local f = silk.Packages.Math.mapRange({ 0, 1 }, { 0, 100 })
		print(f(1)) -- Outputs 100
		```
			
		@within Math
		@param inputBounds { inputMin: number, inputMax: number }
		@param outputBounds { outputMin: number, outputMax: number }
		@return (x: number) -> number
]=]
function mathP.mapRange(inputBounds, outputBounds)
	local inputMin, inputMax = unpack(inputBounds)
	local outputMin, outputMax = unpack(outputBounds)
	return function(x)
		return ((x - inputMin) * (outputMax - outputMin) / (inputMax - inputMin) + outputMin)
	end
end

--[=[
		This package contains extended math functions.
		
		| Package Attribute | Value |
		| --- | --- |
		| __singleton | false |
		| __domain | shared |

		@class Math
]=]
