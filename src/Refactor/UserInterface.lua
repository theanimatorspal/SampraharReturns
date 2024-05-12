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

          local NormalFontSize = Jmath.Lerp(
                    16, -- from
                    50, -- to
                    Spr.WindowDimension.y / 1080
          )

          Spr.UINormalFont = Spr.UIWid.CreateFont(
                    "res/fonts/font.ttf",
                    math.int(NormalFontSize)
          )

          local SmallFontSize = Jmath.Lerp(
                    10, -- from
                    12, -- to
                    Spr.WindowDimension.y / 100
          )

          Spr.UISmallFont = Spr.UIWid.CreateFont(
                    "res/fonts/font.ttf",
                    math.int(SmallFontSize)
          )

          local TitleTextLabel = Spr.UIWid.CreateTextLabel(vec3(100, 100, 5), vec3(10),
                    Spr.UINormalFont,
                    "Hit the Cube",
                    vec4(5))

          local PlayButtonPosition = vec3(0.2, 0.5, 1)
          local ExitButtonPosition = vec3(0.2, 0.6, 1)
          local MainButtonDimension = vec3(0.12, 0.10, 50)
          local ScoreBoardLinePosition = vec3(0.8, 0.1, 50)
          local ScoreBoardLineDimension = vec3(0.1, 0.05, 1)
          local ScoreBoardHealthPosition = vec3(0.1, 0.1, 50)
          local ScoreBoardHealthDimension = vec3(0.1, 0.05, 1)
          local ScorePosition = vec3(0.5, 0.1, 0)

          local PlayButton = Spr.UserInterFaceCreateMainButton(
                    "Play",
                    PlayButtonPosition,
                    MainButtonDimension,
                    function()
                              Spr.PlayCesiumEnterAnimation(1)
                              Spr.PutOffPlayExitButtons()
                    end,
                    0.1,
                    vec4(0, 0.4, 0, 0.7))

          local ExitButton = Spr.UserInterFaceCreateMainButton(
                    "Exit",
                    ExitButtonPosition,
                    MainButtonDimension,
                    function()
                    end,
                    0.1,
                    vec4(0, 0.4, 0, 0.7)
          )

          -- SCORE POWER INDICATOR
          Spr.BlueColor = vec4(0.1, 0.2, 0.95, 1)
          Spr.DarkBlueColor = vec4(0.1, 0.2, 0.95, 0.4)
          Spr.GoodRedColor = vec4(1, 0.2, 0.95, 1)
          Spr.GoodGreenColor = vec4(0.3, 0.99, 0.5, 1)
          local ScoreBoard = Spr.UserInterFaceCreateMainButton(
                    " ",
                    ScoreBoardLinePosition,
                    ScoreBoardLineDimension,
                    function() end,
                    0.1,
                    Spr.BlueColor
          )

          Spr.SetScoreBoardPowerIndicator = function(inNormalizedValue)
                    ScoreBoard.PaintBy(vec4(0, 0, 1, 1), Spr.BlueColor, vec4(0.2, 0, 0, 1))
                    ScoreBoard.PaintBy(vec4(-1, 0, 2, 0.1), Spr.DarkBlueColor, vec4(0.2, 0, 0, 1))
                    ScoreBoard.PaintBy(vec4(-1, 0, Jmath.Lerp(-1, 2, inNormalizedValue), 0.1), Spr.GoodRedColor,
                              vec4(0.2, 0, 0, 1))
          end
          Spr.SetScoreBoardPowerIndicator(0.5)

          -- SCORE Health INDICATOR
          local ScoreBoardHealth = Spr.UserInterFaceCreateMainButton(
                    " ",
                    ScoreBoardHealthPosition,
                    ScoreBoardHealthDimension,
                    function() end,
                    0.1,
                    Spr.BlueColor
          )

          Spr.SetHealthIndicaotr = function(inNormalizedValue)
                    ScoreBoardHealth.PaintBy(vec4(0, 0, 1, 1), Spr.BlueColor, vec4(0.2, 0, 0, 1))
                    ScoreBoardHealth.PaintBy(vec4(-1, 0, 2, 0.1), Spr.DarkBlueColor, vec4(0.2, 0, 0, 1))
                    ScoreBoardHealth.PaintBy(vec4(-1, 0, Jmath.Lerp(-1, 2, inNormalizedValue), 0.1), Spr.GoodGreenColor,
                              vec4(0.2, 0, 0, 1))
          end
          Spr.SetHealthIndicaotr(0.5)

          -- SCORE INDICATOR
          local ScoreIndicatorText = Spr.UserInterfaceCreateRAWLabel("Score: 0", Spr.UISmallFont, ScorePosition, vec3(0))



          Spr.PutOffPlayExitButtons = function()
                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = PlayButtonPosition, mDimension_3f = MainButtonDimension },
                              { mPosition_3f = vec3(3), mDimension_3f = MainButtonDimension },
                              PlayButton,
                              0.1
                    )
                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = ExitButtonPosition, mDimension_3f = MainButtonDimension },
                              { mPosition_3f = vec3(3), mDimension_3f = MainButtonDimension },
                              ExitButton,
                              0.1
                    )

                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = vec3(100, 100, 5), mDimension_3f = MainButtonDimension },
                              { mPosition_3f = vec3(1000, 0, 5), mDimension_3f = MainButtonDimension },
                              TitleTextLabel,
                              0.1
                    )
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

