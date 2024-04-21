require "JkrGUIv2.Basic"
require "JkrGUIv2.Widgets"
require "JkrGUIv2.Threed"
require "JkrGUIv2.Multit"

local i = Jkr.CreateInstance()
local w = Jkr.CreateWindow(i, "Samprahar Returns", vec2(600, 300))
local e = Jkr.CreateEventManager()
local wid = Jkr.CreateWidgetRenderer(i, w)
local mt = Jkr.MultiThreading(i)
local shape3d = Jkr.CreateShapeRenderer3D(i, w)
local simple3d = Jkr.CreateSimple3DPipeline(i, w)

Jkr.ConfigureMultiThreading(mt, {
          { "mtMt",       mt },
          { "mtI",        i },
          { "mtW",        w },
          { "mtShape3d",  shape3d },
          { "mtSimple3d", simple3d }
})


local function Compile()
          mtSimple3d:Compile(mtI, mtW, "res/cache/simple3d.glsl", mtGetDefaultResource("Simple3D", "Vertex"),
                    mtGetDefaultResource("Simple3D", "Fragment"), mtGetDefaultResource("Simple3D", "Compute"), false)
          local h = mtCreateShapesHelper(mtShape3d)
          h.AddDemoPlane()

          local camera = mtJkr.Camera3D:New()
          camera:SetAttributes(vec3(0, 0, 0), vec3(10, 10, 10))
          local dimension = mtW:GetWindowDimension()
          camera:SetPerspective(0.45, 16 / 9, 0.1, 1000)
          mtMt:Inject("mtH", h)
          mtMt:Inject("mtCamera", camera)
end
mt:AddJobF(Compile)
mt:Wait()

local DrawToZero = function()
          mtW:BeginThreadCommandBuffer(0)
          mtW:SetDefaultViewport(0)
          mtW:SetDefaultScissor(0)
          mtSimple3d:Bind(mtW, 0)
          local pc = Jkr.DefaultPushConstant3D();
          pc.m1 = mtCamera.mMatrix
          pc.m1 = Jmath.Scale(mtCamera.mMatrix, vec3(0.01, 0.01, 0.01))
          mtShape3d:Bind(mtW, 0)
          mtSimple3d:Draw(mtW, mtShape3d, pc, 0, mtShape3d:GetIndexCount(0), 1, 0)
          mtW:EndThreadCommandBuffer(0)
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

local Sensitivity = 0.1
local Event = function()
          wid.Event()
          local UpdateCamera = false
          local Camera = mt:Get("mtCamera")
          if e:IsKeyPressed(SDLK_w) then
                    UpdateCamera = true
                    Jkrmt.Camera3D.MoveForward(Camera, Sensitivity)
          elseif e:IsKeyPressed(SDLK_s) then
                    UpdateCamera = true
                    Jkrmt.Camera3D.MoveBackward(Camera, Sensitivity)
          elseif e:IsKeyPressed(SDLK_a) then
                    UpdateCamera = true
                    Jkrmt.Camera3D.MoveLeft(Camera, Sensitivity)
          elseif e:IsKeyPressed(SDLK_d) then
                    UpdateCamera = true
                    Jkrmt.Camera3D.MoveRight(Camera, Sensitivity)
          end

          if UpdateCamera then
                    Jkrmt.Camera3D.SetPerspective(Camera)
                    mt:Inject("mtCamera", Camera)
          end
end

local Update = function()
          wid.Update()
end

local Dispatch = function()
          wid.Dispatch()
end


e:SetEventCallBack(Event)
Jkr.DebugMainLoop(w, e, Update, Dispatch, Draw, nil, vec4(0, 0, 0, 1), mt, MThreaded, MExecute)
