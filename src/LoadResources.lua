Resourcesmt = {}
function Resourcesmt.AddObject(inObjects, inId, inAssociatedModel, inUniformIndex, inSimple3dIndex, inGLTFHandle,
                               inMeshIndex)
    local Object = Jkr.Object3D()
    Object.mId = inId
    Object.mAssociatedModel = inAssociatedModel
    Object.mAssociatedUniform = inUniformIndex
    Object.mAssociatedSimple3D = inSimple3dIndex
    if (inGLTFHandle) then
        local NodeIndices = inGLTFHandle:GetNodeIndexByMeshIndex(inMeshIndex)
        Object.mMatrix = inGLTFHandle:GetNodeMatrixByIndex(NodeIndices[1])
    end
    inObjects:add(Object)
end

function LoadResources(mt, inWorld3d)
    OpaqueObjects = inWorld3d:MakeExplicitObjectsVector()
    ShadowCastingObjects = inWorld3d:MakeExplicitObjectsVector()
    mt:Inject("OpaqueObjects", OpaqueObjects)
    mt:Inject("ShadowCastingObjects", ShadowCastingObjects)
    mt:Inject("Resourcesmt", Resourcesmt)
    local function Compile1()
        local Basic3dV = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .VLayout()
            .Out(0, "vec2", "vUV")
            .Out(1, "vec3", "vNormal")
            .Push()
            .Ubo()
            .GlslMainBegin()
            .Indent()
            .Append("gl_Position = Ubo.proj * Ubo.view * Push.model * vec4(inPosition, 1.0);")
            .NewLine()
            .Append("vUV = inUV;")
            .Append("vNormal = inNormal;")
            .NewLine()
            .InvertY()
            .GlslMainEnd()
            .NewLine().str

        local Basic3dVShadow = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .VLayout()
            .Push()
            .Ubo()
            .GlslMainBegin()
            .Indent()
            .Append("gl_Position = Ubo.proj * Ubo.shadowMatrix * Push.model * vec4(inPosition, 1.0);")
            .NewLine()
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

        local Basic3dFTextured = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .outFragColor()
            .In(0, "vec2", "vUV")
            .In(1, "vec3", "vNormal")
            .uSampler2D(3, "samplerImage")
            .Push()
            .Ubo()
            .GlslMainBegin()
            .Indent()
            .Append([[
                outFragColor = texture(samplerImage, vUV);
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
            ]]).InvertY()
            .NewLine()
            .GlslMainEnd()
            .NewLine().str
        local Skybox3dF = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .In(0, "vec3", "vVertUV")
            .outFragColor()
            .uSamplerCubeMap(20, "samplerCubeMap")
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
                .Out(2, "vec3", "vWorldPos")
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
                    vec4 Pos = Push.model * skinMat * vec4(inPosition, 1.0f);
                    gl_Position = Ubo.proj * Ubo.view * Pos;
                    vUV = inUV;
                    vNormal = vec3(Push.model) * inNormal;
                    vWorldPos = vec3(Pos);
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

        local Shadowed3dFTextured = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .In(0, "vec2", "vUV")
            .In(1, "vec3", "vNormal")
            .In(2, "vec3", "vert_normal")
            .In(3, "vec4", "vert_shadowcoords")
            .In(4, "vec3", "vert_light")
            .In(5, "vec3", "vert_view")
            .uSampler2D(3, "ShadowMap")
            .uSampler2D(4, "ComputeImage")
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
                vec4 computeColor = texture(ComputeImage, vUV);
                outFragColor = vec4(vec3(diffuse * shadow) + vec3(computeColor), computeColor.a);
            ]])
            .GlslMainEnd()
            .NewLine().str


        local PBRBasic3dFragment = Jkrmt.Shader()
            .Header(450)
            .NewLine()
            .outFragColor()
            .In(0, "vec2", "vUV")
            .In(1, "vec3", "vNormal")
            .In(2, "vec3", "vWorldPos")
            .uSampler2D(3, "image")
            .Push()
            .Ubo()
            .PI()
            .MaterialColorBegin()
            .Append([[
                    return vec3(0, 0.8, 1.0) * vec3(texture(image, vUV));
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
                vec3 V = normalize(Ubo.campos - vWorldPos);
                float roughness = 0.8;
                roughness = max(roughness, step(fract(vWorldPos.y * 2.02), 0.5));

                // Specular Contribution
                vec3 Lo = vec3(0.0);
                vec3 L = normalize(vec3(Ubo.lights[0]) - vWorldPos);
                Lo += BRDF(L, V, N, 0, roughness);

                // Combination With Ambient
                // vec3 color = MaterialColor() * 0.2;
                // color += Lo;
                // color = pow(color, vec3(0.4545));
                // outFragColor = vec4(color, 1.0);

                 float ambient  = 0.5;
                 vec3 R = normalize(-reflect(L, N));
                 float diffuse = max(dot(N, L), ambient);
                 outFragColor = vec4(MaterialColor() * diffuse * 2, 1.0);
            ]])
            .GlslMainEnd()
            .NewLine().str

        local basicCompute = mtGetDefaultResource("Simple3D", "Compute")

        -- Compile Shader 0
        local basic3dIndex = world3d:AddSimple3D(i, w)
        local basic3d = world3d:GetSimple3D(0)
        basic3d:Compile(i, w, "res/cache/simple3d.glsl", Basic3dV, Basic3dF,
            basicCompute, false)

        -- Compile Shader 1
        local CesiumSimple3dIndex = world3d:AddSimple3D(i, w)
        local mpbrbasic3d = world3d:GetSimple3D(CesiumSimple3dIndex)
        local VertexShader = Skinning3dV()
        mpbrbasic3d:Compile(i, w, "res/cache/pbrbasic3d.glsl", VertexShader,
            PBRBasic3dFragment, basicCompute, false)

        --Compile Shader 2 (Skybox)
        local skyboxSimple3dIndex = world3d:AddSimple3D(i, w)
        local mSkybox3d = world3d:GetSimple3D(skyboxSimple3dIndex)
        mSkybox3d:SetPipelineContext(Jkr.PipelineContext.Skybox)
        mSkybox3d:Compile(i, w, "res/cache/skybox3d.glsl",
            Skybox3dV,
            Skybox3dF, basicCompute, false)

        --Compile Shader 3 (Shadow)
        local shadowOffscreenSimple3dIndex = world3d:AddSimple3D(i, w)
        local shadowOffscreenSimple3d = world3d:GetSimple3D(shadowOffscreenSimple3dIndex)
        shadowOffscreenSimple3d:CompileForShadowOffscreen(
            i, w, "res/cache/shadowOffscreen3d.glsl",
            Skinning3dV("Shadow"),
            Jkrmt.GetBasic_FragmentShader(), basicCompute, false
        )

        --Compile  Shader 4  (Shadowed)
        local shadowedSimple3dIndex = world3d:AddSimple3D(i, w)
        local shadowedSimple3d = world3d:GetSimple3D(shadowedSimple3dIndex)
        shadowedSimple3d:Compile(
            i, w, "res/cache/shadowed3d.glsl",
            Shadowed3dV,
            Shadowed3dF, basicCompute, false
        )

        -- Compile Shader 5 (Basic Shadow for offscreen)
        local basic3dForOffscreenIndex = world3d:AddSimple3D(i, w)
        local basic3dForOffscreen = world3d:GetSimple3D(basic3dForOffscreenIndex)
        basic3dForOffscreen:CompileForShadowOffscreen(i, w, "res/cache/simple3dOffscreen.glsl", Basic3dVShadow, Basic3dF,
            basicCompute, false)

        -- Compile Shader 6 (Basic Shadowed Textured)
        local shadowedSimple3dTexturedIndex = world3d:AddSimple3D(i, w)
        local shadowedSimple3dTextured = world3d:GetSimple3D(shadowedSimple3dTexturedIndex)
        shadowedSimple3dTextured:Compile(
            i, w, "res/cache/shadowed3dTextured.glsl",
            Shadowed3dV,
            Shadowed3dFTextured, basicCompute, false
        )

        -- Compile Shader 7 (Basic Textured)
        local basicTexturedSimple3dIndex = world3d:AddSimple3D(i, w)
        local basicTexturedSimple3d = world3d:GetSimple3D(basicTexturedSimple3dIndex)
        basicTexturedSimple3d:Compile(
            i, w, "res/cache/basicTexturedSimple3d.glsl",
            Basic3dV,
            Basic3dFTextured, basicCompute, false
        )


        -- Global Uniform is at 0
        local GlobalUniformIndex = world3d:AddUniform3D(i)
        local GlobalUniform3d = world3d:GetUniform3D(GlobalUniformIndex)
        GlobalUniform3d:Build(basic3d)
        world3d:AddWorldInfoToUniform3D(GlobalUniformIndex)

        -- Cesium Uniform is at 1
        local CesiumUniformIndex = world3d:AddUniform3D(i)
        local CesiumUniform = world3d:GetUniform3D(CesiumUniformIndex)
        CesiumUniform:Build(mpbrbasic3d)

        -- Skybox Uniform is at 2
        local skyboxUniformIndex = world3d:AddUniform3D(i)
        local skyboxUniform = world3d:GetUniform3D(skyboxUniformIndex)
        skyboxUniform:Build(mSkybox3d)
        world3d:AddSkyboxToUniform3D(i, "res/images/skybox/", skyboxUniformIndex, 1)

        -- Plane Uniform is at 3
        local planeUniformIndex = world3d:AddUniform3D(i)
        local planeUniform = world3d:GetUniform3D(planeUniformIndex)
        planeUniform:Build(basic3d)

        -- Shadow Uniform is at 4
        local shadowUniformIndex = world3d:AddUniform3D(i)
        local shadowUniform = world3d:GetUniform3D(shadowUniformIndex)
        shadowUniform:Build(shadowOffscreenSimple3d)

        -- Shadowed Uniform is at 5
        local shadowedUniformIndex = world3d:AddUniform3D(i)
        local shadowedUniform = world3d:GetUniform3D(shadowedUniformIndex)
        shadowedUniform:Build(shadowedSimple3d)
        world3d:AddShadowMapToUniform3D(w, shadowedUniformIndex, 1)

        -- Plane Compute Textured Uniform is at 6
        local planeComputeTextureUniformIndex = world3d:AddUniform3D(i)
        local planeComputeTextureUniform = world3d:GetUniform3D(planeComputeTextureUniformIndex)
        planeComputeTextureUniform:Build(shadowedSimple3dTextured)
        world3d:AddShadowMapToUniform3D(w, planeComputeTextureUniformIndex, 1) -- 1 = SetNo, 1 for normal
        mtMt:Inject("planeComputeTextureUniformIndex", planeComputeTextureUniformIndex)
        -- Stuffs

        -- Aimer Uniform is at 7
        local aimerUniformIndex = world3d:AddUniform3D(i)
        local aimerUniform = world3d:GetUniform3D(aimerUniformIndex)
        aimerUniform:Build(basicTexturedSimple3d)
        mtMt:Inject("aimerUniformIndex", aimerUniformIndex)


        mpbrbasic3d = world3d:GetSimple3D(CesiumSimple3dIndex)
        CesiumUniform = world3d:GetUniform3D(CesiumUniformIndex)

        local CesiumGLTFModelIndex = world3d:AddGLTFModel("res/models/CesiumManBlend/CesiumMan.gltf")
        local GLTFModelCesium = world3d:GetGLTFModel(CesiumGLTFModelIndex)
        local CesiumId = worldShape3d:Add(GLTFModelCesium)

        local loadSkin = true
        local loadImages = true
        CesiumUniform:Build(mpbrbasic3d, GLTFModelCesium, 0, loadSkin, loadImages)
        CesiumUniform:AddBindingsToUniform3DGLTF(shadowUniform, loadSkin, not loadImages, 1)

        Resourcesmt.AddObject(OpaqueObjects,
            CesiumId,
            CesiumGLTFModelIndex,
            CesiumUniformIndex,
            CesiumSimple3dIndex,
            GLTFModelCesium,
            0)

        local mSkyboxCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(1, 1, 1))
        local mPlaneCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(10, 0.0001, 10))
        local mCylinder = Jkr.Generator(Jkr.Shapes.Cylinder3D, vec3(5, 5, 16))
        local mAimerCube = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(1, 0.0001, 1))
        local mSkyboxCubeId = worldShape3d:Add(mSkyboxCube, vec3(0, 0, 0))
        local mPlaneCubeId = worldShape3d:Add(mPlaneCube, vec3(0, 0, 0))
        local mCylinderId = worldShape3d:Add(mCylinder, vec3(0, 0, 0))
        local mAimerCubeId = worldShape3d:Add(mAimerCube, vec3(0, 0, 0))
        Resourcesmt.AddObject(OpaqueObjects, mSkyboxCubeId, -1, skyboxUniformIndex, skyboxSimple3dIndex)
        Resourcesmt.AddObject(OpaqueObjects, mPlaneCubeId, -1, planeComputeTextureUniformIndex,
            shadowedSimple3dTexturedIndex)
        Resourcesmt.AddObject(OpaqueObjects, mCylinderId, -1, -1, basic3dIndex)
        Resourcesmt.AddObject(OpaqueObjects, mAimerCubeId, -1, aimerUniformIndex, basicTexturedSimple3dIndex)
        CesiumUniform:UpdateByGLTFAnimation(GLTFModelCesium, 0.0, 0, true)

        Jmath.PrintMatrix(OpaqueObjects[1].mMatrix)
        mtMt:Inject("OpaqueObjects", OpaqueObjects)
        Resourcesmt.AddObject(ShadowCastingObjects, CesiumId, -1, shadowUniformIndex, shadowOffscreenSimple3dIndex)
        Resourcesmt.AddObject(ShadowCastingObjects, mCylinderId, -1, -1, basic3dForOffscreenIndex)
        ShadowCastingObjects[1].mMatrix = OpaqueObjects[CesiumId + 1].mMatrix
        ShadowCastingObjects[2].mMatrix = OpaqueObjects[4].mMatrix
        mtMt:Inject("CesiumId", CesiumId)
        mtMt:Inject("LoadedResources", true)
    end

    mt:AddJobF(Compile1)
end
