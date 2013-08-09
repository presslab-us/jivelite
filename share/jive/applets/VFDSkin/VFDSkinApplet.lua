--[[
=head1 NAME

applets.VFDSkin.VFDSkinApplet - The skin for a 256x64 screen 

=head1 DESCRIPTION

This applet implements the base skin for 256x64 VFD/OLED screens

=head1 FUNCTIONS

Applet related methods are described in L<jive.Applet>.

=cut
--]]


-- stuff we use
local ipairs, pairs, setmetatable, type = ipairs, pairs, setmetatable, type, package, tostring

local oo                     = require("loop.simple")

local Applet                 = require("jive.Applet")
local Audio                  = require("jive.ui.Audio")
local Font                   = require("jive.ui.Font")
local Framework              = require("jive.ui.Framework")
local Icon                   = require("jive.ui.Icon")
local Label                  = require("jive.ui.Label")
local RadioButton            = require("jive.ui.RadioButton")
local RadioGroup             = require("jive.ui.RadioGroup")
local SimpleMenu             = require("jive.ui.SimpleMenu")
local Surface                = require("jive.ui.Surface")
local Textarea               = require("jive.ui.Textarea")
local Tile                   = require("jive.ui.Tile")
local Window                 = require("jive.ui.Window")
local System                 = require("jive.System")

local table                  = require("jive.utils.table")
local debug                  = require("jive.utils.debug")
local autotable              = require("jive.utils.autotable")

local log                    = require("jive.utils.log").logger("applet.VFDSkin")

local LAYER_FRAME            = jive.ui.LAYER_FRAME
local LAYER_CONTENT_ON_STAGE = jive.ui.LAYER_CONTENT_ON_STAGE
local LAYER_TITLE            = jive.ui.LAYER_TITLE

local LAYOUT_NORTH           = jive.ui.LAYOUT_NORTH
local LAYOUT_EAST            = jive.ui.LAYOUT_EAST
local LAYOUT_SOUTH           = jive.ui.LAYOUT_SOUTH
local LAYOUT_WEST            = jive.ui.LAYOUT_WEST
local LAYOUT_CENTER          = jive.ui.LAYOUT_CENTER
local LAYOUT_NONE            = jive.ui.LAYOUT_NONE

local WH_FILL                = jive.ui.WH_FILL

local jiveMain               = jiveMain
local appletManager          = appletManager


module(..., Framework.constants)
oo.class(_M, Applet)


-- Define useful variables for this skin
local imgpath = "applets/VFDSkin/images/"
local fontpath = "fonts/"
local FONT_NAME = "FreeSans"
local BOLD_PREFIX = "Bold"


function init(self)
	self.images = {}
end

function param(self)
	return {
		THUMB_SIZE = 41,
		THUMB_SIZE_MENU = 39,
		POPUP_THUMB_SIZE = 60,
		NOWPLAYING_MENU = true,
		-- NOWPLAYING_TRACKINFO_LINES used in assisting scroll behavior animation on NP
                -- 3 is for a three line track, artist, and album (e.g., SBtouch)
                -- 2 is for a two line track, artist+album (e.g., SBradio, SBcontroller)
                NOWPLAYING_TRACKINFO_LINES = 2,
		nowPlayingScreenStyles = { 
			{
				style = 'nowplaying',
				artworkSize = '64x64',
				text = self:string('NO_ART'),
			},
			{
				style = 'nowplaying_spectrum_text',
				artworkSize = '64x64',
--				localPlayerOnly = 1,
				text = self:string("SPECTRUM_ANALYZER"),
			},
			{
				style = 'nowplaying_vuanalog_text',
				artworkSize = '64x64',
--				localPlayerOnly = 1,
				text = self:string("ANALOG_VU_METER"),
			},
		},

        }
end


function _loadImage(self, file)
	return Surface:loadImage(imgpath .. file)
end


-- define a local function to make it easier to create icons.
function _icon(self, x, y, img)
	local var = {}
	var.x = x
	var.y = y
	var.img = _loadImage(self, img)
	var.layer = LAYER_FRAME
	var.position = LAYOUT_SOUTH

	return var
end

-- define a local function that makes it easier to set fonts
function _font(fontSize)
	return Font:load(fontpath .. FONT_NAME .. ".ttf", fontSize)
end

-- define a local function that makes it easier to set bold fonts
function _boldfont(fontSize)
	return Font:load(fontpath .. FONT_NAME .. BOLD_PREFIX .. ".ttf", fontSize)
end

-- defines a new style that inherrits from an existing style
function _uses(parent, value)
	if parent == nil then
		log:warn("nil parent in _uses at:\n", debug.traceback())
	end
	local style = {}
	setmetatable(style, { __index = parent })
	for k,v in pairs(value or {}) do
		if type(v) == "table" and type(parent[k]) == "table" then
			-- recursively inherrit from parent style
			style[k] = _uses(parent[k], v)
		else
			style[k] = v
		end
	end

	return style
end


