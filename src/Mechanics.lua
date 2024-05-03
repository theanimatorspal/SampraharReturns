Mechanics = {}
MechanicsLoad = function(mt, inWorld3d, i)
          local BindingIndex = 4 -- Shadow xan ta
          local planeComputeTextureUniformIndex = math.int(mt:Get("planeComputeTextureUniformIndex"))
          local PlaneUniform = inWorld3d:GetUniform3D(planeComputeTextureUniformIndex)
          PlaneUniform:AddTextureFromShapeImage(WidUI.s.handle, PlaneTextureComputeImageIndex, BindingIndex, 1)
          UserInterface.DrawPlatform()

          BindingIndex = 3
          local aimerUniformIndex = math.int(mt:Get("aimerUniformIndex"))
          local aimerUniform = inWorld3d:GetUniform3D(aimerUniformIndex)
          aimerUniform:AddTextureFromShapeImage(WidUI.s.handle, AimerTextureComputeImageIndex, BindingIndex, 1)

          UserInterface.DrawToAimer(1)
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
local ShouldListenToCameraEvents = true
local LocalCameraTarget = vec3(0, 0, 0)
local LocalCameraPosition = vec3(0, 2, 0)
local CesiumRotationSensitivity = 1
local FireModeFactor = 0.0
local IsLoaded = false

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

local FarCameraView = 0.0
local NearCameraView = 1.0
local LocalTargetCameraView = 0.0

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
          local aimerObject = objects[5]
          aimerObject.mScale = vec3(0.3, 0.3, 0.3) * FireModeFactor
          aimerObject.mRotation = aimerObject.mRotation:Rotate_deg(30, vec3(1, 0, 0))
          cylinderObject.mScale = vec3(0.1, 0.1, 0.1) * 0.5
          if not IsLoaded then
                    aimerObject.mTranslation = aimerObject.mTranslation + vec3(3, -0.5, 1)
                    aimerObject.mRotation = aimerObject.mRotation:Rotate_deg(90, vec3(0, 0, 1))
                    cylinderObject.mRotation = cylinderObject.mRotation:Rotate_deg(90, vec3(0, 0, 1))
                    IsLoaded = true
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
                    local CameraPosition =
                        (CesiumObjectTranslation - TranslationVector * 5 + LocalCameraPosition) * NearCameraView
                        + (CesiumObjectTranslation - TranslationVector * 10 + LocalCameraPosition) * FarCameraView
                    local CameraTarget = (CesiumObjectTranslation + TranslationVector * 5) * NearCameraView
                        + (CesiumObjectTranslation + TranslationVector * 10) * FarCameraView

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
                    cesiumObject.mRotation = cesiumObject.mRotation:Rotate_deg(10.0 * CesiumRotationSensitivity,
                              vec3(0, 1, 0))
                    CesiumMoving = true
          end

          Mechanics.RotateCesiumRight = function()
                    cesiumObject.mRotation = cesiumObject.mRotation:Rotate_deg(-10.0 * CesiumRotationSensitivity,
                              vec3(0, 1, 0))
                    CesiumMoving = true
          end

          Mechanics.SwitchCameraView = function()
                    local Frame = 1
                    if NearCameraView >= 1 then
                              local NearCameraView_ = NearCameraView
                              while NearCameraView_ >= 0 do
                                        CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                                  NearCameraView = NearCameraView - 0.1
                                                  FarCameraView = FarCameraView + 0.1
                                                  ShouldListenToCameraEvents = false
                                        end), Frame)
                                        NearCameraView_ = NearCameraView_ - 0.1
                                        Frame = Frame + 1
                              end
                              CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                        FarCameraView = 1
                                        NearCameraView = 0
                                        ShouldListenToCameraEvents = true
                              end), Frame)
                    elseif FarCameraView >= 1 then
                              local FarCameraView_ = FarCameraView
                              while FarCameraView_ >= 0 do
                                        CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                                  NearCameraView = NearCameraView + 0.1
                                                  FarCameraView = FarCameraView - 0.1
                                                  ShouldListenToCameraEvents = false
                                        end), Frame)
                                        FarCameraView_ = FarCameraView_ - 0.1
                                        Frame = Frame + 1
                              end
                              CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                        FarCameraView = 0
                                        NearCameraView = 1
                                        ShouldListenToCameraEvents = true
                              end), Frame)
                    end
          end

          Mechanics.StartFireMode = function()
                    local Frame = 1
                    if FireModeFactor == 0.0 then
                              local FireModeFactor_ = FireModeFactor
                              while FireModeFactor_ <= 1.0 do
                                        CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                                  FireModeFactor = FireModeFactor + 0.1
                                                  ShouldListenToEvents = false
                                        end), Frame)
                                        FireModeFactor_ = FireModeFactor_ + 0.1
                                        Frame = Frame + 1
                              end
                              CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                        FireModeFactor = 1.0
                                        ShouldListenToEvents = true
                              end), Frame)
                    elseif FireModeFactor == 1.0 then
                              local FireModeFactor_ = FireModeFactor
                              while FireModeFactor_ >= 0.0 do
                                        CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                                  FireModeFactor = FireModeFactor - 0.1
                                                  ShouldListenToEvents = false
                                        end), Frame)
                                        FireModeFactor_ = FireModeFactor_ - 0.1
                                        Frame = Frame + 1
                              end
                              CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                        FireModeFactor = 0.0
                                        ShouldListenToEvents = true
                              end), Frame)
                    end
          end

          skyboxObject.mRotation = skyboxObject.mRotation:Rotate_deg(0.01, vec3(0, 1, 0))

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
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_F) then
                              Mechanics.StartFireMode()
                              ShouldUpdate = true
                    end
                    if ShouldListenToCameraEvents then
                              if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_C) then
                                        Mechanics.SwitchCameraView()
                              end
                    end
          end

          cesiumObject:SetParent(planeObject)
          cylinderObject:SetParent(planeObject)
          aimerObject:SetParent(cesiumObject)
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
