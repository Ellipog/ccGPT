local request = http.get("https://example.tweaked.cc")
print(request.readAll())

request.close()

local message = {
    message = "hbilken openai modell er du"
}

local headers = {
    ["Content-Type"] = "application/json"
}

local response = http.post(
    "https://cc-gpt-beta.vercel.app/chat",
    textutils.serialiseJSON(message),
    headers
)

-- Handle the streaming response
while true do
    local line = response.readLine()
    if not line then break end
    
    if line:match("^data: ") then
        local data = line:sub(6) -- Remove "data: " prefix
        if data == "[DONE]" then
            break
        end
        
        local success, parsed = pcall(textutils.unserialiseJSON, data)
        if success and parsed and parsed.content then
            write(parsed.content)
        end
    end
end

response.close()