-- skin
-- The meta arranges for this to be called to skin Jive.
function skin(self, s, reload, useDefaultSize)
	local screenWidth, screenHeight = Framework:getScreenSize()

        screenWidth = 256
        screenHeight = 64
        Framework:setVideoMode(screenWidth, screenHeight, 16, jiveMain:isFullscreen())

	--init lastInputType so selected item style is not shown on skin load
	Framework.mostRecentInputType = "scroll"

	s.img = {}

	-- Images and Tiles
	s.img.iconBackground =
		Tile:loadVTiles({
					imgpath .. "Toolbar/toolbar_highlight.png",
					imgpath .. "Toolbar/toolbar.png",
					nil,
			       })

	s.img.titleBox =
		Tile:loadVTiles({
					nil,
				       imgpath .. "Titlebar/titlebar.png",
				       imgpath .. "Titlebar/titlebar_shadow.png",
			       })

	s.img.textinputWheel       = Tile:loadImage(imgpath .. "Text_Entry/text_bar_vert.png")
	s.img.textinputBackground  = Tile:loadTiles({
		imgpath .. "Text_Entry/text_entry_bkgrd.png",
		imgpath .. "Text_Entry/text_entry_bkgrd_tl.png",
		imgpath .. "Text_Entry/text_entry_bkgrd_t.png",
		imgpath .. "Text_Entry/text_entry_bkgrd_tr.png",
		imgpath .. "Text_Entry/text_entry_bkgrd_r.png",
		imgpath .. "Text_Entry/text_entry_bkgrd_br.png",
		imgpath .. "Text_Entry/text_entry_bkgrd_b.png",
		imgpath .. "Text_Entry/text_entry_bkgrd_bl.png",
		imgpath .. "Text_Entry/text_entry_bkgrd_l.png",
	})

	s.img.softbuttonBackground = Tile:loadImage(imgpath .. "Text_Entry/soft_key_bkgrd.png")
	s.img.softbutton = Tile:loadTiles({
		imgpath .. "Text_Entry/soft_key_button.png",
		imgpath .. "Text_Entry/soft_key_button_tl.png",
		imgpath .. "Text_Entry/soft_key_button_t.png",
		imgpath .. "Text_Entry/soft_key_button_tr.png",
		imgpath .. "Text_Entry/soft_key_button_r.png",
		imgpath .. "Text_Entry/soft_key_button_br.png",
		imgpath .. "Text_Entry/soft_key_button_b.png",
		imgpath .. "Text_Entry/soft_key_button_bl.png",
		imgpath .. "Text_Entry/soft_key_button_l.png",
	})

	-- FIXME: these will crash jive if they are removed
	-- textinputs should be able to not have cursor and right arrow assets if not defined
	s.img.textinputCursor     = Tile:loadImage(imgpath .. "Text_Entry/text_bar_vert_fill.png")
	s.img.textinputEnterImg   = Tile:loadImage(imgpath .. "Icons/selection_right_textentry.png")
	s.img.textareaBackground  = Tile:loadImage(imgpath .. "Titlebar/tb_dropdwn_bkrgd.png")

	s.img.textareaBackgroundBottom  = 
		Tile:loadVTiles({
					nil,
					imgpath .. "Titlebar/tb_dropdwn_bkrgd.png",
					imgpath .. "Titlebar/titlebar_shadow.png",
			       })

	s.img.pencilLineMenuDivider =
		Tile:loadTiles({
			nil,
			nil,
			nil,
			nil,
			nil,
			imgpath .. "Menu_Lists/menu_divider_r.png",
			imgpath .. "Menu_Lists/menu_divider.png",
			imgpath .. "Menu_Lists/menu_divider_l.png",
			nil,
		})

	s.img.multiLineSelectionBox =
		Tile:loadHTiles({
					nil,
				       imgpath .. "Menu_Lists/menu_sel_box_82.png",
				       imgpath .. "Menu_Lists/menu_sel_box_82_r.png",
			       })

	s.img.timeInputSelectionBox = Tile:loadImage(imgpath .. "Menu_Lists/menu_box_36.png")
	s.img.oneLineItemSelectionBox =
		Tile:loadHTiles({
					nil,
				       imgpath .. "Menu_Lists/menu_sel_box.png",
				       imgpath .. "Menu_Lists/menu_sel_box_r.png",
			       })

	s.img.contextMenuSelectionBox =
		Tile:loadTiles({
		imgpath .. "Popup_Menu/button_cm.png",
		imgpath .. "Popup_Menu/button_cm_tl.png",
		imgpath .. "Popup_Menu/button_cm_t.png",
		imgpath .. "Popup_Menu/button_cm_tr.png",
		imgpath .. "Popup_Menu/button_cm_r.png",
		imgpath .. "Popup_Menu/button_cm_br.png",
		imgpath .. "Popup_Menu/button_cm_b.png",
		imgpath .. "Popup_Menu/button_cm_bl.png",
		imgpath .. "Popup_Menu/button_cm_l.png",
		})
	

	s.img.songProgressBackground =
		Tile:loadHTiles({
					imgpath .. "Song_Progress_Bar/tb_progress_bkgrd_float_l.png",
					imgpath .. "Song_Progress_Bar/tb_progress_bkgrd_float.png",
					imgpath .. "Song_Progress_Bar/tb_progress_bkgrd_float_r.png",
			       })

	s.img.songProgressBar =
		Tile:loadHTiles({
					imgpath .. "Song_Progress_Bar/tb_progress_fill_l.png",
					imgpath .. "Song_Progress_Bar/tb_progress_fill.png",
					--imgpath .. "Song_Progress_Bar/tb_progressbar_slider.png",
					--- workaround slider end with small tail
					imgpath .. "UNOFFICIAL/tb_progressbar_slider.png",
			       })


	s.img.sliderBackground =
		Tile:loadHTiles({
					imgpath .. "Song_Progress_Bar/progressbar_bkgrd_l.png",
					imgpath .. "Song_Progress_Bar/progressbar_bkgrd.png",
					imgpath .. "Song_Progress_Bar/progressbar_bkgrd_r.png",
			       })

	s.img.sliderBar =
		Tile:loadHTiles({
					imgpath .. "Song_Progress_Bar/rem_sliderbar_fill_l.png",
					imgpath .. "Song_Progress_Bar/rem_sliderbar_fill.png",
					imgpath .. "Song_Progress_Bar/rem_sliderbar_fill_r.png",
					-- FIXME: can't do the end asset right now
					--imgpath .. "Song_Progress_Bar/progressbar_slider.png",
			       })

	s.img.volumeBar =
		Tile:loadHTiles({
					imgpath .. "Song_Progress_Bar/rem_sliderbar_fill_l.png",
					imgpath .. "Song_Progress_Bar/rem_sliderbar_fill.png",
					imgpath .. "Song_Progress_Bar/rem_sliderbar_fill_r.png",
			       })

	s.img.volumeBackground =
		Tile:loadHTiles({
					imgpath .. "Song_Progress_Bar/rem_sliderbar_bkgrd_l.png",
					imgpath .. "Song_Progress_Bar/rem_sliderbar_bkgrd.png",
					imgpath .. "Song_Progress_Bar/rem_sliderbar_bkgrd_r.png",
				})

	s.img.popupBox  = Tile:loadTiles({
		imgpath .. "Popup_Menu/popup_box.png",
		imgpath .. "Popup_Menu/popup_box_tl.png",
		imgpath .. "Popup_Menu/popup_box_t.png",
		imgpath .. "Popup_Menu/popup_box_tr.png",
		imgpath .. "Popup_Menu/popup_box_r.png",
		imgpath .. "Popup_Menu/popup_box_br.png",
		imgpath .. "Popup_Menu/popup_box_b.png",
		imgpath .. "Popup_Menu/popup_box_bl.png",
		imgpath .. "Popup_Menu/popup_box_l.png",
	})

	s.img.contextMenuBox =
                Tile:loadTiles({
			imgpath .. "Popup_Menu/cm_popup_box.png",
			imgpath .. "Popup_Menu/cm_popup_box_tl.png",
			imgpath .. "Popup_Menu/cm_popup_box_t.png",
			imgpath .. "Popup_Menu/cm_popup_box_tr.png",
			imgpath .. "Popup_Menu/cm_popup_box_r.png",
			imgpath .. "Popup_Menu/cm_popup_box_br.png",
			imgpath .. "Popup_Menu/cm_popup_box_b.png",
			imgpath .. "Popup_Menu/cm_popup_box_bl.png",
			imgpath .. "Popup_Menu/cm_popup_box_l.png",
		})

	s.img.scrollBackground =
                Tile:loadVTiles({
                                        imgpath .. "Scroll_Bar/scrollbar_bkgrd_t.png",
                                        imgpath .. "Scroll_Bar/scrollbar_bkgrd.png",
                                        imgpath .. "Scroll_Bar/scrollbar_bkgrd_b.png",
                                })

	s.img.scrollBar =
                Tile:loadVTiles({
                                        imgpath .. "Scroll_Bar/scrollbar_body_t.png",
                                        imgpath .. "Scroll_Bar/scrollbar_body.png",
                                        imgpath .. "Scroll_Bar/scrollbar_body_b.png",
                               })

	s.img.progressBackground = Tile:loadImage(imgpath .. "Alerts/alert_progress_bar_bkgrd.png")
	s.img.progressBar = Tile:loadHTiles({
                nil,
                imgpath .. "Alerts/alert_progress_bar_body.png",
        })

	s.img.popupMask = Tile:fillColor(0x00000085)

	s.img.blackBackground = Tile:fillColor(0x000000ff)

	-- constants table
	-- by putting this in the skin table "s", it's available to child skins
	s.CONSTANTS = {
		THUMB_SIZE = self:param().THUMB_SIZE,
		THUMB_SIZE_MENU = self:param().THUMB_SIZE_MENU,
		POPUP_THUMB_SIZE = self:param().POPUP_THUMB_SIZE,

		CHECK_PADDING  = { 0, 0, 0, 0 },

		MENU_ALBUMITEM_PADDING = { 8, 1, 4, 1 },
		MENU_ALBUMITEM_TEXT_PADDING = { 8, 2, 0, 2 },
		MENU_PLAYLISTITEM_TEXT_PADDING = { 6, 6, 8, 10 },

		HELP_TEXT_PADDING = { 10, 10, 5, 8 },
		TEXTAREA_PADDING = { 13, 8, 8, 8 },
		MENU_ITEM_ICON_PADDING = { 0, 0, 10, 0 },

		TEXT_COLOR = { 0xE7, 0xE7, 0xE7 },
		TEXT_COLOR_TEAL = { 0, 0xbe, 0xbe },
		TEXT_COLOR_BLACK = { 0x00, 0x00, 0x00 },
		TEXT_SH_COLOR = { 0x37, 0x37, 0x37 },

		CM_MENU_HEIGHT = 41,

		TEXTINPUT_WHEEL_COLOR = { 0xB3, 0xB3, 0xB3 },
		TEXTINPUT_WHEEL_SELECTED_COLOR = { 0xE6, 0xE6, 0xE6 },

		SELECT_COLOR = { 0xE7, 0xE7, 0xE7 },
		SELECT_SH_COLOR = { },

		TITLE_HEIGHT = 22,
		TITLE_FONT_SIZE = 17,
		ALBUMMENU_TITLE_FONT_SIZE = 15,
		ALBUMMENU_FONT_SIZE = 14,
		ALBUMMENU_SMALL_FONT_SIZE = 14,
		TEXTMENU_FONT_SIZE = 21,
		POPUP_TEXT_SIZE_1 = 22,
		POPUP_TEXT_SIZE_2 = 16,
		HELP_TEXT_FONT_SIZE = 16,
		TEXTAREA_FONT_SIZE = 16,
		TEXTINPUT_FONT_SIZE = 20,
		TEXTINPUT_SELECTED_FONT_SIZE = 32,
		HELP_FONT_SIZE = 16,
		UPDATE_SUBTEXT_SIZE = 16,
		ICONBAR_FONT = 12,

		ITEM_ICON_ALIGN   = 'right',
		MULTILINE_LINE_ITEM_HEIGHT = 44,
		TIME_LINE_ITEM_HEIGHT = 44,
		LINE_ITEM_HEIGHT  = 44,
	}

	local skinSuffix = '.png'

	-- c is for constants
	local c = s.CONSTANTS

	s.img.smallSpinny = {
		-- FIXME: this is the right asset but Noah needs to update so it gets put in Alerts/
		img = _loadImage(self, "Alerts/wifi_connecting_sm.png"),
		frameRate = 8,
		frameWidth = 26,
		padding = { 0, 0, 0, 0 },
		h = WH_FILL,
	}

	s.img.playArrow = {
		img = _loadImage(self, "Icons/selection_play_off.png"),
	}
	s.img.playArrowSel = {
		img = _loadImage(self, "Icons/selection_play_sel.png"),
	}
	s.img.playAllArrow = s.img.playArrow
	s.img.playAllArrowSel = s.img.playArrowSel
	s.img.itemAdd = {
		img = _loadImage(self, "Icons/selection_add_off.png"),
	}
	s.img.itemAddSel = {
		img = _loadImage(self, "Icons/selection_add_sel.png"),
	}
	s.img.itemAddNext = s.img.itemAdd
	s.img.itemAddNextSel = s.img.itemAddSel
	s.img.itemFav = {
		img = _loadImage(self, "Icons/selection_fav_off.png"),
	}
	s.img.itemFavSel = {
		img = _loadImage(self, "Icons/selection_fav_sel.png"),
	}
	s.img.rightArrowSel = {
		img = _loadImage(self, "Icons/selection_right_sel.png"),
		padding = { 0, 0, 0, 0 },
		h = WH_FILL,
		align = "center",
	}
	s.img.rightArrow = {
		img = _loadImage(self, "Icons/selection_right_off.png"),
		padding = { 0, 0, 0, 0 },
		h = WH_FILL,
		align = "center",
	}
	s.img.checkMark = {
		align = c.ITEM_ICON_ALIGN,
		padding = c.CHECK_PADDING,
		img = _loadImage(self, "Icons/icon_check_off.png"),
	}
	s.img.checkMarkSelected = {
		align = c.ITEM_ICON_ALIGN,
		padding = c.CHECK_PADDING,
		img = _loadImage(self, "Icons/icon_check_sel.png"),
	}


