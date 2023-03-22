local userInterface = {  __domain = 'local' }
userInterface.__index = userInterface

function userInterface.__initialize(silk)
	userInterface.silk = silk
	return userInterface
end

function userInterface.typeWrite(instance, text, step)

	if instance:GetAttribute('TypeWriting', true) then
		instance:SetAttribute('TypeWriting', nil)
	end
	instance:SetAttribute('TypeWriting', true)

	instance.MaxVisibleGraphemes = 0
	instance.Text = text

	local connection
	local thread

	connection = instance.AttributeChanged:Connect(function(attribute)
		if attribute == 'TypeWriting' then
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
		instance:SetAttribute('TypeWriting', nil)
	end)
	coroutine.resume(thread)

end

return userInterface