require("src.Refactor.Spr")
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
    Spr.OpaqueObjects = Spr.world3d:MakeExplicitObjectsVector()
    Spr.BackgroundObjects = Spr.world3d:MakeExplicitObjectsVector()
    Spr.ShadowCastingObjects = Spr.world3d:MakeExplicitObjectsVector()
    -- OPAQUE
    Spr.CesiumObjIndex = Spr.AddObject(Spr.OpaqueObjects)
    Spr.PlaneObjIndex = Spr.AddObject(Spr.OpaqueObjects)
    Spr.CesiumObjIndex = Spr.AddObject(Spr.OpaqueObjects)
    -- BACKGROUND
    Spr.SkyboxObjIndex = Spr.AddObject(Spr.BackgroundObjects)
    -- SHADOW CASTING
    Spr.CesiumShadowObjIndex = Spr.AddObject(Spr.ShadowCastingObjects)
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
    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGate("__MtBasci3dIndex") do end
            print("Here1")
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.GlobalUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.basic3dIndex))
            Uniform:Build(Simple3D)
            Spr.world3d:AddWorldInfoToUniform3D(math.floor(Spr.GlobalUniformIndex))
        end
    )

    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGate("__MtSkinned3dIndex") do end
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.SkinnedUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.skinned3dIndex))
            Uniform:Build(Simple3D)
            local ModelPath = "res/models/CesiumManBlend/CesiumMan.gltf"
            local ModelIndex = Spr.world3d:AddGLTFModel(ModelPath)
            local Model = Spr.world3d:GetGLTFModel(ModelIndex)
            local Id = Spr.buffer3d:Add(Model)
            Engine.mt:InjectToGate("__MtCesiumId", Id)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mId = math.floor(Id)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mAssociatedModel = math.floor(ModelIndex)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mAssociatedSimple3D = math.floor(Spr.skinned3dIndex)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mAssociatedUniform = math.floor(Spr
                .SkinnedUniformIndex)
            local NodeIndices = Model:GetNodeIndexByMeshIndex(0)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mMatrix = Model:GetNodeMatrixByIndex(NodeIndices[1])
        end
    )

    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGate("__MtSkybox3dIndex") do end
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.SkyboxUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.skybox3dIndex))
            Uniform:Build(Simple3D)
            Spr.world3d:AddSkyboxToUniform3D(Engine.i, "res/images/skybox/",
                math.floor(Spr.SkyboxUniformIndex),
                math.floor(Spr.LocalBindingSet))
            local SkyboxCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(1, 1, 1))
            local Id = Spr.buffer3d:Add(SkyboxCube, vec3(0, 0, 0))
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mId = math.floor(Id)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mAssociatedSimple3D = math.floor(Spr.skybox3dIndex)
            Spr.OpaqueObjects[Spr.CesiumObjIndex].mAssociatedUniform = math.floor(Spr
                .SkyboxUniformIndex)
        end
    )

    Engine.mt:AddJobF(
        function()
            while not Engine.mt:GetFromGate("__MtShadowSkinned3dIndex") do end
            while not Engine.mt:GetFromGate("__MtCesiumId") do end
            local Uniform = Spr.world3d:GetUniform3D(math.floor(Spr.ShadowUniformIndex))
            local Simple3D = Spr.world3d:GetSimple3D(math.floor(Spr.shadowSkinned3dIndex))
            Uniform:Build(Simple3D)
            Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mId = math.floor(Engine.mt:GetFromGate("__MtCesiumId"))
            Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mAssociatedModel = -1
            Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mAssociatedUniform = math.floor(Spr.ShadowUniformIndex)
            Spr.ShadowCastingObjects[Spr.CesiumShadowObjIndex].mAssociatedSimple3D = math.floor(Spr.shadowSkinned3dIndex)
        end
    )
end
