-------- SETUP LANGUAGES
local loadFile = LoadResourceFile(GetCurrentResourceName(), "/shared/locales/" .. Config.Language .. ".json")
local lang = json.decode(loadFile)

Translate = function(key, ...)
    return lang[key] and string.format(lang[key], ...) or ("NO_TRANSLATION > " .. key)
end

GetTranslations = function()
    return lang
end

--------------------------
