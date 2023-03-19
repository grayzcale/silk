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
		Creates a new tween object and plays it. `params` is passed in as the tween time if it is a `number`. Returns a `wait` method that is equivalent to `TweenBase.Completed:Wait()`.
		@within Tween
		@yields
		@param object Instance
		@param params number | TweenInfo
		@param goal { [property: string]: endvalue: any }
		@return { Tween: TweenBase, wait: () -> () }
]=]
function tween.play(object, params, goal)
	params = if typeof(params) == "number" then TweenInfo.new(params) else params
	local tweenbase = tween.silk.TweenService:Create(object, params, goal)
	tweenbase:Play()
	return {
		Tween = tweenbase,
		wait = function()
			tweenbase.Completed:Wait()
		end,
	}
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
