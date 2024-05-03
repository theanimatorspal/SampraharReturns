Mechanics = {}
MechanicsLoad = function(mt, inWorld3d)
          local planeComputeTextureUniformIndex = math.int(mt:Get("planeComputeTextureUniformIndex"))
          local PlaneUniform = inWorld3d:GetUniform3D(planeComputeTextureUniformIndex)
          PlaneUniform:AddTextureFromShapeImage(WidUI.s.handle, PlaneTextureComputeImageIndex, 4, 1)
          UserInterface.DrawPlatform()
end

MechanicsEvent = function(e, inWorld3d, inmt)

end

local CallBuffer = Jkr.CreateCallBuffers()
local CurrentStillWalkBlendFactor = 0
local Frame = 1
local CesiumMoving = false

local CameraTarget = vec3(0, 0, 0)
local CameraPosition = vec3(0, 5, -10)
local ShouldListenToEvents = true
local IsCylinderRotated = false
local CameraFarness = 5
local LocalCameraTarget = vec3(0, 0, 0)
local LocalCameraPosition = vec3(0, 2, 0)

local GetTranslationVectorFromYRotation = function(inQuad)
          local rX = inQuad.x
          local rY = inQuad.y
          local rZ = inQuad.z
          local rW = inQuad.w
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
          return vec3(dX, 0, dZ)
end

