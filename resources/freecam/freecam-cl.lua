local speedLevel = 4.0
local noClipCam = nil
local noClipActive = false
local rayDistance = 1200
local checkpointDiameter = 75.0

RegisterNetEvent('camera:enterfreecam')
AddEventHandler('camera:enterfreecam', function()
    Citizen.CreateThread(function()
        noClipActive = true
        if IsPedInAnyVehicle(PlayerPedId(), false) then 
            noclipEntity = GetVehiclePedIsIn(PlayerPedId(), false) else noclipEntity = PlayerPedId()
        end
        local entityCoords = GetEntityCoords(noclipEntity)
        local entityRotation = GetEntityRotation(noclipEntity)
        local offsetRotX, offsetRotY, offsetRotZ = 0.0, 0.0, 0.0
        local checkPointMarkerAngleRotation = 0
        local checkpointLeft, checkpointRight = nil, nil
        loadCheckpointModels()
        noClipCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", entityCoords, 0.0, 0.0, entityRotation.z, 75.0, true, 2)
        AttachCamToEntity(noClipCam, noclipEntity, 0.0, 0.0, 0.0, true)
        RenderScriptCams(true, false, 3000, true, false)
        SetEntityCollision(noclipEntity, false, false)
        FreezeEntityPosition(noclipEntity, true)
        SetEntityInvincible(noclipEntity, true)
        SetEntityVisible(noclipEntity, false)
        SetVehicleRadioEnabled(noclipEntity, false)
        ClearPedTasksImmediately(noclipEntity)
        SetEntityAlpha(noclipEntity, 0)
        checkpointMarkers = {}
        mapBlips = {}

        while true do
            Citizen.Wait(1)
            local yOffset, zOffset = 0.0, 0.0
            local rv, fv, uv, campos = GetCamMatrix(noClipCam)
            local rayFlag = 1 -- 1 for map, 2 for vehicles, 4 and 8 peds, 16 objects
            local destPosition = vector3(campos.x + fv.x * rayDistance, campos.y + fv.y * rayDistance, campos.z + fv.z * rayDistance)
            local rayHandle = StartShapeTestRay(campos.x, campos.y, campos.z, destPosition.x, destPosition.y, destPosition.z, rayFlag, GetPlayerPed(), 0)
            local rayResult, hit, hitPoint, hitNormal, hitEntity = GetShapeTestResult(rayHandle)
            --DrawText3Ds(campos, "dis show?")
            if hitPoint ~= nil then
                local model = #checkpointMarkers == 0 and 'prop_beachflag_01' or 'prop_offroad_tyres02'
                local blipSprite = #mapBlips == 0 and 38 or 1
                DrawMarker(27,hitPoint.x,hitPoint.y,hitPoint.z + 0.5,0,0,0,0,0,0,checkpointDiameter,checkpointDiameter,0.3001,255,255,255,255,0,0,0,0)
                DeleteObject(checkpointLeft)
                DeleteObject(checkpointRight)

                local radius = checkpointDiameter / 2
                local leftCoords = vector3(hitPoint.x-radius,hitPoint.y,hitPoint.z)
                local rightCoords = vector3(hitPoint.x+radius,hitPoint.y,hitPoint.z)
                if (IsControlPressed(1, Config.CONTROLS.keyboard.rollLeft)) then
                    checkPointMarkerAngleRotation = checkPointMarkerAngleRotation - 30
                end
                if (IsControlPressed(1, Config.CONTROLS.keyboard.rollRight)) then
                    checkPointMarkerAngleRotation = checkPointMarkerAngleRotation + 30
                end
                rightCoords = vector3(hitPoint.x + Cos(checkPointMarkerAngleRotation * math.pi/180)*radius, hitPoint.y - Sin(checkPointMarkerAngleRotation * math.pi/180)*radius, hitPoint.z)
                leftCoords = vector3(hitPoint.x - Cos(checkPointMarkerAngleRotation * math.pi/180)*radius, hitPoint.y + Sin(checkPointMarkerAngleRotation * math.pi/180)*radius, hitPoint.z)
                checkpointLeft = CreateObject(GetHashKey(model), leftCoords, false, false, false)
                PlaceObjectOnGroundProperly(checkpointLeft)
                SetEntityCollision(checkpointLeft, false, true)
                checkpointRight = CreateObject(GetHashKey(model), rightCoords, false, false, false)
                PlaceObjectOnGroundProperly(checkpointRight)
                SetEntityCollision(checkpointRight, false, true)
                if IsControlJustPressed(0,Config.CONTROLS.keyboard.leftMouse) then                      
                        local checkpointLeft = CreateObject(GetHashKey(model), leftCoords, false, false, false)
                        local checkpointRight = CreateObject(GetHashKey(model), rightCoords, false, false, false)
                        local blipIndex = #mapBlips+1
                        checkpointMarkers[#checkpointMarkers+1] = {
                          left = checkpointLeft,
                          right = checkpointRight
                        }
                        PlaceObjectOnGroundProperly(checkpointLeft)
                        SetEntityAsMissionEntity(checkpointLeft)
                        PlaceObjectOnGroundProperly(checkpointRight)
                        SetEntityAsMissionEntity(checkpointRight)
                        mapBlips[blipIndex] = AddBlipForCoord(hitPoint.x, hitPoint.y, hitPoint.z)
                        SetBlipSprite(mapBlips[blipIndex], blipSprite)
                        SetBlipColour(mapBlips[blipIndex], 17) -- orange
                        SetBlipDisplay(mapBlips[blipIndex], 2) -- map and minimap
                        ShowNumberOnBlip(mapBlips[blipIndex], blipIndex)
                end
            end
            
            if IsControlPressed(0, Config.CONTROLS.keyboard.hold) then
                if IsControlJustPressed(0, Config.CONTROLS.keyboard.zoomIn) then 
                    if speedLevel < 20.0 then speedLevel = speedLevel + 0.5 end
                end
                if IsControlJustPressed(0, Config.CONTROLS.keyboard.zoomOut) then 
                    if speedLevel > 4.0 then speedLevel = speedLevel - 0.5 end
                end
                TriggerEvent("DoLongHudText","CamSpeed: " .. speedLevel,1)
            else
                if (IsControlPressed(1, Config.CONTROLS.keyboard.zoomIn)) then
                    if ((checkpointDiameter + 1.0) < 75.0) then checkpointDiameter = checkpointDiameter + 1.0 else checkpointDiameter = 75.0 end
                end
                if (IsControlPressed(1, Config.CONTROLS.keyboard.zoomOut)) then
                    if ((checkpointDiameter - 1.0) > 15.0) then checkpointDiameter = checkpointDiameter - 1.0 else checkpointDiameter = 15.0 end
                end
            end
            -- Movement controls
            -- Dont use z from moveVectors, makes navigating the cam easier (for purposes of race creation)
            if IsControlPressed(0, Config.CONTROLS.keyboard.forwards) then
                local moveVector = GetEntityCoords(noclipEntity) + fv * (speedLevel * Config.MOVE_DISTANCE.y)
                SetEntityCoordsNoOffset(noclipEntity, vector3(moveVector.x, moveVector.y, campos.z))
                print()
            end
            if IsControlPressed(0, Config.CONTROLS.keyboard.backwards) then 
                local moveVector = GetEntityCoords(noclipEntity) - fv * (speedLevel * Config.MOVE_DISTANCE.y)
                SetEntityCoordsNoOffset(noclipEntity, vector3(moveVector.x, moveVector.y, campos.z))
            end
            if IsControlPressed(0, Config.CONTROLS.keyboard.left) then
                local moveVector = GetEntityCoords(noclipEntity) - rv * (speedLevel * Config.MOVE_DISTANCE.x)
                SetEntityCoordsNoOffset(noclipEntity, vector3(moveVector.x, moveVector.y, campos.z))
            end
            if IsControlPressed(0, Config.CONTROLS.keyboard.right) then
                local moveVector = GetEntityCoords(noclipEntity) + rv * (speedLevel * Config.MOVE_DISTANCE.x)
                SetEntityCoordsNoOffset(noclipEntity, vector3(moveVector.x, moveVector.y, campos.z))
            end
            if IsControlPressed(0, Config.CONTROLS.keyboard.upArrow) then SetEntityCoordsNoOffset(noclipEntity, GetEntityCoords(noclipEntity) + uv * (speedLevel * Config.MOVE_DISTANCE.z)) end
            if IsControlPressed(0, Config.CONTROLS.keyboard.downArrow) then SetEntityCoordsNoOffset(noclipEntity, GetEntityCoords(noclipEntity) - uv * (speedLevel * Config.MOVE_DISTANCE.z)) end
            -- Cam rotation

            SetCamRot(noClipCam, offsetRotX, offsetRotY, offsetRotZ, 2)
            SetEntityHeading(noclipEntity, (360 + offsetRotZ) % 360.0)
            offsetRotX = offsetRotX - (GetControlNormal(1, 2) * 8.0)
            offsetRotZ = offsetRotZ - (GetControlNormal(1, 1) * 8.0)
            if not noClipActive then
                return
            end
        end
    end)
end)

