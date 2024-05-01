Mechanics = {}
MechanicsLoad = function(mt, inWorld3d)
          local planeComputeTextureUniformIndex = math.int(mt:Get("planeComputeTextureUniformIndex"))
          local PlaneUniform = inWorld3d:GetUniform3D(planeComputeTextureUniformIndex)
          PlaneUniform:AddTextureFromShapeImage(WidUI.s.handle, PlaneTextureComputeImageIndex, 4, 1)
end

MechanicsEvent = function(e, inWorld3d, inmt)

end

local CurrentBlendFactor = 0
MechanicsUpdate = function(e, inWorld3d, inmt)
          local CesiumModelGLTF = inWorld3d:GetGLTFModel(0)
          local Uniform = inWorld3d:GetUniform3D(1)
          local cesiumId = inmt:Get("CesiumId")
          local objects = inmt:Get("OpaqueObjects")
          local cesiumObject = objects[1]
          local rX = cesiumObject.mRotation.x
          local rY = cesiumObject.mRotation.y
          local rZ = cesiumObject.mRotation.z
          local rW = cesiumObject.mRotation.w
          inWorld3d:GetCamera3D(0):SetAttributes(vec3(0, 0, 0) + cesiumObject.mTranslation * 0.5,
                    cesiumObject.mTranslation * 0.5 + vec3(0, 5, -10))
          inWorld3d:GetCamera3D(0):SetPerspective(0.80, 16 / 9, 0.1, 10000)

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

          local WalkAnimationIndex = 0
          local StillAnimationIndex = 1
          if CurrentBlendFactor < 1.0 then
                    CurrentBlendFactor = CurrentBlendFactor + 0.1
          elseif CurrentBlendFactor > 1.0 then
                    CurrentBlendFactor = 1.0
          end
          Mechanics.MoveCesiumFront = function()
                    CesiumModelGLTF:BlendCombineAnimation(0.1, WalkAnimationIndex, StillAnimationIndex,
                              CurrentBlendFactor, true)
                    cesiumObject.mTranslation = cesiumObject.mTranslation + vec3(dX, 0, dZ) * 0.1
                    if CurrentBlendFactor > 0 then
                              CurrentBlendFactor = CurrentBlendFactor - 0.2
                    elseif CurrentBlendFactor < 0 then
                              CurrentBlendFactor = 0
                    end
          end

          Mechanics.MoveCesiumBack = function()
                    CesiumModelGLTF:BlendCombineAnimation(0.1, WalkAnimationIndex, StillAnimationIndex,
                              CurrentBlendFactor, true)
                    cesiumObject.mTranslation = cesiumObject.mTranslation - vec3(dX, 0, dZ) * 0.1
                    if CurrentBlendFactor > 0 then
                              CurrentBlendFactor = CurrentBlendFactor - 0.2
                    elseif CurrentBlendFactor < 0 then
                              CurrentBlendFactor = 0
                    end
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

          CesiumModelGLTF:BlendCombineAnimation(0.01,
                    WalkAnimationIndex,
                    StillAnimationIndex,
                    CurrentBlendFactor,
                    true)
          Uniform:UpdateByGLTFAnimation(CesiumModelGLTF)
          local ShadowCastingObjects = inmt:Get("ShadowCastingObjects")
          ShadowCastingObjects[cesiumId + 1].mTranslation = cesiumObject.mTranslation
          ShadowCastingObjects[cesiumId + 1].mRotation = cesiumObject.mRotation
          ShadowCastingObjects[cesiumId + 1].mScale = cesiumObject.mScale
          ShadowCastingObjects[cesiumId + 1].mMatrix = cesiumObject.mMatrix
end
