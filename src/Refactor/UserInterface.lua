Spr.UserInterfaceLoad = function()
          Spr.UIWid = Jkr.CreateWidgetRenderer(
                    Engine.i,
                    Spr.w,
                    Engine.e
          )

          Spr.MainButtonPainter = Jkr.CreateCustomImagePainter(
                    "res/cache/MainButtonCShader.glsl",
                    Spr.MainButtonCShader)

          if Spr.ShouldLoad then
                    Spr.MainButtonPainter:Load(Engine.i, Spr.w)
          else
                    Spr.MainButtonPainter:Store(Engine.i, Spr.w)
          end

          Spr.WindowDimension = Spr.w:GetWindowDimension()

          local FontSize = Jmath.Lerp(
                    16, -- from
                    50, -- to
                    Spr.WindowDimension.y / 1080
          )

          Spr.UINormalFont = Spr.UIWid.CreateFont(
                    "res/fonts/font.ttf",
                    math.int(FontSize)
          )

          Spr.UIWid.CreateTextLabel(vec3(100, 100, 5), vec3(10),
                    Spr.UINormalFont,
                    "Samprahar Returns",
                    vec4(5))

          local PlayButtonPosition = vec3(0.5, 0.5, 1)
          local ExitButtonPosition = vec3(0.5, 0.6, 1)
          local MainButtonDimension = vec3(0.12, 0.10, 50)

          local PlayButton = Spr.UserInterFaceCreateMainButton(
                    "Play",
                    PlayButtonPosition,
                    MainButtonDimension,
                    function()
                              print("Hello")
                    end,
                    0.1)
          local ExitButton = Spr.UserInterFaceCreateMainButton(
                    "Exit",
                    ExitButtonPosition,
                    MainButtonDimension,
                    function()
                              print("Hello")
                    end,
                    0.1)

          -- Jkr.CreateAnimationPosDimen(
          --           Spr.UIWid.c,
          --           { mPosition_3f = vec3(0), mDimension_3f = vec3(0) },
          --           { mPosition_3f = vec3(0), mDimension_3f = vec3(0) },
          --           PlayButton,
          --           0.1
          -- )
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

Spr.UserInterFaceEvent = function()
          Spr.UIWid.Event()
end

Spr.UserInterFaceCreateMainButton = function(inText, inRelativePosition_3f, inRelativeDimension_3f,
                                             inOnClickFunction, inOffset)
          local o = {}
          local Position = vec3(
                    inRelativePosition_3f.x * Spr.WindowDimension.x,
                    inRelativePosition_3f.y * Spr.WindowDimension.y,
                    50)
          local Dimension = vec3(
                    inRelativeDimension_3f.x * Spr.WindowDimension.x,
                    inRelativeDimension_3f.y * Spr.WindowDimension.y,
                    1)

          local TextPosition = vec3(Position)
          local ImagePosition = vec3(Position)
          local Offset = inOffset
          ImagePosition.z = ImagePosition.z + 1
          TextPosition.x = TextPosition.x + Dimension.x * Offset
          TextPosition.y = TextPosition.y + Dimension.y * Offset

          local Button = Spr.UIWid.CreateButton(ImagePosition, Dimension, inOnClickFunction)
          local Image = Spr.UIWid.CreateComputeImageLabel(Position, Dimension)
          local Text = Spr.UIWid.CreateTextLabel(TextPosition, Dimension, Spr.UINormalFont, inText)
          Image.RegisterPainter(Spr.MainButtonPainter)

          Spr.UIWid.c.PushOneTime(
                    Jkr.CreateDispatchable(
                              function()
                                        Image.BindPainter(Spr.PlaneCShader)
                                        local PC = Jkr.DefaultCustomImagePainterPushConstant()
                                        PC.x = vec4(0, 0, 0.8, 0.8)
                                        PC.y = vec4(0, 0.4, 0, 0.7)
                                        PC.z = vec4(0.1, 0, 0, 0)
                                        Image.DrawPainter(
                                                  Spr.PlaneCShader,
                                                  PC,
                                                  math.int(Dimension.x),
                                                  math.int(Dimension.y), 1)
                                        Image.CopyToSampled()
                              end
                    ), 1)

          function o.Update(self, inRelativePosition_3f, inRelativeDimension_3f, inText, inOffset)
                    local Position = vec3(
                              inRelativePosition_3f.x * Spr.WindowDimension.x,
                              inRelativePosition_3f.y * Spr.WindowDimension.y,
                              50)
                    local Dimension = vec3(
                              inRelativeDimension_3f.x * Spr.WindowDimension.x,
                              inRelativeDimension_3f.y * Spr.WindowDimension.y,
                              1)

                    if inOffset then
                              Offset = inOffset
                    end

                    local TextPosition = vec3(Position)
                    TextPosition.x = TextPosition.x + Dimension.x * Offset
                    TextPosition.x = TextPosition.x + Dimension.y * Offset
                    local ImagePosition = vec3(Position)
                    ImagePosition.z = ImagePosition.z + 1
                    Image.sampledImage:Update(ImagePosition, Dimension)
                    Text:Update(TextPosition, Dimension, nil, inText)
          end

          return o
end