-- Exit freecam when done
RegisterNetEvent('camera:exitfreecam')
AddEventHandler('camera:exitfreecam', function()
    if noClipCam ~= nil then
        DestroyCam(noClipCam, false)
        noClipCam = nil
        noClipActive = false
        RenderScriptCams(false, false, 3000, true, false)
        FreezeEntityPosition(noclipEntity, false)
        SetEntityCollision(noclipEntity, true, true)
        SetEntityAlpha(noclipEntity, 255)
        SetPedCanRagdoll(noclipEntity, true)
        SetEntityVisible(noclipEntity, true)
        ClearPedTasksImmediately(noclipEntity)
        SetEntityVisible(noclipEntity, true)
    end
end)

function loadCheckpointModels()
    local models = {}
    models[1] = "prop_offroad_tyres02"
    models[2] = "prop_beachflag_01"
    for i = 1, #models do
      local checkpointModel = GetHashKey(models[i])
      RequestModel(checkpointModel)
      while not HasModelLoaded(checkpointModel) do
        Citizen.Wait(1)
      end
    end
end


function drawPreviewCheckpoints(lastHitpointWasNull, hitPoint, checkpointLeft, checkpointRight, checkpointDiameter)
    if lastHitpointWasNull or (hitPoint.x ~= lastHitpoint.x or hitPoint.y ~= lastHitpoint.y or hitPoint.z ~= lastHitpoint.z) then
        DeleteObject(checkpointLeft)
        DeleteObject(checkpointRight)
        local leftCoords = vector3(hitPoint.x-checkpointDiameter/2,hitPoint.y,hitPoint.z)
        local rightCoords = vector3(hitPoint.x+checkpointDiameter/2,hitPoint.y,hitPoint.z)
        checkpointLeft = CreateObject(GetHashKey(model), leftCoords, false, false, false)
        checkpointRight = CreateObject(GetHashKey(model), rightCoords, false, false, false)
        PlaceObjectOnGroundProperly(checkpointLeft)
        PlaceObjectOnGroundProperly(checkpointRight)
        print('entity reassign happens')
        lastHitpointWasNull = false
    end
