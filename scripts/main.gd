extends Control
## Pixel Quest, Week 1: a deliberately incomplete starter.
## Included: PixelBot introduction, RGB exploration, live preview, navigation.
## Students add: target-color challenge, feedback, scaffold, independent retry,
## reflection, and optional interaction logging.

const BACKGROUND := Color("10182b")
const PANEL := Color("1d2b47")
const ACCENT := Color("66dbdd")
const TEXT := Color("f3f7ff")
const MUTED := Color("c4d2e4")

var intro_panel: VBoxContainer
var explore_panel: VBoxContainer
var red_slider: HSlider
var green_slider: HSlider
var blue_slider: HSlider
var red_value: Label
var green_value: Label
var blue_value: Label
var color_preview: ColorRect
var rgb_readout: Label


func _ready() -> void:
	_build_layout()
	_show_intro()


func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 64)
	outer.add_theme_constant_override("margin_right", 64)
	outer.add_theme_constant_override("margin_top", 38)
	outer.add_theme_constant_override("margin_bottom", 38)
	add_child(outer)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	outer.add_child(column)

	var eyebrow := _label("PIXEL QUEST   /   MISSION 02: RGB MIXING", 15, ACCENT)
	column.add_child(eyebrow)
	column.add_child(_label("Restore the Exoplanet's Colors", 32, TEXT))
	column.add_child(_label("A starter scene for your first complete learning unit", 15, MUTED))
	column.add_child(HSeparator.new())

	intro_panel = VBoxContainer.new()
	intro_panel.add_theme_constant_override("separation", 20)
	column.add_child(intro_panel)
	intro_panel.add_child(_label("PIXELBOT  •  Mission briefing", 20, ACCENT))
	intro_panel.add_child(_label("Welcome, explorer! Our camera shows strange colors on the exoplanet. Before we repair them, let's discover how red, green, and blue light combine.", 20, TEXT))
	intro_panel.add_child(_label("Your task: experiment with the three RGB controls. What changes when you increase just one channel?", 17, MUTED))
	var start_button := _button("Begin RGB exploration")
	start_button.pressed.connect(_show_explore)
	intro_panel.add_child(start_button)

	explore_panel = VBoxContainer.new()
	explore_panel.add_theme_constant_override("separation", 13)
	column.add_child(explore_panel)
	explore_panel.add_child(_label("PIXELBOT  •  Exploration lab", 20, ACCENT))
	explore_panel.add_child(_label("Move the sliders. Watch the preview change immediately. RGB values range from 0 to 255.", 17, TEXT))

	var activity := HBoxContainer.new()
	activity.add_theme_constant_override("separation", 40)
	explore_panel.add_child(activity)

	var controls := VBoxContainer.new()
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_theme_constant_override("separation", 16)
	activity.add_child(controls)

	var red := _make_slider_row("Red", 218.0)
	controls.add_child(red[0])
	red_slider = red[1]
	red_value = red[2]
	var green := _make_slider_row("Green", 105.0)
	controls.add_child(green[0])
	green_slider = green[1]
	green_value = green[2]
	var blue := _make_slider_row("Blue", 168.0)
	controls.add_child(blue[0])
	blue_slider = blue[1]
	blue_value = blue[2]

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(245, 0)
	right.add_theme_constant_override("separation", 9)
	activity.add_child(right)
	right.add_child(_label("LIVE COLOR PREVIEW", 14, MUTED))
	color_preview = ColorRect.new()
	color_preview.custom_minimum_size = Vector2(245, 185)
	right.add_child(color_preview)
	rgb_readout = _label("", 16, TEXT)
	right.add_child(rgb_readout)

	red_slider.value_changed.connect(_update_preview)
	green_slider.value_changed.connect(_update_preview)
	blue_slider.value_changed.connect(_update_preview)
	_update_preview(0)

	explore_panel.add_child(HSeparator.new())
	explore_panel.add_child(_label("Think about it: What happens when all three channels are 0? What happens when all are 255?", 17, TEXT))
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 14)
	explore_panel.add_child(nav)
	var back := _button("Back to briefing")
	back.pressed.connect(_show_intro)
	nav.add_child(back)
	var next := _button("Next: build the challenge →")
	next.pressed.connect(_show_placeholder)
	nav.add_child(next)


func _show_intro() -> void:
	intro_panel.visible = true
	explore_panel.visible = false


func _show_explore() -> void:
	intro_panel.visible = false
	explore_panel.visible = true


func _show_placeholder() -> void:
	# Students replace this placeholder with a real color-matching activity.
	var dialog := AcceptDialog.new()
	dialog.title = "Your Week 1 development task"
	dialog.dialog_text = "Build the rest of the unit here: target-color challenge, feedback, scaffold, independent application, and reflection."
	add_child(dialog)
	dialog.popup_centered(Vector2i(560, 180))
	dialog.confirmed.connect(dialog.queue_free)
	dialog.close_requested.connect(dialog.queue_free)


func _update_preview(_unused: float) -> void:
	var r := int(red_slider.value)
	var g := int(green_slider.value)
	var b := int(blue_slider.value)
	color_preview.color = Color8(r, g, b)
	red_value.text = str(r)
	green_value.text = str(g)
	blue_value.text = str(b)
	rgb_readout.text = "RGB (%d, %d, %d)" % [r, g, b]


func _make_slider_row(channel_name: String, initial: float) -> Array:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 5)
	var heading := HBoxContainer.new()
	group.add_child(heading)
	var name_label := _label(channel_name, 17, TEXT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(name_label)
	var value_label := _label(str(int(initial)), 17, MUTED)
	heading.add_child(value_label)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 255
	slider.step = 1
	slider.value = initial
	slider.custom_minimum_size = Vector2(340, 24)
	group.add_child(slider)
	return [group, slider, value_label]


func _button(title: String) -> Button:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(220, 45)
	return button


func _label(title: String, font_size: int, font_color: Color) -> Label:
	var result := Label.new()
	result.text = title
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", font_color)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return result
