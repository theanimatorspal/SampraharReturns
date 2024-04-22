function LoadResources(mt)
          local function Compile1()
                    mtWorld3d:AddSimple3D(mtI, mtW)
                    simple3d = mtWorld3d:GetSimple3D(0)
                    simple3d:Compile(mtI, mtW, "res/cache/simple3d.glsl", mtGetDefaultResource("Simple3D", "Vertex"),
                              mtGetDefaultResource("Simple3D", "Fragment"), mtGetDefaultResource("Simple3D", "Compute"),
                              false)
          end
          local function Load()
                    mtWorld3d:BuildDemo()
          end
          mt:AddJobF(Compile1)
          mt:AddJobF(Load)
end
