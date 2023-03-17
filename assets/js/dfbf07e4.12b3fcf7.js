"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[999],{65200:t=>{t.exports=JSON.parse('{"functions":[{"name":"AppendCommunicators","desc":"Use this method to add communicators during the initialization phase.","params":[{"name":"commDirectories","desc":"","lua_type":"{Folder}"}],"returns":[],"function_type":"method","source":{"line":36,"path":"src/essentials/Network.lua"}},{"name":"GetCommunicator","desc":"Using the communicator and remote name, you can obtain access to the remote. If called by the server, a [RemoteEvent] or [RemoteFunction] is returned directly. For clients however, instead of returning the remote Instance directly, only the remote methods are exposed through a table.\\n\\nCommunicators can also be obtained by calling the Network package directly with the same parameters.\\n\\n##### Getting a communicator by calling the package\\n```lua\\nlocal remote = network{ <Communicator>, <Remote> }\\n```","params":[{"name":"communicator","desc":"","lua_type":"string"},{"name":"remote","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"NetworkRemote"}],"function_type":"method","source":{"line":86,"path":"src/essentials/Network.lua"}}],"properties":[],"types":[],"name":"Network","desc":"A package written for easy server and client communication.\\n\\n| Package Attribute | Value |\\n| --- | --- |\\n| __singleton | true |\\n| __domain | shared |\\n\\n---\\n\\n### Communicators\\n\\nCommunicators can be used to configure and setup communication between the server and client.\\n\\nTo create commuincators, insert a new private [Folder] anywhere inside your project and name it \\"Communicators.\\" To create a new commuincator, insert a new [ModuleScript] inside the folder and name the script, for example \\"Coins\\" or \\"Shop.\\" This will be the name of the communicator.\\n\\n##### Communicator script format:\\n```lua\\nreturn {\\n\\t\\n\\t-- Configuration for RemoteEvents\\n\\tevents = {\\n\\n\\t\\t-- List of events\\n\\t\\tremotes = {\\n\\t\\t\\t\'Event\'\\n\\t\\t},\\n\\n\\t\\t-- List of actions for the events\\n\\t\\tactions = {\\n\\n\\t\\t\\t-- An action that is triggered whenever the remote is fired by the client\\n\\t\\t\\tEvent = function(client)\\n\\t\\t\\t\\tprint(`This remote was fired by {client.Name}!`)\\n\\t\\t\\tend,\\n\\t\\t},\\n\\t},\\n\\t\\n\\t-- Configuration for RemoteFunctions\\n\\tfunctions = {\\n\\t\\t\\n\\t\\t-- List of functions\\n\\t\\tremotes = {\\n\\t\\t\\t\'Function\'\\n\\t\\t},\\n\\n\\t\\t-- List of actions for the functions\\n\\t\\tactions = {\\n\\n\\t\\t\\t-- An action that is triggered whenever the remote is invoked by the client\\n\\t\\t\\tEvent = function(client)\\n\\t\\t\\t\\treturn `{client.Name} invoked this remote!`\\n\\t\\t\\tend,\\n\\t\\t},\\n\\n\\t}\\n\\t\\n}\\n```\\n\\n:::caution Naming Remotes\\nWhen naming remotes, make sure to avoid having remotes with the same name.\\n:::\\n\\n---\\n\\n### Adding Communicators\\n\\nCommunicators can be added in using the initializer script. Add the communicators in using the `Network.AppendCommunicators` method.\\n\\n##### Adding communicators during the initialization phase:\\n```lua\\n-- || initializer.server.lua ||\\n\\nsilk.Packages.Network:AppendCommunicators{ \\n\\tsilk.ServerStorage:WaitForChild(\'Communicators\'),\\n}\\n```\\n\\n---\\n\\n### Accessing Communicators\\n\\nTo access a communicator, use the method [Network.GetCommunicator] or call the package itself.\\n\\n##### Accessing a communicator\\n```lua\\n-- Retrieve the Network package\\nlocal network = silk.Packages.Network\\n\\n-- Similar to using Network.GetCommunicator\\nlocal remote = network.Communicator{ <Communicator>, <Remote> }\\n\\n```","source":{"line":218,"path":"src/essentials/Network.lua"}}')}}]);