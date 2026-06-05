local InputDialog = require("ui/widget/inputdialog")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local logger = require("logger")
local _ = require("gettext")

local AcornyHelper = require("acorny_helper")

local AcornyExporter = require("base"):new {
    name = "acorny",
    is_remote = true,
}

AcornyExporter.endpoint = "https://acorny.io/api/v2/highlights/"

function AcornyExporter:isReadyToExport()
    return self.settings.token ~= nil and self.settings.token ~= ""
end

function AcornyExporter:getMenuTable()
    return {
        text = _("Acorny"),
        checked_func = function() return self:isEnabled() end,
        sub_item_table = {
            {
                text = _("Set authorization token"),
                keep_menu_open = true,
                callback = function()
                    local auth_dialog
                    auth_dialog = InputDialog:new {
                        title = _("Set authorization token for Acorny"),
                        input = self.settings.token,
                        text_type = "password",
                        buttons = {
                            {
                                {
                                    text = _("Cancel"),
                                    callback = function()
                                        UIManager:close(auth_dialog)
                                    end
                                },
                                {
                                    text = _("Set token"),
                                    callback = function()
                                        self.settings.token = auth_dialog:getInputText()
                                        self:saveSettings()
                                        UIManager:close(auth_dialog)
                                    end
                                },
                            },
                        },
                    }
                    UIManager:show(auth_dialog)
                    auth_dialog:onShowKeyboard()
                end,
            },
            {
                text = _("Export to Acorny"),
                enabled_func = function() return self:isReadyToExport() end,
                checked_func = function() return self:isEnabled() end,
                callback = function() self:toggleEnabled() end,
            },
            {
                text = _("Automatically sync new highlights"),
                enabled_func = function() return self:isReadyToExport() end,
                checked_func = function() return self.settings.auto_sync == true end,
                callback = function()
                    self.settings.auto_sync = not self.settings.auto_sync
                    self:saveSettings()
                end,
            },
            {
                text = _("Show sync notifications"),
                checked_func = function() return self.settings.notify_sync == true end,
                callback = function()
                    self.settings.notify_sync = not self.settings.notify_sync
                    self:saveSettings()
                end,
            },
            {
                text = _("Help"),
                keep_menu_open = true,
                callback = function()
                    UIManager:show(InfoMessage:new {
                        text = _([[To sync highlights to Acorny, sign in to Acorny and open Settings > Import API tokens. Create a token, copy it immediately, then paste it here with "Set authorization token". Enable "Automatically sync new highlights" to upload new KOReader highlights when network is available.]])
                    })
                end,
            },
        },
    }
end

function AcornyExporter:createHighlightsFromPayloads(highlights)
    if not self:isReadyToExport() then
        return false, "Acorny token is not configured"
    end
    if #highlights == 0 then
        return true
    end

    local result, err = self:makeJsonRequest(self.endpoint, "POST", {
        highlights = highlights,
    }, {
        ["Authorization"] = "Token " .. self.settings.token,
    })

    if not result then
        logger.warn("Acorny: error creating highlights", err)
        return false, err
    end
    return true
end

function AcornyExporter:createHighlightFromAnnotation(annotation, book)
    return self:createHighlightsFromPayloads({
        AcornyHelper.buildHighlightPayload(annotation, book),
    })
end

function AcornyExporter:createHighlights(booknotes)
    local highlights = {}
    local book = {
        title = booknotes.title,
        author = booknotes.author,
    }

    for _, chapter in ipairs(booknotes) do
        for _, clipping in ipairs(chapter) do
            table.insert(highlights, {
                text = clipping.text,
                title = book.title,
                author = book.author and book.author ~= "" and book.author:gsub("\n", ", ") or nil,
                source_type = "koreader",
                category = "books",
                note = clipping.note,
                location = clipping.page,
                location_type = "order",
                highlighted_at = os.date("!%Y-%m-%dT%H:%M:%S", clipping.time) .. "Z",
            })
        end
    end

    return self:createHighlightsFromPayloads(highlights)
end

function AcornyExporter:export(booknotes_list)
    if not self:isReadyToExport() then return false end

    for _, booknotes in ipairs(booknotes_list) do
        local ok = self:createHighlights(booknotes)
        if not ok then return false end
    end
    return true
end

return AcornyExporter
