function LoadResources(mt)
    local function Compile1()
        local Basic3dV = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .VLayout()
            .Push()
            .Ubo()
            .GlslMainBegin()
            .Indent()
            .Append("gl_Position = Ubo.proj * Ubo.view * Push.model * vec4(inPosition, 1.0);")
            .NewLine()
            .InvertY()
            .GlslMainEnd()
            .NewLine().str
        local Basic3dF = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .outFragColor()
            .Push()
            .Ubo()
            .GlslMainBegin()
            .Indent()
            .Append([[
                outFragColor = vec4(1.0, 1.0, 1.0, 1.0);
            ]])
            .GlslMainEnd()
            .NewLine().str


        local Skybox3dV = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .VLayout()
            .Out(0, "vec3", "vVertUV")
            .Push()
            .Ubo()
            .GlslMainBegin()
            .Indent()
            .Append([[
                    vec3 position = mat3(Ubo.view * Push.model) * inPosition.xyz;
                    gl_Position = (Ubo.proj * vec4(position, 0.0)).xyzz;
                    vVertUV = inPosition.xyz;
            ]])
            .NewLine()
            .GlslMainEnd()
            .NewLine().str
        local Skybox3dF = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .In(0, "vec3", "vVertUV")
            .outFragColor()
            .uSamplerCubeMap(8, "samplerCubeMap")
            .Push()
            .Ubo()
            .GlslMainBegin()
            .Indent()
            .Append([[
                outFragColor = texture(samplerCubeMap, vVertUV);
            ]])
            .GlslMainEnd()
            .NewLine().str

        local function Skinning3dV(inType)
            local s = Jkrmt.Shader()
                .Header(450)
                .NewLine()
                .VLayout()
                .Out(0, "vec2", "vUV")
                .Out(1, "vec3", "vNormal")
                .Push()
                .Ubo()
                .inJointInfluence()
                .inJointMatrices()
                .GlslMainBegin()
                .Indent()
                .Append([[
                vec4 jweight = inJointInfluence[gl_VertexIndex].mJointWeights;
                vec4 jindex = inJointInfluence[gl_VertexIndex].mJointIndices;
                mat4 skinMat  =
                        jweight.x * inJointMatrices[int(jindex.x)] +
                        jweight.y * inJointMatrices[int(jindex.y)] +
                        jweight.z * inJointMatrices[int(jindex.z)] +
                        jweight.w * inJointMatrices[int(jindex.w)];

            ]])
                .NewLine()

            if (not inType) then
                return s.Append([[
                    gl_Position = Ubo.proj * Ubo.view * Push.model * skinMat * vec4(inPosition, 1.0f);
                    vUV = inUV;
                    vNormal = inNormal;
                ]])
                    .InvertY()
                    .NewLine()
                    .GlslMainEnd()
                    .NewLine().str
            elseif (inType == "Shadow") then
                return s
                    .Append([[
                        gl_Position = Ubo.proj * Ubo.shadowMatrix * Push.model * skinMat * vec4(inPosition, 1.0);
                ]])
                    .NewLine()
                    .GlslMainEnd()
                    .NewLine().str
            end
        end

        local Shadowed3dV = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .VLayout()
            .Push()
            .Ubo()
            .BiasMatrix()
            .Out(0, "vec2", "vUV")
            .Out(1, "vec3", "vNormal")
            .Out(2, "vec3", "vert_normal")
            .Out(3, "vec4", "vert_shadowcoords")
            .Out(4, "vec3", "vert_light")
            .Out(5, "vec3", "vert_view")
            .GlslMainBegin()
            .Append([[

                vec4 pos = Push.model * vec4(inPosition, 1.0);
                gl_Position = Ubo.proj * Ubo.view * Push.model * vec4(inPosition, 1.0);

                vert_normal = mat3(Push.model) * inNormal;
                vert_light = normalize(Ubo.lights[0].xyz - inPosition);
                vert_view = -pos.xyz;
                vert_shadowcoords = (BiasMatrix * Ubo.proj * Ubo.shadowMatrix  * Push.model) * vec4(inPosition.x, inPosition.y, inPosition.z, 1.0);
                vUV = inUV;
            ]])
            .NewLine()
            .InvertY()
            .GlslMainEnd()
            .NewLine().str

        local Shadowed3dF = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .In(0, "vec2", "vUV")
            .In(1, "vec3", "vNormal")
            .In(2, "vec3", "vert_normal")
            .In(3, "vec4", "vert_shadowcoords")
            .In(4, "vec3", "vert_light")
            .In(5, "vec3", "vert_view")
            .uSampler2D(3, "ShadowMap")
            .outFragColor()
            .Push()
            .Ubo()
            .LinearizeDepth()
            .Define("ambient", "0.1")
            .Append([[

                float textureProj(vec4 shadowCoord, vec2 off)
                {
                    float shadow = 1.0;
                    if ( shadowCoord.z > -1.0 && shadowCoord.z < 1.0 )
                    {
                        float dist = LinearizeDepth(texture(ShadowMap, shadowCoord.st + off).r, 0.1, 10000); // Todo Place this in ubo near = 0.1, far = 10000
                        if ( shadowCoord.w > 0.0 && dist < shadowCoord.z )
                        {
                            shadow = ambient;
                        }
                    }
                    return shadow;
                }
            ]])
            .GlslMainBegin()
            .Indent()
            .Append([[
                vec4 shadowcoords_norm = vert_shadowcoords / vert_shadowcoords.w;
                float shadow = textureProj(shadowcoords_norm, vec2(0.0));
                vec3 N = normalize(vert_normal);
                vec3 L = normalize(vert_light);
                vec3 V = normalize(vert_view);
                vec3 R = normalize(-reflect(L, N));
                float diffuse = max(dot(N, L), ambient);
                outFragColor = vec4(vec3(diffuse * shadow), 1.0);
            ]])
            .GlslMainEnd()
            .NewLine().str


        local PBRBasic3dFragment = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .outFragColor()
            .In(0, "vec2", "vUV")
            .In(1, "vec3", "vNormal")
            .uSampler2D(3, "image")
            .Push()
            .Ubo()
            .PI()
            .MaterialColorBegin()
            .Append([[
                    return vec3(texture(image, vUV));
            ]])
            .MaterialColorEnd()
            .D_GGX()
            .G_SchlicksmithGGX()
            .F_Schlick()
            .BRDF()
            .GlslMainBegin()
            .Indent()
            .Append([[
                vec3 N = normalize(vNormal);
                vec3 V = normalize(Ubo.campos - vec3(0, 0, 0)); // TODO Ubo.campos - PositioninWorld
                float roughness = 0.8; // TODO Use that shit
                // Specular Contribution
                vec3 Lo = vec3(0.0);
                vec3 L = normalize(vec3(Ubo.lights[0]) - vec3(0, 0, 0)); // in World ko position
                Lo += BRDF(L, V, N, 1, roughness);

                // Combination With Ambient
                vec3 color = MaterialColor() * 0.02;
                color += Lo;
                color = pow(color, vec3(0.4545));
                outFragColor = vec4(color, 1.0);
            ]])
            .GlslMainEnd()
            .NewLine().str

        -- Compile Shader 0
        local basic3dIndex = mtWorld3d:AddSimple3D(mtI, mtW)
        local basic3d = mtWorld3d:GetSimple3D(0)
        basic3d:Compile(mtI, mtW, "res/cache/simple3d.glsl", Basic3dV, Basic3dF,
            mtGetDefaultResource("Simple3D", "Compute"), false)

        -- Compile Shader 1
        local CesiumSimple3dIndex = mtWorld3d:AddSimple3D(mtI, mtW)
        local mpbrbasic3d = mtWorld3d:GetSimple3D(CesiumSimple3dIndex)
        local CesiumGLTFModelIndex = mtWorld3d:AddGLTFModel("res/models/CesiumMan/CesiumMan.gltf")
        local GLTFModelCesium = mtWorld3d:GetGLTFModel(0)
        local CesiumId = mtWorldShape3d:Add(GLTFModelCesium)
        local VertexShader = Skinning3dV()
        mpbrbasic3d:Compile(mtI, mtW, "res/cache/pbrbasic3d.glsl", VertexShader,
            PBRBasic3dFragment, mtGetDefaultResource("Simpl3D", "Compute"), false)

        --Compile Shader 2 (Skybox)
        local skyboxSimple3dIndex = mtWorld3d:AddSimple3D(mtI, mtW)
        local mSkybox3d = mtWorld3d:GetSimple3D(skyboxSimple3dIndex)
        mSkybox3d:SetPipelineContext(Jkr.PipelineContext.Skybox)
        mSkybox3d:Compile(mtI, mtW, "res/cache/skybox3d.glsl",
            Skybox3dV,
            Skybox3dF, mtGetDefaultResource("Simple3D", "Compute"), false)

        --Compile Shader 3 (Shadow)
        local shadowOffscreenSimple3dIndex = mtWorld3d:AddSimple3D(mtI, mtW)
        local shadowOffscreenSimple3d = mtWorld3d:GetSimple3D(shadowOffscreenSimple3dIndex)
        shadowOffscreenSimple3d:CompileForShadowOffscreen(
            mtI, mtW, "res/cache/shadowOffscreen3d.glsl",
            Skinning3dV("Shadow"),
            Jkrmt.GetBasic_FragmentShader(), mtGetDefaultResource("Simple3D", "Compute"), false
        )

        --Compile  Shader 4  (Shadowed)
        local shadowedSimple3dIndex = mtWorld3d:AddSimple3D(mtI, mtW)
        local shadowedSimple3d = mtWorld3d:GetSimple3D(shadowedSimple3dIndex)
        shadowedSimple3d:Compile(
            mtI, mtW, "res/cache/shadowed3d.glsl",
            Shadowed3dV,
            Shadowed3dF, mtGetDefaultResource("Simple3D", "Compute"), false
        )

        -- Global Uniform is at 0

        local GlobalUniformIndex = mtWorld3d:AddUniform3D(mtI)
        local GlobalUniform3d = mtWorld3d:GetUniform3D(GlobalUniformIndex)
        GlobalUniform3d:Build(basic3d)
        mtWorld3d:AddWorldInfoToUniform3D(GlobalUniformIndex)


        -- Cesium Uniform is at 1
        local CesiumUniformIndex = mtWorld3d:AddUniform3D(mtI)
        local CesiumUniform = mtWorld3d:GetUniform3D(CesiumUniformIndex)
        CesiumUniform:Build(mpbrbasic3d)
        local WorldInfoBinding = 0 -- TODO Don't do this, make this auto // TODO Use a set


        -- Skybox Uniform is at 2
        local skyboxUniformIndex = mtWorld3d:AddUniform3D(mtI)
        local skyboxUniform = mtWorld3d:GetUniform3D(skyboxUniformIndex)
        skyboxUniform:Build(mSkybox3d)
        mtWorld3d:AddSkyboxToUniform3D(mtI, "res/images/skybox/", skyboxUniformIndex, 1)
        local WorldInfoBinding = 0 -- TODO Don't do this, make this auto // TODO use a set

        -- Plane Uniform is at 3
        local planeUniformIndex = mtWorld3d:AddUniform3D(mtI)
        local planeUniform = mtWorld3d:GetUniform3D(planeUniformIndex)
        planeUniform:Build(basic3d)

        -- Shadow Uniform is at 4
        local shadowUniformIndex = mtWorld3d:AddUniform3D(mtI)
        local shadowUniform = mtWorld3d:GetUniform3D(shadowUniformIndex)
        shadowUniform:Build(shadowOffscreenSimple3d)

        -- Shadowed Uniform is at 5
        local shadowedUniformIndex = mtWorld3d:AddUniform3D(mtI)
        local shadowedUniform = mtWorld3d:GetUniform3D(shadowedUniformIndex)
        shadowedUniform:Build(shadowedSimple3d)
        mtWorld3d:AddShadowMapToUniform3D(mtW, shadowedUniformIndex, 1)

        mpbrbasic3d = mtWorld3d:GetSimple3D(CesiumSimple3dIndex)
        CesiumUniform = mtWorld3d:GetUniform3D(CesiumUniformIndex)
        local loadSkin = true
        local loadImages = true
        -- COPY Uniform from a GlTF
        CesiumUniform:Build(mpbrbasic3d, GLTFModelCesium, 0, loadSkin, loadImages)
        CesiumUniform:AddBindingsToUniform3DGLTF(shadowUniform, loadSkin, not loadImages, 1)

        -- =============================================================
        mtWorld3d:AddObject(CesiumId, CesiumGLTFModelIndex, CesiumUniformIndex,
            CesiumSimple3dIndex)
        -- =============================================================
        local mSkyboxCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(1, 1, 1))
        local mSkyboxCubeId = mtWorldShape3d:Add(mSkyboxCube, vec3(0, 0, 0))
        mtWorld3d:AddObject(mSkyboxCubeId, -1, skyboxUniformIndex, skyboxSimple3dIndex)
        -- =============================================================
        local mPlaneCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(3, 0.01, 3))
        local mPlaneCubeId = mtWorldShape3d:Add(mPlaneCube, vec3(0, 0, 0))
        mtWorld3d:AddObject(mPlaneCubeId, -1, shadowedUniformIndex, shadowedSimple3dIndex)
        -- =============================================================

        local NodeIndices    = GLTFModelCesium:GetNodeIndexByMeshIndex(0)
        mat                  = GLTFModelCesium:GetNodeMatrixByIndex(NodeIndices[1]) -- MeshIndex is std::vector<ui>
        local objects        = mtWorld3d:GetExplicitObjects()
        local cesiumObject   = objects[1]
        cesiumObject.mMatrix = GLTFModelCesium:GetNodeMatrixByIndex(NodeIndices[1])
        --mtWorld3d:SetObjectMatrix(CesiumId, mat)
        CesiumUniform:UpdateByGLTFAnimation(GLTFModelCesium, 0.0, 0, true)

        local shadowCastingObjects = mtWorld3d:GetExplicitShadowCastingObjects()
        local Object = Jkr.Object3D()
        Object.mId = CesiumId
        Object.mAssociatedModel = -1
        Object.mAssociatedUniform = shadowUniformIndex
        Object.mAssociatedSimple3D = shadowOffscreenSimple3dIndex
        shadowCastingObjects:add(Object)
        mtMt:Inject("CesiumId", CesiumId)
    end
    mt:AddJobF(Compile1)
end
