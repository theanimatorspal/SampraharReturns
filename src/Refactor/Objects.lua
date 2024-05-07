require("src.Refactor.Spr")
-- TODO Add this to Engine
Spr.AddObject = function(inObjects, inId, inAssociatedModel, inUniformIndex, inSimple3dIndex, inGLTFHandle,
                         inMeshIndex)
    local Object = Jkr.Object3D()
    if inId then Object.mId = inId end
    if inAssociatedModel then Object.mAssociatedModel = inAssociatedModel end
    if inUniformIndex then Object.mAssociatedUniform = inUniformIndex end
    if inSimple3dIndex then Object.mAssociatedSimple3D = inSimple3dIndex end
    if (inGLTFHandle) then
        local NodeIndices = inGLTFHandle:GetNodeIndexByMeshIndex(inMeshIndex)
        Object.mMatrix = inGLTFHandle:GetNodeMatrixByIndex(NodeIndices[1])
    end
    inObjects:add(Object)
    return #inObjects
end

Spr.SetupObjects = function()
    --[==================================================================================[
                    Objects
    ]==================================================================================]
    -- OPAQUE
    Spr.OpaqueObjects = Spr.world3d:MakeExplicitObjectsVector()
    Spr.CesiumObjIndex = Spr.AddObject(Spr.OpaqueObjects)

    -- BACKGROUND
    Spr.BackgroundObjects = Spr.world3d:MakeExplicitObjectsVector()
    Spr.SkyboxObjIndex = Spr.AddObject(Spr.BackgroundObjects)

    -- SHADOW CASTING
    Spr.ShadowCastingObjects = Spr.world3d:MakeExplicitObjectsVector()
    Spr.CesiumShadowObjIndex = Spr.AddObject(Spr.ShadowCastingObjects)

    -- TRANSPARENT
    Spr.TransparentObjects = Spr.world3d:MakeExplicitObjectsVector()
    Spr.PlaneObjIndex = Spr.AddObject(Spr.TransparentObjects)
    Spr.AimerObjIndex = Spr.AddObject(Spr.TransparentObjects)

    -- GLTFs INDEX
    local ModelPath = "res/models/CesiumManBlend/CesiumMan.gltf"
    Spr.CesiumGLTFIndex = Spr.world3d:AddGLTFModel(ModelPath)

    --[==================================================================================[
        Uniforms
    ]==================================================================================]
    Spr.GlobalUniformIndex = Spr.world3d:AddUniform3D(Engine.i)
    Spr.SkinnedUniformIndex = Spr.world3d:AddUniform3D(Engine.i)
    Spr.SkyboxUniformIndex = Spr.world3d:AddUniform3D(Engine.i)
    Spr.PlaneUniformIndex = Spr.world3d:AddUniform3D(Engine.i)
    Spr.ShadowUniformIndex = Spr.world3d:AddUniform3D(Engine.i)
    Spr.ShadowedUniformIndex = Spr.world3d:AddUniform3D(Engine.i)
    Spr.PlaneComputeTextureUniformIndex = Spr.world3d:AddUniform3D(Engine.i)
    Spr.AimerUniformIndex = Spr.world3d:AddUniform3D(Engine.i)
end

