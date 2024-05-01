require "JkrGUIv2.ShaderFactory"
local ButtonComputeFrame = 1
local CShader = Jkrmt.Shader()
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
          final_color = mix(final_color, old_color, push.mParam.w);

          imageStore(storageImage, to_draw_at, final_color);
              ]])
    .GlslMainEnd()
    .NewLine()
    .str

local wid = {}
UILoad = function(i, w, e)
    wid = Jkr.CreateWidgetRenderer(i, w, e)
    if (ANDROID) then
        local Painter = Jkr.CreateCustomImagePainter("res/cache/UIbasic.glsl", CShader)
        Painter:Store(i, w)
        local CreateButton = function(x, y, inFunction)
            local Dimension = vec3(wid.WindowDimension.x / 10, wid.WindowDimension.y / 10, 1)
            local Position = vec3(wid.WindowDimension.x * x - Dimension.x,
                wid.WindowDimension.y * y - Dimension.y, 50)
            local ComputeImage = wid.CreateComputeImage(Position, Dimension)
            ComputeImage.RegisterPainter(Painter)
            wid.c.PushOneTime(Jkr.CreateDispatchable(function()
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
            wid.c.Push(Jkr.CreateUpdatable(function()
                local Dimension = vec3(wid.WindowDimension.x / 10, wid.WindowDimension.y / 10, 1)
                local Position = vec3(wid.WindowDimension.x * x - Dimension.x,
                    wid.WindowDimension.y * y - Dimension.y, 50)
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
    wid.Draw()
end

UIDispatch = function()
    wid.Dispatch()
end

UIUpdate = function()
    wid.Update()
end

UIEvent = function()
    wid.Event()
end
