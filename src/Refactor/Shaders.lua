require "src.Refactor.Spr"

Spr.SetupBasicShaders = function(inShouldLoad)
    Spr.basic3dIndex = Spr.world3d:AddSimple3D(Engine.i, Spr.w)
    Spr.basicTextured3dIndex = Spr.world3d:AddSimple3D(Engine.i, Spr.w)
    Spr.skinned3dIndex = Spr.world3d:AddSimple3D(Engine.i, Spr.w)
    Spr.skybox3dIndex = Spr.world3d:AddSimple3D(Engine.i, Spr.w)
    Spr.basicShadow3dIndex = Spr.world3d:AddSimple3D(Engine.i, Spr.w)
    Spr.shadowSkinned3dIndex = Spr.world3d:AddSimple3D(Engine.i, Spr.w)
    Spr.shadowed3dIndex = Spr.world3d:AddSimple3D(Engine.i, Spr.w)
    Spr.shadowedTexture3dIndex = Spr.world3d:AddSimple3D(Engine.i, Spr.w)

    Spr.ShaderInfos = {
        { index = Spr.basic3dIndex,           v = Spr.Basic3dV,              f = Spr.Basic3dF,            c = Spr.BasicCompute, n = "__MtBasci3dIndex",           cacheName = "res/cache/basic3dIndex.glsl" },
        { index = Spr.basicTextured3dIndex,   v = Spr.Basic3dV,              f = Spr.Basic3dFTextured,    c = Spr.BasicCompute, n = "__MtBasicTextured3dIndex",   cacheName = "res/cache/basicTextured3dIndex.glsl" },
        { index = Spr.skinned3dIndex,         v = Spr.Skinning3dV(),         f = Spr.PBRBasic3dFragment,  c = Spr.BasicCompute, n = "__MtSkinned3dIndex",         cacheName = "res/cache/skinned3dIndex.glsl" },
        { index = Spr.skybox3dIndex,          v = Spr.Skybox3dV,             f = Spr.Skybox3dF,           c = Spr.BasicCompute, n = "__MtSkybox3dIndex",          cacheName = "res/cache/skybox3dIndex.glsl" },
        { index = Spr.basicShadow3dIndex,     v = Spr.Basic3dVShadow,        f = Spr.Basic3dF,            c = Spr.BasicCompute, n = "__MtBasicShadow3dIndex",     cacheName = "res/cache/basicShadow3dIndex.glsl",    shadow = true },
        { index = Spr.shadowSkinned3dIndex,   v = Spr.Skinning3dV("Shadow"), f = Spr.Basic3dF,            c = Spr.BasicCompute, n = "__MtShadowSkinned3dIndex",   cacheName = "res/cache/shadowSkinned3dIndex.glsl",  shadow = true },
        { index = Spr.shadowed3dIndex,        v = Spr.Shadowed3dV,           f = Spr.Shadowed3dF,         c = Spr.BasicCompute, n = "__MtShadowed3dIndex",        cacheName = "res/cache/shadowed3dIndex.glsl" },
        { index = Spr.shadowedTexture3dIndex, v = Spr.Shadowed3dV,           f = Spr.Shadowed3dFTextured, c = Spr.BasicCompute, n = "__MtShadowedTexture3dIndex", cacheName = "res/cache/shadowedTexture3dIndex.glsl" }
    }

    Spr.ShouldLoad = false
    Spr.GlobalBindingSet = 0
    Spr.LocalBindingSet = 1
    if inShouldLoad then Spr.ShouldLoad = inShouldLoad end
end



Spr.CompileShaders = function()
    local Si = Spr.ShaderInfos[1]
    Engine.mt:AddJobF(function()
        local Si = Spr.ShaderInfos[1]
        Spr.CompileAndInject(Si.index, Si.v, Si.f, Si.c, Si.n, Si.cacheName, Spr.ShouldLoad, Si.shadow)
    end)
    Engine.mt:AddJobF(function()
        local Si = Spr.ShaderInfos[2]
        Spr.CompileAndInject(Si.index, Si.v, Si.f, Si.c, Si.n, Si.cacheName, Spr.ShouldLoad, Si.shadow)
    end)
    Engine.mt:AddJobF(function()
        local Si = Spr.ShaderInfos[3]
        Spr.CompileAndInject(Si.index, Si.v, Si.f, Si.c, Si.n, Si.cacheName, Spr.ShouldLoad, Si.shadow)
    end)
    Engine.mt:AddJobF(function()
        local Si = Spr.ShaderInfos[4]
        Spr.CompileAndInject(Si.index, Si.v, Si.f, Si.c, Si.n, Si.cacheName, Spr.ShouldLoad, Si.shadow)
    end)
    Engine.mt:AddJobF(function()
        local Si = Spr.ShaderInfos[5]
        Spr.CompileAndInject(Si.index, Si.v, Si.f, Si.c, Si.n, Si.cacheName, Spr.ShouldLoad, Si.shadow)
    end)
    Engine.mt:AddJobF(function()
        local Si = Spr.ShaderInfos[6]
        Spr.CompileAndInject(Si.index, Si.v, Si.f, Si.c, Si.n, Si.cacheName, Spr.ShouldLoad, Si.shadow)
    end)
    Engine.mt:AddJobF(function()
        local Si = Spr.ShaderInfos[7]
        Spr.CompileAndInject(Si.index, Si.v, Si.f, Si.c, Si.n, Si.cacheName, Spr.ShouldLoad, Si.shadow)
    end)
    Engine.mt:AddJobF(function()
        local Si = Spr.ShaderInfos[8]
        Spr.CompileAndInject(Si.index, Si.v, Si.f, Si.c, Si.n, Si.cacheName, Spr.ShouldLoad, Si.shadow)
    end)
