require "JkrGUIv2.ShaderFactory"
local Frame = 0
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
          local Dimension = vec3(100, 100, 1)
          local Position = vec3(wid.WindowDimension.x / 2 - Dimension.x, wid.WindowDimension.y / 2 - Dimension.y, 50)
          local ComputeImage = wid.CreateComputeImage(Position, Dimension)
          local Painter = ComputeImage.CreatePainter("res/cache/UIbasic.glsl", CShader)
          wid.c.PushOneTime(Jkr.CreateDispatchable(function()
                    ComputeImage.BindPainter(Painter)
                    local PC = Jkr.DefaultCustomImagePainterPushConstant()
                    PC.x = vec4(0, 0, 50, 50)
                    PC.y = vec4(1, 0, 0, 1)
                    PC.z = vec4(0.8)
                    ComputeImage.DrawPainter(Painter, PC, 50, 50, 1)
          end), Frame)
end

UIDraw = function()

end

UIDispatch = function()

end

UIUpdate = function()

end

UIEvent = function()

end
