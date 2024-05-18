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

          print("FONT")
          Spr.UINormalFont = Spr.UIWid.CreateFont(
                    "res/fonts/font.ttf",
                    math.int(NormalFontSize)
          )
          print("FONTLOADED")

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
                    "Samprahar Returns",
                    vec4(5))

          print("hit the cube text label")

          local PlayButtonPosition = vec3(0.2, 0.5, 1)
          local ExitButtonPosition = vec3(0.2, 0.6, 1)
          local MainButtonDimension = vec3(0.12, 0.10, 50)
          local ScoreBoardLinePosition = vec3(0.8, 0.1, 50)
          local ScoreBoardLineDimension = vec3(0.1, 0.05, 1)
          local ScoreBoardHealthPosition = vec3(0.1, 0.1, 50)
          local ScoreBoardHealthDimension = vec3(0.1, 0.05, 1)
          local ScorePosition = vec3(0.5, 0.1, 0)
          local GameOverPosition = vec3(0.6, 0.5, 50)

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
          Spr.DarkGreenColor = vec4(0, 0.4, 0, 0.7)
          local ScoreBoard = Spr.UserInterFaceCreateMainButton(
                    " ",
                    vec3(10, 0, 0),
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
                    vec3(10, 0, 0),
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
          local ScoreIndicatorText = Spr.UserInterfaceCreateRAWLabel("Score: 0", Spr.UISmallFont, vec3(10, 0, 0), vec3(0))
          Spr.SetScoreIndicator = function(inScore)
                    ScoreIndicatorText:Update(ScorePosition, vec3(0), nil, "Score: " .. tostring(inScore))
          end

          -- GAME OVER
          local GameOverText = Spr.UserInterfaceCreateRAWLabel("GAME OVER", Spr.UINormalFont, vec3(10, 0, 0), vec3(0))
          Spr.SetGameOverText = function(inText)
                    GameOverText:Update(GameOverPosition, vec3(0), nil, inText)
          end

          local ButtonDimension = vec3(0.05, 0.1, 2)
          local UpButtonPosition = vec3(0.75, 0.55, 50)
          local DownButtonPosition = vec3(0.75, 0.85, 50)
          local LeftButtonPosition = vec3(0.7, 0.7, 50)
          local RightButtonPosition = vec3(0.8, 0.7, 50)
          local CameraButtonPosition = vec3(0.5, 0.75, 50)
          local FireButtonPosition = vec3(0.05, 0.75, 50)
          local AimButtonPosition = vec3(0.1, 0.75, 50)

          print("Play Exit Plus Socre Buttons")

          local UpButton = Spr.UserInterFaceCreateMainButton(
                    "U",
                    vec3(10, 0, 0),
                    ButtonDimension,
                    function() Spr.MoveCesiumFront() end,
                    0.13,
                    Spr.DarkGreenColor,
                    true
          )

          local DownButton = Spr.UserInterFaceCreateMainButton(
                    "D",
                    vec3(10, 0, 0),
                    ButtonDimension,
                    function()
                              Spr.MoveCesiumBack()
                    end,
                    0.13,
                    Spr.DarkGreenColor,
                    true
          )

          local LeftButton = Spr.UserInterFaceCreateMainButton(
                    "L",
                    vec3(10, 0, 0),
                    ButtonDimension,
                    function()
                              Spr.RotateCesiumLeft()
                    end,
                    0.13,
                    Spr.DarkGreenColor
                    , true
          )

          local RightButton = Spr.UserInterFaceCreateMainButton(
                    "R",
                    vec3(10, 0, 0),
                    ButtonDimension,
                    function()
                              Spr.RotateCesiumRight()
                    end,
                    0.13,
                    Spr.DarkGreenColor
                    , true
          )

          local CameraButton = Spr.UserInterFaceCreateMainButton(
                    "C",
                    vec3(10, 0, 0),
                    ButtonDimension,
                    function()
                              Spr.SwitchCameraView()
                    end,
                    0.13,
                    Spr.DarkGreenColor
          )

          local FireButton = Spr.UserInterFaceCreateMainButton(
                    "F",
                    vec3(10, 0, 0),
                    ButtonDimension,
                    function()
                              Spr.FireEve()
                    end,
                    0.13,
                    Spr.DarkGreenColor
          )

          local AimButton = Spr.UserInterFaceCreateMainButton(
                    "A",
                    vec3(10, 0, 0),
                    ButtonDimension,
                    function()
                              Spr.SwitchFireMode()
                    end,
                    0.13,
                    Spr.DarkGreenColor
          )

          print("All other buttons")

          Spr.PutOnGameOverText = function()
                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = vec3(10, 0, 0), mDimension_3f = vec3(0) },
                              { mPosition_3f = GameOverPosition, mDimension_3f = vec3(0) },
                              GameOverText,
                              0.1
                    )
          end

          Spr.PutOffGameOverText = function()
                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = GameOverPosition, mDimension_3f = vec3(0) },
                              { mPosition_3f = vec3(10, 0, 0), mDimension_3f = vec3(0) },
                              GameOverText,
                              0.1
                    )
          end

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

          Spr.PutOnPlayExitButtons = function()
                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = vec3(3), mDimension_3f = MainButtonDimension },
                              { mPosition_3f = PlayButtonPosition, mDimension_3f = MainButtonDimension },
                              PlayButton,
                              0.1
                    )
                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = vec3(3), mDimension_3f = MainButtonDimension },
                              { mPosition_3f = ExitButtonPosition, mDimension_3f = MainButtonDimension },
                              ExitButton,
                              0.1
                    )

                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = vec3(1000, 0, 5), mDimension_3f = MainButtonDimension },
                              { mPosition_3f = vec3(100, 100, 5), mDimension_3f = MainButtonDimension },
                              TitleTextLabel,
                              0.1
                    )
          end

          Spr.PutOnScoreBoardStuffs = function()
                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = vec3(10, 0, 0), mDimension_3f = ScoreBoardHealthDimension },
                              { mPosition_3f = ScoreBoardHealthPosition, mDimension_3f = ScoreBoardHealthDimension },
                              ScoreBoardHealth,
                              0.1
                    )
                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = vec3(10, 0, 0), mDimension_3f = ScoreBoardLineDimension },
                              { mPosition_3f = ScoreBoardLinePosition, mDimension_3f = ScoreBoardLineDimension },
                              ScoreBoard, -- Power wala
                              0.1
                    )

                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = vec3(10, 0, 0), mDimension_3f = vec3(0) },
                              { mPosition_3f = ScorePosition, mDimension_3f = vec3(0) },
                              ScoreIndicatorText,
                              0.1
                    )

                    function PutStuff(inPosition, inWidget)
                              Jkr.CreateAnimationPosDimen(
                                        Spr.UIWid.c,
                                        { mPosition_3f = vec3(10, 0, 0), mDimension_3f = ButtonDimension },
                                        { mPosition_3f = inPosition, mDimension_3f = ButtonDimension },
                                        inWidget,
                                        0.1
                              )
                    end

                    PutStuff(UpButtonPosition, UpButton)
                    PutStuff(DownButtonPosition, DownButton)
                    PutStuff(LeftButtonPosition, LeftButton)
                    PutStuff(RightButtonPosition, RightButton)
                    PutStuff(CameraButtonPosition, CameraButton)
                    PutStuff(AimButtonPosition, AimButton)
                    PutStuff(FireButtonPosition, FireButton)
          end

          Spr.PutOffScoreBoardStuffs = function()
                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = ScoreBoardHealthPosition, mDimension_3f = ScoreBoardHealthDimension },
                              { mPosition_3f = vec3(10, 0, 0), mDimension_3f = ScoreBoardHealthDimension },
                              ScoreBoardHealth,
                              0.1
                    )
                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = ScoreBoardLinePosition, mDimension_3f = ScoreBoardLineDimension },
                              { mPosition_3f = vec3(10, 0, 0), mDimension_3f = ScoreBoardLineDimension },
                              ScoreBoard, -- Power wala
                              0.1
                    )

                    Jkr.CreateAnimationPosDimen(
                              Spr.UIWid.c,
                              { mPosition_3f = ScorePosition, mDimension_3f = vec3(0) },
                              { mPosition_3f = vec3(10, 0, 0), mDimension_3f = vec3(0) },
                              ScoreIndicatorText,
                              0.1
                    )
                    function PutStuff(inPosition, inWidget)
                              Jkr.CreateAnimationPosDimen(
                                        Spr.UIWid.c,
                                        { mPosition_3f = inPosition, mDimension_3f = ButtonDimension },
                                        { mPosition_3f = vec3(10, 0, 0), mDimension_3f = ButtonDimension },
                                        inWidget,
                                        0.1
                              )
                    end

                    PutStuff(UpButtonPosition, UpButton)
                    PutStuff(DownButtonPosition, DownButton)
                    PutStuff(LeftButtonPosition, LeftButton)
                    PutStuff(RightButtonPosition, RightButton)
                    PutStuff(CameraButtonPosition, CameraButton)
                    PutStuff(AimButtonPosition, AimButton)
                    PutStuff(FireButtonPosition, FireButton)
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
                                             inOnClickFunction, inOffset, inColor, inContinous)
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
          local Offset = 0.1
          if inOffset then
                    Offset = inOffset
          end
          ImagePosition.z = ImagePosition.z + 1
          TextPosition.x = TextPosition.x + Dimension.x * Offset
          TextPosition.y = TextPosition.y + Dimension.y * Offset

          local Button = Spr.UIWid.CreateButton(ImagePosition, Dimension, inOnClickFunction, inContinous)
          local Image = Spr.UIWid.CreateComputeImageLabel(Position, vec3(100, 100, 1))
          Image.sampledImage:Update(Position, Dimension)
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
                                                            math.int(100),
                                                            math.int(100), 1)
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
                                                  math.int(100),
                                                  math.int(100), 1)
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
                    Image.sampledImage:Update(Position, Dimension)
                    Text:Update(TextPosition, Dimension, nil, inText)
                    Button:Update(ImagePosition, Dimension)
          end

          return o
end