--------- DEFAULT WIDGET STYLES ---------
	--
	-- These are the default styles for the widgets

	s.window = {
		w = screenWidth,
		h = screenHeight,
	}

	-- window with absolute positioning
	s.absolute = _uses(s.window, {
		layout = Window.noLayout,
	})

	s.popup = _uses(s.window, {
		border = { 0, 0, 0, 0 },
		maskImg = s.img.blackBackground,
	})

	s.scrollbar = {
		w          = 16,
		h          = c.LINE_ITEM_HEIGHT - 6,
		border     = { 0, 0, 0, 0},  -- bug in jive_menu, makes it so bottom and right values are ignored
		horizontal = 0,
		bgImg      = s.img.scrollBackground,
		img        = s.img.scrollBar,
		layer      = LAYER_CONTENT_ON_STAGE,
	}

	s.title = {
		h = c.TITLE_HEIGHT,
		border = 0,
		position = LAYOUT_NORTH,
		bgImg = s.img.titleBox,
		order = { "text" },
		text = {
			w = WH_FILL,
			h = WH_FILL,
			padding = { 10, 0, 10, 0 },
			align = 'left',
			font = _boldfont(c.TITLE_FONT_SIZE),
			fg = c.SELECT_COLOR,
			sh = c.SELECT_SH_COLOR,
		},
	}

	s.title.textButton = _uses(s.title.text, {
		padding = 0,
	})
	s.title.pressed = {}
	s.title.pressed.textButton = s.title.textButton

	s.text_block_black = {
		hidden = 1,
	}

	s.menu = {
		h = screenHeight,
		position = LAYOUT_NORTH,
		padding = 0,
		border = { 0, 22, 0, 0 },
		itemHeight = c.LINE_ITEM_HEIGHT,
		font = _boldfont(48),
		fg = c.TEXT_COLOR,
		sh = c.TEXT_SH_COLOR,
	}
	s.menu.selected = {}
	s.menu.selected.item = {}

	s.menu_hidden = _uses(s.menu, {
		hidden = 1,
	})

	s.item = {
		order = { "icon", "text", "arrow" },
		padding = { 10, 1, 5, 1 },
		bgImg = s.img.pencilLineMenuDivider,
		text = {
			padding = { 0, 0, 0, 0 },
			align = "left",
			w = WH_FILL,
			h = WH_FILL,
			font = _boldfont(c.TEXTMENU_FONT_SIZE),
			fg = c.TEXT_COLOR,
			sh = c.TEXT_SH_COLOR,
		},
		icon = {
			padding = c.MENU_ITEM_ICON_PADDING,
			align = 'center',
			h = c.THUMB_SIZE,
		},
		arrow = s.img.rightArrow,
	}

	s.item_play = _uses(s.item, {
		arrow = {
			img = false
		},
	})
	s.item_add = _uses(s.item)

	-- Checkbox
        s.checkbox = { 
		h = WH_FILL, 
		padding = { 0, 8, 3, 0 },
	}
        s.checkbox.img_on = _loadImage(self, "Icons/checkbox_on.png")
        s.checkbox.img_off = _loadImage(self, "Icons/checkbox_off.png")

        -- Radio button
        s.radio = { 
		h = WH_FILL, 
		padding = { 0, 8, 3, 0 },
	}
        s.radio.img_on = _loadImage(self, "Icons/radiobutton_on.png")
        s.radio.img_off = _loadImage(self, "Icons/radiobutton_off.png")
		
	s.choice = {
		align = 'right',
		font = _boldfont(c.TEXTMENU_FONT_SIZE - 3),
		fg = c.TEXT_COLOR,
		sh = c.TEXT_SH_COLOR,
		h = WH_FILL,
	}

	s.item_choice = _uses(s.item, {
		order  = { 'icon', 'text', 'check' },
		check = {
			align = 'right',
			h = WH_FILL,
		},
	})
	s.item_info = _uses(s.item, {
		order = { 'text' },
		padding = c.MENU_ALBUMITEM_PADDING,
		text = {
			align = "top-left",
			w = WH_FILL,
			h = WH_FILL,
			padding = { 0, 4, 0, 4 },
			font = _font(14),
 			line = {
				{
					font = _font(14),
					height = 16,
				},
				{
					font = _boldfont(18),
					height = 18,
				},
			},
 		},
	})

	s.item_checked = _uses(s.item, {
		order = { 'icon', "text", "check", "arrow" },
		check = s.img.checkMark,
	})

	s.item_no_arrow = _uses(s.item, {
		order = { 'icon', 'text' },
	})
	s.item_checked_no_arrow = _uses(s.item_checked, {
		order = { 'icon', 'text', 'check' },
	})

        -- selected menu item
        s.selected = {}
	s.selected.item = _uses(s.item, {
		order = { 'icon', 'text', 'arrow' },
		text = {
			font = _boldfont(c.TEXTMENU_FONT_SIZE),
			fg = c.SELECT_COLOR,
			sh = c.SELECT_SH_COLOR
		},
		bgImg = s.img.oneLineItemSelectionBox,
		arrow = s.img.rightArrowSel,
	})
	s.selected.item_info = _uses(s.item_info, {
		bgImg = s.img.oneLineItemSelectionBox,
		text = {
 			line = {
				{
					font = _font(14),
					height = 14,
				},
				{
					font = _boldfont(21),
					height = 21,
				},
			},
		},
 	
	})

	--FIXME: doesn't seem to take effect...
	s.selected.choice = _uses(s.choice, {
		fg = c.SELECT_COLOR,
		sh = c.SELECT_SH_COLOR,
	})
	s.selected.item_choice = _uses(s.selected.item, {
		order = { 'icon', 'text', 'check' },
		check = {
			align = 'right',
			font = _boldfont(c.TEXTMENU_FONT_SIZE),
			fg = c.SELECT_COLOR,
			sh = c.SELECT_SH_COLOR,
		},
		radio = {
        		img_on = _loadImage(self, "Icons/radiobutton_on_sel.png"),
			img_off = _loadImage(self, "Icons/radiobutton_off_sel.png"),
			padding = { 0, 6, 0, 0 },
		},
		checkbox = {
        		img_on = _loadImage(self, "Icons/checkbox_on_sel.png"),
			img_off = _loadImage(self, "Icons/checkbox_off_sel.png"),
			padding = { 0, 6, 0, 0 },
		},
	})

	s.selected.item_play = _uses(s.selected.item, {
		arrow = {
			img = false
		},
	})
	s.selected.item_add = _uses(s.selected.item)
	s.selected.item_checked = _uses(s.selected.item, {
		order = { "icon", "text", "check", "arrow" },
		check = s.img.checkMarkSelected,
	})
        s.selected.item_no_arrow = _uses(s.selected.item, {
		order = { 'text' },
	})
        s.selected.item_checked_no_arrow = _uses(s.selected.item_checked, {
		order = { 'icon', 'text', 'check' },
		check = s.img.checkMark,
	})

	s.pressed = {
		item = _uses(s.selected.item, {
			bgImg = threeItemPressedBox,
		}),
		item_checked = _uses(s.selected.item_checked, {
			bgImg = threeItemPressedBox,
		}),
		item_play = _uses(s.selected.item_play, {
			bgImg = threeItemPressedBox,
		}),
		item_add = _uses(s.selected.item_add, {
			bgImg = threeItemPressedBox,
		}),
		item_no_arrow = _uses(s.selected.item_no_arrow, {
			bgImg = threeItemPressedBox,
		}),
		item_checked_no_arrow = _uses(s.selected.item_checked_no_arrow, {
			bgImg = threeItemPressedBox,
		}),
		item_choice = _uses(s.selected.item_choice, {
			bgImg = threeItemPressedBox,
		}),
	}

	s.locked = {
		item = _uses(s.pressed.item, {
			arrow = s.img.smallSpinny
		}),
		item_checked = _uses(s.pressed.item_checked, {
			arrow = s.img.smallSpinny
		}),
		item_play = _uses(s.pressed.item_play, {
			arrow = s.img.smallSpinny
		}),
		item_add = _uses(s.pressed.item_add, {
			arrow = s.img.smallSpinny
		}),
		item_no_arrow = _uses(s.pressed.item_no_arrow, {
			arrow = s.img.smallSpinny
		}),
		item_checked_no_arrow = _uses(s.pressed.item_checked_no_arrow, {
			arrow = s.img.smallSpinny
		}),
	}
	s.item_blank = {
		padding = {  },
		text = {},
		bgImg = s.img.textareaBackground,
	}
	s.item_blank_bottom = _uses(s.item_blank, {
		bgImg = s.img.textareaBackgroundBottom,
	})

	s.pressed.item_blank = _uses(s.item_blank)
	s.selected.item_blank = _uses(s.item_blank)
	s.pressed.item_blank_bottom = _uses(s.item_blank_bottom)
	s.selected.item_blank_bottom = _uses(s.item_blank_bottom)

	s.help_text = {
		w = screenWidth - 20,
		padding = c.HELP_TEXT_PADDING,
		font = _font(c.HELP_TEXT_FONT_SIZE),
		lineHeight = c.HELP_TEXT_FONT_SIZE + 4,
		fg = c.TEXT_COLOR,
		sh = c.TEXT_SH_COLOR,
		align = "top-left",
	}

	s.text = {
		w = screenWidth,
		padding = c.TEXTAREA_PADDING,
		font = _boldfont(c.TEXTAREA_FONT_SIZE),
		fg = c.TEXT_COLOR,
		sh = c.TEXT_SH_COLOR,
		align = "left",
	}

	s.multiline_text = {
		w = WH_FILL,
		padding = { 10, 0, 2, 0 },
		lineHeight = 21,
		font = _font(18),
		fg = { 0xe6, 0xe6, 0xe6 },
		sh = { },
		align = "left",
		scrollbar = {
			h = c.MULTILINE_LINE_ITEM_HEIGHT - 8,
			border = {0,4,20,0},
		},
	}

	-- FIXME: using volume slider assets as an acceptable workaround
	-- slider asset rendering is not working when there are four assets (l, middle, r, and end "button")
	s.slider = {
		border = 5,
		w = WH_FILL,
		horizontal = 1,
		bgImg = s.img.volumeBackground,
		img = s.img.volumeBar,
	}

	s.slider_group = {
		w = WH_FILL,
		order = { "slider" },
	}

	-- FIXME: bug 12402, these sliders need some work to come up to spec
	s.settings_slider_group = {
		bgImg = s.img.textareaBackground,
                order = {  'slider' },
                position = LAYOUT_NONE,
		x = 0,
		y = 3,
                h = 23,
                w = WH_FILL,
        }

	s.settings_slider = {
                w = WH_FILL,
                border = { 10, 16, 10, 0 },
                padding = { 0, 0, 0, 0 },
                position = LAYOUT_SOUTH,
                horizontal = 1,
                bgImg = s.img.volumeBackground,
                img = s.img.volumeBar,
        }

	s.volume_slider_group = s.slider_group

	s.brightness_group = s.settings_slider_group
	s.brightness_slider = s.settings_slider

--------- SPECIAL WIDGETS ---------

	-- text input
	s.textinput = {
		h          = WH_FILL,
		border     = { 8, 0, 8, 0 },
		padding    = { 8, 0, 8, 0 },
		align = 'center',
		font       = _boldfont(c.TEXTINPUT_FONT_SIZE),
		cursorFont = _boldfont(c.TEXTINPUT_SELECTED_FONT_SIZE),
		wheelFont  = _boldfont(24),
		charHeight = 46,
		wheelCharHeight =  24,
		fg         = c.TEXT_COLOR_BLACK,
		wh         = c.TEXTINPUT_WHEEL_COLOR,
		bgImg      = s.img.textinputBackground,
		cursorImg  = s.img.textinputCursor,
		enterImg   = s.img.textinputEnterImg,
		wheelImg   = s.img.textinputWheel,
		cursorColor = c.TEXTINPUT_WHEEL_SELECTED_COLOR,
		charOffsetY = 13,
		wheelCharOffsetY = 6,
	}

	-- soft buttons
	s.softButtons = {
		order = { 'spacer' },
		position = LAYOUT_SOUTH,
		h = 51,
		w = WH_FILL,
		spacer = {
			w = WH_FILL,
			font = _font(10),
			fg = TEXT_COLOR,
		},
		bgImg = s.img.softbuttonBackground,
		padding = { 8, 8, 8, 8 },
	}

