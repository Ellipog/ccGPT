local request = http.get("https://example.tweaked.cc")
print(request.readAll())

request.close()

local response = http.post("https://cc-gpt-beta.vercel.app/chat", "hello chatgpt")
print(response.readAll())

response.close()

