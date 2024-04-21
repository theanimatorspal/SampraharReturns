require "JkrGUIv2.Basic"
require "JkrGUIv2.Widgets"
require "JkrGUIv2.Threed"
require "JkrGUIv2.Multit"

local i = Jkr.CreateInstance()
local w = Jkr.CreateWindow(i, "Samprahar Returns", vec2(900, 480))
local e = Jkr.CreateEventManager()
local wid = Jkr.CreateWidgetRenderer(i, w)
local mt = Jkr.MultiThreading(i)
local shape3d = Jkr.CreateShapeRenderer3D(i, w)
local simple3d = Jkr.CreateSimple3DPipeline(i, w)
local world3d = Jkr.World3D(shape3d)

Jkr.ConfigureMultiThreading(mt, {
          { "mtMt",       mt },
          { "mtI",        i },
          { "mtW",        w },
          { "mtShape3d",  shape3d },
          { "mtSimple3d", simple3d },
          { "mtWorld3d",  world3d }
})


local function Compile()
          mtSimple3d:Compile(mtI, mtW, "res/cache/simple3d.glsl", mtGetDefaultResource("Simple3D", "Vertex"),
                    mtGetDefaultResource("Simple3D", "Fragment"), mtGetDefaultResource("Simple3D", "Compute"), false)
          h = mtCreateShapesHelper(mtShape3d)
          h.AddDemoPlane()
          CppCam = Jkr.Camera3D()
          CppCam:SetAttributes(vec3(0, 0, 0), vec3(10, 3, 10))
          local dimension = mtW:GetWindowDimension()
          CppCam:SetPerspective(0.45, 16 / 9, 0.1, 10000)
          CppCam:GetMatrix()

          mtMt:Inject("mtH", h)
          mtMt:Inject("mtCppCam", CppCam)
end
local function Compile1()
          mtWorld3d:BuildDemo()
end
mt:AddJobF(Compile)
mt:AddJobF(Compile1)
mt:Wait()

local DrawToZero = function()
          mtW:BeginThreadCommandBuffer(0)
          mtW:SetDefaultViewport(0)
          mtW:SetDefaultScissor(0)
          mtSimple3d:Bind(mtW, 0)
          local pc = Jkr.DefaultPushConstant3D();
          pc.m1 = mtCppCam:GetMatrix()
          pc.m1 = Jmath.Scale(pc.m1, vec3(0.01, 0.01, 0.01))
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
          local Camera = mt:Get("mtCppCam")
          if e:IsKeyPressed(SDLK_w) then
                    UpdateCamera = true
                    Camera:MoveForward(Sensitivity)
          elseif e:IsKeyPressed(SDLK_s) then
                    UpdateCamera = true
                    Camera:MoveBackward(Sensitivity)
          elseif e:IsKeyPressed(SDLK_a) then
                    UpdateCamera = true
                    Camera:MoveLeft(Sensitivity)
          elseif e:IsKeyPressed(SDLK_d) then
                    UpdateCamera = true
                    Camera:MoveRight(Sensitivity)
          end

          if UpdateCamera then
                    Camera:SetPerspective()
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
