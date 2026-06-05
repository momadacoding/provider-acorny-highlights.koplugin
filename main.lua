local Provider = require("provider")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local UIManager = require("ui/uimanager")
local NetworkMgr = require("ui/network/manager")
local Notification = require("ui/widget/notification")
local logger = require("logger")
local _ = require("gettext")

local AcornyExporter = require("acorny")
local AcornyHelper = require("acorny_helper")

local AcornyProvider = WidgetContainer:extend {
    name = "provider-acorny-highlights",
    is_doc_only = false,
}

local function getAcornySettings()
    local exporter_settings = G_reader_settings:readSetting("exporter") or {}
    exporter_settings.acorny = exporter_settings.acorny or {}
    return exporter_settings.acorny, exporter_settings
end

local function saveAcornySettings(settings, exporter_settings)
    exporter_settings.acorny = settings
    G_reader_settings:saveSetting("exporter", exporter_settings)
end

local function listContains(list, value)
    for _, item in ipairs(list or {}) do
        if item == value then
            return true
        end
    end
    return false
end

local function markSynced(settings, key)
    settings.synced_highlights = settings.synced_highlights or {}
    if listContains(settings.synced_highlights, key) then
        return
    end

    table.insert(settings.synced_highlights, key)
    while #settings.synced_highlights > 200 do
        table.remove(settings.synced_highlights, 1)
    end
end

local function removePending(settings, uploaded_keys)
    local uploaded = {}
    for _, key in ipairs(uploaded_keys) do
        uploaded[key] = true
    end

    local remaining = {}
    for _, queued in ipairs(settings.pending_highlights or {}) do
        if not uploaded[queued.key] then
            table.insert(remaining, queued)
        end
    end
    settings.pending_highlights = remaining
end

function AcornyProvider:init()
    Provider:register("exporter", "acorny", AcornyExporter)
end

function AcornyProvider:getBookInfo()
    local props = self.ui and self.ui.doc_props or {}
    local document = self.ui and self.ui.document

    return {
        file = document and document.file,
        title = props.display_title or props.title,
        author = props.authors,
    }
end

function AcornyProvider:queueHighlight(annotation)
    local settings, exporter_settings = getAcornySettings()
    local book = self:getBookInfo()
    local key = AcornyHelper.annotationKey(annotation, book)

    if listContains(settings.synced_highlights, key) then
        return
    end

    settings.pending_highlights = settings.pending_highlights or {}
    for _, queued in ipairs(settings.pending_highlights) do
        if queued.key == key then
            return
        end
    end

    table.insert(settings.pending_highlights, {
        key = key,
        highlight = AcornyHelper.buildHighlightPayload(annotation, book),
    })
    saveAcornySettings(settings, exporter_settings)
    self:flushQueue()
end

function AcornyProvider:flushQueue()
    local settings, exporter_settings = getAcornySettings()
    if self.is_flushing or not settings.auto_sync or not settings.token or settings.token == "" then
        return
    end
    if not settings.pending_highlights or #settings.pending_highlights == 0 then
        return
    end
    if not NetworkMgr:isOnline() then
        logger.dbg("Acorny: network is offline, queued highlights will sync later")
        return
    end

    local highlights = {}
    local keys = {}
    for _, queued in ipairs(settings.pending_highlights) do
        table.insert(highlights, queued.highlight)
        table.insert(keys, queued.key)
    end

    self.is_flushing = true
    UIManager:nextTick(function()
        AcornyExporter:loadSettings()
        local ok, err = AcornyExporter:createHighlightsFromPayloads(highlights)
        self.is_flushing = false
        if ok then
            local current_settings, current_exporter_settings = getAcornySettings()
            for _, key in ipairs(keys) do
                markSynced(current_settings, key)
            end
            removePending(current_settings, keys)
            saveAcornySettings(current_settings, current_exporter_settings)
            if current_settings.notify_sync then
                Notification:notify(_("Highlights synced to Acorny"))
            end
        else
            logger.warn("Acorny: automatic highlight sync failed", err)
        end
    end)
end

function AcornyProvider:onAnnotationsModified(items)
    if not AcornyHelper.shouldAutoSync(items) then
        return
    end

    local settings = getAcornySettings()
    if settings.auto_sync and settings.token and settings.token ~= "" then
        self:queueHighlight(items[1])
    end
end

function AcornyProvider:onNetworkConnected()
    self:flushQueue()
end

return AcornyProvider
