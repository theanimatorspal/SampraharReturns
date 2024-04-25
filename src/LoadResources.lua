function LoadResources(mt)
    local function Compile1()
        -- Compile Shader 0
        basic3dIndex = mtWorld3d:AddSimple3D(mtI, mtW)
        basic3d = mtWorld3d:GetSimple3D(0)
        basic3d:Compile(mtI, mtW, "res/cache/simple3d.glsl",
            mtJkr.GetPBRBasic_VertexShaderLayout() .. mtJkr.GetPBRBasic_VertexShaderMain(),
            mtJkr.GetBasic_FragmentShader(), mtGetDefaultResource("Simple3D", "Compute"),
            false)


        -- Compile Shader 1
        CesiumSimple3dIndex = mtWorld3d:AddSimple3D(mtI, mtW)
        mpbrbasic3d = mtWorld3d:GetSimple3D(CesiumSimple3dIndex)
        CesiumGLTFModelIndex = mtWorld3d:AddGLTFModel("res/models/CesiumMan/CesiumMan.gltf")
        GLTFModelCesium = mtWorld3d:GetGLTFModel(0)
        CesiumId = mtWorldShape3d:Add(GLTFModelCesium)
        VertexShader = mtJkr.GetPBRBasic_VertexShaderLayout() ..
            mtJkr.GetSkinningLayout(GLTFModelCesium, 0) ..
            mtJkr.GetPBRBasic_VertexShaderWithSkinningMain()
        mpbrbasic3d:Compile(mtI, mtW, "res/cache/pbrbasic3d.glsl", VertexShader,
            mtJkr.GetPBRBasic_FragmentShader(), mtGetDefaultResource("Simpl3D", "Compute"), false)

        --Compile Shader 2 (Skybox)
        skyboxSimple3dIndex = mtWorld3d:AddSimple3D(mtI, mtW)
        mSkybox3d = mtWorld3d:GetSimple3D(2)
        mSkybox3d:SetPipelineContext(Jkr.PipelineContext.Skybox)
        mSkybox3d:Compile(mtI, mtW, "res/cache/skybox3d.glsl", mtJkr.GetSkyboxVertexShader(),
            mtJkr.GetSkyboxFragmentShader(), mtGetDefaultResource("Simple3D", "Compute"), false)

        -- Global Uniform is at 0
        GlobalUniformIndex = mtWorld3d:AddUniform3D(mtI)
        uniform3d = mtWorld3d:GetUniform3D(GlobalUniformIndex)
        uniform3d:Build(mpbrbasic3d)
        mtWorld3d:AddWorldInfoToUniform3D(GlobalUniformIndex)

        -- Cesium Uniform is at 1
        CesiumUniformIndex = mtWorld3d:AddUniform3D(mtI)
        CesiumUniform = mtWorld3d:GetUniform3D(CesiumUniformIndex)
        CesiumUniform:Build(mpbrbasic3d)
        local WorldInfoBinding = 0 -- TODO Don't do this, make this auto // TODO Use a set
        uniform3d:AddUniformBufferToUniform3D(CesiumUniform, WorldInfoBinding)

        -- Skybox Uniform is at 2
        skyboxUniformIndex = mtWorld3d:AddUniform3D(mtI)
        skyboxUniform = mtWorld3d:GetUniform3D(skyboxUniformIndex)
        skyboxUniform:Build(mSkybox3d)
        mtWorld3d:AddSkyboxToUniform3D(mtI, "res/images/skybox/", skyboxUniformIndex)
        local WorldInfoBinding = 0 -- TODO Don't do this, make this auto // TODO use a set
        uniform3d:AddUniformBufferToUniform3D(skyboxUniform, WorldInfoBinding)

        -- Plane Uniform is at 3
        planeUniformIndex = mtWorld3d:AddUniform3D(mtI)
        planeUniform = mtWorld3d:GetUniform3D(planeUniformIndex)
        planeUniform:Build(basic3d)
        uniform3d:AddUniformBufferToUniform3D(planeUniform, WorldInfoBinding)

        mpbrbasic3d = mtWorld3d:GetSimple3D(CesiumSimple3dIndex)
        CesiumUniform = mtWorld3d:GetUniform3D(CesiumUniformIndex)
        CesiumUniform:Build(mpbrbasic3d, GLTFModelCesium, 0, true)

        -- =============================================================
        mtWorld3d:AddObject(CesiumId, CesiumGLTFModelIndex, CesiumUniformIndex, CesiumSimple3dIndex)
        -- =============================================================
        mSkyboxCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(1, 1, 1))
        mSkyboxCubeId = mtWorldShape3d:Add(mSkyboxCube, vec3(0, 0, 0))
        mtWorld3d:AddObject(mSkyboxCubeId, -1, skyboxUniformIndex, skyboxSimple3dIndex)
        -- =============================================================
        mPlaneCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(3, 0.01, 3))
        mPlaneCubeId = mtWorldShape3d:Add(mPlaneCube, vec3(0, 0, 0))
        mtWorld3d:AddObject(mPlaneCubeId, -1, planeUniformIndex, basic3dIndex)
        -- =============================================================

        local NodeIndices = GLTFModelCesium:GetNodeIndexByMeshIndex(0)
        mat = GLTFModelCesium:GetNodeMatrixByIndex(NodeIndices[1]) -- MeshIndex is std::vector<ui>
        mtWorld3d:SetObjectMatrix(CesiumId, mat)
        CesiumUniform:UpdateByGLTFAnimation(GLTFModelCesium, 0.0, 0)
        mtMt:Inject("CesiumId", CesiumId)
    end
    mt:AddJobF(Compile1)
end
