local AcornyHelper = {}

local function isPresent(value)
    return value ~= nil and tostring(value) ~= ""
end

local function normalizeAuthor(author)
    if not isPresent(author) then
        return nil
    end
    return tostring(author):gsub("\r\n", "\n"):gsub("\n", ", ")
end

local function getLocation(annotation)
    local page = annotation.pageno or annotation.page
    if type(page) == "table" then
        return page.page
    end
    if page ~= nil then
        return page
    end
    if type(annotation.pos0) == "table" then
        return annotation.pos0.page
    end
end

local function parseLocalDateTime(datetime)
    if type(datetime) == "number" then
        return datetime
    end
    if type(datetime) ~= "string" then
        return nil
    end

    local year, month, day, hour, min, sec = datetime:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)%s+(%d%d):(%d%d):(%d%d)")
    if not year then
        return nil
    end

    return os.time {
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec),
    }
end

local function toIso8601(datetime, now)
    local timestamp = parseLocalDateTime(datetime) or now or os.time()
    return os.date("!%Y-%m-%dT%H:%M:%S", timestamp) .. "Z"
end

local function positionKey(position)
    if type(position) ~= "table" then
        return tostring(position or "")
    end
    return table.concat({
        tostring(position.page or ""),
        tostring(position.x or ""),
        tostring(position.y or ""),
    }, ":")
end

function AcornyHelper.shouldAutoSync(items)
    local item = type(items) == "table" and items[1]
    return items
        and items.nb_highlights_added == 1
        and type(item) == "table"
        and item.drawer ~= nil
        and isPresent(item.text)
        or false
end

function AcornyHelper.buildHighlightPayload(annotation, book, now)
    local title = book and (book.title or book.display_title) or nil
    local author = book and (book.author or book.authors) or nil

    return {
        text = annotation.text,
        title = isPresent(title) and title or "Untitled",
        author = normalizeAuthor(author),
        source_type = "koreader",
        category = "books",
        note = isPresent(annotation.note) and annotation.note or nil,
        location = getLocation(annotation),
        location_type = "order",
        highlighted_at = toIso8601(annotation.datetime, now),
    }
end

function AcornyHelper.annotationKey(annotation, book)
    local file = book and book.file or ""
    local title = book and (book.title or book.display_title) or ""

    return table.concat({
        tostring(file),
        tostring(title),
        tostring(getLocation(annotation) or ""),
        positionKey(annotation.pos0),
        positionKey(annotation.pos1),
        tostring(annotation.datetime or ""),
        tostring(annotation.text or ""),
    }, " | ")
end

return AcornyHelper
