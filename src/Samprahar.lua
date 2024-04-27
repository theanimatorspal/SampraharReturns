require "JkrGUIv2.Basic"
require "JkrGUIv2.Widgets"
require "JkrGUIv2.Threed"
require "JkrGUIv2.Multit"
require "JkrGUIv2.ShaderFactory"

local i = Jkr.CreateInstance()
local w = Jkr.CreateWindow(i, "Samprahar Returns", vec2(900, 480))
w:BuildShadowPass()

local e = Jkr.CreateEventManager()
local wid = Jkr.CreateWidgetRenderer(i, w)
local mt = Jkr.MultiThreading(i)
local simple3d = Jkr.CreateSimple3DPipeline(i, w)
local worldShape3d = Jkr.CreateShapeRenderer3D(i, w)
local world3d = Jkr.World3D(worldShape3d)
local DefaultCamera = Jkr.Camera3D()
DefaultCamera:SetAttributes(vec3(0, 0, 0), vec3(10, 10, 10))
DefaultCamera:SetPerspective(0.30, 16 / 9, 0.1, 10000)
world3d:AddCamera(DefaultCamera)
world3d:AddLight3D(vec4(-10, 10, 10, 1), Jmath.Normalize(vec4(0, 0, 0, 0) - vec4(-10, 10, 10, 1)))

Jkr.ConfigureMultiThreading(mt, {
          { "mtMt",           mt },
          { "mtI",            i },
          { "mtW",            w },
          { "mtWorldShape3d", worldShape3d },
          { "mtSimple3d",     simple3d },
          { "mtWorld3d",      world3d },
})

require("src.LoadResources")
LoadResources(mt)
mt:Wait()

require("src.Mechanics")


local DrawToZero = function()
          mtW:BeginThreadCommandBuffer(0)
          mtW:SetDefaultViewport(0)
          mtW:SetDefaultScissor(0)
          --          mtWorld3d:DrawObjectsUniformed3D(mtW, 0)
          mtWorld3d:DrawObjectsExplicit(mtW, mtWorld3d:GetExplicitObjects(), 0)
          mtW:EndThreadCommandBuffer(0)
end

local ShadowPass = function()
          world3d:DrawObjectsExplicit(w, world3d:GetExplicitShadowCastingObjects(), Jkr.CmdParam.None)
end

local MThreaded = function()
          mt:AddJobF(DrawToZero)
end

local MExecute = function()
          w:ExecuteThreadCommandBuffer(0)
end


local Draw = function()
          wid.Draw()
end

local Event = function()
          wid.Event()
          world3d:Event(e)
          MechanicsEvent(e, world3d, mt)
end

local Update = function()
          wid.Update()
          world3d:Update(e)
          MechanicsUpdate(e, world3d, mt)
end

local Dispatch = function()
          wid.Dispatch()
end
e:SetEventCallBack(Event)

local oldTime = 0.0
local frameCount = 0
while not e:ShouldQuit() do
          oldTime = w:GetWindowCurrentTime()
          e:ProcessEvents()

          -- /* All Updates are done here*/
          w:BeginUpdates()
          Update()
          WindowDimension = w:GetWindowDimension()
          w:EndUpdates()

          w:BeginDispatches()
          Dispatch()
          w:EndDispatches()

          w:BeginShadowPass(0.5)
          ShadowPass()
          w:EndShadowPass()


          MThreaded()
          -- /* All UI Renders are Recordeed here*/
          w:BeginUIs()
          Draw()
          w:EndUIs()

          -- /* All ComputeShader Invocations are Done here*/

          -- /* All Draws (Main CmdBuffer Recording) is done here*/
          w:BeginDraws(0.1, 0.1, 0.1, 1, 1)
          mt:Wait()
          MExecute()
          w:ExecuteUIs() -- The UI CmdBuffer is executed onto the main CmdBuffer
          w:EndDraws()

          -- /* Finally is presented onto the screen */
          w:Present()
          local delta = w:GetWindowCurrentTime() - oldTime
          if (frameCount % 100 == 0) then
                    w:SetTitle("FrameRate: " .. 1000 / delta)
          end
          frameCount = frameCount + 1
end
