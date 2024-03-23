require 'lib.moonloader'
local sampev = require "samp.events"
local dlstatus = require('moonloader').download_status
local script_version = 201 --201
local update_state = false

local script_path = thisScript().path
local script_url = 'https://raw.githubusercontent.com/Riyso/TDM-Tools/main/TDM-Tools.lua'
local update_path = getWorkingDirectory() .. '/tdm_update.ini'
local update_url = 'https://raw.githubusercontent.com/Riyso/TDM-Tools/main/tdm_update.ini'

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	repeat wait(100) until isSampAvailable()
	sampRegisterChatCommand("asmenu", ASGH)
	sampRegisterChatCommand("aschat", chaT)
	downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            local tm_update = inicfg.load(nil, update_path)
            if tonumber(tm_update.info.version) > script_version then
            	sampAddChatMessage("�������� ����������, ����������!", -1)
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
                	sampAddChatMessage("���������� �����������!")
                    thisScript():reload()
                end
            end)
            break
        end
    end
end

function ASGH() -- ������ ��� �������� �������\n������� �������\n����������\n� �������\n����������� ���������\n����������
	sampShowDialog(1999, "{F08080}* ASGH", string.format("{FFFFFF}������ ��� �������� �������\n������ ��� �������� �������\n������� �������\n����������\n� �������\n����������� ���������\n����������"), "�����", "������", 2)
end

function chaT()
	for i = 1, 94 do sampAddChatMessage('', -1) end
	sampAddChatMessage("{ffffff}*{f08080} [ ASGH ]:{FFFFFF} �� �������� ���� ���", 0xf08080)
end