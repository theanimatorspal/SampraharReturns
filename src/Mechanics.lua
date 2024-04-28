Mechanics = {}
MechanicsEvent = function(e, inWorld3d, inmt)

end

MechanicsUpdate = function(e, inWorld3d, inmt)
          local Model = inWorld3d:GetGLTFModel(0)
          local Uniform = inWorld3d:GetUniform3D(1)
          local cesiumId = inmt:Get("CesiumId")
          local objects = inWorld3d:GetExplicitObjects()
          local cesiumObject = objects[cesiumId + 1]
          local cesiumCurrentRotation = cesiumObject.mRotation
          local rX = cesiumObject.mRotation.x
          local rY = cesiumObject.mRotation.y
          local rZ = cesiumObject.mRotation.z
          local rW = cesiumObject.mRotation.w

          if rW > 1.0 then
                    rW = 1
          elseif rW < -1.0 then
                    rW = -1.0
          end

          local CosInvW = math.acos(rW)
          if (rY < 0) then
                    CosInvW = 2 * math.pi - CosInvW
          end
          local twoCosInvW = 2 * CosInvW
          local dX = math.sin(twoCosInvW)
          local dZ = math.cos(twoCosInvW)

          Mechanics.MoveCesiumFront = function()
                    Uniform:UpdateByGLTFAnimation(Model, 0.1, 0)
                    cesiumObject.mTranslation = cesiumObject.mTranslation + vec3(dX, 0, dZ) * 0.1
          end

          Mechanics.MoveCesiumBack = function()
                    Uniform:UpdateByGLTFAnimation(Model, -0.1, 0)
                    cesiumObject.mTranslation = cesiumObject.mTranslation - vec3(dX, 0, dZ) * 0.1
          end

          Mechanics.RotateCesiumLeft = function()
                    cesiumObject.mRotation = cesiumObject.mRotation:Rotate_deg(10.0, vec3(0, 1, 0))
          end

          Mechanics.RotateCesiumRight = function()
                    cesiumObject.mRotation = cesiumObject.mRotation:Rotate_deg(-10.0, vec3(0, 1, 0))
          end

          if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_UP) then
                    Mechanics.MoveCesiumFront()
          end
          if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_DOWN) then
                    Mechanics.MoveCesiumBack()
          end
          if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_LEFT) then
                    Mechanics.RotateCesiumLeft()
          end
          if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_RIGHT) then
                    Mechanics.RotateCesiumRight()
          end
end
