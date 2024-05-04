require "JkrGUIv2.ShaderFactory"
local ButtonComputeFrame = 1
local RoundedRectangleCShader = Jkrmt.Shader()
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

local AimerCShader = Jkrmt.Shader()
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

          float color = distance(center, xy) - radius;
          //color = smoothstep(-0.5, 0.5, -color);

          vec4 final_color = vec4(push.mColor.x, push.mColor.y, push.mColor.z, push.mColor.w * color);
          final_color.w = sin(color * 10 + push.mParam.z);
          imageStore(storageImage, to_draw_at, final_color);

    ]])
    .GlslMainEnd()
    .NewLine()
    .str

UserInterface = {}
WidUI = {}
UILoad = function(i, w, e, inWorld3d, mt)
    WidUI = Jkr.CreateWidgetRenderer(i, w, e)
    local Painter = Jkr.CreateCustomImagePainter("res/cache/PlaneShaderCompute.glsl", RoundedRectangleCShader)
    Painter:Store(i, w)
    local AimerPainter = Jkr.CreateCustomImagePainter("res/cache/AimerShaderCompute.glsl", AimerCShader)
    AimerPainter:Store(i, w)

    local PlaneTextureComputeImage = WidUI.CreateComputeImage(vec3(math.huge, math.huge, math.huge), vec3(500, 500, 1))
    PlaneTextureComputeImage.RegisterPainter(Painter)
    WidUI.c.PushOneTime(Jkr.CreateDispatchable(
        function()
            PlaneTextureComputeImage.BindPainter(Painter)
            local PC = Jkr.DefaultCustomImagePainterPushConstant()
            PC.x = vec4(0, 0, 0.8, 0.8)
            PC.y = vec4(0, 1, 0, 0.1)
            PC.z = vec4(0.1, 0, 0, 0)
            PlaneTextureComputeImage.DrawPainter(Painter, PC, math.int(500), math.int(500), 1)
            PlaneTextureComputeImage.CopyToSampled()
        end
    ), ButtonComputeFrame)

    local AimerTextureComputeImage = WidUI.CreateComputeImage(vec3(math.huge, math.huge, math.huge), vec3(500, 500, 1))
    AimerTextureComputeImage.RegisterPainter(Painter)
    AimerTextureComputeImageIndex = AimerTextureComputeImage.sampledImage

    local Offset = 0
    UserInterface.DrawToAimer = function()
        WidUI.c.Push(Jkr.CreateDispatchable(
            function()
                local PC = Jkr.DefaultCustomImagePainterPushConstant()
                PC.x = vec4(0, 0, 0.2, 0.2)
                PC.y = vec4(5, 0.2, 0.2, 3)
                PC.z = vec4(0.5, 0, Offset, 0.5)
                AimerTextureComputeImage.BindPainter(AimerPainter)
                AimerTextureComputeImage.DrawPainter(AimerPainter, PC, math.int(500), math.int(500), 1)
                AimerTextureComputeImage.CopyToSampled()
                Offset = Offset + 0.4
            end
        ))
    end

    UserInterface.DrawPlatform = function(inBackColor, inCenterColor, inSideColor)
        local Color = 1
        WidUI.c.PushOneTime(Jkr.CreateDispatchable(
            function()
                PlaneTextureComputeImage.BindPainter(Painter)
                local PC = Jkr.DefaultCustomImagePainterPushConstant()
                local ColorBack = vec4(0.35, 0.5, 0.4, 0.1)
                local ColorCenter = vec4(1, 0.3, 0.2, 0.7)
                local ColorSides = vec4(0.35, 0.1, 0.5, 0.7)
                if inBackColor then ColorBack = inBackColor end
                if inCenterColor then ColorCenter = inCenterColor end
                if inSideColor then ColorSides = inSideColor end

                PC.x = vec4(0, 0, 0.9, 0.9)
                PC.y = vec4(0, 1, 0, 1)
                PC.z = vec4(0.5, 0, 0, 0.5)
                PlaneTextureComputeImage.DrawPainter(Painter, PC, math.int(500), math.int(500), 1)

                PC.x = vec4(0, 0, 0.5, 0.5)
                PC.y = ColorBack
                PC.z = vec4(0.5, 0, 0, 0.5)
                PlaneTextureComputeImage.DrawPainter(Painter, PC, math.int(500), math.int(500), 1)
                PC.x = vec4(0, 0, 0.1, 0.1)
                PC.y = ColorCenter
                PC.z = vec4(0.2, 0, 0, 0.5)
                PlaneTextureComputeImage.DrawPainter(Painter, PC, math.int(500), math.int(500), 1)
                PC.x = vec4(0, 0.8, 0.01, 0.1)
                PC.y = ColorSides
                PC.z = vec4(0.2, 0, 0, 0.5)
                PlaneTextureComputeImage.DrawPainter(Painter, PC, math.int(500), math.int(500), 1)
                PC.x = vec4(0, -0.8, 0.01, 0.1)
                PC.y = ColorSides
                PC.z = vec4(0.2, 0, 0, 0.5)
                PlaneTextureComputeImage.DrawPainter(Painter, PC, math.int(500), math.int(500), 1)
                PC.x = vec4(-0.8, 0.0, 0.01, 0.1)
                PC.y = ColorSides
                PC.z = vec4(0.2, 0, 0, 0.5)
                PlaneTextureComputeImage.DrawPainter(Painter, PC, math.int(500), math.int(500), 1)
                PC.x = vec4(0.8, 0.0, 0.01, 0.1)
                PC.y = ColorSides
                PC.z = vec4(0.2, 0, 0, 0.5)
                PlaneTextureComputeImage.DrawPainter(Painter, PC, math.int(500), math.int(500), 1)
                PlaneTextureComputeImage.CopyToSampled()
                Color = Color + 0.1
            end
        ), ButtonComputeFrame)
    end

    while not mt:Get("planeComputeTextureUniformIndex") do end
    local Binding = 4
    PlaneTextureComputeImageIndex = PlaneTextureComputeImage.sampledImage
    local planeComputeTextureUniformIndex = math.int(mt:Get("planeComputeTextureUniformIndex"))
    local PlaneUniform = inWorld3d:GetUniform3D(planeComputeTextureUniformIndex)
    PlaneUniform:AddTextureFromShapeImage(WidUI.s.handle, PlaneTextureComputeImageIndex, Binding, 1)

    if (ANDROID) then
        local Painter = Jkr.CreateCustomImagePainter("res/cache/UIbasic.glsl", RoundedRectangleCShader)
        Painter:Store(i, w)
        local CreateButton = function(x, y, inFunction)
            local Dimension = vec3(WidUI.WindowDimension.x / 10, WidUI.WindowDimension.y / 10, 1)
            local Position = vec3(WidUI.WindowDimension.x * x - Dimension.x,
                WidUI.WindowDimension.y * y - Dimension.y, 50)
            local ComputeImage = WidUI.CreateComputeImage(Position, Dimension)
            ComputeImage.RegisterPainter(Painter)
            WidUI.c.PushOneTime(Jkr.CreateDispatchable(function()
                ComputeImage.BindPainter(Painter)
                local PC = Jkr.DefaultCustomImagePainterPushConstant()
                PC.x = vec4(0, 0, 0.8, 0.8)
                PC.y = vec4(1, 0, 0, 0.8)
                PC.z = vec4(0.0)
                ComputeImage.DrawPainter(Painter, PC, math.int(Dimension.x), math.int(Dimension.y), 1)
                ComputeImage.CopyToSampled()
            end), ButtonComputeFrame)
            local Button = ComputeImage.CreateButton(Position, Dimension, function()
                inFunction()
            end)
            -- TODO space thichesi garne bana
            WidUI.c.Push(Jkr.CreateUpdatable(function()
                local Dimension = vec3(WidUI.WindowDimension.x / 10, WidUI.WindowDimension.y / 10, 1)
                local Position = vec3(WidUI.WindowDimension.x * x - Dimension.x,
                    WidUI.WindowDimension.y * y - Dimension.y, 50)
                Button.Update(Position, Dimension)
            end))
        end
        CreateButton(0.3, 0.6, function() Mechanics.MoveCesiumFront() end)
        CreateButton(0.2, 0.7, function() Mechanics.RotateCesiumLeft() end)
        CreateButton(0.4, 0.7, function() Mechanics.RotateCesiumRight() end)
        CreateButton(0.3, 0.8, function() Mechanics.MoveCesiumBack() end)
        ButtonComputeFrame = ButtonComputeFrame + 1
    end
end

UIDraw = function()
    WidUI.Draw()
end

UIDispatch = function()
    WidUI.Dispatch()
end

UIUpdate = function(mt)
    WidUI.Update()
end

UIEvent = function()
    WidUI.Event()
end
