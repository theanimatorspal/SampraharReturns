require("src.Refactor.Spr")
require("src.Refactor.Shaders")
require("src.Refactor.Objects")
require("src.Refactor.Assets")
require("src.Refactor.Mechanics")
Spr.SetupBasicShaders()
Spr.SetupObjects()
Spr.AssetsLoad()
Engine.mt:Inject("Spr", Spr)
Engine.mt:Inject("Engine", Engine)
Spr.CompileShaders()
Spr.LoadObjects()


--[================================================================[
          DRAW CALLS MAIN LOOP
]================================================================]

local oldTime = 0.0
local frameCount = 0
local e = Engine.e
local w = Spr.w
local mt = Engine.mt

local Draw = function()
          -- Spr.world3d:DrawObjectsExplicit(Spr.w, Spr.OpaqueObjects, Jkr.CmdParam.UI)
end

mt:InjectToGate("__MtDrawCount", 0)
local Draw0 = function()
          Spr.w:BeginThreadCommandBuffer(0)
          Spr.w:SetDefaultViewport(0)
          Spr.w:SetDefaultScissor(0)
          Spr.world3d:DrawObjectsExplicit(Spr.w, Spr.OpaqueObjects, 0)
          Spr.w:EndThreadCommandBuffer(0)
          local DrawCount = Engine.mt:GetFromGateToThread("__MtDrawCount", StateId)
          Engine.mt:InjectToGate("__MtDrawCount", DrawCount + 1)
end

local Update = function()
          while not mt:GetFromGateToThread("__MtWorldUniform", -1) do end
          Spr.world3d:Update(e)
end

local Dispatch = function()
          Spr.buffer3d:Dispatch(w)
end

local ShadowPass = function()
          Spr.world3d:DrawObjectsExplicit(w, Spr.ShadowCastingObjects, Jkr.CmdParam.None)
end

local MultiThreadedDraws = function()
          Engine.mt:AddJobF(Draw0)
end

local MultiThreadedExecute = function()
          while Engine.mt:GetFromGate("__MtDrawCount") ~= 1 do end
          Spr.w:ExecuteThreadCommandBuffer(0)
end

while not e:ShouldQuit() do
          oldTime = w:GetWindowCurrentTime()
          e:ProcessEvents()
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

          MultiThreadedDraws()
          w:BeginUIs()
          Draw()
          w:EndUIs()

          w:BeginDraws(1, 0.1, 0.1, 1, 1)
          MultiThreadedExecute()
          w:ExecuteUIs()
          w:EndDraws()
          w:Present()
          local delta = w:GetWindowCurrentTime() - oldTime
          if (frameCount % 100 == 0) then
                    w:SetTitle("Samprahar Frame Rate" .. 1000 / delta)
          end
          frameCount = frameCount + 1
          mt:InjectToGate("__MtDrawCount", 0)
end


Engine.mt:Wait()