--------- WINDOW STYLES ---------
	--
	-- These styles override the default styles for a specific window

	-- text_list is the standard window style
	s.text_list = _uses(s.window)

	-- text_only removes icons
	s.text_only = _uses(s.text_list, {
		menu = {
			item = {
				order = { 'text', 'arrow', },
			},
			selected = {
				item = {
					order = { 'text', 'arrow', },
				}
			},
			pressed = {
				item = {
					order = { 'text', 'arrow', },
				}
			},
			locked = {
				item = {
					order = { 'text', 'arrow', },
				}
			},
		},
	})

	--hack until SC changes are in place
	s.text_list.title = _uses(s.title, {
		text = {
			line = {
					{
						font = _boldfont(c.ALBUMMENU_TITLE_FONT_SIZE),
						height = c.ALBUMMENU_TITLE_FONT_SIZE + 1,
					},
					{
						font = _boldfont(c.ALBUMMENU_TITLE_FONT_SIZE - 6),
						height = c.ALBUMMENU_TITLE_FONT_SIZE - 9,
					},
					{
						--minimize visibility of this...
						font = _font(1),
						height = 1,
					}
			},
		},
	})

	s.text_list.title.textButton = _uses(s.text_list.title.text, {
		padding = 0,
		border = 0,
	})
	s.text_list.title.pressed = {}
	s.text_list.title.pressed.textButton = s.text_list.title.textButton

	-- popup "spinny" window
	s.waiting_popup = _uses(s.popup)

	s.waiting_popup.text = {
		padding = { 0, 8, 0, 0 },
		fg = c.TEXT_COLOR,
		sh = c.TEXT_SH_COLOR,
		align = "top",
		position = LAYOUT_NORTH,
		font = _font(c.POPUP_TEXT_SIZE_1),
	}

	s.waiting_popup.subtext = {
		padding = { 0, 0, 0, 10 },
		font = _boldfont(c.POPUP_TEXT_SIZE_2),
		fg = c.TEXT_COLOR,
		sh = c.TEXT_SH_COLOR,
		align = "top",
		position = LAYOUT_SOUTH,
		w = WH_FILL,
	}

	s.waiting_popup.subtext_connected = _uses(s.waiting_popup.subtext, {
		fg = c.TEXT_COLOR_TEAL,
	})

	s.black_popup = _uses(s.waiting_popup)
	s.black_popup.title = _uses(s.title, {
		bgImg = false,
		order = { },
	})

	-- input window (including keyboard)
	-- XXX: needs layout
	s.input = _uses(s.window)

	-- error window
	-- XXX: needs layout
	s.error = _uses(s.window)

	s.home_menu = _uses(s.window, {
		menu = {
			item = _uses(s.item, {
				icon = {
					img = _loadImage(self, "IconsResized/icon_loading" .. skinSuffix),
				},
			}),
			selected = {
				item = _uses(s.selected.item, {
					icon = {
						img = _loadImage(self, "IconsResized/icon_loading" .. skinSuffix),
					},
				}),
			},
			locked = {
				item = _uses(s.locked.item, {
					icon = {
						img = _loadImage(self, "IconsResized/icon_loading" .. skinSuffix),
					},
				}),
			},
		},
	})

	s.home_menu.menu.item.icon_no_artwork = {
		img = _loadImage(self, "IconsResized/icon_loading" .. skinSuffix ),
		w = 51,
		padding = { 0, 1, 0, 0 },
	}
	s.home_menu.menu.selected.item.icon_no_artwork = {
		img = _loadImage(self, "IconsResized/icon_loading" .. skinSuffix ),
		w   = 51,
		padding = { 0, 1, 0, 0 },
	}
	s.home_menu.menu.locked.item.icon_no_artwork = {
		img = _loadImage(self, "IconsResized/icon_loading" .. skinSuffix ),
		w   = 51,
		padding = { 0, 1, 0, 0 },
	}
	s.home_menu.menu.item_play = _uses(s.home_menu.menu.item, {
		arrow = { 
			img = false, 
		},
	})
	s.home_menu.menu.selected.item_play = _uses(s.home_menu.menu.selected.item, {
		arrow = { 
			img = false, 
		},
	})
	s.home_menu.menu.locked.item_play = _uses(s.home_menu.menu.locked.item, {
		arrow = { 
			img = false, 
		},
	})

	s.help_list = _uses(s.text_list)

	-- choose player window is exactly the same as text_list on all windows
        s.choose_player = s.text_list

	local _timeFirstColumnX12h = 65
	local _timeFirstColumnX24h = 98

	s.time_input_menu_box_12h = { hidden = 1, img = false }
	s.time_input_menu_box_24h = { hidden = 1, img = false }

	s.time_input_background_12h = {
		w = WH_FILL,
		h = screenHeight,
		position = LAYOUT_NONE,
		img = _loadImage(self, "Multi_Character_Entry/land_multi_char_bkgrd_3c.png"),
		x = 0,
		y = c.TITLE_HEIGHT,
	}

	s.time_input_background_24h = {
		w = WH_FILL,
		h = screenHeight,
		position = LAYOUT_NONE,
		img = _loadImage(self, "Multi_Character_Entry/land_multi_char_bkgrd_2c.png"),
		x = 0,
		y = c.TITLE_HEIGHT,
	}

	-- time input window
	s.input_time_12h = _uses(s.window)
	s.input_time_12h.hour = _uses(s.menu, {
		w = 60,
		h = 40,
		itemHeight = c.TIME_LINE_ITEM_HEIGHT,
		position = LAYOUT_WEST,
		padding = 0,
		border = { _timeFirstColumnX12h, 16, 0, 24 },
		item = {
			bgImg = false,
			order = { 'text' },
			text = {
				align = 'right',
				font = _boldfont(21),
				padding = { 2, 0, 12, 0 },
				fg = { 0xb3, 0xb3, 0xb3 },
				sh = { },
			},
		},
		selected = {
			item = {
				order = { 'text' },
				bgImg = s.img.timeInputSelectionBox,
				text = {
					font = _boldfont(24),
					fg = { 0xe6, 0xe6, 0xe6 },
					sh = { },
					align = 'right',
					padding = { 2, 0, 10, 0 },
				},
			},
		},
	})
	s.input_time_12h.minute = _uses(s.input_time_12h.hour, {
		border = { _timeFirstColumnX12h + 65, 16, 0, 24 },
	})
	s.input_time_12h.ampm = _uses(s.input_time_12h.hour, {
		border = { _timeFirstColumnX12h + 65 + 65, 16, 0, 24 },
		item = {
			text = {
				padding = { 0, 0, 8, 0 },
				font = _boldfont(20),
			},
		},
		selected = {
			item = {
				text = {
					padding = { 0, 0, 8, 0 },
					font = _boldfont(23),
				},
			},
		},
	})
	s.input_time_12h.hourUnselected = _uses(s.input_time_12h.hour, {
		item = {
			text = {
				fg = { 0x66, 0x66, 0x66 },
				font = _boldfont(21),
			},
		},
		selected = {
			item = {
				bgImg = false,
				text = {
					fg = { 0x66, 0x66, 0x66 },
					font = _boldfont(21),
					padding = { 2, 0, 12, 0 },
				},
			},
		},
	})
	s.input_time_12h.minuteUnselected = _uses(s.input_time_12h.minute, {
		item = {
			text = {
				fg = { 0x66, 0x66, 0x66 },
				font = _boldfont(21),
			},
		},
		selected = {
			item = {
				bgImg = false,
				text = {
					fg = { 0x66, 0x66, 0x66 },
					font = _boldfont(21),
					padding = { 2, 0, 12, 0 },
				},
			},
		},
	})
	s.input_time_12h.ampmUnselected = _uses(s.input_time_12h.ampm, {
		item = {
			text = {
				fg = { 0x66, 0x66, 0x66 },
				font = _boldfont(20),
				padding = { 0, 0, 8, 0 },
			},
		},
		selected = {
			item = {
				bgImg = false,
				text = {
					fg = { 0x66, 0x66, 0x66 },
					font = _boldfont(20),
					padding = { 0, 0, 8, 0 },
				},
			},
		},
	})

	s.input_time_24h = _uses(s.input_time_12h, {
		hour = {
			border = { _timeFirstColumnX24h, 16, 0, 24 },
		},
		minute = {
			border = { _timeFirstColumnX24h + 65, 16, 0, 24 },
		},
		hourUnselected = {
			border = { _timeFirstColumnX24h, 16, 0, 24 },
		},
		minuteUnselected = {
			border = { _timeFirstColumnX24h + 65, 16, 0, 24 },
		},
	})


	-- icon_list window
	s.icon_list = _uses(s.window, {
		menu = _uses(s.menu, {
			itemHeight = c.LINE_ITEM_HEIGHT,
			item = {
				order = { "icon", "text", "arrow" },
				padding = c.MENU_ALBUMITEM_PADDING,
				text = {
					align = "top-left",
					w = WH_FILL,
					h = WH_FILL,
					padding = c.MENU_ALBUMITEM_TEXT_PADDING,
					font = _font(c.ALBUMMENU_SMALL_FONT_SIZE),
					line = {
					{
						font = _boldfont(18),
						height = 20,
					},
					{
						font = _font(14),
						height = 18,
					},
			},
			fg = c.TEXT_COLOR,
					sh = c.TEXT_SH_COLOR,
				},
				icon = {
					w = c.THUMB_SIZE,
					h = c.THUMB_SIZE,
				},
				arrow = s.img.rightArrow,
			},
		}),
	})


	s.icon_list.menu.item_checked = _uses(s.icon_list.menu.item, {
		order = { 'icon', 'text', 'check' },
		check = {
			align = c.ITEM_ICON_ALIGN,
			padding = c.CHECK_PADDING,
			img = _loadImage(self, "Icons/icon_check_off.png")
		},
	})

	s.icon_list.menu.item_play = _uses(s.icon_list.menu.item, {
		arrow = { 
			img = false, 
		},
	})
	s.icon_list.menu.item_add  = _uses(s.icon_list.menu.item)
	s.icon_list.menu.item_no_arrow = _uses(s.icon_list.menu.item)
	s.icon_list.menu.item_checked_no_arrow = _uses(s.icon_list.menu.item_checked)
	s.icon_list.menu.albumcurrent = _uses(s.icon_list.menu.item, {
		arrow = {
			img = _loadImage(self, "Icons/icon_nplay_off.png"),
		},
	})


	s.icon_list.menu.selected = {}
	s.icon_list.menu.selected.item = _uses(s.icon_list.menu.item, {
		order = { 'icon', 'text', 'arrow' },
		text = {
			font = _boldfont(c.TEXTMENU_FONT_SIZE),
			fg = c.SELECT_COLOR,
			sh = c.SELECT_SH_COLOR,
			line = {
					{
						font = _boldfont(21),
						height = 23,
					},
					{
						font = _font(14),
						height = 14,
					},
			},
               },
		bgImg = s.img.oneLineItemSelectionBox,
		arrow = s.img.rightArrowSel,
	})

	s.icon_list.menu.selected.item_checked          = _uses(s.icon_list.menu.selected.item, {
		order = { 'icon', 'text', 'check', 'arrow' },
	})
	s.icon_list.menu.selected.item_play             = _uses(s.icon_list.menu.selected.item, {
		arrow = { img = false},
	})
	s.icon_list.menu.selected.albumcurrent          = _uses(s.icon_list.menu.selected.item, {
		arrow = {
			img = _loadImage(self, "Icons/icon_nplay_sel.png"),
		},
	})
	s.icon_list.menu.selected.item_add              = _uses(s.icon_list.menu.selected.item)
	s.icon_list.menu.selected.item_no_arrow         = _uses(s.icon_list.menu.selected.item, {
		order = { 'icon', 'text' },
	})
	s.icon_list.menu.selected.item_checked_no_arrow = _uses(s.icon_list.menu.selected.item, {
		order = { 'icon', 'text', 'check' },
		check = s.img.checkMark,
	})

        s.icon_list.menu.pressed = {
                item = _uses(s.icon_list.menu.selected.item, {
			bgImg = threeItemPressedBox
		}),
                item_checked = _uses(s.icon_list.menu.selected.item_checked, {
			bgImg = threeItemPressedBox
		}),
                item_play = _uses(s.icon_list.menu.selected.item_play, {
			bgImg = threeItemPressedBox
		}),
                item_add = _uses(s.icon_list.menu.selected.item_add, {
			bgImg = threeItemPressedBox
		}),
                item_no_arrow = _uses(s.icon_list.menu.selected.item_no_arrow, {
			bgImg = threeItemPressedBox
		}),
                item_checked_no_arrow = _uses(s.icon_list.menu.selected.item_checked_no_arrow, {
			bgImg = threeItemPressedBox
		}),
                albumcurrent = _uses(s.icon_list.menu.selected.albumcurrent, {
			bgImg = threeItemPressedBox
		}),
        }
	s.icon_list.menu.locked = {
		item = _uses(s.icon_list.menu.pressed.item, {
			arrow = s.img.smallSpinny
		}),
		item_checked = _uses(s.icon_list.menu.pressed.item_checked, {
			arrow = s.img.smallSpinny
		}),
		item_play = _uses(s.icon_list.menu.pressed.item_play, {
			arrow = s.img.smallSpinny
		}),
		item_add = _uses(s.icon_list.menu.pressed.item_add, {
			arrow = s.img.smallSpinny
		}),
                albumcurrent = _uses(s.icon_list.menu.pressed.albumcurrent, {
			arrow = s.img.smallSpinny
		}),
	}

	s.multiline_text_list = _uses(s.text_list, {
		multiline_text = {
			w = WH_FILL,
			padding = { 10, 0, 2, 0 },
			lineHeight = 21,
			font = _font(18),
			fg = { 0xe6, 0xe6, 0xe6 },
			sh = { },
			align = "left",
		},
	})


	s.multiline_text_list.title = _uses(s.title, {
		h = 39,
	})

	s.multiline_text_list.menu =  _uses(s.menu, {
			h = screenHeight - 51,
			border = { 0, 39, 0, 24 },
			itemHeight = c.MULTILINE_LINE_ITEM_HEIGHT,
			scrollbar = { 
				h = c.MULTILINE_LINE_ITEM_HEIGHT - 8,
				border = { 0, 4, 0, 4 },
			},
			item = {
				order = { "icon", "text", "arrow" },
				padding = { 10, 13, 2, 8 },
				text = {
					align = "top-left",
					w = WH_FILL,
					h = WH_FILL,
					padding = c.MENU_ALBUMITEM_TEXT_PADDING,
					font = _font(18),
					lineHeight = 21,
					fg = { 0xe6, 0xe6, 0xe6 },
				},
				icon = {
					w = c.THUMB_SIZE,
					h = c.THUMB_SIZE,
					padding = { 0, 10, 10, 0 },
				},
				arrow = s.img.rightArrow,
			},
	})

	s.multiline_text_list.menu.item_no_arrow = _uses(s.multiline_text_list.menu.item)

	s.multiline_text_list.menu.selected = {}
	s.multiline_text_list.menu.selected.item = _uses(s.multiline_text_list.menu.item, {
		bgImg = s.img.multiLineSelectionBox,
		arrow = s.img.rightArrowSel,
	})
	s.multiline_text_list.menu.selected.item_no_arrow = _uses(s.multiline_text_list.menu.selected.item)
	
	s.multiline_text_list.menu.pressed = _uses(s.multiline_text_list.menu.selected)
	s.multiline_text_list.menu.locked = _uses(s.multiline_text_list.menu.selected, {
		item = {
			arrow = s.img.smallSpinny,
		},
	})
	-- information window
	s.information = _uses(s.window)

	s.information.text = {
		font = _font(16),
                fg = c.TEXT_COLOR,
                sh = c.TEXT_SH_COLOR,
                padding = { 10, 10, 10, 10},
                lineHeight = 20,
        }

	-- help window (likely the same as information)
	s.help_info = _uses(s.window, {
		text = {
			font = _font(c.TEXTAREA_FONT_SIZE),
		},
	})


	--track_list window
	-- XXXX todo
	s.track_list = _uses(s.text_list)

	s.track_list.title = _uses(s.title, {
		h = 22,
		order = { 'icon', 'text' },
		padding = { 10,0,0,0 },
		icon  = {
			w = 49,
			h = WH_FILL,
		},
		text = {
--			padding = c.MENU_ALBUMITEM_TEXT_PADDING,
			align = "top-left",
			font = _font(c.ALBUMMENU_TITLE_FONT_SIZE),
			lineHeight = c.ALBUMMENU_TITLE_FONT_SIZE + 1,
			line = {
					{
						font = _boldfont(c.ALBUMMENU_TITLE_FONT_SIZE),
						height = c.ALBUMMENU_TITLE_FONT_SIZE + 2,
					},
					{
						font = _font(14),
						height = 16,
					},
			},
		},
	})
	s.track_list.menu = _uses(s.menu, {
		itemHeight = 41,
		h = 41,
		border = { 0, 50, 0, 0 },
	})


	--playlist window
	-- identical to icon_list but with some different formatting on the text
	s.play_list = _uses(s.icon_list, {
		title = {
			order = { 'text' },
		},
		menu = {
			item = {
				text = {
					padding = c.MENU_PLAYLISTITEM_TEXT_PADDING,
					font = _font(c.ALBUMMENU_FONT_SIZE),
					lineHeight = 16,
					line = {
						{
							font = _boldfont(c.ALBUMMENU_FONT_SIZE),
							height = c.ALBUMMENU_FONT_SIZE + 3
						},
					},
				},
			},
		},
	})
	s.play_list.menu.item_checked = _uses(s.play_list.menu.item, {
		order = { 'icon', 'text', 'check', 'arrow' },
		check = {
			align = c.ITEM_ICON_ALIGN,
			padding = c.CHECK_PADDING,
			img = _loadImage(self, "Icons/icon_check_off.png")
		},
	})
	s.play_list.menu.selected = {
		item = _uses(s.play_list.menu.item, {
			text = {
				fg = c.SELECT_COLOR,
				sh = c.SELECT_SH_COLOR,
			},
			bgImg = s.img.oneLineItemSelectionBox,
		}),
		item_checked = _uses(s.play_list.menu.item_checked),
	}
	s.play_list.menu.pressed = {
		item = _uses(s.play_list.menu.item, { bgImg = threeItemPressedBox }),
		item_checked = _uses(s.play_list.menu.item_checked, { bgImg = threeItemPressedBox }),
	}
	s.play_list.menu.locked = {
		item = _uses(s.play_list.menu.pressed.item, {
			arrow = s.img.smallSpinny
		}),
		item_checked = _uses(s.play_list.menu.pressed.item_checked, {
			arrow = s.img.smallSpinny
		}),
	}

	-- software update window
	s.update_popup = _uses(s.popup)

	s.update_popup.text = {
                w = WH_FILL,
                h = (c.POPUP_TEXT_SIZE_1 + 8 ) * 2,
                position = LAYOUT_NORTH,
                border = { 0, 28, 0, 0 },
                padding = { 12, 0, 12, 0 },
                align = "center",
                font = _font(c.POPUP_TEXT_SIZE_1),
                lineHeight = c.POPUP_TEXT_SIZE_1 + 8,
                fg = c.TEXT_COLOR,
                sh = c.TEXT_SH_COLOR,
        }


        s.update_popup.subtext = {
                w = WH_FILL,
                -- note this is a hack as the height and padding push
                -- the content out of the widget bounding box.
                h = 30,
                padding = { 0, 0, 0, 36 },
                font = _boldfont(18),
                fg = c.TEXT_COLOR,
                sh = TEXT_SH_COLOR,
                align = "bottom",
                position = LAYOUT_SOUTH,
        }
	s.update_popup.progress = {
                border = { 12, 0, 12, 20 },
                position = LAYOUT_SOUTH,
                horizontal = 1,
                bgImg = s.img.progressBackground,
                img = s.img.progressBar,
        }


	-- toast_popup popup (is now text only)
	s.toast_popup_textarea = {
		padding = { 6, 6, 8, 8 } ,
		align = 'left',
		w = WH_FILL,
		h = 60,
		font = _boldfont(18),
		lineHeight = 21,
		fg = c.TEXT_COLOR,
		sh = c.TEXT_SH_COLOR,
		scrollbar = {
			h = 60,
		},
	}

	s.toast_popup = {
		x = 19,
		y = 46,
		w = screenWidth - 38,
		h = 60,
		bgImg = s.img.popupBox,
		group = {
			padding = { 12, 12, 12, 0 },
			order = { 'text' },
			text = {
				padding = { 6, 3, 8, 8 } ,
				align = 'center',
				w = WH_FILL,
				h = WH_FILL,
				font = _font(18),
				lineHeight = 17,
				line = {
					{
						font = _boldfont(18),
						height = 17
					},
				},
			},
		}
	}

	-- new style that incorporates text, icon, more text, and maybe a badge
	s.toast_popup_mixed = {
		x = 19,
		y = 16,
		position = LAYOUT_NONE,
		w = screenWidth - 38,
		h = 214,
		bgImg = s.img.popupBox,
		text = {
			position = LAYOUT_NORTH,
			padding = { 8, 24, 8, 0 },
			align = 'top',
			w = WH_FILL,
			h = WH_FILL,
			font = _boldfont(14),
			fg = c.TEXT_COLOR,
			sh = c.TEXT_SH_COLOR,
		},
		subtext = {
			position = LAYOUT_NORTH,
			padding = { 8, 178, 8, 0 },
			align = 'top',
			w = WH_FILL,
			h = WH_FILL,
			font = _boldfont(14),
			fg = c.TEXT_COLOR,
			sh = c.TEXT_SH_COLOR,
		},
	}

	s._badge = {
		position = LAYOUT_NONE,
		zOrder = 99,
		-- middle of the screen plus half of the icon width minus half of the badge width. gotta love LAYOUT_NONE
		x = screenWidth/2 + 21,
		w = 34,
		y = 34,
	}
	s.badge_none = _uses(s._badge, {
		img = false,
	})
	s.badge_favorite = _uses(s._badge, {
		img = _loadImage(self, "Icons/icon_badge_fav.png")
	})
	s.badge_add = _uses(s._badge, {
		img = _loadImage(self, "Icons/icon_badge_add.png")
	})

	-- toast without artwork
	s.toast_popup_text = _uses(s.toast_popup)

	-- toast popup with icon only
	s.toast_popup_icon = _uses(s.toast_popup, {
		w = 132,
		h = 60,
		x = 54,
		y = 2,
		position = LAYOUT_NONE,
		group = {
			order = { 'icon' },
			border = { 26, 26, 0, 0 },
			padding = 0,
			icon = {
				w = WH_FILL,
				h = WH_FILL,
				align = 'center',
			},
		}
	})

	-- context menu window
	s.context_menu = {

		x = 10,
		y = 2,
		w = screenWidth - 18,
		h = screenHeight - 4,
		border = 0,
		padding = 0,
		bgImg = s.img.contextMenuBox,
		layer = LAYER_TITLE,

		--FIXME, something very wrong here. space still being allocated for hidden, no height title
		title = {
			layer = LAYER_TITLE,
			hidden = 1,
			h = 0,
			text = {
				hidden = 1,
			},
			bgImg = false,
			border = 0,
		},

		multiline_text = {
			w = WH_FILL,
			h = screenHeight - 27,
			padding = { 14, 18, 14, 18 },
			border = { 0, 0, 6, 15 },
			lineHeight = 22,
			font = _font(18),
			fg = { 0xe6, 0xe6, 0xe6 },
			sh = { },
			align = "top-left",
			scrollbar = {
				h = screenHeight - 23,
				border = {0, 10, 2, 10},
			},
		},

		menu = {
			h = c.CM_MENU_HEIGHT,
			w = screenWidth - 32,
			x = 9,
			y = 10,
			border = 0,
			itemHeight = c.CM_MENU_HEIGHT,
			position = LAYOUT_NORTH,
			scrollbar = { 
				h = c.CM_MENU_HEIGHT - 4,
				border = {0,2,0,2},
			},
			item = {
				h = c.CM_MENU_HEIGHT,
				order = { "text", "arrow" },
				padding = { 8, 0, 5, 0 },
				text = {
					w = WH_FILL,
					h = WH_FILL,
					padding = { 0, 0, 0, 0 },
					align = 'left',
					fg = TEXT_COLOR,
					sh = TEXT_SH_COLOR,
					font = _font(c.ALBUMMENU_SMALL_FONT_SIZE),
					line = {
						{
							font = _boldfont(18),
							height = 20,
						},
						{
							font = _font(14),
							height = 18,
						},
					},
				},
				arrow = _uses(s.item.arrow),
				bgImg = false,
			},
			item_no_arrow = {
				bgImg = false,
			},
			selected = {
				item = {
					bgImg = s.img.contextMenuSelectionBox,
					order = { "text", "arrow" },
					padding = { 8, 0, 5, 0 },
					text = {
						w = WH_FILL,
						h = WH_FILL,
						align = 'left',
						font = _boldfont(c.TEXTMENU_FONT_SIZE),
						fg = c.SELECT_COLOR,
						sh = c.SELECT_SH_COLOR,
						padding = { 0, 2, 0, 0 },
						line = {
							{
								font = _boldfont(21),
								height = 23,
							},
							{
								font = _font(14),
								height = 14,
							},
						},	
					},
					arrow = _uses(s.selected.item.arrow),
				},
			},
			locked = {
				item = {
					bgImg = s.img.contextMenuSelectionBox,
				},
			}

		},
	}

	s.context_menu.menu.item_play = _uses(s.context_menu.menu.item, {
		arrow = {img = s.img.playArrow.img},
	})
	s.context_menu.menu.selected.item_play = _uses(s.context_menu.menu.selected.item, {
		arrow = {img = s.img.playArrowSel.img},
	})
	
	s.context_menu.menu.item_insert = _uses(s.context_menu.menu.item, {
		arrow = {img = s.img.itemAddNext.img},
	})
	s.context_menu.menu.selected.item_insert = _uses(s.context_menu.menu.selected.item, {
		arrow = {img = s.img.itemAddNextSel.img},
	})
	
	s.context_menu.menu.item_add = _uses(s.context_menu.menu.item, {
		arrow = {img = s.img.itemAdd.img},
	})
	s.context_menu.menu.selected.item_add = _uses(s.context_menu.menu.selected.item, {
		arrow = {img = s.img.itemAddSel.img},
	})
	
	s.context_menu.menu.item_playall = _uses(s.context_menu.menu.item, {
		arrow = {img = s.img.playAllArrow.img},
	})
	s.context_menu.menu.selected.item_playall = _uses(s.context_menu.menu.selected.item, {
		arrow = {img = s.img.playAllArrowSel.img},
	})
	
	s.context_menu.menu.item_fav = _uses(s.context_menu.menu.item, {
		arrow = {img = s.img.itemFav.img},
	})
	s.context_menu.menu.selected.item_fav = _uses(s.context_menu.menu.selected.item, {
		arrow = {img = s.img.itemFavSel.img},
	})

	s.context_menu.menu.item_no_arrow = _uses(s.context_menu.menu.item_play, {
		order = { 'text' },
	})
	s.context_menu.menu.selected.item_no_arrow = _uses(s.context_menu.menu.selected.item, {
		order = { 'text' },
	})

	s.alarm_header = {
			w = screenWidth - 20,
			order = { 'time' },
			time = {
				h = WH_FILL,
				w = WH_FILL,
			},
	}

	s.alarm_time = {
		w = WH_FILL,
		fg = c.TEXT_COLOR,
		sh = c.TEXT_SH_COLOR,
		align = "center",
--TODO
		font = _font(52),
	}
	s.preview_text = _uses(s.alarm_time, {
		font = _boldfont(c.TITLE_FONT_SIZE),
	})

	-- alarm menu window
	s.alarm_popup = {
		x = 10,
		y = 10,
		w = screenWidth - 20,
		h = screenHeight - 17,
		border = 0,
		padding = 0,
		bgImg = s.img.contextMenuBox,
		maskImg = s.img.popupMask,
		layer = LAYER_TITLE,

		title = {
			hidden = 1,
		},

		menu = {
			h = c.CM_MENU_HEIGHT,
			w = screenWidth - 34,
			x = 7,
			y = 3,
			border = 0,
			itemHeight = c.CM_MENU_HEIGHT,
			position = LAYOUT_NORTH,
			scrollbar = { 
				h = c.CM_MENU_HEIGHT - 8,
				border = {0,4,0,0},
			},
			item = {
				h = c.CM_MENU_HEIGHT,
				order = { "text", "arrow" },
				text = {
					w = WH_FILL,
					h = WH_FILL,
					align = 'left',
					font = _boldfont(c.TEXTMENU_FONT_SIZE),
					fg = TEXT_COLOR,
					sh = TEXT_SH_COLOR,
				},
				arrow = _uses(s.item.arrow),
			},
			selected = {
				item = {
					bgImg = s.img.contextMenuSelectionBox,
					order = { "text", "arrow" },
					text = {
						w = WH_FILL,
						h = WH_FILL,
						align = 'left',
						font = _boldfont(c.TEXTMENU_FONT_SIZE),
						fg = c.TEXT_COLOR,
						sh = c.TEXT_SH_COLOR,
					},
					arrow = _uses(s.item.arrow),
				},
			},

		},
	}

	-- slider popup (volume)
	s.slider_popup = {
		x = 6,
		y = 3,
		w = screenWidth - 12,
		h = 60,
		bgImg = s.img.popupBox,
		heading = {
			w = WH_FILL,
			align = 'center',
			padding = { 4, 12, 4, 0 },
			font = _boldfont(c.TITLE_FONT_SIZE),
			fg = c.TEXT_COLOR,
		},
		slider_group = {
			w = WH_FILL,
			align = 'center',
			border = { 8, 0, 8, 0 },
			order = { "slider" },
		},
	}

	-- scanner popup
	s.scanner_popup = _uses(s.slider_popup, {
		y = 3,
		h = 60,
		heading = {
			padding = { 4, 12, 4, 0 },
		},
		slider_group = {
			border = { 8, 0, 8, 0 },
		},
	})


	s.image_popup = _uses(s.popup, {
		image = {
                        w = screenWidth,
                        position = LAYOUT_CENTER,
                        align = "center",
                        h = screenHeight,
                        border = 0,
                },
	})


