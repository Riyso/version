script_name('Autoupdate script') -- название скрипта
script_author('FORMYS') -- автор скрипта
script_description('Autoupdate') -- описание скрипта

local lib = require('lib.moonloader')
local sampev = require('samp.events')
local dlstatus = require('moonloader').download_status

update_state = false

local script_vers = 3
local script_vers_text = "1.06"

local update_url = "https://raw.githubusercontent.com/Riyso/version/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://raw.githubusercontent.com/Riyso/version/main/ASGH.lua" -- тут свою ссылку
local script_path = thisScript().path

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	repeat wait(100) until isSampAvailable()
	sampRegisterChatCommand("asmenu", ASGH)
	sampRegisterChatCommand("aschat", chaT)
    sampRegisterChatCommand("check", function()
        update()
    end)
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
    while true do
		wait(0)
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

function ASGH() -- Раздел для младшего состава\nГорячие клавиши\nИнформация\nО скрипте\nТехническая Поддержка\nПерезапуск
	sampShowDialog(1999, "{F08080}* ASGH", string.format("{FFFFFF}Раздел для старшего состава\nРаздел для младшего состава\nГорячие клавиши\nИнформация\nО скрипте\nТехническая Поддержка\nПерезапуск"), "Выбор", "Отмена", 2)
end

function chaT()
	for i = 1, 94 do sampAddChatMessage('', -1) end
	sampAddChatMessage("{ffffff}*{f08080} [ ASGH ]:{FFFFFF} Вы очистили свой чат", 0xf08080)
end