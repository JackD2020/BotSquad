
BotSquad = {
	Locales = {},
}

local _usedLocale
function BotSquad.InitLocale()
	_usedLocale = BotSquad.Locales[GetLocale()]
end

function BotSquad.I18n(text)
	if _usedLocale then
		return _usedLocale[text] or text
	else
		return text
	end
end
