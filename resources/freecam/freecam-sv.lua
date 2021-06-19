local races = {}
print (GetRegisteredCommands())
-- Racing Handler. Handles the primary logic for racing server side.
-- Citizen.CreateThread(function()
    -- No need to overload the thread, 100ms probably excessively low
--    Citizen.Wait(100)
--
--   for index,race in races do
--
--    end
--end)

--[[ Enter Racing free cam to create waypoints.
RegisterServerEvent('racing-camera:enterfreecam')
AddEventHandler('racing-camera:enterfreecam', function()
    ClearFocus()
    local playerPed = PlayerPedId()
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayFov() * 1.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    SetCamAffectsAiming(cam, false)
end)

-- Exit freecam when done
RegisterServerEvent('racing-camera:exitfreecam')
AddEventHandler('racing-camera:exitfreecam', function()
    ClearFocus()
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
end)--]]

-- Create Race
