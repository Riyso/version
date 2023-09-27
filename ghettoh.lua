script_name('Autoupdate script') -- название скрипта
script_author('FORMYS') -- автор скрипта
script_description('Autoupdate') -- описание скрипта

require "lib.moonloader" -- подключение библиотеки
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local keys = require "vkeys"
local imgui = require 'imgui'
local encoding = require 'encoding'
local sampev = require 'lib.samp.events'
local weapon = require 'game.weapons'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local bodyparts = {"Торс", "Пах", "Левая рука", "Правая рука", "Левая нога", "Правая нога", "Голова"}
update_state = false

local script_vers = 1
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/Riyso/version/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://raw.githubusercontent.com/Riyso/version/main/ghettoh.lua?raw=true" -- тут свою ссылку
local script_path = thisScript().path

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

	sampRegisterChatCommand("ku", function()
		lua_thread.create(function()
			sampSendChat("/get guns")
			wait(700)
			sampSendChat("/de 160")
		end)
	end)
	sampRegisterChatCommand("kus", function()
		lua_thread.create(function()
			sampSendChat("/get guns")
			wait(700)
			sampSendChat("/m4 160")
		end)
	end)
	--[[sampRegisterChatCommand("unloading", function()
		printStyledString('~w~van is unloaded~n~~y~Respect +', 3000, 1)
		return true
	end)]]--
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
            if isKeyDown(18) and isKeyJustPressed(88) and not sampIsChatInputActive() and not sampIsDialogActive() then -- Alt + X
                sampAddChatMessage(string.format("Последнее попадание: {CCCCCC}%s[%d] | %s | -%d HP | %s | %s", sampGetPlayerNickname(last_damage.playerid), last_damage.playerid, weapon.get_name(last_damage.weapon), math.round(last_damage.damage, 2), bodyparts[last_damage.bodypart - 2], os.date("%X")), 0xFF9000)
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
    end
end

function cmd_update(arg)
    sampShowDialog(1000, "Автообновление v1.01", "{FFFFFF}Это урок по обновлению\n{ffaa11}Новая версия", "Закрыть", "", 0)
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