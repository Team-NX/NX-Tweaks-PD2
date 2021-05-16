NX = NX or {}

NX.mod_path = ModPath
NX.script_path = ModPath .. "scripts/"
NX.locale_path = ModPath .. "locales/"

NX.menu_file = ModPath .. "menu/Menu.json"
NX.settings_file = SavePath .. "NX-Tweaks.json"
NX.locale_file = NX.locale_path .. "en.json"

NX.settings = {
	disable_shaped_charges_during_stealth = true,
	civilians_distinguish_detection = false,
	civilians_display_intimidation = false,
}

NX.prevMusicVolume = 0
NX.prevSfxVolume = 0

-- no BLT, no MenuHelper ):
if not MenuHelper then
	return
end

_, NX.lib = blt.load_native(ModPath .. "NX-Tweaks-Lib.dll")

_G.OnFocusLoss = function()
	-- save current volume levels
	NX.prevMusicVolume = managers.user:get_setting("music_volume")
	NX.prevSfxVolume = managers.user:get_setting("sfx_volume")
	
	-- set the volume levels to zero for music & sfx
	MenuManager:music_volume_changed("music_volume_changed", NX.prevMusicVolume, 0)
	MenuManager:sfx_volume_changed("sfx_volume_changed", NX.prevSfxVolume, 0)
end

_G.OnFocusGain = function()
	-- restore the volume levels for music & sfx
	MenuManager:music_volume_changed("music_volume_changed", 0, NX.prevMusicVolume)
	MenuManager:sfx_volume_changed("sfx_volume_changed", 0, NX.prevSfxVolume)
end

-- Load Settings from JSON
function NX:LoadSettings()
	local file = io.open(NX.settings_file, "r")
	
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			if NX.settings[k] ~= nil then
				NX.settings[k] = v
			end
		end
		
		file:close()
	end
end

-- Save Settings to JSON
function NX:SaveSettings()
	local file = io.open(NX.settings_file, "w")
	
	if file then
		file:write(json.encode(NX.settings or {}))
		file:close()
	end
end

-- Hook LocalizationManager to load locale
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_NX", function()
	local f,err = io.open(NX.locale_file, "r")
	
	if f then
		f:close()
		LocalizationManager:load_localization_file(NX.locale_file)
	end
end)

-- Implement MenuCallbackHandler for Changing Settings
function MenuCallbackHandler:nx_toggle(item)
	local index = item._parameters.name
	
	if NX.settings then
		NX.settings[index] = item:value() == "on"
	end
end

-- Implement MenuCallbackHandler for Saving Settings
function MenuCallbackHandler:nx_save()
	NX:SaveSettings()
end

-- Load Settings and Setup Menu from JSON
NX:LoadSettings()
MenuHelper:LoadFromJsonFile(NX.menu_file, NX, NX.settings)

-- Hook MenuManager to populate options
Hooks:Add("MenuManagerPopulateCustomMenus", "PopulateCustomMenus_NX", function(menu_manager, nodes)
	for k,v in pairs(NX.settings or {}) do
		MenuHelper:AddToggle({
			id = k,
			title = string.format("nx_%s_title", k),
			desc = string.format("nx_%s_desc", k),
			callback = 'nx_toggle',
			value = v,
			default_value = true,
			menu_id = 'nx_opt',
			localized = true
		})
	end
end)
