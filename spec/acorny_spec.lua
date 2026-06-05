local source = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("\\", "/")
local plugin_root = source:match("^(.+)/spec/[^/]+$") or "."
package.path = plugin_root .. "/?.lua;" .. package.path

local acorny = require("acorny_helper")

local function assert_equal(expected, actual)
    assert(expected == actual, string.format("expected %q, got %q", tostring(expected), tostring(actual)))
end

local new_highlight_event = {
    {
        text = "Highlighted text",
        note = "Reader note",
        page = 42,
        datetime = "2026-06-05 12:34:56",
        drawer = "lighten",
        pos0 = { page = 42, x = 10, y = 20 },
        pos1 = { page = 42, x = 30, y = 40 },
    },
    nb_highlights_added = 1,
}

assert(acorny.shouldAutoSync(new_highlight_event))
assert(not acorny.shouldAutoSync({ new_highlight_event[1], nb_highlights_added = -1 }))
assert(not acorny.shouldAutoSync({ { text = "Bookmark", page = 42 }, nb_highlights_added = 1 }))

local payload = acorny.buildHighlightPayload(new_highlight_event[1], {
    title = "KOReader Book",
    author = "Author One\nAuthor Two",
})

assert_equal("Highlighted text", payload.text)
assert_equal("KOReader Book", payload.title)
assert_equal("Author One, Author Two", payload.author)
assert_equal("Reader note", payload.note)
assert_equal(42, payload.location)
assert_equal("order", payload.location_type)
assert_equal("koreader", payload.source_type)
assert_equal("books", payload.category)
assert(payload.highlighted_at:match("^2026%-06%-05T%d%d:%d%d:%d%dZ$"))

local key = acorny.annotationKey(new_highlight_event[1], {
    file = "/books/book.epub",
    title = "KOReader Book",
})
assert(key:find("/books/book.epub", 1, true))
assert(key:find("Highlighted text", 1, true))

print("acorny spec ok")