Spr.UserInterFaceEvent = function()
          Spr.UIWid.Event()
end

Spr.UserInterfaceCreateRAWLabel = function(inText, inFont, inRelativePosition_3f, inRelativeDimension_3f)
          local o = {}
          local Position = vec3(
                    inRelativePosition_3f.x * Spr.WindowDimension.x,
                    inRelativePosition_3f.y * Spr.WindowDimension.y,
                    50)
          local Dimension = vec3(
                    inRelativeDimension_3f.x * Spr.WindowDimension.x,
                    inRelativeDimension_3f.y * Spr.WindowDimension.y,
                    1)
          local TitleTextLabel = Spr.UIWid.CreateTextLabel(Position, Dimension,
                    inFont,
                    inText,
                    vec4(5))
          o.Update = function(self, inRelativePosition_3f, inRelativeDimension_3f, inFont, inText)
                    local Position = vec3(
                              inRelativePosition_3f.x * Spr.WindowDimension.x,
                              inRelativePosition_3f.y * Spr.WindowDimension.y,
                              50)
                    local Dimension = vec3(
                              inRelativeDimension_3f.x * Spr.WindowDimension.x,
                              inRelativeDimension_3f.y * Spr.WindowDimension.y,
                              1)
                    TitleTextLabel:Update(Position, Dimension, inFont, inText)
          end
          return o
end

Spr.UserInterFaceCreateMainButton = function(inText, inRelativePosition_3f, inRelativeDimension_3f,
                                             inOnClickFunction, inOffset, inColor)
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

          o.PaintBy = function(inPosDimen, inColor, inParam)
                    Spr.UIWid.c.PushOneTime(
                              Jkr.CreateDispatchable(
                                        function()
                                                  Image.BindPainter(Spr.PlaneCShader)
                                                  local PC = Jkr.DefaultCustomImagePainterPushConstant()
                                                  PC.x = inPosDimen
                                                  PC.y = inColor
                                                  PC.z = inParam
                                                  Image.DrawPainter(
                                                            Spr.PlaneCShader,
                                                            PC,
                                                            math.int(Dimension.x),
                                                            math.int(Dimension.y), 1)
                                                  Image.CopyToSampled()
                                        end
                              ), 1)
          end

          Spr.UIWid.c.PushOneTime(
                    Jkr.CreateDispatchable(
                              function()
                                        Image.BindPainter(Spr.PlaneCShader)
                                        local PC = Jkr.DefaultCustomImagePainterPushConstant()
                                        PC.x = vec4(0, 0, 0.8, 0.8)
                                        PC.y = inColor
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