end

function DrawText3Ds(camCoords, text)
    local onScreen,_x,_y=World3dToScreen2d(camCoords.x,camCoords.y,camCoords.z)
    local px,py,pz=table.unpack(camCoords)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function loadCheckpointModels()
    local models = {}
    models[1] = "prop_offroad_tyres02"
    models[2] = "prop_beachflag_01"
    for i = 1, #models do
      local checkpointModel = GetHashKey(models[i])
      RequestModel(checkpointModel)
      while not HasModelLoaded(checkpointModel) do
        Citizen.Wait(1)
      end
    end
end



  
--   function addCheckpointMarker(leftMarker, rightMarker)
--     local model = #checkpointMarkers == 0 and 'prop_beachflag_01' or 'prop_offroad_tyres02'
  
--     local checkpointLeft = CreateObject(GetHashKey(model), leftMarker, false, false, false)
--     local checkpointRight = CreateObject(GetHashKey(model), rightMarker, false, false, false)
--     checkpointMarkers[#checkpointMarkers+1] = {
--       left = checkpointLeft,
--       right = checkpointRight
--     }
--     PlaceObjectOnGroundProperly(checkpointLeft)
--     --SetEntityAsMissionEntity(checkpointLeft)
--     PlaceObjectOnGroundProperly(checkpointRight)
--     --SetEntityAsMissionEntity(checkpointRight)
--   end