--------- SLIDERS ---------

	s.volume_slider = _uses(s.slider, {
		img = s.img.volumeBar,
		bgImg = s.img.volumeBackground,
	})

	s.scanner_slider = s.volume_slider


--------- BUTTONS ---------


--------- ICONS --------

	-- icons used for 'waiting' and 'update' windows
	s._icon = {
		hidden = 1,
--		w = WH_FILL,
--		zOrder = 1,
--		align = "right",
--		position = LAYOUT_RIGHT,
--		padding = { 0, 25, 0, 5 }
	}

	-- icon for albums with no artwork
	s.icon_no_artwork = {
		img = _loadImage(self, "IconsResized/icon_album_noart.png"),
		w   = c.THUMB_SIZE,
		h   = c.THUMB_SIZE,
	}

	s.icon_connecting = _uses(s._icon, {
		img = _loadImage(self, "Alerts/wifi_connecting.png"),
		frameRate = 8,
		frameWidth = 120,
		padding = { 0, 25, 0, 5 }
	})

	s.icon_connected = _uses(s.icon_connecting, {
		img = _loadImage(self, "Alerts/connecting_success_icon.png"),
	})

	s.icon_photo_loading = _uses(s._icon, {
		img = _loadImage(self, "Icons/image_viewer_loading.png"),
		padding = { 5, 40, 0, 5 }
	})

	s.icon_software_update = _uses(s._icon, {
                img = _loadImage(self, "IconsResized/icon_firmware_update.png"),
		padding = { 0, 0, 0, 44 },
        })

        s.icon_restart = _uses(s._icon, {
                img = _loadImage(self, "IconsResized/icon_restart.png"),
        })

	s.icon_power = _uses(s._icon, {
		img = _loadImage(self, "Icons/icon_shut_down.png"),
		padding = { 0, 18, 0, 5 },
	})

	s.icon_battery_low = _uses(s._icon, {
		padding = { 0, 11, 0, 0 },
		img = _loadImage(self, "Icons/icon_popup_box_battery.png"),
	})
	s.icon_locked = _uses(s._icon, {
		img = _loadImage(self, "Icons/icon_locked.png"),
	})
	s.icon_art = _uses(s._icon, {
		padding = 0,
                img = false,
	})
	s.icon_linein = _uses(s._icon, {
                img = _loadImage(self, "IconsResized/icon_linein_143.png"),
		w = WH_FILL,
		align = "center",
		padding = { 0, 66, 0, 0 },
	})

	s.icon_alarm = {
		img = _loadImage(self, "Icons/icon_alarm.png")
	}

	s._popupIcon = {
		w = WH_FILL,
		h = 70,
		align = 'center',
		padding = 0,
	}
	s.icon_popup_volume = _uses(s._popupIcon, {
		hidden = 1,
--		img = _loadImage(self, "Icons/icon_popup_box_volume_bar.png"),
	})
	s.icon_popup_mute = _uses(s._popupIcon, {
		hidden = 1,
--		img = _loadImage(self, "Icons/icon_popup_box_volume_mute.png"),
	})
	s.icon_popup_sleep_15 = _uses(s._popupIcon, {
		img = _loadImage(self, "Icons/icon_popup_box_sleep_15.png"),
		h = WH_FILL,
		w = WH_FILL,
		padding = { 0, 8, 0, 0 },
	})
	s.icon_popup_sleep_30 = _uses(s.icon_popup_sleep_15, {
		img = _loadImage(self, "Icons/icon_popup_box_sleep_30.png"),
	})
	s.icon_popup_sleep_45 = _uses(s.icon_popup_sleep_15, {
		img = _loadImage(self, "Icons/icon_popup_box_sleep_45.png"),
	})
	s.icon_popup_sleep_60 = _uses(s.icon_popup_sleep_15, {
		img = _loadImage(self, "Icons/icon_popup_box_sleep_60.png"),
	})
	s.icon_popup_sleep_90 = _uses(s.icon_popup_sleep_15, {
		img = _loadImage(self, "Icons/icon_popup_box_sleep_90.png"),
	})
	s.icon_popup_sleep_cancel = _uses(s.icon_popup_sleep_15, {
		img = _loadImage(self, "Icons/icon_popup_box_sleep_off.png"),
	})

	s.icon_popup_shuffle0 = {
		img = _loadImage(self, "Icons/icon_popup_box_shuffle_off.png"),
		h = WH_FILL,
	}
	s.icon_popup_shuffle1 = _uses(s.icon_popup_shuffle0, {
		img = _loadImage(self, "Icons/icon_popup_box_shuffle.png"),
	})
	s.icon_popup_shuffle2 = _uses(s.icon_popup_shuffle0, {
		img = _loadImage(self, "Icons/icon_popup_box_shuffle_album.png"),
	})

	s.icon_popup_repeat0 = _uses(s.icon_popup_shuffle0, {
		img = _loadImage(self, "Icons/icon_popup_box_repeat_off.png"),
	})
	s.icon_popup_repeat1 = _uses(s.icon_popup_shuffle0, {
		img = _loadImage(self, "Icons/icon_popup_box_repeat_song.png"),
	})
	s.icon_popup_repeat2 = _uses(s.icon_popup_shuffle0, {
		img = _loadImage(self, "Icons/icon_popup_box_repeat.png"),
	})

	s._popupTransportIcon = {
		padding = { 26, 26, 0, 0, },
	}

	s.icon_popup_pause = _uses(s._popupTransportIcon, {
		img = _loadImage(self, "Icons/icon_popup_box_pause.png"),
	})
	s.icon_popup_play = _uses(s._popupTransportIcon, {
		img = _loadImage(self, "Icons/icon_popup_box_play.png"),
	})
	s.icon_popup_fwd = _uses(s._popupTransportIcon, {
		img = _loadImage(self, "Icons/icon_popup_box_fwd.png"),
	})
	s.icon_popup_rew = _uses(s._popupTransportIcon, {
		img = _loadImage(self, "Icons/icon_popup_box_rew.png"),
	})
	s.icon_popup_stop = _uses(s._popupTransportIcon, {
		img = _loadImage(self, "Icons/icon_popup_box_stop.png"),
	})
	s.icon_popup_lineIn = _uses(s._popupTransportIcon, {
		img = _loadImage(self, "IconsResized/icon_linein_80.png"),
	})

	s.presetPointer3 = {
		w = WH_FILL,
		h = WH_FILL,
		position = LAYOUT_NONE,
		x = 10,
		y = screenHeight - 22,
		img = _loadImage(self, "UNOFFICIAL/preset3.png"),
	}

	s.presetPointer6 = {
		w = WH_FILL,
		h = WH_FILL,
		position = LAYOUT_NONE,
		x = screenWidth - 100,
		y = screenHeight - 22,
		img = _loadImage(self, "UNOFFICIAL/preset6.png"),
	}


	-- button icons, on left of menus
	s._buttonicon = {
		border = c.MENU_ITEM_ICON_PADDING,
		align = 'center',
		h = c.THUMB_SIZE,
	}
	s._selectedButtonicon = {
		border = c.MENU_ITEM_ICON_PADDING,
		align = 'center',
		h = c.THUMB_SIZE,
	}


        s.region_US = _uses(s._buttonicon, {
                img = _loadImage(self, "IconsResized/icon_region_americas" .. skinSuffix),
        })
        s.region_XX = _uses(s._buttonicon, {
                img = _loadImage(self, "IconsResized/icon_region_other" .. skinSuffix),
        })

        s.icon_help = _uses(s._buttonicon, {
                img = _loadImage(self, "IconsResized/icon_help" .. skinSuffix),
        })

	s.player_transporter = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_transporter.png"),
	})
	s.player_squeezebox = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_SB1n2.png"),
	})
	s.player_squeezebox2 = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_SB1n2.png"),
	})
	s.player_squeezebox3 = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_SB3.png"),
	})
	s.player_boom = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_boom.png"),
	})
	s.player_slimp3 = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_slimp3.png"),
	})
	s.player_softsqueeze = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_softsqueeze.png"),
	})
	s.player_controller = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_controller.png"),
	})
	s.player_receiver = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_receiver.png"),
	})
	s.player_squeezeplay = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_squeezeplay.png"),
	})
	s.player_fab4 = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_fab4.png"),
	})
	s.player_baby = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_baby.png"),
	})
	s.player_http = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_tunein_url.png"),
	})

	-- misc home menu icons
	s.hm_appletImageViewer = _uses(s._buttonicon, {
                img = _loadImage(self, "IconsResized/icon_image_viewer" .. skinSuffix),
        })
	s.hm_appletNowPlaying = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_nowplaying" .. skinSuffix),
	})
	s.hm_eject = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_eject" .. skinSuffix),
	})
	s.hm_usbdrive = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_device_USB" .. skinSuffix),
	})
	s.hm_sdcard = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_device_SDcard" .. skinSuffix),
	})
	s.hm_settings = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings" .. skinSuffix),
	})
	s.hm_advancedSettings = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_adv" .. skinSuffix),
	})
	s.hm_radio = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_internet_radio" .. skinSuffix),
	})
	s.hm_radios = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_internet_radio" .. skinSuffix),
	})
	s.hm_myApps = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_my_apps" .. skinSuffix),
	})
	s.hm_myMusic = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_mymusic" .. skinSuffix),
	})
	s.hm__myMusic = _uses(s.hm_myMusic)
	s.hm_otherLibrary = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_ml_other_library" .. skinSuffix),
	})
	s.hm_myMusicSelector = _uses(s.hm_myMusic)

	s.hm_favorites = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_favorites" .. skinSuffix),
	})
	s.hm_settingsAlarm = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_alarm" .. skinSuffix),
	})
	s.hm_settingsPlayerNameChange = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_name" .. skinSuffix),
	})
	s.hm_settingsBrightness = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_brightness" .. skinSuffix),
	})
	s.hm_settingsSync = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_sync" .. skinSuffix),
	})
	s.hm_selectPlayer = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_choose_player" .. skinSuffix),
	})
	s.hm_quit = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_power_off" .. skinSuffix),
	})
	s.hm_playerpower = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_power_off" .. skinSuffix),
	})
	s.hm_settingsScreen = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_blank" .. skinSuffix),
	})
	s.hm_myMusicArtists = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_ml_artist" .. skinSuffix),
	})
	s.hm_myMusicAlbums = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_ml_albums" .. skinSuffix),
	})
	s.hm_myMusicGenres = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_ml_genres" .. skinSuffix),
	})
	s.hm_myMusicYears = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_ml_years" .. skinSuffix),
	})

	s.hm_myMusicNewMusic = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_ml_new_music" .. skinSuffix),
	})
	s.hm_myMusicPlaylists = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_ml_playlist" .. skinSuffix),
	})
	s.hm_myMusicSearch = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_ml_search" .. skinSuffix),
	})
        s.hm_myMusicSearchArtists   = _uses(s.hm_myMusicSearch)
        s.hm_myMusicSearchAlbums    = _uses(s.hm_myMusicSearch)
        s.hm_myMusicSearchSongs     = _uses(s.hm_myMusicSearch)
        s.hm_myMusicSearchPlaylists = _uses(s.hm_myMusicSearch)
        s.hm_myMusicSearchRecent    = _uses(s.hm_myMusicSearch)
        s.hm_homeSearchRecent       = _uses(s.hm_myMusicSearch)
        s.hm_globalSearch           = _uses(s.hm_myMusicSearch)

	s.hm_myMusicMusicFolder = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_ml_folder" .. skinSuffix),
	})
	s.hm_randomplay = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_ml_random" .. skinSuffix),
	})
	s.hm_skinTest = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_blank" .. skinSuffix),
	})

	s.hm_settingsBrightness = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_brightness" .. skinSuffix),
	})
	s.hm_settingsRepeat = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_repeat" .. skinSuffix),
	})
	s.hm_settingsShuffle = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_shuffle" .. skinSuffix),
	})
	s.hm_settingsSleep = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_sleep" .. skinSuffix),
	})
	s.hm_settingsScreen = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_screen" .. skinSuffix),
	})
	s.hm_appletCustomizeHome = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_home" .. skinSuffix),
	})
	s.hm_settingsAudio = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_audio" .. skinSuffix),
	})
	s.hm_linein = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_linein" .. skinSuffix),
	})
	-- ??
	s.hm_settingsPlugin = _uses(s._buttonicon, {
		img = _loadImage(self, "IconsResized/icon_settings_plugin" .. skinSuffix),
	})

	-- indicator icons, on right of menus
	s._indicator = {
		align = "right",
		padding = { 0, 0, 3, 0 },
	}

	s.wirelessLevel0 = _uses(s._indicator, {
		img = _loadImage(self, "Icons/icon_wireless_0_off.png")
	})
	s.menu.selected.item.wirelessLevel0 = _uses(s.wirelessLevel0, {
		img = _loadImage(self, "Icons/icon_wireless_0_sel.png"),
		padding = 0,
	})

	s.wirelessLevel1 = _uses(s._indicator, {
		img = _loadImage(self, "Icons/icon_wireless_1_off.png")
	})
	s.menu.selected.item.wirelessLevel1 = _uses(s.wirelessLevel1, {
		img = _loadImage(self, "Icons/icon_wireless_1_sel.png"),
		padding = 0,
	})

	s.wirelessLevel2 = _uses(s._indicator, {
		img = _loadImage(self, "Icons/icon_wireless_2_off.png")
	})
	s.menu.selected.item.wirelessLevel2 = _uses(s.wirelessLevel2, {
		img = _loadImage(self, "Icons/icon_wireless_2_sel.png"),
		padding = 0,
	})

	s.wirelessLevel3 = _uses(s._indicator, {
		img = _loadImage(self, "Icons/icon_wireless_3_off.png")
	})
	s.menu.selected.item.wirelessLevel3 = _uses(s.wirelessLevel3, {
		img = _loadImage(self, "Icons/icon_wireless_3_sel.png"),
		padding = 0,
	})

	s.wirelessLevel4 = _uses(s._indicator, {
		img = _loadImage(self, "Icons/icon_wireless_4_off.png")
	})
	s.menu.selected.item.wirelessLevel4 = _uses(s.wirelessLevel4, {
		img = _loadImage(self, "Icons/icon_wireless_4_sel.png"),
		padding = 0,
	})


