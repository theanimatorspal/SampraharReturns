require("src.Refactor.Spr")

require("src.Refactor.Shaders")
require("src.Refactor.Objects")
Spr.SetupBasicShaders()
Spr.SetupObjects()
Engine.mt:Inject("Spr", Spr, -1)
Engine.mt:Inject("Engine", Engine, -1)

Spr.CompileShaders()
Spr.LoadObjects()