Spr.LoadObjects = function()
    --[======================================================================================================================[
        OPAQUE OBJECTS
    ]======================================================================================================================]
    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGateToThread("__MtBasci3dIndex", StateId) do end
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.GlobalUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.basic3dIndex))
            Uniform:Build(Simple3D)
            Spr.world3d:AddWorldInfoToUniform3D(math.floor(Spr.GlobalUniformIndex))
            Engine.mt:InjectToGate("__MtWorldUniform", true)
            print("Global Uniform Done")
        end
    )

    --[=======[
        GROUND
    --]=======]
    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGateToThread("__MtShadowedTexture3dIndex", -1) do end
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.PlaneComputeTextureUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.shadowedTexture3dIndex))
            Uniform:Build(Simple3D)
            Spr.world3d:AddShadowMapToUniform3D(Spr.w, math.floor(Spr.PlaneComputeTextureUniformIndex),
                math.floor(Spr.LocalBindingSet))
            local PlaneCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(20, 0.0001, 20))
            local PlaneCubeId = Spr.buffer3d:Add(PlaneCube, vec3(0, 0, 0))
            Spr.TransparentObjects[Spr.PlaneObjIndex].mId = math.floor(PlaneCubeId)
            Spr.TransparentObjects[Spr.PlaneObjIndex].mAssociatedModel = -1
            Spr.TransparentObjects[Spr.PlaneObjIndex].mAssociatedSimple3D = math.floor(Spr.shadowedTexture3dIndex)
            Spr.TransparentObjects[Spr.PlaneObjIndex].mAssociatedUniform = math.floor(Spr
                .PlaneComputeTextureUniformIndex)
            Engine.mt:InjectToGate("__MtPlaneObjGround", true)
            print("Ground Done")
        end
    )

    --[=======[
        CESIUM
    --]=======]
    Engine.mt:AddJobF(
        function()
            local Model = Spr.world3d:GetGLTFModel(math.floor(Spr.CesiumGLTFIndex))
            local Id = Spr.buffer3d:Add(Model)
            Engine.mt:InjectToGate("__MtCesiumId", Id)
        end
    )

    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGateToThread("__MtSkinned3dIndex", -1) do end
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.SkinnedUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.skinned3dIndex))
            while not Engine.mt:GetFromGateToThread("__MtCesiumId", StateId) do end
            local Model = Spr.world3d:GetGLTFModel(math.floor(Spr.CesiumGLTFIndex))
            local loadSkin = true
            local loadImages = true
            Uniform:Build(Simple3D, Model, 0, loadSkin, loadImages)
            local Id = math.floor(Engine.mt:GetFromGateToThread("__MtCesiumId", StateId))
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mId = math.floor(Id)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mAssociatedModel = math.floor(Spr.CesiumGLTFIndex)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mAssociatedSimple3D = math.floor(Spr.skinned3dIndex)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mAssociatedUniform = math.floor(Spr
                .SkinnedUniformIndex)
            local NodeIndices = Model:GetNodeIndexByMeshIndex(0)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mMatrix = Model:GetNodeMatrixByIndex(NodeIndices[1])
            print("Cesium Object Done")
            Engine.mt:InjectToGate("__MtCesiumObjLoaded", true)
        end
    )

    --[=======[
        SKYBOX
    --]=======]
    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGateToThread("__MtSkybox3dIndex", -1) do end
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.SkyboxUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.skybox3dIndex))
            Uniform:Build(Simple3D)
            Spr.world3d:AddSkyboxToUniform3D(Engine.i, "res/images/skybox/",
                math.floor(Spr.SkyboxUniformIndex),
                math.floor(Spr.LocalBindingSet))
            local SkyboxCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(1, 1, 1))
            local Id = Spr.buffer3d:Add(SkyboxCube, vec3(0, 0, 0))
            Spr.BackgroundObjects[Spr.SkyboxObjIndex].mId = math.floor(Id)
            Spr.BackgroundObjects[Spr.SkyboxObjIndex].mAssociatedSimple3D = math.floor(Spr.skybox3dIndex)
            Spr.BackgroundObjects[Spr.SkyboxObjIndex].mAssociatedUniform = math.floor(Spr
                .SkyboxUniformIndex)
            print("Skybox Object Done")
        end
    )


    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGateToThread("__MtShadowed3dIndex", StateId) do end
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.ShadowedUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.shadowed3dIndex))
            Uniform:Build(Simple3D)
            Spr.world3d:AddShadowMapToUniform3D(Spr.w, math.floor(Spr.ShadowedUniformIndex),
                math.floor(Spr.LocalBindingSet))
            print("Shadowed Uniform Done")
        end
    )


    --[=======[
        AIMER
    --]=======]

    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGateToThread("__MtBasicTextured3dIndex", StateId) do end
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.AimerUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.basicTextured3dIndex))
            Uniform:Build(Simple3D)
            Spr.world3d:AddShadowMapToUniform3D(Spr.w, math.floor(Spr.AimerUniformIndex),
                math.floor(Spr.LocalBindingSet))

            local AimerCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(1, 0.0001, 1))
            local AimerCubeId = Spr.buffer3d:Add(AimerCube, vec3(0, 0, 0))
            Spr.TransparentObjects[Spr.AimerObjIndex].mId = math.floor(AimerCubeId)
            Spr.TransparentObjects[Spr.AimerObjIndex].mAssociatedModel = -1
            Spr.TransparentObjects[Spr.AimerObjIndex].mAssociatedUniform = math.floor(Spr.AimerUniformIndex)
            Spr.TransparentObjects[Spr.AimerObjIndex].mAssociatedSimple3D = math.floor(Spr.basicTextured3dIndex)
            Engine.mt:InjectToGate("__MtAimerObj", true)
            print("Aimer Done")
        end
    )

    --[======================================================================================================================[
        SHADOW CASTING OBJECTS
    ]======================================================================================================================]

    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGateToThread("__MtShadowSkinned3dIndex", StateId) do end
            while not Engine.mt:GetFromGateToThread("__MtCesiumId", StateId) do end
            while not Engine.mt:GetFromGateToThread("__MtCesiumObjLoaded", StateId) do end
            local CesiumId = Engine.mt:GetFromGateToThread("__MtCesiumId", StateId)
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.ShadowUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.shadowSkinned3dIndex))
            local CesiumSkinnedUniform = Spr.world3d:GetUniform3D(math.floor(Spr.SkinnedUniformIndex))
            local loadSkin = true
            local loadImages = true
            Uniform:Build(Simple3D)
            CesiumSkinnedUniform:AddBindingsToUniform3DGLTF(Uniform, loadSkin, not loadImages,
                math.floor(Spr.LocalBindingSet))
            Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mId = math.floor(CesiumId)
            Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mAssociatedModel = -1
            Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mAssociatedUniform = math.floor(Spr.ShadowUniformIndex)
            Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mAssociatedSimple3D = math.floor(Spr.shadowSkinned3dIndex)
            print("Cesium Shadow Done")
        end
    )
end
