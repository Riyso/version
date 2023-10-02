script_version('2');
local dlstatus = require('moonloader').download_status;
local inicfg = require('inicfg');

local update = {
    tempFilePath = ('%s\\temp-%s.ini'):format(getWorkingDirectory(), thisScript().name),
    infoUrl = 'https://raw.githubusercontent.com/Riyso/version/main/just_a_test.ini',
    message = {
        updateFound = 'Update found! New version: %s',
        updateNotFound = 'Update not found! (Current version: %s)',
        updateCheckError = 'Error checking updates (%s)',
        downloadStart = 'Loading update...',
        downloadFinish = 'Update loaded, reloading!',
        downloadError = 'Error loading update!'
    },
    info = {
        checked = false,
        lastVersion = thisScript().version,
        url = nil
    }
};

function update.download()
    assert(update.info.checked, 'call update.checkForUpdates() first!');
    local tempFileName = thisScript().path:gsub(thisScript().filename, 'update_' .. thisScript().filename);
    sampAddChatMessage(update.message.downloadStart, -1);
    downloadUrlToFile(update.info.url, tempFileName, function(id, status, p1, p2)
        if (status == dlstatus.STATUSEX_ENDDOWNLOAD) then
            sampAddChatMessage(update.message.downloadFinish, -1);
            os.rename(tempFileName, thisScript().path);
            thisScript():reload();
        end
    end);
    return;
end

function update.checkForUpdates()
    downloadUrlToFile(update.infoUrl, update.tempFilePath, function(id, status, p1, p2)
        if (status == dlstatus.STATUSEX_ENDDOWNLOAD) then
            local data = inicfg.load(nil, update.tempFilePath);
            os.remove(update.tempFilePath);
            if (not data) then
                return sampAddChatMessage(update.message.updateCheckError:format('ini == nil'), -1);
            end
            
            if (not data.update.lastVersion or not data.update.url) then
                return sampAddChatMessage(update.message.updateCheckError:format('invalid ini file ("lastVersion" or "url" not found)'), -1);
            end
            update.info = data.update;
            update.info.checked = true;
            if (update.info.lastVersion ~= thisScript().version) then
                sampAddChatMessage(update.message.updateFound:format(update.info.lastVersion), -1);
            end
        end
    end)
end

function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('inicheck', update.checkForUpdates);
    sampRegisterChatCommand('iniupd', update.download);
    wait(-1);
end