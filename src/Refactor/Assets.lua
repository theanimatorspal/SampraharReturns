Spr.AssetsLoad = function()
          Spr.Wid = Jkr.CreateWidgetRenderer(Engine.i, Spr.w, Engine.e)

          Spr.PlaneCShader = Jkr.CreateCustomImagePainter("res/cache/PlaneShaderCompute.glsl",
                    Spr.RoundedRectangleCShader)
          Spr.AimerCShader = Jkr.CreateCustomImagePainter("res/cache/AimerShaderCompute.glsl", Spr.AimerCShader)
          if Spr.ShouldLoad then
                    Spr.PlaneCShader:Load(Engine.i, Spr.w)
                    Spr.AimerCShader:Load(Engine.i, Spr.w)
          else
                    Spr.PlaneCShader:Store(Engine.i, Spr.w)
                    Spr.AimerCShader:Store(Engine.i, Spr.w)
          end

          Spr.PlaneTextureComputeImage = Spr.Wid.CreateComputeImageLabel(vec3(math.huge, math.huge, math.huge),
                    vec3(500, 500, 1), true)
          Spr.PlaneTextureComputeImage.RegisterPainter(Spr.PlaneCShader)
          Spr.Wid.c.PushOneTime(
                    Jkr.CreateDispatchable(
                              function()
                                        Spr.PlaneTextureComputeImage.BindPainter(Spr.PlaneCShader)
                                        local PC = Jkr.DefaultCustomImagePainterPushConstant()
                                        PC.x = vec4(0, 0, 0.8, 0.8)
                                        PC.y = vec4(0, 1, 0, 0.1)
                                        PC.z = vec4(0.1, 0, 0, 0)
                                        Spr.PlaneTextureComputeImage.DrawPainter(Spr.PlaneCShader, PC, math.int(500),
                                                  math.int(500), 1)
                                        Spr.PlaneTextureComputeImage.CopyToSampled()
                              end
                    ),
                    1)
          Spr.AimerTextureComputeImage = Spr.Wid.CreateComputeImageLabel(vec3(math.huge, math.huge, math.huge),
                    vec3(500, 500, 1), true)
          Spr.AimerTextureComputeImage.RegisterPainter(Spr.PlaneCShader)

          local Offset = 0
          Spr.DrawToAimer = function()
                    Spr.Wid.c.Push(Jkr.CreateDispatchable(
                              function()
                                        local PC = Jkr.DefaultCustomImagePainterPushConstant()
                                        PC.x = vec4(0, 0, 0.2, 0.2)
                                        PC.y = vec4(0.8, 0.8, 1, 1)
                                        PC.z = vec4(0.5, 0, Offset, 0.5)
                                        Spr.AimerTextureComputeImage.BindPainter(Spr.AimerCShader)
                                        Spr.AimerTextureComputeImage.DrawPainter(Spr.AimerCShader, PC, math.int(500),
                                                  math.int(500), 1)
                                        Spr.AimerTextureComputeImage.CopyToSampled()
                                        Offset = Offset + 0.4
                              end
                    ))
          end
          Spr.DrawPlatform = function(inBackColor, inCenterColor, inSideColor)
                    local Color = 1
                    Spr.Wid.c.PushOneTime(Jkr.CreateDispatchable(
                              function()
                                        Spr.PlaneTextureComputeImage.BindPainter(Spr.PlaneCShader)
                                        local PC = Jkr.DefaultCustomImagePainterPushConstant()
                                        local ColorBack = vec4(0.35, 0.5, 0.4, 0.1)
                                        local ColorCenter = vec4(0.4, 0.3, 0.2, 0.7)
                                        local ColorSides = vec4(0.35, 0.1, 0.5, 0.7)
                                        if inBackColor then ColorBack = inBackColor end
                                        if inCenterColor then ColorCenter = inCenterColor end
                                        if inSideColor then ColorSides = inSideColor end

                                        PC.x = vec4(0, 0, 0.9, 0.9)
                                        PC.y = vec4(0, 1, 0, 1)
                                        PC.z = vec4(0.5, 0, 0, 0.5)
                                        Spr.PlaneTextureComputeImage.DrawPainter(Spr.PlaneCShader, PC, math.int(500),
                                                  math.int(500), 1)
                                        PC.x = vec4(0, 0, 0.5, 0.5)
                                        PC.y = ColorBack
                                        PC.z = vec4(0.5, 0, 0, 0.5)
                                        Spr.PlaneTextureComputeImage.DrawPainter(Spr.PlaneCShader, PC, math.int(500),
                                                  math.int(500), 1)
                                        PC.x = vec4(0, 0, 0.1, 0.1)
                                        PC.y = ColorCenter
                                        PC.z = vec4(0.2, 0, 0, 0.5)
                                        Spr.PlaneTextureComputeImage.DrawPainter(Spr.PlaneCShader, PC, math.int(500),
                                                  math.int(500), 1)
                                        PC.x = vec4(0, 0.8, 0.01, 0.1)
                                        PC.y = ColorSides
                                        PC.z = vec4(0.2, 0, 0, 0.5)
                                        Spr.PlaneTextureComputeImage.DrawPainter(Spr.PlaneCShader, PC, math.int(500),
                                                  math.int(500), 1)
                                        PC.x = vec4(0, -0.8, 0.01, 0.1)
                                        PC.y = ColorSides
                                        PC.z = vec4(0.2, 0, 0, 0.5)
                                        Spr.PlaneTextureComputeImage.DrawPainter(Spr.PlaneCShader, PC, math.int(500),
                                                  math.int(500), 1)
                                        PC.x = vec4(-0.8, 0.0, 0.01, 0.1)
                                        PC.y = ColorSides
                                        PC.z = vec4(0.2, 0, 0, 0.5)
                                        Spr.PlaneTextureComputeImage.DrawPainter(Spr.PlaneCShader, PC, math.int(500),
                                                  math.int(500), 1)
                                        PC.x = vec4(0.8, 0.0, 0.01, 0.1)
                                        PC.y = ColorSides
                                        PC.z = vec4(0.2, 0, 0, 0.5)
                                        Spr.PlaneTextureComputeImage.DrawPainter(Spr.PlaneCShader, PC, math.int(500),
                                                  math.int(500), 1)
                                        Spr.PlaneTextureComputeImage.CopyToSampled()
                                        Color = Color + 0.1
                              end
                    ), 1)
          end

          while not Engine.mt:GetFromGateToThread("__MtPlaneObjGround", -1) do end
          while not Engine.mt:GetFromGateToThread("__MtAimerObj", -1) do end
          local BindingIndex = 4 -- Shadow xan ta
          local PlaneUniform = Spr.world3d:GetUniform3D(Spr.PlaneComputeTextureUniformIndex)
          PlaneUniform:AddTextureFromShapeImage(Spr.Wid.s.handle,
                    math.floor(Spr.PlaneTextureComputeImage.sampledImage.mId), BindingIndex,
                    1)
          Spr.DrawPlatform()

          BindingIndex = 3
          local aimerUniform = Spr.world3d:GetUniform3D(Spr.AimerUniformIndex)
          aimerUniform:AddTextureFromShapeImage(Spr.Wid.s.handle,
                    math.floor(Spr.AimerTextureComputeImage.sampledImage.mId),
                    BindingIndex,
                    1)
          Spr.DrawToAimer(1)

          Spr.StepsSound = Jkr.Sound("res/audio/steps.wav")
          Spr.StepsSound:SetupAudioDevice()
          Spr.JumpSound = Jkr.Sound("res/audio/jump.wav")
          Spr.JumpSound:SetupAudioDevice()
          Spr.AimSound = Jkr.Sound("res/audio/aim.wav")
          Spr.AimSound:SetupAudioDevice()
          Spr.FireSound = Jkr.Sound("res/audio/fire.wav")
          Spr.FireSound:SetupAudioDevice()
          Spr.GameOverSound = Jkr.Sound("res/audio/gameover.wav")
          Spr.GameOverSound:SetupAudioDevice()
          Spr.DangerSound = Jkr.Sound("res/audio/danger.wav")
          Spr.DangerSound:SetupAudioDevice()
end

Spr.AssetsUpdate = function()
          Spr.Wid.Update()
end

Spr.AssetsDispatch = function()
          Spr.Wid.Dispatch()
end
