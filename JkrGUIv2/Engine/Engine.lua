require "JkrGUIv2.Basic"
require "JkrGUIv2.Widgets"
require "JkrGUIv2.Threed"
require "JkrGUIv2.Multit"
require "JkrGUIv2.ShaderFactory"

Engine = {}
Engine.Load = function(self, inEnableValidation)
          self.i = Jkr.CreateInstance(inEnableValidation)
          self.e = Jkr.CreateEventManager()
          self.mt = Jkr.MultiThreading(self.i)
end

Engine.MakeRigidBody = function(inObject, inType)
          local o = {}
          o.mType = inType
          local object = inObject
          o.object = inObject
          object.mMass = 1

          object.mForce.y = -10
          if inType == "STATIC" then
                    object.mMass = 1000
                    o.Simulate = function(dt)
                              object.mVelocity = vec3(0)
                              object.mForce = vec3(0)
                    end
          else
                    o.Simulate = function(dt)
                              object.mVelocity = object.mVelocity + object.mForce / object.mMass
                              object.mTranslation = object.mTranslation + object.mVelocity * dt
                              object.mForce = vec3(0, -10, 0) -- Apply gravity
                    end
          end
          return o
end

local GetVelocityAfterCollision = function(inObject1, inObject2, e, inType)
          local m1 = inObject1.mMass
          local m2 = inObject2.mMass
          local v1 = inObject1.mVelocity
          local v2 = inObject2.mVelocity
          if inType == "STATIC" then
                    return vec3(0)
          end
          return (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * e) / (m1 + m2)
end

Engine.SimulateRigidBody = function(inObjectsTable, dt, e)
          local ObjectsSize = #inObjectsTable
          for i = 1, ObjectsSize, 1 do
                    local O1 = inObjectsTable[i].object
                    inObjectsTable[i].Simulate(dt)

                    for j = i + 1, ObjectsSize, 1 do
                              local O2 = inObjectsTable[j].object
                              if O1:IsCollidingWith(O2) then
                                        O1.mVelocity = GetVelocityAfterCollision(O1, O2, e, inObjectsTable[i].mType)
                                        O2.mVelocity = GetVelocityAfterCollision(O2, O1, e, inObjectsTable[j].mType)
                                        if O1:GetCollisionThreashold(O2) > 0.01 then
                                                  O1.mVelocity = O1.mVelocity - O1.mForce / O1.mMass
                                        end
                              end
                    end
          end
end

Engine.SimulateRigidBodySubSteps = function(inObjectsTable, dt, inSubsteps, e)
          local SubSteps = 10
          if inSubsteps then
                    SubSteps = inSubsteps
          end
          local newdt = dt / SubSteps
          for i = 1, SubSteps, 1 do
                    Engine.SimulateRigidBody(inObjectsTable, newdt, e)
          end
end
