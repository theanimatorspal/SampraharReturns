Spr.Mechanics = {}

local GravityY = -10.0
local CesiumJumpVY = 10

Spr.MechanicsLoad = function()

end

local function MechanicsCopyTransformations(inFrom, inTo)
    inTo.mTranslation = inFrom.mTranslation
    inTo.mRotation = inFrom.mRotation
    inTo.mScale = inFrom.mScale
    inTo.mMatrix = inFrom.mMatrix
end

local CallBuffer                        = Jkr.CreateCallBuffers()
local CurrentStillWalkBlendFactor       = 0
local CurrentJumpBlendFactor            = 0
local Frame                             = 1
local CesiumMoving                      = false

local CameraTarget                      = vec3(0, 0, 0)
local CameraPosition                    = vec3(0, 5, -10)
local ShouldListenToEvents              = true
local ShouldListenToCameraEvents        = true
local ShouldListenToJumpEvent           = true
local ShouldListenToAimerEvents         = true
local ShouldListenToFireEvents          = true
local LocalCameraTarget                 = vec3(0, 0, 0)
local LocalCameraPosition               = vec3(0, 2, 0)
local CesiumRotationSensitivity         = 1
local FireModeFactor                    = 0.0
local IsLoaded                          = false

local FarCameraView                     = 0.0
local NearCameraView                    = 1.0
local CesiumForwardTranslationVector    = 0

local CesiumModelGLTF                   = 0
local CesiumUniform                     = 0

local CurrentFrame                      = 1

local WalkAnimationIndex                = 0
local StillAnimationIndex               = 1
local JumpAnimationIndex                = 2
local AimAnimationIndex                 = 3
local AimerRigidBodyIndex               = 3

local WalkAnimationSpeed                = 0.1

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

local cesiumObject                      = {}
local skyboxObject                      = {}
local planeGroundObject                 = {}
local aimerObject                       = {}
local targetCubeBigObject               = {}
local targetCubeSmallObject             = {}
local RigidBodies                       = {}
local BottomGroundObject                = Jkr.Object3D()