end

Spr.CompileAndInject = function(index, vertexShader, fragmentShader, computeShader, inMutexName, inCacheName,
                                shouldLoad, inShadow)
    local Simple3D = Spr.world3d:GetSimple3D(math.floor(index))
    if (inShadow) then
        Simple3D:CompileForShadowOffscreen(
            Engine.i, Spr.w, inCacheName,
            vertexShader,
            fragmentShader, computeShader, shouldLoad
        )
    else
        Simple3D:Compile(Engine.i, Spr.w, inCacheName, vertexShader, fragmentShader, computeShader,
            shouldLoad)
    end
    Engine.mt:InjectToGate(inMutexName, true, StateId)
end


Spr.BasicCompute = Engine.Shader()
    .Header(450)
    .GlslMainBegin()
    .GlslMainEnd().str

Spr.Basic3dV = Engine.Shader()
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

Spr.Basic3dVShadow = Engine.Shader()
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

Spr.Basic3dF = Engine.Shader()
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

Spr.Basic3dFTextured = Engine.Shader()
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

Spr.Skybox3dV = Engine.Shader()
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
Spr.Skybox3dF = Engine.Shader()
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

Spr.Skinning3dV = function(inType)
    local s = Engine.Shader()
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

Spr.Shadowed3dV = Engine.Shader()
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

Spr.Shadowed3dF = Engine.Shader()
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
    .Define("ambient", "0.5")
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

Spr.Shadowed3dFTextured = Engine.Shader()
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


Spr.PBRBasic3dFragment = Engine.Shader()
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


--[========================================================================================[
    COMPUTE SHADERS (CUSTOM PAINTER)
--]========================================================================================]
Spr.RoundedRectangleCShader = Jkrmt.Shader()
    .Header(450)
    .CInvocationLayout(1, 1, 1)
    .uImage2D()
    .ImagePainterPush()
    .GlslMainBegin()
    .ImagePainterAssist()
    .Append([[

          vec2 center = vec2(push.mPosDimen.x, push.mPosDimen.y);
          vec2 hw = vec2(push.mPosDimen.z, push.mPosDimen.w);
          float radius = push.mParam.x;
          vec2 Q = abs(xy - center) - hw;

          float color = distance(max(Q, vec2(0.0)), vec2(0.0)) + min(max(Q.x, Q.y), 0.0) - radius;
          color = smoothstep(-0.05, 0.05, -color);

          vec4 old_color = imageLoad(storageImage, to_draw_at);
          vec4 final_color = vec4(push.mColor.x * color, push.mColor.y * color, push.mColor.z * color, push.mColor.w * color);
          final_color = mix(final_color, old_color, 1 - color);
          imageStore(storageImage, to_draw_at, final_color);
              ]])
    .GlslMainEnd()
    .NewLine()
    .str

Spr.AimerCShader = Jkrmt.Shader()
    .Header(450)
    .CInvocationLayout(1, 1, 1)
    .uImage2D()
    .ImagePainterPush()
    .GlslMainBegin()
    .ImagePainterAssist()
    .Append [[
          vec2 center = vec2(push.mPosDimen.x, push.mPosDimen.y);
          vec2 hw = vec2(push.mPosDimen.z, push.mPosDimen.w);
          float radius = push.mParam.x;
          vec2 Q = abs(xy - center) - hw;

          float color = distance(center, xy) - radius;
          //color = smoothstep(-0.5, 0.5, -color);

          vec4 final_color = vec4(push.mColor.x, push.mColor.y, push.mColor.z, push.mColor.w * color);
          final_color.w = sin(color * 10 + push.mParam.z);
          imageStore(storageImage, to_draw_at, final_color);

    ]]
    .GlslMainEnd()
    .NewLine()
    .str


Spr.MainButtonCShader = Jkrmt.Shader()
    .Header(450)
    .CInvocationLayout(1, 1, 1)
    .uImage2D()
    .ImagePainterPush()
    .GlslMainBegin()
    .ImagePainterAssist()
    .Append([[

          vec2 center = vec2(push.mPosDimen.x, push.mPosDimen.y);
          vec2 hw = vec2(push.mPosDimen.z, push.mPosDimen.w);
          float radius = push.mParam.x;
          vec2 Q = abs(xy - center) - hw;

          float color = distance(max(Q, vec2(0.0)), vec2(0.0)) + min(max(Q.x, Q.y), 0.0) - radius;
          color = smoothstep(-0.05, 0.05, -color);

          vec4 old_color = imageLoad(storageImage, to_draw_at);
          vec4 final_color = vec4(push.mColor.x * color, push.mColor.y * color, push.mColor.z * color, push.mColor.w * color);
          final_color = mix(final_color, old_color, 1 - color);
          imageStore(storageImage, to_draw_at, final_color);
              ]])
    .GlslMainEnd()
    .NewLine()
    .str
