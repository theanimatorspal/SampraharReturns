MechanicsEvent = function(e, inWorld3d, inmt)

end

MechanicsUpdate = function(e, inWorld3d, inmt)
          local Model = inWorld3d:GetGLTFModel(0)
          local Uniform = inWorld3d:GetUniform3D(1)
          local cesiumId = inmt:Get("CesiumId")

          if e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_LEFT) then
                    Uniform:UpdateByGLTFAnimation(Model, 0.1, 0)
                    inWorld3d:SetObjectDelPosition(math.int(cesiumId), vec3(0, 0, 0.1))
          elseif e:IsKeyPressedContinous(Keyboard.SDL_SCANCODE_RIGHT) then
                    inWorld3d:SetObjectDelPosition(math.int(cesiumId), vec3(0, 0, -0.1))
          end
end