MechanicsUpdate = function(e, inWorld3d, inmt)
          CesiumMoving = false
          local CesiumModelGLTF = inWorld3d:GetGLTFModel(0)
          local Uniform = inWorld3d:GetUniform3D(1)
          local cesiumId = inmt:Get("CesiumId")
          local objects = inmt:Get("OpaqueObjects")
          local cesiumObject = objects[1]
          local skyboxObject = objects[2]
          local planeObject = objects[3]
          local cylinderObject = objects[4]
          cylinderObject.mScale = vec3(0.1, 0.1, 0.1)
          if not IsCylinderRotated then
                    cylinderObject.mRotation = cylinderObject.mRotation:Rotate_deg(90, vec3(0, 0, 1))
                    IsCylinderRotated = true
          end
          cylinderObject.mTranslation = vec3(0, 0.5, 0)

          local TranslationVector = GetTranslationVectorFromYRotation(cesiumObject.mRotation)

          local WalkAnimationIndex = 0
          local StillAnimationIndex = 1
          if CurrentStillWalkBlendFactor < 1.0 then
                    CurrentStillWalkBlendFactor = CurrentStillWalkBlendFactor + 0.1
          elseif CurrentStillWalkBlendFactor > 1.0 then
                    CurrentStillWalkBlendFactor = 1.0
          end


          Mechanics.PutCameraAtCesium = function()
                    local CesiumObjectTranslation = cesiumObject:GetLocalMatrix():GetTranslationComponent()
                    local CameraPosition = CesiumObjectTranslation - TranslationVector * CameraFarness +
                        LocalCameraPosition
                    local CameraTarget = CesiumObjectTranslation + TranslationVector * CameraFarness
                    inWorld3d:GetCamera3D(0):SetAttributes(CameraTarget, CameraPosition)
                    inWorld3d:GetCamera3D(0):SetPerspective(0.80, 16 / 9, 0.1, 10000)
          end


          Mechanics.MoveCesiumFront = function()
                    CesiumModelGLTF:BlendCombineAnimation(0.1, WalkAnimationIndex, StillAnimationIndex,
                              CurrentStillWalkBlendFactor, true)
                    cesiumObject.mTranslation = cesiumObject.mTranslation + TranslationVector * 0.1
                    if CurrentStillWalkBlendFactor > 0 then
                              CurrentStillWalkBlendFactor = CurrentStillWalkBlendFactor - 0.2
                    elseif CurrentStillWalkBlendFactor < 0 then
                              CurrentStillWalkBlendFactor = 0
                    end
                    CesiumMoving = true
          end

          Mechanics.MoveCesiumBack = function()
                    CesiumModelGLTF:BlendCombineAnimation(0.1, WalkAnimationIndex, StillAnimationIndex,
                              CurrentStillWalkBlendFactor, true)
                    cesiumObject.mTranslation = cesiumObject.mTranslation - TranslationVector * 0.1
                    if CurrentStillWalkBlendFactor > 0 then
                              CurrentStillWalkBlendFactor = CurrentStillWalkBlendFactor - 0.2
                    elseif CurrentStillWalkBlendFactor < 0 then
                              CurrentStillWalkBlendFactor = 0
                    end
                    CesiumMoving = true
          end

          Mechanics.RotateCesiumLeft = function()
                    cesiumObject.mRotation = cesiumObject.mRotation:Rotate_deg(10.0, vec3(0, 1, 0))
                    CesiumMoving = true
          end

          Mechanics.RotateCesiumRight = function()
                    cesiumObject.mRotation = cesiumObject.mRotation:Rotate_deg(-10.0, vec3(0, 1, 0))
                    CesiumMoving = true
          end

          skyboxObject.mRotation = skyboxObject.mRotation:Rotate_deg(0.01, vec3(0, 1, 0))
          --planeObject.mRotation = planeObject.mRotation:Rotate_deg(0.01, vec3(0, 1, 0))

          if ShouldListenToEvents then
                    local ShouldUpdate = false
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_UP) then
                              Mechanics.MoveCesiumFront()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_DOWN) then
                              Mechanics.MoveCesiumBack()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_LEFT) then
                              Mechanics.RotateCesiumLeft()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_RIGHT) then
                              Mechanics.RotateCesiumRight()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_C) then
                              if CameraFarness == 5 then
                                        local Frame = 1
                                        local CameraFarness_ = CameraFarness
                                        while CameraFarness_ >= 3 do
                                                  CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                                            CameraFarness = CameraFarness - 0.1
                                                            ShouldListenToEvents = false
                                                  end), Frame)
                                                  CameraFarness_ = CameraFarness_ - 0.1
                                                  LocalCameraTarget.y = LocalCameraTarget.y + 0.1
                                                  Frame = Frame + 1
                                        end
                                        CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                                  ShouldListenToEvents = true
                                        end), Frame)
                              else
                                        local Frame = 1
                                        local CameraFarness_ = CameraFarness
                                        while CameraFarness_ <= 5 do
                                                  CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                                            CameraFarness = CameraFarness - 0.1
                                                            ShouldListenToEvents = false
                                                  end), Frame)
                                                  CameraFarness_ = CameraFarness_ + 0.1
                                                  LocalCameraTarget.y = LocalCameraTarget.y - 0.1
                                                  Frame = Frame + 1
                                        end
                                        CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                                  ShouldListenToEvents = true
                                        end), Frame)
                              end
                    end
          end

          cesiumObject:SetParent(planeObject)
          cylinderObject:SetParent(planeObject)
          Mechanics.PutCameraAtCesium()
          CesiumModelGLTF:BlendCombineAnimation(0.01,
                    WalkAnimationIndex,
                    StillAnimationIndex,
                    CurrentStillWalkBlendFactor,
                    true)
          Uniform:UpdateByGLTFAnimation(CesiumModelGLTF)
          local ShadowCastingObjects = inmt:Get("ShadowCastingObjects")
          ShadowCastingObjects[cesiumId + 1]:SetParent(planeObject)
          ShadowCastingObjects[cesiumId + 1].mTranslation = cesiumObject.mTranslation
          ShadowCastingObjects[cesiumId + 1].mRotation = cesiumObject.mRotation
          ShadowCastingObjects[cesiumId + 1].mScale = cesiumObject.mScale
          ShadowCastingObjects[cesiumId + 1].mMatrix = cesiumObject.mMatrix

          ShadowCastingObjects[cesiumId + 2]:SetParent(planeObject)
          ShadowCastingObjects[cesiumId + 2].mTranslation = cylinderObject.mTranslation
          ShadowCastingObjects[cesiumId + 2].mRotation = cylinderObject.mRotation
          ShadowCastingObjects[cesiumId + 2].mScale = cylinderObject.mScale
          ShadowCastingObjects[cesiumId + 2].mMatrix = cylinderObject.mMatrix
          CallBuffer.Update()
end