--------- ICONBAR ---------

	s.iconbar_group = {
		hidden = 1,
	}

	-- time
	s.button_time = {
		hidden = 1,
	}

	s.demo_text = {
		h = 50,
		font = _boldfont(14),
		position = LAYOUT_SOUTH,
		w = screenWidth,
		align = 'center',
		padding = { 6, 0, 6, 10 },
		fg = c.TEXT_COLOR,
		sh = c.TEXT_SH_COLOR,
	}

	s.keyboard = { hidden = 1 }

	s.debug_canvas = {
			zOrder = 9999
	}


	local NP_ARTISTALBUM_FONT_SIZE = 18
	local NP_TRACK_FONT_SIZE = 26
	local NP_TITLE_HEIGHT = 31
	local NP_TRACKINFO_RIGHT_PADDING = 9

	local _tracklayout = {
		border = 0,
		position = LAYOUT_NORTH,
		w = WH_FILL,
		align = "left",
		lineHeight = NP_TRACK_FONT_SIZE,
		fg = { 0xe7, 0xe7, 0xe7 },
	}

	s.nowplaying = _uses(s.window, {
		bgImg = Tile:fillColor(0x000000ff),
		title = {
			zOrder = 9,
			h = 64,
			text = {
				hidden = 1,
			},
		},
		-- Song metadata
		nptitle = {
			order = { 'nptrack', 'xofy' },
			border     = _tracklayout.border,
			position   = _tracklayout.position,
			zOrder = 10,
			nptrack =  {
				w          = _tracklayout.w,
				align      = _tracklayout.align,
				lineHeight = _tracklayout.lineHeight,
				fg         = _tracklayout.fg,
				padding    = { 10, 3, 0, 0 },
				font       = _boldfont(NP_TRACK_FONT_SIZE), 
			},
			xofy =  {
				w          = 48,
				align      = 'right',
				fg         = _tracklayout.fg,
				padding    = { 0, 2, NP_TRACKINFO_RIGHT_PADDING, 0 },
				font       = _font(15), 
			},
			xofySmall =  {
				w          = 48,
				align      = 'right',
				fg         = _tracklayout.fg,
				padding    = { 0, 2, NP_TRACKINFO_RIGHT_PADDING, 0 },
				font       = _font(10), 
			},
		},
		npartistalbum  = {
			zOrder = 10,
			border     = _tracklayout.border,
			position   = _tracklayout.position,
			w          = _tracklayout.w,
			align      = _tracklayout.align,
			lineHeight = _tracklayout.lineHeight,
			fg = { 0xb3, 0xb3, 0xb3 },
			padding    = { 10, NP_TRACK_FONT_SIZE + 2, 10, 0 },
			font       = _font(NP_ARTISTALBUM_FONT_SIZE),
		},
		nptrack       = { hidden = 1},
		npalbumgroup  = { hidden = 1},
		npartistgroup = { hidden = 1},
		npalbum       = { hidden = 1},
		npartist      = { hidden = 1},
		npvisu        = { hidden = 1},
	
		-- cover art
		npartwork = {
			hidden = 1,
--			position = LAYOUT_WEST,
--			zOrder = 1,
--			w = WH_FILL,
--			align = "center",
--			artwork = {
--				w = WH_FILL,
--				align = "center",
--				padding = { 0, 0, 0, 0 },
--				img = false,
--			},
		},
	
		--transport controls
		npcontrols = { hidden = 1 },
	
		-- Progress bar
		npprogress = {
			zOrder = 10,
			position = LAYOUT_NORTH,
			padding = { 10, 0, 10, 0 },
			border = { 0, 46, 0, 0 },
			w = WH_FILL,
			order = { 'elapsed', 'slider', 'remain' },
			elapsed = {
				zOrder = 10,
				font = _boldfont(12),
				fg = { 0xb3, 0xb3, 0xb3 },
			},
			remain = {
				zOrder = 10,
				font = _boldfont(12),
				fg = { 0xb3, 0xb3, 0xb3 },
			},
			elapsedSmall = {
				zOrder = 10,
				font = _boldfont(9),
				fg = { 0xb3, 0xb3, 0xb3 },
			},
			remainSmall = {
				zOrder = 10,
				font = _boldfont(9),
				fg = { 0xb3, 0xb3, 0xb3 },
			},
			npprogressB = {
				w = WH_FILL,
				align = 'center',
				border = { 10, 0, 10, 0 },
				horizontal = 1,
				bgImg = s.img.songProgressBackground,
				img = s.img.songProgressBar,
				h = 15,
			},
		},
	
		-- special style for when there shouldn't be a progress bar (e.g., internet radio streams)
		npprogressNB = {
			zOrder = 10,
			position = LAYOUT_NORTH,
			padding = { 10, 0, 0, 0 },
			border = { 0, 63, 0, 0 },
			align = 'center',
			w = WH_FILL,
			order = { 'elapsed' },
			elapsed = {
				w = WH_FILL,
				align = 'left',
				font = _boldfont(12),
				fg = { 0xb3, 0xb3, 0xb3 },
			},
			
		},
	
	})

	s.nowplaying.npprogressNB.elapsedSmall = s.nowplaying.npprogressNB.elapsed

