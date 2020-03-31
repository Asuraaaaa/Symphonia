local vocalLevel = 2

AddEventHandler('onClientMapStart', function()
	vocalLevel = 2
	NetworkSetTalkerProximity(5.001)
end)

function ShowNotif(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

local keyPressed = false
local once = true
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if once then
			once = false
			NetworkSetVoiceActive(1)
		end

		while IsControlPressed(1, 288) and keyPressed do
			Wait(10)
		end
		if IsControlPressed(1, 288) and not keyPressed then
			keyPressed = true
			vocalLevel = vocalLevel + 1
			if vocalLevel > 3 then
				vocalLevel = 1
			end
			--if vocalLevel < 1 then
			--	vocalLevel = 3
			--end

			if vocalLevel == 1 then
				NetworkSetTalkerProximity(3.001)
				ShowNotif("Le niveau de votre voix a été réglé sur ~b~chuchoter")
			elseif vocalLevel == 2 then
				NetworkSetTalkerProximity(5.001)
				ShowNotif("Le niveau de votre voix a été réglé sur ~g~normal")
			elseif vocalLevel == 3 then
				NetworkSetTalkerProximity(12.091)
				ShowNotif("L'intensité de votre voix a été réglé sur ~r~crier")
			end
			Wait(200)
		elseif not IsControlPressed(1, 288) and keyPressed then
			keyPressed = false
		end
	end
end)

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local t = 0
			for i = 0,256 do
				if(GetPlayerName(i))then
					if(NetworkIsPlayerTalking(i))then
						t = t + 1
						drawTxt(0.520, 0.95 + (t * 0.023), 1.0,1.0,0.4, "" .. GetPlayerName(i), 255, 255, 255, 255)
					end
				end
			end
	end
end)
