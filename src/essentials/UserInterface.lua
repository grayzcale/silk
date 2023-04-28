-- Package: UserInterface.lua
-- Written for SILK Game Framework by @Wicked_Wlzard
-- API: https://wicked-wlzard.github.io/silk/

local userInterface = { __domain = "local" }
userInterface.__index = userInterface

function userInterface.__initialize(silk)
	userInterface.silk = silk
	return userInterface
end

--[=[
		Dynamically constrain text based on the size of any [GuiObject] with the `Text` property.
		@within UserInterface
		@param object GuiObject
		@param idealSize number
		@param anchor number
]=]
function userInterface.constrainText(object, idealSize, anchor)
	object:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
		object.TextSize = object.AbsoluteSize.Y * idealSize / anchor
	end)
	object.TextSize = object.AbsoluteSize.Y * idealSize / anchor
end

--[=[
		Perform a typewrite effect on any [GuiObject] with the `Text` property. This method overrides the previous effect if active.
		@within UserInterface
		@param instance GuiObject
		@param text string
		@param step number?
]=]
function userInterface.typeWrite(instance, text, step)
	if instance:GetAttribute("TypeWriting", true) then
		instance:SetAttribute("TypeWriting", nil)
	end
	instance:SetAttribute("TypeWriting", true)

	instance.MaxVisibleGraphemes = 0
	instance.Text = text

	local connection
	local thread

	connection = instance.AttributeChanged:Connect(function(attribute)
		if attribute == "TypeWriting" then
			connection:Disconnect()
			task.defer(coroutine.close, thread)
		end
	end)

	thread = coroutine.create(function()
		for i = 1, #text do
			instance.MaxVisibleGraphemes = i
			task.wait(step or 0.01)
		end
		instance.MaxVisibleGraphemes = -1
		instance:SetAttribute("TypeWriting", nil)
	end)
	coroutine.resume(thread)
end

return userInterface

--[=[
		UI related methods.
		
		| Package Attribute | Value |
		| --- | --- |
		| __singleton | false |
		| __domain | local |

		@class UserInterface
]=]