--	s.nowplaying.pressed = s.nowplaying

	-- sliders
        s.nowplaying.npprogress.npprogressB_disabled = _uses(s.nowplaying.npprogress.npprogressB)

	s.npvolumeB = { hidden = 1 }
	s.npvolumeB_disabled = { hidden = 1 }

	-- line in is the same as s.nowplaying but with transparent background
	s.linein = _uses(s.nowplaying, {
		bgImg = false,
	})

	s.nowplaying_visualizer_common = _uses(s.nowplaying, {
		bgImg = nocturneWallpaper,

		npartistgroup = { hidden = 1 },
		npalbumgroup = { hidden = 1 },
		npartwork = { hidden = 1 },
		title = { hidden = 1 },

		-- Drawn over regular test between buttons
		nptitle = { hidden = 1 },
		npartistalbum = { hidden = 1 },
		npprogress = { hidden = 1 },
		npprogressNB = { hidden = 1 },
	})
	s.nowplaying_visualizer_common.npprogress.npprogressB_disabled = s.nowplaying_visualizer_common.npprogress.npprogressB


	-- Visualizer: Spectrum Visualizer
	s.nowplaying_spectrum_text = _uses(s.nowplaying_visualizer_common, {
		npvisu = {
			hidden = 0,
			position = LAYOUT_NONE,
			x = 0,
			y = 0,
			w = 256,
			h = 62,
			border = { 0, 0, 0, 0 },
			padding = { 0, 0, 0, 0 },

			spectrum = {
				position = LAYOUT_NONE,
				x = 0,
				y = 0,
				w = 256,
				h = 62,
				border = { 0, 0, 0, 0 },
				padding = { 0, 0, 0, 0 },

				bg = { 0x00, 0x00, 0x00, 0x00 },

				barColor = { 0x90, 0x90, 0x90, 0xff },
				capColor = { 0xd0, 0xd0, 0xd0, 0xff },

				isMono = 0,				-- 0 / 1
				minBands = 48,

				capHeight = { 2, 2 },			-- >= 0
				capSpace = { 2, 2 },			-- >= 0
				channelFlipped = { 0, 1 },		-- 0 / 1
				barsInBin = { 2, 2 },			-- > 1
				barWidth = { 1, 1 },			-- > 1
				barSpace = { 1, 1 },			-- >= 0
				binSpace = { 3, 3 },			-- >= 0
				clipSubbands = { 1, 1 },		-- 0 / 1
			}
		},
	})
	s.nowplaying_spectrum_text.pressed = s.nowplaying_spectrum_text

	-- Visualizer: Analog VU Meter
	s.nowplaying_vuanalog_text = _uses(s.nowplaying_visualizer_common, {
		npvisu = {
			zOrder = 10,
			hidden = 0,
			position = LAYOUT_NONE,
			x = 0,
			y = 0,
			w = 256,
			h = 64,
			border = { 0, 0, 0, 0 },
			padding = { 0, 0, 0, 0 },

			vumeter_analog = {
				position = LAYOUT_NONE,
				x = 0,
				y = 0,
				w = 240,
				h = 64,
				border = { 8, 0, 8, 0 },
				padding = { 8, 0, 8, 0 },
				bgImg = _loadImage(self, "UNOFFICIAL/VUMeter/vu_analog_25seq_b.png"),
			}
		},
	})
	s.nowplaying_vuanalog_text.pressed = s.nowplaying_vuanalog_text

end


--[[

=head1 LICENSE

Copyright 2010 Logitech. All Rights Reserved.

This file is licensed under BSD. Please see the LICENSE file for details.

=cut
--]]

