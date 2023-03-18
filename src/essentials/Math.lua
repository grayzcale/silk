-- Package: Math.lua
-- Written for SILK Game Framework by @Wicked_Wlzard
-- API: https://wicked-wlzard.github.io/silk/

local mathP = {}
mathP.__index = mathP

function mathP.__initialize(silk)
	mathP.silk = silk
	return mathP
end

--[=[
		Returns a boolean `true` if `value` is within bounds (inclusive).		
		@within Math
		@param value number
		@param min number
		@param max number
		@return boolean
]=]
function mathP.isInRange(value, min, max)
	return if min <= value and value <= max then true else false
end

--[=[
		Returns a function with an input parameter, which when executed, returns an output for the given bounds.
		
		```lua
		Math.mapRange({ 0, 1 }, { 0, 100 })(0.5) -- 50
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

return mathP

--[=[
		This package contains extended math functions.
		
		| Package Attribute | Value |
		| --- | --- |
		| __singleton | false |
		| __domain | shared |

		@class Math
]=]
