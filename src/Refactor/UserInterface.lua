Spr.UserInterfaceLoad = function()
          Spr.UIWid = Jkr.CreateWidgetRenderer(Engine.i, Spr.w, Engine.e)
          Spr.WindowDimension = Spr.w:GetWindowDimension()
          local FontSize = Jmath.Lerp(16, 50, Spr.WindowDimension.y / 1080)
          Spr.UINormalFont = Spr.UIWid.CreateFont("res/fonts/font.ttf", math.int(FontSize))
          Spr.UIWid.CreateTextLabel(vec3(100, 100, 5), vec3(10),
                    Spr.UINormalFont,
                    "Samprahar",
                    vec4(5))
          local o = {}
          Spr.CreateTextLabel = function(inText, inRelativePosition_3f, inRelativeDimension_3f)

          end
end

Spr.UserInterFaceDraw = function()
          Spr.UIWid.Draw()
end

Spr.UserInterFaceUpdate = function()
          Spr.UIWid.Update()
end

Spr.UserInterFaceDispatch = function()
          Spr.UIWid.Dispatch()
end
