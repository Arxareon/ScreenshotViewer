--[[ RESOURCES ]]

---Addon namespace
---@class ns
local addonNameSpace, ns = ...

---WidgetTools toolbox
---@class wt
local wt = ns.WidgetToolbox

--Addon title
local addonTitle = wt.Clear(select(2, GetAddOnInfo(addonNameSpace))):gsub("^%s*(.-)%s*$", "%1")

--Custom Tooltip
ns.tooltip = wt.CreateGameTooltip(addonNameSpace)

--[ Data Tables ]

local db = {} --Account-wide options
local dbc = {} --Character-specific options
local cs --Cross-session account-wide data

--Default values
local dbDefault = {
	display = {
		visibility = {
			autoHide = false,
			statusNotice = true,
		},
		position = {
			anchor = "TOP",
			offset = { x = 0, y = -60 },
		},
		layer = {
			strata = "MEDIUM",
		},
		value = {
			units = { true, false, false },
			fractionals = 0,
			noTrim = false,
		},
		font = {
			family = ns.strings.defaultFont,
			size = 11,
			valueColoring = true,
			color = { r = 1, g = 1, b = 1, a = 1 },
			alignment = "CENTER",
		},
		background = {
			visible = false,
			colors = {
				bg = { r = 0, g = 0, b = 0, a = 0.5 },
				border = { r = 1, g = 1, b = 1, a = 0.4 },
			},
		},
	},
}
local dbcDefault = {
}

--[ References ]

--Local frame references
local frames = {
	display = {},
	options = {
		main = {},
		specifications = {},
		advanced = {
			backup = {},
		},
	},
}


--[[ UTILITIES ]]

--[ Screenshot Handling ]

--Latest screenshot dating
local lastDate1
local lastDate2
local lastDate

