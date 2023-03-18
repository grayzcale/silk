-- Package: Tween.lua
-- Written for SILK Game Framework by @Wicked_Wlzard
-- API: https://wicked-wlzard.github.io/silk/

local tween = {}
tween.__index = tween

function tween.__initialize(silk)
	tween.silk = silk
	return tween
end

--[=[
		Creates a new tween object and plays it. `params` could be a number to directly pass in the tween time.
		@within Tween
		@param object Instance
		@param params number | TweenInfo
		@param goal { [string]: any }
]=]
function tween.play(object, params, goal)
	params = if typeof(params) == "number" then TweenInfo.new(params) else params
	return tween.silk.TweenService:Create(object, params, goal):Play().Completed
end

return tween

--[=[
		Custom wrapper for TweenService.
		
		| Package Attribute | Value |
		| --- | --- |
		| __singleton | false |
		| __domain | shared |

		@class Tween
]=]
