--[[ RESOURCES ]]

---Addon namespace
---@class ns
local addonNameSpace, ns = ...

--Addon root folder
local root = "Interface/AddOns/" .. addonNameSpace .. "/"


--[[ CHANGELOG ]]

local changelogDB = {
	{
		"#V_Version 1.0_# #H_(10/26/2020)_#",
		"#H_It's alive!_#",
	},
}

---Get an assembled & formatted string of the full changelog
---@param latest? boolean Whether to get the update notes of the latest version or the entire changelog | ***Default:*** false
---@return string
ns.GetChangelog = function(latest)
	--Colors
	local highlight = "FFFFFFFF"
	local new = "FF66EE66"
	local fix = "FFEE4444"
	local change = "FF8888EE"
	local note = "FFEEEE66"

	--Assemble the changelog
	local changelog = ""
		for i = #changelogDB, 1, -1 do
			local firstLine = latest and 2 or 1
			for j = firstLine, #changelogDB[i] do
				changelog = changelog .. (j > firstLine and "\n\n" or "") .. changelogDB[i][j]:gsub(
					"#V_(.-)_#", (i < #changelogDB and "\n\n\n" or "") .. "|c" .. highlight .. "• %1|r"
				):gsub(
					"#N_(.-)_#", "|c".. new .. "%1|r"
				):gsub(
					"#F_(.-)_#", "|c".. fix .. "%1|r"
				):gsub(
					"#C_(.-)_#", "|c".. change .. "%1|r"
				):gsub(
					"#O_(.-)_#", "|c".. note .. "%1|r"
				):gsub(
					"#H_(.-)_#", "|c".. highlight .. "%1|r"
				)
			end
			if latest then break end
		end
	return changelog
end


--[[ LOCALIZATIONS ]]

--# flags will be replaced with code
--\n represents the newline character

local english = {
	options = {
		main = {
			name = "Main page",
			description = "Customize #ADDON to fit your needs. Type #KEYWORD for chat commands.",
			shortcuts = {
				title = "Shortcuts",
				description = "Access specific options by expanding the #ADDON categories on the left or by clicking a button here.",
			},
			about = {
				title = "About",
				description = "Thanks for using #ADDON! Copy the links to see how to share feedback, get help & support development.",
				version = "Version",
				date = "Date",
				author = "Author",
				license = "License",
				curseForge = "CurseForge Page",
				wago = "Wago Page",
				repository = "GitHub Repository",
				issues = "Issues & Feedback",
				changelog = {
					label = "Update Notes",
					tooltip = "Notes of all the changes, updates & fixes introduced with the latest version.\n\nThe changelog is only available in English for now.",
				},
				openFullChangelog = {
					label = "Open the full Changelog",
					tooltip = "Access the full list of update notes of all addon versions.",
				},
				fullChangelog = {
					label = "#ADDON Changelog",
					tooltip = "Notes of all the changes included in the addon updates for all versions.\n\nThe changelog is only available in English for now.",
				},
			},
			sponsors = {
				title = "Sponsors",
				description = "Your continued support is greatly appreciated! Thank you!",
			},
		},
		display = {
			title = "Display",
			description = "Customize the main #ADDON display where you view your screenshots.",
			position = {
				title = "Position",
				description = "Drag & drop the display while holding SHIFT to position it anywhere on the screen, fine-tune it here.",
				anchor = {
					label = "Screen Anchor Point",
					tooltip = "Select which point of the screen should the display be anchored to.",
				},
				xOffset = {
					label = "Horizontal Offset",
					tooltip = "Set the amount of horizontal offset (X axis) of the display from the selected #ANCHOR.",
				},
				yOffset = {
					label = "Vertical Offset",
					tooltip = "Set the amount of vertical offset (Y axis) of the display from the selected #ANCHOR.",
				},
				strata = {
					label = "Screen Layer",
					tooltip = "Raise or lower the display to be in front of or behind other UI elements.",
				},
			},
		},
		specifications = {
			title = "Specifications",
			description = "Addon specs.",
			enabled = {
				label = "Enable Functionality",
				tooltip = "Enable the addon functionality.",
			},
		},
		advanced = {
			title = "Advanced",
			description = "Configure #ADDON settings further, change options manually or backup your data by importing, exporting settings.",
			profiles = {
				title = "Profiles",
				description = "Create, edit and apply unique options profiles to customize #ADDON separately between your characters. (Soon™)", --# flags will be replaced with
			},
			backup = {
				title = "Backup",
				description = "Import or export #ADDON options to save, share or apply them between your accounts.",
				backupBox = {
					label = "Import & Export",
					tooltip = {
						"The backup string in this box contains the currently saved addon data and frame positions.",
						"Copy it to save, share or use it for another account.",
						"If you have a string, just override the text inside this box. Select it, and paste your string here. Press ENTER to load the data stored in it.",
						"Note: If you are using a custom font file, that file can not carry over with this string. It will need to be inserted into the addon folder to be applied.",
						"Only load strings that you have verified yourself or trust the source of!",
					},
				},
				compact = {
					label = "Compact",
					tooltip = "Toggle between a compact and a readable view.",
				},
				load = {
					label = "Load",
					tooltip = "Check the current string, and attempt to load all data from it.",
				},
				reset = {
					label = "Reset",
					tooltip = "Reset the string to reflect the currently stored values.",
				},
				import = "Load the string",
				warning = "Are you sure you want to attempt to load the currently inserted string?\n\nIf you've copied it from an online source or someone else has sent it to you, only load it after you've checked the code inside and you know what you are doing.\n\nIf don't trust the source, you may want to cancel to prevent any unwanted actions.",
				error = "The provided backup string could not be validated and no data was loaded. It might be missing some characters or errors may have been introduced if it was edited.",
			},
		},
	},
	chat = {
		help = {
			thanks = "Thank you for using #ADDON!",
			hint = "Type #HELP_COMMAND to see the full command list.",
			move = "Hold SHIFT to drag the #ADDON display anywhere you like.",
			list = "chat command list",
		},
		options = {
			description = "open the #ADDON options",
		},
		defaults = {
			description = "restore everything to defaults",
			response = "The #CATEGORY options have been reset to defaults.",
		},
		position = {
			save = "The speed display position was saved.",
			cancel = "The repositioning of the speed display was cancelled.",
			error = "Hold SHIFT until the mouse button is released to save the position.",
		},
	},
	misc = {
		date = "#MONTH/#DAY/#YEAR",
		options = "Options",
		default = "Default",
		custom = "Custom",
		override = "Override",
		enabled = "enabled",
		disabled = "disabled",
		days = "days",
		hours = "hours",
		minutes = "minutes",
		seconds = "seconds",
	},
}

---Load the proper localization table based on the client language
---@return string
local LoadLocale = function()
	local strings
	local locale = GetLocale()

	if (locale == "") then
		--TODO: Add localization for other languages (locales: https://wowwiki-archive.fandom.com/wiki/API_GetLocale#Locales)
		--Different font locales: https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/Fonts.xml
	else --Default: English (UK & US)
		strings = english
		strings.defaultFont = UNIT_NAME_FONT_ROMAN:gsub("\\", "/")
	end

	--Fill static & internal references
	strings.options.main.description = strings.options.main.description:gsub("#KEYWORD", "/" .. ns.chat.keyword)
	strings.options.display.position.xOffset.tooltip = strings.options.display.position.xOffset.tooltip:gsub("#ANCHOR", strings.options.display.position.anchor.label)
	strings.options.display.position.yOffset.tooltip = strings.options.display.position.yOffset.tooltip:gsub("#ANCHOR", strings.options.display.position.anchor.label)

	--Set screenshot file name format
	strings.scr = "WoWScrnShot_#DATE.#TYPE"

	return strings
end


--[[ ASSETS ]]

--Chat commands
ns.chat = {
	keyword = "scrvr",
	commands = {
		help = "help",
		options = "options",
		defaults = "defaults",
	}
}

--Strings
ns.strings = LoadLocale()

--Colors
ns.colors = {
	grey = {
		{ r = 0.54, g = 0.54, b = 0.54 },
		{ r = 0.7, g = 0.7, b = 0.7 },
	},
	yellow = {
		{ r = 1, g = 0.87, b = 0.28 },
		{ r = 1, g = 0.98, b = 0.60 },
	},
	green = {
		{ r = 0.31, g = 0.85, b = 0.21 },
		{ r = 0.56, g = 0.91, b = 0.49 },
	},
	blue = {
		{ r = 0.33, g = 0.69, b = 0.91 },
		{ r = 0.62, g = 0.83, b = 0.96 },
	},
}

--Textures
ns.textures = {
	logo = root .. "Textures/Logo.tga",
}