---Format a screenshot file name
---@param date string Must be in "MMDDYY_hhmmss" format (when calling [date(...)](https://wowpedia.fandom.com/wiki/API_date), use `"%m%d%y_%H%M%S"` to get this formatting)
---@return string
local function GetScrName(date)
	return ns.strings.scr:gsub("#DATE", date):gsub("#TYPE", GetCVar("screenshotFormat"):gsub("jpeg", "jpg"))
end

---Format a screenshot texture file path
---@param name string name of the texture file (use GetScrName(...) to format)
---@return string
local function GetScrPath(name)
	return "Screenshots/" .. name
end

--Check the last screenshot and  verify its date & time to set its file name
local function FindLastScreenshot()
	frames.display.texture:SetTexture(ns.textures.logo)

	frames.display.texture:SetTexture(GetScrPath(GetScrName(lastDate1)))
	if frames.display.texture:GetTexture() ~= ns.textures.logo then
		lastDate = lastDate1
		return
	end

	frames.display.texture:SetTexture(GetScrPath(GetScrName(lastDate2)))
	if frames.display.texture:GetTexture() ~= ns.textures.logo then
		lastDate = lastDate2
		return
	end

	print("STILL NOT FOUND!")
end


--[ DB Management ]

--Check the validity of the provided key value pair
local function CheckValidity(k, v)
	if type(v) == "number" then
		--Non-negative
		if k == "size" then return v > 0 end
		--Range constraint: 0 - 1
		if k == "r" or k == "g" or k == "b" or k == "a" then return v >= 0 and v <= 1 end
		--Corrupt Anchor Points
		if k == "anchor" then return false end
	end return true
end

--Check & fix the account-wide & character-specific DBs
---@param dbCheck table
---@param dbSample table
---@param dbcCheck table
---@param dbcSample table
local function CheckDBs(dbCheck, dbSample, dbcCheck, dbcSample)
	wt.RemoveEmpty(dbCheck, CheckValidity)
	wt.RemoveEmpty(dbcCheck, CheckValidity)
	wt.AddMissing(dbCheck, dbSample)
	wt.AddMissing(dbcCheck, dbcSample)
	wt.RemoveMismatch(dbCheck, dbSample, {})
	wt.RemoveMismatch(dbcCheck, dbcSample, {})
end


--[[ INTERFACE OPTIONS ]]

--[ Main ]

--Create the widgets
local function CreateAboutInfo(panel)
	--Text: Version
	local version = wt.CreateText({
		parent = panel,
		name = "VersionTitle",
		position = { offset = { x = 16, y = -32 } },
		width = 45,
		text = ns.strings.options.main.about.version .. ":",
		font = "GameFontNormalSmall",
		justify = { h = "RIGHT", },
	})
	wt.CreateText({
		parent = panel,
		name = "Version",
		position = {
			relativeTo = version,
			relativePoint = "TOPRIGHT",
			offset = { x = 5 }
		},
		width = 140,
		text = GetAddOnMetadata(addonNameSpace, "Version"),
		font = "GameFontHighlightSmall",
		justify = { h = "LEFT", },
	})

	--Text: Date
	local date = wt.CreateText({
		parent = panel,
		name = "DateTitle",
		position = {
			relativeTo = version,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		width = 45,
		text = ns.strings.options.main.about.date .. ":",
		font = "GameFontNormalSmall",
		justify = { h = "RIGHT", },
	})
	wt.CreateText({
		parent = panel,
		name = "Date",
		position = {
			relativeTo = date,
			relativePoint = "TOPRIGHT",
			offset = { x = 5 }
		},
		width = 140,
		text = ns.strings.misc.date:gsub(
			"#DAY", GetAddOnMetadata(addonNameSpace, "X-Day")
		):gsub(
			"#MONTH", GetAddOnMetadata(addonNameSpace, "X-Month")
		):gsub(
			"#YEAR", GetAddOnMetadata(addonNameSpace, "X-Year")
		),
		font = "GameFontHighlightSmall",
		justify = { h = "LEFT", },
	})

	--Text: Author
	local author = wt.CreateText({
		parent = panel,
		name = "AuthorTitle",
		position = {
			relativeTo = date,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		width = 45,
		text = ns.strings.options.main.about.author .. ":",
		font = "GameFontNormalSmall",
		justify = { h = "RIGHT", },
	})
	wt.CreateText({
		parent = panel,
		name = "Author",
		position = {
			relativeTo = author,
			relativePoint = "TOPRIGHT",
			offset = { x = 5 }
		},
		width = 140,
		text = GetAddOnMetadata(addonNameSpace, "Author"),
		font = "GameFontHighlightSmall",
		justify = { h = "LEFT", },
	})

	--Text: License
	local license = wt.CreateText({
		parent = panel,
		name = "LicenseTitle",
		position = {
			relativeTo = author,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		width = 45,
		text = ns.strings.options.main.about.license .. ":",
		font = "GameFontNormalSmall",
		justify = { h = "RIGHT", },
	})
	wt.CreateText({
		parent = panel,
		name = "License",
		position = {
			relativeTo = license,
			relativePoint = "TOPRIGHT",
			offset = { x = 5 }
		},
		width = 140,
		text = GetAddOnMetadata(addonNameSpace, "X-License"),
		font = "GameFontHighlightSmall",
		justify = { h = "LEFT", },
	})

	--Copybox: CurseForge
	local curse = wt.CreateCopyBox({
		parent = panel,
		name = "CurseForge",
		title = ns.strings.options.main.about.curseForge .. ":",
		position = {
			relativeTo = license,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -11 }
		},
		size = { width = 190, },
		text = "curseforge.com/wow/addons/screenshot-viewer",
		font = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.8, g = 0.95, b = 1, a = 1 },
	})

	--Copybox: Wago
	local wago = wt.CreateCopyBox({
		parent = panel,
		name = "Wago",
		title = ns.strings.options.main.about.wago .. ":",
		position = {
			relativeTo = curse,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		size = { width = 190, },
		text = "addons.wago.io/addons/screenshot-viewer",
		font = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.8, g = 0.95, b = 1, a = 1 },
	})

	--Copybox: Repository
	local repo = wt.CreateCopyBox({
		parent = panel,
		name = "Repository",
		title = ns.strings.options.main.about.repository .. ":",
		position = {
			relativeTo = wago,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		size = { width = 190, },
		text = "github.com/Arxareon/ScreenshotViewer",
		font = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.8, g = 0.95, b = 1, a = 1 },
	})

	--Copybox: Issues
	wt.CreateCopyBox({
		parent = panel,
		name = "Issues",
		title = ns.strings.options.main.about.issues .. ":",
		position = {
			relativeTo = repo,
			relativePoint = "BOTTOMLEFT",
			offset = { y = -8 }
		},
		size = { width = 190, },
		text = "github.com/Arxareon/ScreenshotViewer/issues",
		font = "GameFontNormalSmall",
		color = { r = 0.6, g = 0.8, b = 1, a = 1 },
		colorOnMouse = { r = 0.8, g = 0.95, b = 1, a = 1 },
	})

	--EditScrollBox: Changelog
	local changelog = wt.CreateEditScrollBox({
		parent = panel,
		name = "Changelog",
		title = ns.strings.options.main.about.changelog.label,
		tooltip = { lines = { { text = ns.strings.options.main.about.changelog.tooltip, }, } },
		arrange = {},
		size = { width = panel:GetWidth() - 225, height = panel:GetHeight() - 42 },
		text = ns.GetChangelog(true),
		font = { normal = "GameFontDisableSmall", },
		color = ns.colors.grey[2],
		readOnly = true,
	})

	--Button: Full changelog
	local changelogFrame
	wt.CreateButton({
		parent = panel,
		name = "OpenFullChangelog",
		title = ns.strings.options.main.about.openFullChangelog.label,
		tooltip = { lines = { { text = ns.strings.options.main.about.openFullChangelog.tooltip, }, } },
		position = {
			anchor = "TOPRIGHT",
			relativeTo = changelog,
			relativePoint = "TOPRIGHT",
			offset = { x = -3, y = 2 }
		},
		size = { width = 176, height = 14 },
		font = {
			normal = "GameFontNormalSmall",
			highlight = "GameFontHighlightSmall",
		},
		events = { OnClick = function()
			if changelogFrame then changelogFrame:Show()
			else
				--Panel: Changelog frame
				changelogFrame = wt.CreatePanel({
					parent = UIParent,
					name = addonNameSpace .. "Changelog",
					append = false,
					title = ns.strings.options.main.about.fullChangelog.label:gsub("#ADDON", addonTitle),
					position = { anchor = "CENTER", },
					keepInBounds = true,
					size = { width = 740, height = 560 },
					background = { color = { a = 0.9 }, },
					initialize = function(windowPanel)
						--EditScrollBox: Full changelog
						wt.CreateEditScrollBox({
							parent = windowPanel,
							name = "FullChangelog",
							title = ns.strings.options.main.about.fullChangelog.label:gsub("#ADDON", addonTitle),
							label = false,
							tooltip = { lines = { { text = ns.strings.options.main.about.fullChangelog.tooltip, }, } },
							arrange = {},
							size = { width = windowPanel:GetWidth() - 32, height = windowPanel:GetHeight() - 88 },
							text = ns.GetChangelog(),
							font = { normal = "GameFontDisable", },
							color = ns.colors.grey[2],
							readOnly = true,
						})

						--Button: Close
						wt.CreateButton({
							parent = windowPanel,
							name = "CancelButton",
							title = wt.GetStrings("close"),
							arrange = {},
							events = { OnClick = function() windowPanel:Hide() end },
						})
					end,
					arrangement = {
						margins = { l = 16, r = 16, t = 42, b = 16 },
						flip = true,
					}
				})
				_G[changelogFrame:GetName() .. "Title"]:SetPoint("TOPLEFT", 18, -18)
				wt.SetMovability(changelogFrame, true)
				changelogFrame:SetFrameStrata("DIALOG")
				changelogFrame:IsToplevel(true)
			end
		end, },
	}):SetFrameLevel(changelog:GetFrameLevel() + 1) --Make sure it's on top to be clickable
end

--Create the category page
local function CreateMainOptions() frames.options.main.page = wt.CreateOptionsCategory({
	addon = addonNameSpace,
	name = "Main",
	description = ns.strings.options.main.description:gsub("#ADDON", addonTitle),
	logo = ns.textures.logo,
	titleLogo = true,
	initialize = function(canvas)
		--Panel: About
		wt.CreatePanel({
			parent = canvas,
			name = "About",
			title = ns.strings.options.main.about.title,
			description = ns.strings.options.main.about.description:gsub("#ADDON", addonTitle),
			arrange = {},
			size = { height = 258 },
			initialize = CreateAboutInfo,
			arrangement = {
				flip = true,
				resize = false
			}
		})

		--Panel: Sponsors
		local top = GetAddOnMetadata(addonNameSpace, "X-TopSponsors")
		local normal = GetAddOnMetadata(addonNameSpace, "X-Sponsors")
		if top or normal then
			local sponsorsPanel = wt.CreatePanel({
				parent = canvas,
				name = "Sponsors",
				title = ns.strings.options.main.sponsors.title,
				description = ns.strings.options.main.sponsors.description,
				arrange = {},
				size = { height = 64 + (top and normal and 24 or 0) },
				initialize = function(panel)
					if top then
						wt.CreateText({
							parent = panel,
							name = "Top",
							position = { offset = { x = 16, y = -33 } },
							width = panel:GetWidth() - 32,
							text = top:gsub("|", " • "),
							font = "GameFontNormalLarge",
							justify = { h = "LEFT", },
						})
					end
					if normal then
						wt.CreateText({
							parent = panel,
							name = "Normal",
							position = { offset = { x = 16, y = -33 -(top and 24 or 0) } },
							width = panel:GetWidth() - 32,
							text = normal:gsub("|", " • "),
							font = "GameFontHighlightMedium",
							justify = { h = "LEFT", },
						})
					end
				end,
			})
			wt.CreateText({
				parent = sponsorsPanel,
				name = "DescriptionHeart",
				position = { offset = { x = _G[sponsorsPanel:GetName() .. "Description"]:GetStringWidth() + 16, y = -10 } },
				text = "♥",
				font = "ChatFontSmall",
				justify = { h = "LEFT", },
			})
		end
	end,
	arrangement = {}
}) end

--[ Specifications ]

--Create the widgets
local function CreateSpecificationsOptions(panel)
	--Checkbox: Enabled
	frames.options.specifications.enabled = wt.CreateCheckbox({
		parent = panel,
		name = "Enabled",
		title = ns.strings.options.specifications.enabled.label,
		tooltip = { lines = { { text = ns.strings.options.specifications.enabled.tooltip:gsub("#ADDON", addonTitle), }, } },
		arrange = {},
		optionsData = {
			optionsKey = addonNameSpace .. "Specifications",
			workingTable = db.specifications,
			storageKey = "enabled",
		}
	})
end

--Create the category page
local function CreateSpecificationsPageOptions() frames.options.specifications.page = wt.CreateOptionsCategory({
	parent = frames.options.main.page.category,
	addon = addonNameSpace,
	name = "Specifications",
	title = ns.strings.options.specifications.title,
	description = ns.strings.options.specifications.description:gsub("#ADDON", addonTitle),
	logo = ns.textures.logo,
	optionsKeys = { addonNameSpace .. "Specifications" },
	storage = { {
		workingTable =  db.specifications,
		storageTable = ScreenshotViewerDB.specifications,
		defaultsTable = dbDefault.specifications,
	}, },
	onDefault = function(user)
		if not user then return end

		--Notification
		print(wt.Color(addonTitle .. ":", ns.colors.green[1]) .. " " .. wt.Color(ns.strings.chat.defaults.response:gsub(
			"#CATEGORY", wt.Color(ns.strings.options.specifications.title, ns.colors.green[2])
		), ns.colors.yellow[2]))
	end,
	initialize = function(canvas)
		--Panel: Specifications
		wt.CreatePanel({
			parent = canvas,
			name = "Specifications",
			title = ns.strings.options.specifications.title,
			description = ns.strings.options.specifications.description,
			arrange = {},
			initialize = CreateSpecificationsOptions,
			arrangement = {}
		})
	end,
	arrangement = {}
}) end

--[ Advanced ]

--Create the widgets
local function CreateOptionsProfiles(panel)
	--TODO: Add profiles handler widgets
end
local function CreateBackupOptions(panel)
	--EditScrollBox & Popup: Import & Export
	local importPopup = wt.CreatePopup({
		addon = addonNameSpace,
		name = "IMPORT",
		text = ns.strings.options.advanced.backup.warning,
		accept = ns.strings.options.advanced.backup.import,
		onAccept = function()
			--Load from string to a temporary table
			local success, t = pcall(loadstring("return " .. wt.Clear(frames.options.advanced.backup.string.getText())))
			if success and type(t) == "table" then
				--Run DB checkup on the loaded table
				CheckDBs(t.account, db, t.character, dbc)

				--Copy values from the loaded DBs to the addon DBs
				wt.CopyValues(t.account, db)
				wt.CopyValues(t.character, dbc)

				--Load the options data & update the interface options
				frames.options.specifications.page.load(true)
				frames.options.advanced.page.load(true)
			else print(wt.Color(addonTitle .. ":", ns.colors.green[1]) .. " " .. wt.Color(ns.strings.options.advanced.backup.error, ns.colors.yellow[2])) end
		end
	})
	frames.options.advanced.backup.string = wt.CreateEditScrollBox({
		parent = panel,
		name = "ImportExport",
		title = ns.strings.options.advanced.backup.backupBox.label,
		tooltip = { lines = {
			{ text = ns.strings.options.advanced.backup.backupBox.tooltip[1], },
			{ text = "\n" .. ns.strings.options.advanced.backup.backupBox.tooltip[2], },
			{ text = "\n" .. ns.strings.options.advanced.backup.backupBox.tooltip[3], },
			{ text = ns.strings.options.advanced.backup.backupBox.tooltip[4], color = { r = 0.89, g = 0.65, b = 0.40 }, },
			{ text = "\n" .. ns.strings.options.advanced.backup.backupBox.tooltip[5], color = { r = 0.92, g = 0.34, b = 0.23 }, },
		}, },
		arrange = {},
		size = { width = panel:GetWidth() - 24, height = panel:GetHeight() - 76 },
		font = { normal = "GameFontWhiteSmall", },
		maxLetters = 4500,
		scrollSpeed = 0.2,
		events = {
			OnEnterPressed = function() StaticPopup_Show(importPopup) end,
			OnEscapePressed = function(self) self.setText(wt.TableToString({ account = db, character = dbc }, frames.options.advanced.backup.compact.getState(), true)) end,
		},
		optionsData = {
			optionsKey = addonNameSpace .. "Advanced",
			onLoad = function(self) self.setText(wt.TableToString({ account = db, character = dbc }, frames.options.advanced.backup.compact.getState(), true)) end,
		}
	})

	--Checkbox: Compact
	frames.options.advanced.backup.compact = wt.CreateCheckbox({
		parent = panel,
		name = "Compact",
		title = ns.strings.options.advanced.backup.compact.label,
		tooltip = { lines = { { text = ns.strings.options.advanced.backup.compact.tooltip, }, } },
		position = {
			anchor = "BOTTOMLEFT",
			offset = { x = 12, y = 12 }
		},
		events = { OnClick = function(_, state)
			frames.options.advanced.backup.string.setText(wt.TableToString({ account = db, character = dbc }, state, true))

			--Set focus after text change to set the scroll to the top and refresh the position character counter
			frames.options.advanced.backup.string.scrollFrame.EditBox:SetFocus()
			frames.options.advanced.backup.string.scrollFrame.EditBox:ClearFocus()
		end, },
		optionsData = {
			optionsKey = addonNameSpace .. "Advanced",
			workingTable = cs,
			storageKey = "compactBackup",
		}
	})

	--Button: Load
	wt.CreateButton({
		parent = panel,
		name = "Load",
		title = ns.strings.options.advanced.backup.load.label,
		tooltip = { lines = { { text = ns.strings.options.advanced.backup.load.tooltip, }, } },
		arrange = {},
		size = { height = 26 },
		events = { OnClick = function() StaticPopup_Show(importPopup) end, },
	})

	--Button: Reset
	wt.CreateButton({
		parent = panel,
		name = "Reset",
		title = ns.strings.options.advanced.backup.reset.label,
		tooltip = { lines = { { text = ns.strings.options.advanced.backup.reset.tooltip, }, } },
		position = {
			anchor = "BOTTOMRIGHT",
			offset = { x = -100, y = 12 }
		},
		size = { height = 26 },
		events = { OnClick = function()
			frames.options.advanced.backup.string.setText(wt.TableToString({ account = db, character = dbc }, frames.options.advanced.backup.compact.getState(), true))

			--Set focus after text change to set the scroll to the top and refresh the position character counter
			frames.options.advanced.backup.string.scrollFrame.EditBox:SetFocus()
			frames.options.advanced.backup.string.scrollFrame.EditBox:ClearFocus()
		end, },
	})
end

--Create the category page
local function CreateAdvancedOptions() frames.options.advanced.page = wt.CreateOptionsCategory({
	parent = frames.options.main.page.category,
	addon = addonNameSpace,
	name = "Advanced",
	title = ns.strings.options.advanced.title,
	description = ns.strings.options.advanced.description:gsub("#ADDON", addonTitle),
	logo = ns.textures.logo,
	optionsKeys = { addonNameSpace .. "Advanced" },
	onDefault = function()
		print(wt.Color(addonTitle .. ":", ns.colors.green[1]) .. " " .. wt.Color(ns.strings.chat.defaults.response:gsub(
			"#CATEGORY", wt.Color(ns.strings.options.specifications.title, ns.colors.green[2])
		), ns.colors.yellow[2]))
	end,
	initialize = function(canvas)
		--Panel: Profiles
		wt.CreatePanel({
			parent = canvas,
			name = "Profiles",
			title = ns.strings.options.advanced.profiles.title,
			description = ns.strings.options.advanced.profiles.description:gsub("#ADDON", addonTitle),
			arrange = {},
			size = { height = 64 },
			initialize = CreateOptionsProfiles,
		})

		--Panel: Backup
		wt.CreatePanel({
			parent = canvas,
			name = "Backup",
			title = ns.strings.options.advanced.backup.title,
			description = ns.strings.options.advanced.backup.description:gsub("#ADDON", addonTitle),
			arrange = {},
			size = { height = canvas:GetHeight() - 200 },
			initialize = CreateBackupOptions,
			arrangement = {
				flip = true,
				resize = false
			}
		})
	end,
	arrangement = {}
}) end


--[[ CHAT CONTROL ]]

--[ Chat Utilities ]

---Print visibility info
---@param load boolean | ***Default:*** false
local function PrintStatus(load)
	if load == true and not db.display.visibility.statusNotice then return end

	print(wt.Color(addonTitle .. ":", ns.colors.green[1]))
end

--Print help info
local function PrintInfo()
	print(wt.Color(ns.strings.chat.help.thanks:gsub("#ADDON", wt.Color(addonTitle, ns.colors.green[1])), ns.colors.yellow[1]))
	PrintStatus()
	print(wt.Color(ns.strings.chat.help.hint:gsub("#HELP_COMMAND", wt.Color("/" .. ns.chat.keyword .. " " .. ns.chat.commands.help, ns.colors.green[2])), ns.colors.yellow[2]))
	print(wt.Color(ns.strings.chat.help.move:gsub("#ADDON", addonTitle), ns.colors.yellow[2]))
end

---Format and print a command description
---@param command string Command name
---@param description string Command description text
local function PrintCommand(command, description)
	print("    " .. wt.Color("/" .. ns.chat.keyword .. " " .. command, ns.colors.green[2])  .. wt.Color(" - " .. description, ns.colors.yellow[2]))
end

--Reset to defaults confirmation
local resetDefaultsPopup = wt.CreatePopup({
	addon = addonNameSpace,
	name = "DefaultOptions",
	text = (wt.GetStrings("warning") or ""):gsub("#TITLE", wt.Clear(addonTitle)),
	onAccept = function()
		--Reset the options data & update the interface options
		frames.options.specifications.page.default()
		frames.options.advanced.page.default(true)
	end,
})

--[ Commands ]

--Register handlers
local commandManager = wt.RegisterChatCommands(addonNameSpace, { ns.chat.keyword }, {
	{
		command = ns.chat.commands.help,
		handler = function() print(wt.Color(addonTitle .. " ", ns.colors.green[1]) .. wt.Color(ns.strings.chat.help.list .. ":", ns.colors.yellow[1])) end,
		help = true,
	},
	{
		command = ns.chat.commands.options,
		handler = function() frames.options.main.page.open() end,
		onHelp = function() PrintCommand(ns.chat.commands.options, ns.strings.chat.options.description:gsub("#ADDON", addonTitle)) end
	},
	{
		command = ns.chat.commands.defaults,
		handler = function() StaticPopup_Show(resetDefaultsPopup) end,
		onHelp = function() PrintCommand(ns.chat.commands.defaults, ns.strings.chat.defaults.description) end
	},
}, PrintInfo)


--[[ INITIALIZATION ]]

--[ Event Handlers ]

--Main frame
local function AddonLoaded(self, addon)
	if addon ~= addonNameSpace then return end
	self:UnregisterEvent("ADDON_LOADED")

	--[ DBs ]

	local firstLoad = not ScreenshotViewerDB

	--Load storage DBs
	ScreenshotViewerDB = ScreenshotViewerDB or wt.Clone(dbDefault)
	ScreenshotViewerDBC = ScreenshotViewerDBC or wt.Clone(dbcDefault)

	--DB checkup & fix
	CheckDBs(ScreenshotViewerDB, dbDefault, ScreenshotViewerDBC, dbcDefault)

	--Load working DBs
	db = wt.Clone(ScreenshotViewerDB)
	dbc = wt.Clone(ScreenshotViewerDBC)

	--Load cross-session DBs
	ScreenshotViewerCS = ScreenshotViewerCS or {}
	cs = ScreenshotViewerCS

	--Welcome message
	if firstLoad then PrintInfo() end

	--[ Settings Setup ]

	--Load cross-session data
	if cs.compactBackup == nil then cs.compactBackup = true end

	--Set up the interface options
	CreateMainOptions()
	CreateSpecificationsPageOptions()
	CreateAdvancedOptions()

	--[ Frame Setup ]

	--Position
	wt.SetPosition(self, db.display.position)

	--Make movable
	wt.SetMovability(frames.main, true, "SHIFT", { frames.display.panel, }, {
		onStop = function()
			--Save the position (for account-wide use)
			wt.CopyValues(wt.PackPosition(frames.main:GetPoint()), db.display.position)

			--Update in the SavedVariables DB
			ScreenshotViewerDB.display.position = wt.Clone(db.display.position)

			--Update the GUI options in case the window was open
			frames.options.display.position.presets.setSelected(nil, ns.strings.options.display.position.presets.select)
			frames.options.display.position.anchor.setSelected(db.display.position.anchor)
			frames.options.display.position.xOffset.setValue(db.display.position.offset.x)
			frames.options.display.position.yOffset.setValue(db.display.position.offset.y)

			--Chat response
			print(wt.Color(addonTitle .. ":", ns.colors.green[1]) .. " " .. wt.Color(ns.strings.chat.position.save, ns.colors.yellow[2]))
		end,
		onCancel = function()
			--Reset the position
			wt.SetPosition(frames.main, db.display.position)

			--Chat response
			print(wt.Color(addonTitle .. ":", ns.colors.green[1]) .. " " .. wt.Color(ns.strings.chat.position.cancel, ns.colors.yellow[1]))
			print(wt.Color(ns.strings.chat.position.error, ns.colors.yellow[2]))
		end
	})
end

--[ Frames ]

--Create main addon frame & display
frames.main = wt.CreateFrame({
	parent = UIParent,
	name = addonNameSpace,
	position = { anchor = "CENTER", },
	onEvent = {
		ADDON_LOADED = AddonLoaded,
		SCREENSHOT_STARTED = function()
			lastDate1 = date("%m%d%y_%H%M%S")
			print("A screenshot is being created…")
		end,
		SCREENSHOT_SUCCEEDED = function()
			lastDate2 = date("%m%d%y_%H%M%S")
			print(lastDate1 .. " - 1")
			print(lastDate2 .. " - 2")
			print("A new screenshot was saved. " .. wt.CustomHyperlink(addonNameSpace, nil, nil, "[Click here to view!]"))
		end,
	},
	initialize = function(frame)
		frames.display.panel = wt.CreatePanel({
			parent = UIParent,
			name = addonNameSpace .. "Display",
			append = false,
			title = addonTitle,
			position = {
				anchor = "CENTER",
				offset = { y = 24 },
			},
			keepInBounds = true,
			size = { width = 1312, height = 808 },
			background = { color = { a = 0.9 }, },
			initialize = function(panel)
				wt.CreateTexture({
					parent = panel,
					position = {
						anchor = "TOP",
						offset = { y = -42 },
					},
					size = { width = 1280, height = 720 },
					path = GetScrPath(GetScrName("050623_074413")),
				})
				wt.CreateFrame({
					parent = panel,
					name = "Image",
					arrange = {},
				})
				frames.display.texture = panel:CreateTexture()

				--Button: Close
				wt.CreateButton({
					parent = panel,
					name = "CancelButton",
					title = wt.GetStrings("close"),
					position = {
						anchor = "BOTTOMRIGHT",
						offset = { x = -16, y = 16 },
					},
					events = { OnClick = function() panel:Hide() end },
				})

				--Button: Reset position
				wt.CreateButton({
					parent = panel,
					name = "ResetButton",
					title = "Reset Position",
					position = {
						anchor = "BOTTOMRIGHT",
						offset = { x = -108, y = 16 },
					},
					size = { width = 120, },
					events = { OnClick = function() wt.SetPosition(panel, {
						anchor = "CENTER",
						offset = { y = 24 },
					}) end },
				})
			end,
		})
		_G[frames.display.panel:GetName() .. "Title"]:SetPoint("TOPLEFT", 18, -18)
		wt.SetMovability(frames.display.panel, true)
		frames.display.panel:SetFrameStrata("DIALOG")
		frames.display.panel:IsToplevel(true)
		-- frames.display.panel:Hide()

		--Hyperlink: Open screenshot viewer
		wt.SetHyperlinkHandler(addonNameSpace, nil, function()
			frames.display.panel:Show()
			FindLastScreenshot()
			print("Showing " .. GetScrName(lastDate) .. "..")
		end)
	end
})