Spr.MechanicsUpdate                     = function()
    CesiumMoving = false
    CesiumModelGLTF = Spr.world3d:GetGLTFModel(Spr.CesiumGLTFIndex)
    CesiumUniform = Spr.world3d:GetUniform3D(Spr.CesiumSkinnedUniformIndex)
    if not IsLoaded then
        Spr.ResetAimer                     = function()
            aimerObject:SetParent(nil)
            aimerObject.mRotation    = quat(1, 0, 0, 0)
            aimerObject.mTranslation = vec3(0)
            aimerObject.mScale       = vec3(1)
            aimerObject.mMatrix      = Jmath.GetIdentityMatrix4x4()

            aimerObject.mScale       = vec3(0.5, 2, 0.5)
            aimerObject.mMatrix      = aimerObject:GetLocalMatrix()
            aimerObject.mScale       = vec3(1)
            aimerObject.mTranslation = aimerObject.mTranslation + vec3(-0.5, 1, 2)
            aimerObject.mRotation    = aimerObject.mRotation:Rotate_deg(90, vec3(1, 0, 0))
        end

        Spr.AimerApplyTransformsWithParent = function()
            local Matrix             = aimerObject:GetLocalMatrix()
            aimerObject.mRotation    = Matrix:GetRotationComponent()
            aimerObject.mTranslation = Matrix:GetTranslationComponent()
            aimerObject.mScale       = Matrix:GetScaleComponent()
            aimerObject.mMatrix      = Jmath.GetIdentityMatrix4x4()
        end

        Spr.SetAimerPower                  = function()
            aimerObject.mScale = vec3(10, 10, 10)
        end

        Spr.PlayCesiumEnterAnimation       = function(inStartingFrame)
            Spr.ResetAimer()
            local Frame = inStartingFrame

            CallBuffer.PushOneTime(Jkr.CreateUpdatable(
                function()
                    ShouldListenToEvents = false
                end
            ), Frame)
            ShouldListenToAimerEvents = false
            aimerObject:SetParent(nil)
            local Key1 = {
                mPosition_3f = vec3(0, -5, 0),
                mRotation_Qf = quat(),
                mScale_3f = vec3(1)
            }
            local Key2 = {
                mPosition_3f = vec3(0, 2, 0),
                mRotation_Qf = quat(),
                mScale_3f = vec3(2)
            }
            Engine.AnimateObject(CallBuffer, Key1, Key2, aimerObject, 0.1, Frame)

            local Key2 = {
                mPosition_3f = vec3(0, 0, 0),
                mRotation_Qf = quat(),
                mScale_3f = vec3(1)
            }
            Engine.AnimateObject(CallBuffer, Key1, Key2, planeGroundObject, 0.1, Frame)

            local Key1 = {
                mPosition_3f = vec3(0, -10, 0),
                mScale_3f = vec3(0)
            }
            local Key2 = {
                mPosition_3f = vec3(0, 0, 0),
                mScale_3f = vec3(1)
            }
            Engine.AnimateObject(CallBuffer, Key1, Key2, Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex], 0.1, Frame)
            Frame = Engine.AnimateObject(CallBuffer, Key1, Key2, cesiumObject, 0.1, Frame)

            CallBuffer.PushOneTime(Jkr.CreateUpdatable(
                function()
                    ShouldListenToEvents = true
                end
            ), Frame)
        end

        ShouldListenToEvents               = false

        cesiumObject                       = Spr.OpaqueObjects[Spr.CesiumObjIndex]
        skyboxObject                       = Spr.BackgroundObjects[Spr.SkyboxObjIndex]
        planeGroundObject                  = Spr.TransparentObjects[Spr.PlaneObjIndex]
        aimerObject                        = Spr.TransparentObjects[Spr.AimerObjIndex]
        targetCubeBigObject                = Spr.OpaqueObjects[Spr.TargetBigCubeObjIndex]
        targetCubeSmallObject              = Spr.OpaqueObjects[Spr.TargetSmallCubeObjIndex]

        Spr.ResetAimer()
        cesiumObject.mScale                = vec3(0, 0, 0)
        aimerObject.mTranslation           = vec3(0, -10, 0)
        cesiumObject.mTranslation          = vec3(0, -10, 0)

        targetCubeBigObject.mTranslation   = vec3(0, 4, 10)
        targetCubeSmallObject.mTranslation = vec3(0, 10, 10)
        targetCubeSmallObject.mScale       = vec3(0)
        targetCubeBigObject.mScale         = vec3(1)

        planeGroundObject.mScale           = vec3(20, 10, 20)
        planeGroundObject.mTranslation     = vec3(0, 10, 0)
        planeGroundObject.mMatrix          = planeGroundObject:GetLocalMatrix()
        planeGroundObject.mScale           = vec3(1)
        planeGroundObject.mTranslation     = vec3(0)

        BottomGroundObject                 = Jkr.Object3D(planeGroundObject)
        BottomGroundObject.mTranslation.y  = BottomGroundObject.mTranslation.y - 20

        local TopGroundObject              = Jkr.Object3D(planeGroundObject)
        TopGroundObject.mTranslation.y     = TopGroundObject.mTranslation.y + 20

        local LeftGroundObject             = Jkr.Object3D(planeGroundObject)
        LeftGroundObject.mTranslation.x    = LeftGroundObject.mTranslation.x - 40

        local RightGroundObject            = Jkr.Object3D(planeGroundObject)
        RightGroundObject.mTranslation.x   = RightGroundObject.mTranslation.x + 40

        local FrontGroundObject            = Jkr.Object3D(planeGroundObject)
        FrontGroundObject.mTranslation.z   = FrontGroundObject.mTranslation.z + 40

        local BackGroundObject             = Jkr.Object3D(planeGroundObject)
        BackGroundObject.mTranslation.z    = BackGroundObject.mTranslation.z - 40

        local DemoObj                      = Jkr.Object3D()

        targetCubeBigObject.mMass          = 10
        RigidBodies                        = {}

        Spr.RigidBodiesWithoutAimer        = function()
            RigidBodies = {
                Engine.MakeRigidBody(targetCubeBigObject),
                -- Engine.MakeRigidBody(aimerObject),
                Engine.MakeRigidBody(BottomGroundObject, "STATIC"),
            }
        end
        Spr.RigidBodiesWithAimer           = function()
            RigidBodies = {
                Engine.MakeRigidBody(targetCubeBigObject),
                Engine.MakeRigidBody(aimerObject),
                Engine.MakeRigidBody(BottomGroundObject, "STATIC"),
            }
        end

        Spr.RigidBodiesWithoutAimer()
    end

    if ShouldListenToAimerEvents then
        aimerObject.mScale = vec3(0.3, 0.3, 0.3) * FireModeFactor
        aimerObject.mRotation = aimerObject.mRotation:Rotate_deg(30, vec3(0, 0, 1))
    end

    CesiumForwardTranslationVector = GetTranslationVectorFromYRotation(cesiumObject.mRotation)

    if CurrentStillWalkBlendFactor < 1.0 then
        CurrentStillWalkBlendFactor = CurrentStillWalkBlendFactor + 0.1
    elseif CurrentStillWalkBlendFactor > 1.0 then
        CurrentStillWalkBlendFactor = 1.0
    end

    -- JUMP MECHANICS


    if not IsLoaded then
        Spr.PutCameraAtCesium = function()
            local CesiumObjectTranslation = cesiumObject:GetLocalMatrix():GetTranslationComponent()
            local CameraPosition =
                (CesiumObjectTranslation - CesiumForwardTranslationVector * 5 + LocalCameraPosition) *
                NearCameraView
                + (CesiumObjectTranslation - CesiumForwardTranslationVector * 10 + LocalCameraPosition) *
                FarCameraView
            local CameraTarget = (CesiumObjectTranslation + CesiumForwardTranslationVector * 5) * NearCameraView
                + (CesiumObjectTranslation + CesiumForwardTranslationVector * 10) * FarCameraView

            Spr.world3d:GetCamera3D(0):SetAttributes(CameraTarget, CameraPosition)
            Spr.world3d:GetCamera3D(0):SetPerspective(0.80, 16 / 9, 0.1, 10000)
        end

        Spr.MoveCesiumFront = function()
            cesiumObject.mTranslation = cesiumObject.mTranslation + CesiumForwardTranslationVector * 0.1
            if CurrentStillWalkBlendFactor > 0 then
                CurrentStillWalkBlendFactor = CurrentStillWalkBlendFactor - 0.2
            elseif CurrentStillWalkBlendFactor < 0 then
                CurrentStillWalkBlendFactor = 0
            end

            if FireModeFactor == 1 then
                Spr.SwitchFireMode()
            end
            CesiumMoving = true
            Spr.StepsSound:Play()
        end

        Spr.MoveCesiumBack = function()
            cesiumObject.mTranslation = cesiumObject.mTranslation - CesiumForwardTranslationVector * 0.1
            if CurrentStillWalkBlendFactor > 0 then
                CurrentStillWalkBlendFactor = CurrentStillWalkBlendFactor - 0.2
            elseif CurrentStillWalkBlendFactor < 0 then
                CurrentStillWalkBlendFactor = 0
            end
            if FireModeFactor == 1 then
                Spr.SwitchFireMode()
            end
            CesiumMoving = true
            Spr.StepsSound:Play()
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
                5.0 * CesiumRotationSensitivity,
                vec3(0, 1, 0))
            CesiumMoving = true
        end

        Spr.RotateCesiumRight = function()
            cesiumObject.mRotation = cesiumObject.mRotation:Rotate_deg(
                -5.0 * CesiumRotationSensitivity,
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
            ShouldListenToAimerEvents = true
            Spr.RigidBodiesWithoutAimer()
            if FireModeFactor == 0.0 then
                Spr.ResetAimer()
                aimerObject:SetParent(cesiumObject)
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
                    Spr.AimSound:Pause()
                    ShouldListenToEvents = true
                end), Frame)
            end
        end

        Spr.Fire = function()
            local Frame = 1
            if FireModeFactor >= 1.0 then
                Spr.SwitchFireMode()
            end
            CallBuffer.PushOneTime(Jkr.CreateUpdatable(
                function()
                    ShouldListenToFireEvents = false
                    aimerObject.mMass = 1000000
                    Spr.AimerApplyTransformsWithParent()
                    ShouldListenToAimerEvents = false
                    aimerObject:SetParent(nil)
                    Spr.RigidBodiesWithAimer()
                end
            ), Frame)
            for i = 1, 10, 1 do
                CallBuffer.PushOneTime(Jkr.CreateUpdatable(
                    function()
                        aimerObject.mForce = aimerObject.mForce + CesiumForwardTranslationVector * 1000000000
                    end
                ), Frame)
                Frame = Frame + 1
            end

            CallBuffer.PushOneTime(Jkr.CreateUpdatable(
                function()
                    ShouldListenToFireEvents = true
                    ShouldListenToEvents = true
                end
            ), Frame)
        end

        Spr.JumpCesium = function()
            local vy = 10
            local g = -10
            local function __Jump()
                Spr.JumpSound:Play()
                CallBuffer.PushOneTime(Jkr.CreateUpdatable(function()
                    vy = vy + g * 0.1
                    CurrentJumpBlendFactor = CurrentJumpBlendFactor + vy * 0.1
                    Frame = Frame + 1
                    if CurrentJumpBlendFactor >= 0 then
                        __Jump()
                        ShouldListenToJumpEvent = false
                    else
                        CurrentJumpBlendFactor = 0
                        ShouldListenToJumpEvent = true
                        vy = 10
                        g = -10
                        Spr.JumpSound:Pause()
                        Frame = 1
                    end
                end), Frame)
            end
            __Jump()
        end
    end

    cesiumObject.mTranslation.y = CurrentJumpBlendFactor
    skyboxObject.mRotation = skyboxObject.mRotation:Rotate_deg(0.01, vec3(0, 1, 0))

    if ShouldListenToEvents then
        local e = Engine.e
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
        if ShouldListenToFireEvents and e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_X) then
            Spr.Fire()
        end
        if ShouldListenToCameraEvents then
            if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_C) then
                Spr.SwitchCameraView()
                ShouldUpdate = true
            end
        end
    end

    if (CurrentFrame % 10 == 0 and not CesiumMoving) then
        if (not CesiumMoving) then
            Spr.StepsSound:Pause()
        end
    end
    if (FireModeFactor > 0.0) then
        Spr.AimSound:Play()
    end

    cesiumObject:SetParent(planeGroundObject)
    if ShouldListenToAimerEvents then
        aimerObject:SetParent(cesiumObject)
    else
        aimerObject:SetParent(nil)
    end

    if targetCubeSmallObject.mTranslation.y < -1 then
        targetCubeSmallObject.mTranslation.y = 10
        targetCubeSmallObject.mTranslation.x = math.random(-1, 1)
    end

    if targetCubeBigObject.mTranslation.y < -1 then
        targetCubeBigObject.mTranslation.y = 8
        targetCubeBigObject.mTranslation.x = math.random(-18, 18)
        targetCubeBigObject.mTranslation.z = math.random(-18, 18)
        targetCubeBigObject.mVelocity = vec3(0)
        targetCubeBigObject.mForce = vec3(0, -targetCubeBigObject.mMass * Engine.GravitationalForce, 0)
    end

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

    CesiumUniform:UpdateByGLTFAnimation(CesiumModelGLTF)
    Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex]:SetParent(planeGroundObject)
    MechanicsCopyTransformations(cesiumObject, Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex])
    MechanicsCopyTransformations(targetCubeBigObject, Spr.ShadowCastingObjects[Spr.TargetBigCubeShadowObjIndex])
    MechanicsCopyTransformations(targetCubeSmallObject, Spr.ShadowCastingObjects[Spr.TargetSmallCubeShadowObjIndex])


    CallBuffer.Update()
    if not IsLoaded then
        IsLoaded = true
    end

    Engine.SimulateRigidBodySubSteps(RigidBodies, 0.1, 10, 1)
    for i = 1, #RigidBodies, 1 do
        RigidBodies[i].ResetForces()
    end
    CurrentFrame = CurrentFrame + 1
end
