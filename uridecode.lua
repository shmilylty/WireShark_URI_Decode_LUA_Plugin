local uri_decode = Proto("uri_decode", "Decoded Full HTTP Request URI of ")
local get_full_uri = Field.new("http.request.full_uri")
local get_uri = Field.new("http.request.uri")
local get_method = Field.new("http.request.method")
local get_segments = Field.new("tcp.segments")

function decode_char(hex)
    return string.char(tonumber(hex,16))
end
 
function decode_string(str)
    local output, t = string.gsub(str,"%%(%x%x)",decode_char)
    return output
end

function decode_tw()
    if not gui_enabled() then return end
    tw = TextWindow.new("Decoded Full HTTP Request URI")
    tw:set_editable(true)
    tw:add_button("Decode",function() tw:set(decode_string(tw:get_text())) end)
    tw:add_button("Copy",function() copy_to_clipboard(tw:get_text()) end)
end

function uri_decode.dissector(tvb, pinfo, tree)
    local encoded_full_uri = get_full_uri()
    local encoded_uri = get_uri()
    local method = get_method()
    local segments = get_segments()
    if encoded_full_uri and encoded_uri and method and (not segments) then
        local decoded_full_uri = decode_string(encoded_full_uri.value)
        local subtree = tree:add(uri_decode,tvb(14+20+20,method.len+1+encoded_uri.len))
        subtree:append_text(method.display..": "..decoded_full_uri)
    end
end

register_postdissector(uri_decode)
register_menu("Decode URI",function() decode_tw() end,MENU_TOOLS_UNSORTED)