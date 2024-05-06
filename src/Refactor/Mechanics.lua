Spr.Mechanics = {}

Spr.MechanicsLoad = function()

end

local CallBuffer = Jkr.CreateCallBuffers()
local CurrentStillWalkBlendFactor = 0
local CurrentJumpBlendFactor = 0
local Frame = 1
local CesiumMoving = false

local CameraTarget = vec3(0, 0, 0)
local CameraPosition = vec3(0, 5, -10)
local ShouldListenToEvents = true
local ShouldListenToCameraEvents = true
local ShouldListenToJumpEvent = true
local LocalCameraTarget = vec3(0, 0, 0)
local LocalCameraPosition = vec3(0, 2, 0)
local CesiumRotationSensitivity = 1
local FireModeFactor = 0.0
local IsLoaded = false

local FarCameraView = 0.0
local NearCameraView = 1.0
local LocalTargetCameraView = 0.0
local cesiumObject = 0
local skyboxObject = 0
local planeObject = 0
local cylinderObject = 0
local aimerObject = 0
local TranslationVector = 0

local CesiumModelGLTF = 0
local Uniform = 0
local cesiumId = 0
local objects = 0

local CurrentFrame = 1

local WalkAnimationIndex = 0
local StillAnimationIndex = 1
local JumpAnimationIndex = 2
local AimAnimationIndex = 3

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

