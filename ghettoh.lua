script_name("ghettoh")
script_version("1.5")

require "lib.moonloader" -- подключение библиотеки
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local vkeys, keys = require "vkeys"
local imgui = require 'imgui'
local encoding = require 'encoding'
local sampev = require 'lib.samp.events'
local bNotf, notf = pcall(import, "lib\\imgui_notf.lua")
local weapon = require 'game.weapons'
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false

local script_vers = 1
local script_vers_text = "1.5"

local update_url = "https://raw.githubusercontent.com/Riyso/version/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://raw.githubusercontent.com/Riyso/version/main/ghettoh.lua?raw=true" -- тут свою ссылку
local script_path = thisScript().path

font = renderCreateFont("Tahoma", 10, FCR_BOLD + FCR_BORDER)
local bodyparts = {"Торс", "Пах", "Левая рука", "Правая рука", "Левая нога", "Правая нога", "Голова"}

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

	sampRegisterChatCommand("update", cmd_update)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)
	
	downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)

    while true do wait(0)
        if last_damage then
            if isKeyJustPressed(18) and not sampIsChatInputActive() and not sampIsDialogActive() then -- Alt + X
                --sampAddChatMessage(string.format("Последнее попадание: {CCCCCC}%s[%d] | %s | -%d HP | %s | %s", sampGetPlayerNickname(last_damage.playerid), last_damage.playerid, weapon.get_name(last_damage.weapon), math.round(last_damage.damage, 2), bodyparts[last_damage.bodypart - 2], os.date("%X")), 0xFF9000)
				if bNotf then
					notf.addNotification(string.format("Последнее попадание: {CCCCCC}%s[%d] | %s | -%d HP | %s | %s", sampGetPlayerNickname(last_damage.playerid), last_damage.playerid, weapon.get_name(last_damage.weapon), math.round(last_damage.damage, 2), bodyparts[last_damage.bodypart - 2], os.date("%X")), 4, 2)
				end
				last_damage = nil
            end
        end
		if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", -1)
                    thisScript():reload()
                end
            end)
            break
        end
		if isKeyDown(VK_MENU) and isKeyDown(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive()  then
            local X, Y = getScreenResolution()
            renderFigure2D(X/2, Y/2, 50, 200, 0xFFFF8C00)
            local x, y, z = getCharCoordinates(PLAYER_PED)
            local posX, posY = convert3DCoordsToScreen(x, y, z)
            renderDrawPolygon(X/2, Y/2, 7, 7, 40, 0, -1)
            local player = getNearCharToCenter(200)
            if player then
                local playerId = select(2, sampGetPlayerIdByCharHandle(player))
                local playerNick = sampGetPlayerNickname(playerId)
                local x2, y2, z2 = getCharCoordinates(player)
                local isScreen = isPointOnScreen(x2, y2, z2, 200)
                if isScreen then
                    local posX2, posY2 = convert3DCoordsToScreen(x2, y2, z2)
                    renderDrawLine(posX, posY - 50, posX2, posY2, 2.0, 0xFF00FFFF)
                    renderDrawPolygon(posX2, posY2, 10, 10, 40, 0, 0xFF00FFFF)
                    local distance = math.floor(getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
                    renderFontDrawTextAlign(font, string.format('%s[%d]', playerNick, playerId),posX2, posY2-30, 0xFF00FFFF, 2)
                    renderFontDrawTextAlign(font, string.format('Дистанция: %s', distance),X/2, Y/2+210, 0xFFFF8C00, 2)
                    renderFontDrawTextAlign(font, '{FF8C00}1 - Отблагодарить\n2 - Передать паспорт\n3 - Передать ключи\n4 - Извиниться',X/2+210, Y/2-30, -1, 1)
                    if isKeyJustPressed(VK_1) then
                        sampSendChat('/sms '..playerId..' sps')
                    end
                    if isKeyJustPressed(VK_2) then
                        sampSendChat('/showpass '..playerId)
                    end
                    if isKeyJustPressed(VK_3) then
                        sampSendChat('/givelock '..playerId)
                    end
                    if isKeyJustPressed(VK_4) then
                        sampSendChat('/sms '..playerId..' соррян')
                    end
                end
            end
        end
    end
end

function cmd_update(arg)
    sampShowDialog(1000, "Автообновление v1.5", "{ff8c00}Новая версия", "Закрыть", "", 0)
end

function renderFigure2D(x, y, points, radius, color)
    local step = math.pi * 2 / points
    local render_start, render_end = {}, {}
    for i = 0, math.pi * 2, step do
        render_start[1] = radius * math.cos(i) + x
        render_start[2] = radius * math.sin(i) + y
        render_end[1] = radius * math.cos(i + step) + x
        render_end[2] = radius * math.sin(i + step) + y
        renderDrawLine(render_start[1], render_start[2], render_end[1], render_end[2], 1, color)
    end
end

function getNearCharToCenter(radius)
    local arr = {}
    local sx, sy = getScreenResolution()
    for _, player in ipairs(getAllChars()) do
        if select(1, sampGetPlayerIdByCharHandle(player)) and isCharOnScreen(player) and player ~= playerPed then
            local plX, plY, plZ = getCharCoordinates(player)
            local cX, cY = convert3DCoordsToScreen(plX, plY, plZ)
            local distBetween2d = getDistanceBetweenCoords2d(sx / 2, sy / 2, cX, cY)
            if distBetween2d <= tonumber(radius and radius or sx) then
                table.insert(arr, {distBetween2d, player})
            end
        end
    end
    if #arr > 0 then
        table.sort(arr, function(a, b) return (a[1] < b[1]) end)
        return arr[1][2]
    end
    return nil
end

function renderFontDrawTextAlign(font, text, x, y, color, align)
    if not align or align == 1 then -- слева
        renderFontDrawText(font, text, x, y, color)
    end
  
    if align == 2 then -- по центру
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text) / 2, y, color)
    end
  
    if align == 3 then -- справа
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text), y, color)
    end
end

function sampev.onSendTakeDamage(playerid, damage, weapon, bodypart)
    if sampIsPlayerConnected(playerid) then -- если урон получен от игрока
        last_damage = {playerid = playerid, damage = damage, weapon = weapon, bodypart = bodypart}
    end
end

math.round = function(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end