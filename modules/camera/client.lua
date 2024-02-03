local camera = {}

function camera:create()
    local cam = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 25.0, false, 2)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    ShakeCam(cam, "HAND_SHAKE", 0.1)
    SetCamCoord(cam, 416.4084, -998.3806, -99.24789)
    SetCamRot(cam, 0.878834, -0.022102, 90.0173, 2)
    PointCamAtCoord(cam, 409.08, -998.47, -98.8)
    self.camera = cam
end

function camera:delete()
    local cam = self.camera
    if not cam then return end

    SetCamActive(cam, false)
    RenderScriptCams(false, false, 0, true, true)
    DestroyAllCams(true)
    self.camera = nil
end

return camera
