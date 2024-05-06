require "JkrGUIv2.Engine.Engine"
require "JkrGUIv2.Engine.Shader"
Spr = {}
Engine:Load()
Spr.w = Jkr.CreateWindow(Engine.i, "Hello", vec2(900, 480), 3)
Spr.buffer3d = Jkr.CreateShapeRenderer3D(Engine.i, Spr.w)
Spr.buffer3d:CheckAndResize(50000, 50000)
Spr.world3d = Jkr.World3D(Spr.buffer3d)
Spr.camera = Jkr.Camera3D()

-- SetUP Defaults
Spr.w:BuildShadowPass(5000, 5000)
Spr.camera:SetAttributes(vec3(0, 0, 0), vec3(0, 5, -10))
Spr.camera:SetPerspective(0.30, 16 / 9, 0.1, 10000)
Spr.world3d:AddCamera(Spr.camera)
Spr.world3d:AddLight3D(vec4(100, 100, -100, 1),
          Jmath.Normalize(vec4(0, 0, 0, 0) - vec4(10, 10, -10, 1)))
