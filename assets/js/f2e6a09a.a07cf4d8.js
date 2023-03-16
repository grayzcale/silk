"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[994],{69299:e=>{e.exports=JSON.parse('{"functions":[{"name":"__initialize","desc":"An optional meta function that can be included in any package. The typical usecase for this is when `silk` is needed to perform futher intiailizations inside the package and to provide a simple, non-desrutive way for the package to access the main class.\\n\\n:::danger yielding\\n[Package.__initialize] should be treated like a normal metamethod. Therefore, any thread yielding functions inside of the method will result in an error.\\n:::","params":[{"name":"silk","desc":"","lua_type":"Silk"}],"returns":[{"desc":"","lua_type":"any"}],"function_type":"static","source":{"line":609,"path":"src/init.lua"}}],"properties":[{"name":"__singleton","desc":"An optional meta attribute that can be included in any package. If set to true, a cached reference to the package is returned whenever the package is referenced.\\n\\n:::info\\nIf [Package.__initialize] is also provided, the return value recieved after calling this method is cached instead.\\n:::","lua_type":"boolean","source":{"line":597,"path":"src/init.lua"}}],"types":[],"name":"Package","desc":"A Package is a normal Roblox [ModuleScript] that can return any datatype. SILK conveniently provides a number of pre-written packages known as *essentials*. Navigate to \\"Included Packages\\" to view a complete list.\\n\\n---\\n\\n### Implementation\\n\\nSince a Package is just a [ModuleScript], the implementation of one gives flexibility for developers to adapt their Package best suited to their needs. The most common implementation of a Package, however, is shown below.\\n\\n##### Typical implementation of a Package:\\n```lua\\n--|| Package.lua ||\\n\\nlocal package = {}\\npackage.__index = package\\n\\n-- Optionally indicate that the package is a singleton\\npackage.__singleton = true\\n\\n-- This is called whenever this package is referenced or once if the package is a singleton\\n-- Conveniently access silk to perform further intialization\\npackage.__initialize = function(silk)\\n\\n\\t-- Store silk within the package for future use\\n\\tpackage.silk = silk\\n\\t\\n\\t-- This is the value that is returned during runtime\\n\\t-- If the package is a singleton, this return value is cached internally\\n\\treturn package\\nend\\n\\nfunction package.new()\\n\\treturn setmetatable({}, package)\\nend\\n\\n-- If a package has package.__initialize, the method is called and that value is returned instead during runtime\\nreturn package\\n```\\n\\n---\\n\\n### Management\\n\\nAll packages should be added in using the [Silk.AppendPackages] method during the *initializer phase*.\\n\\n:::tip Storing Packages\\nWhen storing package, place them in a secure location alongside all your other packages. For example, a folder containing all your *shared* packages.\\n:::\\n\\n##### Adding in packages through the initializer script:\\n```lua\\n--|| initializer.server.lua ||\\n\\nsilk:AppendPackages{\\n\\n\\t-- Directory that contains all the packages\\n\\tgame.ReplicatedStorage.Packages,\\n}\\n```\\n\\n---\\n\\n### Usage\\n\\n##### Initialize and return contents of package:\\n```lua\\n-- Can be accessed immediately after a package is added\\nlocal package = silk.Packages.Package\\n```\\n\\nAlternatively, when intialization for singleton packages is required during the initializer phase, instead of initializing the package directly using `silk.Packages.Package`, use [Silk.InitPackage].\\n\\n##### Intializing a package directly:\\n```lua\\n-- Initialize the package directly, executing package.__intialize if it exists\\nsilk:InitPackage(\'Package\')\\n```","source":{"line":587,"path":"src/init.lua"}}')}}]);