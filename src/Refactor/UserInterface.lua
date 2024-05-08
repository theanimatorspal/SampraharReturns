Spr.UserInterfaceLoad = function()
                    Spr.UIWid = Jkr.CreateWidgetRenderer(Engine.i, Spr.w, Engine.e)
                    Spr.WindowDimension = Spr.w:GetWindowDimension()
                    local FontSize = Jmath.Lerp(16, 50, Spr.WindowDimension.y / 1080)
                    Spr.UINormalFont = Spr.UIWid.CreateFont("res/fonts/font.ttf", math.int(FontSize))
                    Spr.UIWid.CreateTextLabel(vec3(Spr.WindowDimension.x / 2, Spr.WindowDimension.y / 2, 50), vec3(10),
                                        Spr.UINormalFont,
                                        "Hello",
                                        vec4(5))
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