Spr.MechanicsUpdate = function()
          CesiumMoving = false
          CesiumModelGLTF = Spr.world3d:GetGLTFModel(0)
          Uniform = Spr.world3d:GetUniform3D(1)
          cesiumId = Engine.mt:Get("CesiumId")
          objects = Engine.mt:Get("OpaqueObjects")
          cesiumObject = Spr.OpaqueObjects[Spr.CesiumObjIndex]
          skyboxObject = Spr.OpaqueObjects[Spr.SkyboxObjIndex]
          planeObject = Spr.OpaqueObjects[Spr.PlaneObjIndex]
          aimerObject = Spr.OpaqueObjects[5]
          aimerObject.mScale = vec3(0.3, 0.3, 0.3) * FireModeFactor
          aimerObject.mRotation = aimerObject.mRotation:Rotate_deg(30, vec3(1, 0, 0))
          if not IsLoaded then
                    aimerObject.mTranslation = aimerObject.mTranslation + vec3(3, -0.5, 1)
                    aimerObject.mRotation = aimerObject.mRotation:Rotate_deg(90, vec3(0, 0, 1))
          end

          TranslationVector = GetTranslationVectorFromYRotation(cesiumObject.mRotation)

          if CurrentStillWalkBlendFactor < 1.0 then
                    CurrentStillWalkBlendFactor = CurrentStillWalkBlendFactor + 0.1
          elseif CurrentStillWalkBlendFactor > 1.0 then
                    CurrentStillWalkBlendFactor = 1.0
          end

          -- JUMP MECHANICS
          cesiumObject.mTranslation.y = CurrentJumpBlendFactor * 1


          if not IsLoaded then
                    Spr.PutCameraAtCesium = function()
                              local CesiumObjectTranslation = cesiumObject:GetLocalMatrix():GetTranslationComponent()
                              local CameraPosition =
                                  (CesiumObjectTranslation - TranslationVector * 5 + LocalCameraPosition) *
                                  NearCameraView
                                  + (CesiumObjectTranslation - TranslationVector * 10 + LocalCameraPosition) *
                                  FarCameraView
                              local CameraTarget = (CesiumObjectTranslation + TranslationVector * 5) * NearCameraView
                                  + (CesiumObjectTranslation + TranslationVector * 10) * FarCameraView

                              Spr.world3d:GetCamera3D(0):SetAttributes(CameraTarget, CameraPosition)
                              Spr.world3d:GetCamera3D(0):SetPerspective(0.80, 16 / 9, 0.1, 10000)
                    end


                    Spr.MoveCesiumFront = function()
                              cesiumObject.mTranslation = cesiumObject.mTranslation + TranslationVector * 0.1
                              if CurrentStillWalkBlendFactor > 0 then
                                        CurrentStillWalkBlendFactor = CurrentStillWalkBlendFactor - 0.2
                              elseif CurrentStillWalkBlendFactor < 0 then
                                        CurrentStillWalkBlendFactor = 0
                              end

                              if FireModeFactor == 1 then
                                        Spr.SwitchFireMode()
                              end
                              CesiumMoving = true
                              StepsSound:Play()
                    end

                    Spr.MoveCesiumBack = function()
                              cesiumObject.mTranslation = cesiumObject.mTranslation - TranslationVector * 0.1
                              if CurrentStillWalkBlendFactor > 0 then
                                        CurrentStillWalkBlendFactor = CurrentStillWalkBlendFactor - 0.2
                              elseif CurrentStillWalkBlendFactor < 0 then
                                        CurrentStillWalkBlendFactor = 0
                              end
                              if FireModeFactor == 1 then
                                        Spr.SwitchFireMode()
                              end
                              CesiumMoving = true
                              StepsSound:Play()
                    end

                    Spr.MoveAimerUp = function()
                              if FireModeFactor == 1 then
                                        aimerObject.mTranslation.z = aimerObject.mTranslation.z + 0.01
                              end
                    end

                    Spr.MoveAimerDown = function()
                              if FireModeFactor == 1 then
                                        aimerObject.mTranslation.z = aimerObject.mTranslation.z - 0.01
                              end
                    end

                    Spr.RotateCesiumLeft = function()
                              cesiumObject.mRotation = cesiumObject.mRotation:Rotate_deg(
                                        10.0 * CesiumRotationSensitivity,
                                        vec3(0, 1, 0))
                              CesiumMoving = true
                    end

                    Spr.RotateCesiumRight = function()
                              cesiumObject.mRotation = cesiumObject.mRotation:Rotate_deg(
                                        -10.0 * CesiumRotationSensitivity,
                                        vec3(0, 1, 0))
                              CesiumMoving = true
                    end

                    Spr.SwitchCameraView = function()
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

                    Spr.SwitchFireMode = function()
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
                                                  CesiumRotationSensitivity = 0.1
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
                                                  CesiumRotationSensitivity = 1
                                                  AimSound:Pause()
                                                  ShouldListenToEvents = true
                                        end), Frame)
                              end
                    end

                    Spr.JumpCesium = function()
                              local Frame = 1
                              JumpSound:Play()
                              local CurrentJumpBlendFactor_ = CurrentJumpBlendFactor
                              while CurrentJumpBlendFactor_ < 1.0 do
                                        CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                                  CurrentJumpBlendFactor = CurrentJumpBlendFactor + 0.1
                                                  ShouldListenToJumpEvent = false
                                        end), Frame)
                                        CurrentJumpBlendFactor_ = CurrentJumpBlendFactor_ + 0.1
                                        Frame = Frame + 1
                              end

                              while CurrentJumpBlendFactor_ >= 0.0 do
                                        CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                                  CurrentJumpBlendFactor = CurrentJumpBlendFactor - 0.1
                                                  ShouldListenToJumpEvent = false
                                        end), Frame)
                                        CurrentJumpBlendFactor_ = CurrentJumpBlendFactor_ - 0.1
                                        Frame = Frame + 1
                              end

                              CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                                        CurrentJumpBlendFactor = 0
                                        ShouldListenToJumpEvent = true
                                        JumpSound:Pause()
                              end), Frame)
                    end
          end

          skyboxObject.mRotation = skyboxObject.mRotation:Rotate_deg(0.01, vec3(0, 1, 0))

          if ShouldListenToEvents then
                    local ShouldUpdate = false
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_UP) then
                              Spr.MoveCesiumFront()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_DOWN) then
                              Spr.MoveCesiumBack()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_LEFT) then
                              Spr.RotateCesiumLeft()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_RIGHT) then
                              Spr.RotateCesiumRight()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_W) then
                              Spr.MoveAimerUp()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_S) then
                              Spr.MoveAimerDown()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_F) then
                              Spr.SwitchFireMode()
                              ShouldUpdate = true
                    end
                    if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_SPACE) and ShouldListenToJumpEvent then
                              Spr.JumpCesium()
                              ShouldUpdate = true
                    end
                    if ShouldListenToCameraEvents then
                              if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_C) then
                                        Mechanics.SwitchCameraView()
                                        ShouldUpdate = true
                              end
                    end
          end

          if (CurrentFrame % 10 == 0 and not CesiumMoving) then
                    if (not CesiumMoving) then
                              StepsSound:Pause()
                    end
          end
          if (FireModeFactor > 0.0) then
                    AimSound:Play()
          end

          cesiumObject:SetParent(planeObject)
          cylinderObject:SetParent(planeObject)
          aimerObject:SetParent(cesiumObject)
          Spr.PutCameraAtCesium()

          CesiumModelGLTF:UpdateAnimation(StillAnimationIndex, 0.01, true)
          CesiumModelGLTF:UpdateBlendCombineAnimation(0.1,
                    WalkAnimationIndex,
                    1 - CurrentStillWalkBlendFactor,
                    true,
                    true
          )
          CesiumModelGLTF:UpdateBlendCombineAnimation(0.1,
                    JumpAnimationIndex,
                    CurrentJumpBlendFactor,
                    false,
                    true
          )

          CesiumModelGLTF:UpdateBlendCombineAnimation(0.1,
                    AimAnimationIndex,
                    FireModeFactor,
                    false,
                    true
          )

          Uniform:UpdateByGLTFAnimation(CesiumModelGLTF)
          Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex]:SetParent(planeObject)
          Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mTranslation = cesiumObject.mTranslation
          Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mRotation = cesiumObject.mRotation
          Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mScale = cesiumObject.mScale
          Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mMatrix = cesiumObject.mMatrix

          CallBuffer.Update()
          if not IsLoaded then
                    IsLoaded = true
          end
          CurrentFrame = CurrentFrame + 1
end
