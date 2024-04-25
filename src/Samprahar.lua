require "JkrGUIv2.Basic"
require "JkrGUIv2.Widgets"
require "JkrGUIv2.Threed"
require "JkrGUIv2.Multit"

local i = Jkr.CreateInstance()
local w = Jkr.CreateWindow(i, "Samprahar Returns", vec2(900, 480))
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

Jkr.ConfigureMultiThreading(mt, {
          { "mtMt",           mt },
          { "mtI",            i },
          { "mtW",            w },
          { "mtWorldShape3d", worldShape3d },
          { "mtSimple3d",     simple3d },
          { "mtWorld3d",      world3d }
})

require("src.LoadResources")
LoadResources(mt)
mt:Wait()

require("src.Mechanics")


local DrawToZero = function()
          mtW:BeginThreadCommandBuffer(0)
          mtW:SetDefaultViewport(0)
          mtW:SetDefaultScissor(0)
          mtWorld3d:DrawObjectsUniformed3D(mtW, 0)
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
Jkr.DebugMainLoop(w, e, Update, Dispatch, Draw, nil, vec4(0, 0, 0, 1), mt, MThreaded, MExecute)
