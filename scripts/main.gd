extends Control
## Pixel Quest, Week 1: complete RGB Mixing learning unit.
##
## Six stages:
##   1 Introduction -> 2 Exploration -> 3 Challenge -> 4 Scaffold + revision
##   (appears inside the challenge) -> 5 Independent application -> 6 Reflection + completion.
##
## DESIGN RULES (document these in the group report):
##   - A color match means EVERY channel is within +/- TOLERANCE of the target.
##   - Scaffold trigger: two unsuccessful submissions in the first challenge.
##   - Scaffold level 1 (2+ misses): a guiding question about the channel that is furthest off.
##   - Scaffold level 2 (4+ misses): the hint also says whether that channel is too high or too low.
##   - The independent challenge never shows automatic hints.
##   - Every attempt is logged on screen and saved to a local JSON file.

const BACKGROUND := Color("10182b")
const PANEL := Color("1d2b47")
const ACCENT := Color("66dbdd")
const TEXT := Color("f3f7ff")
const MUTED := Color("c4d2e4")
const GOOD := Color("7be08a")
const WARN := Color("ffd166")

const TOLERANCE := 20
const SCAFFOLD_AFTER := 2
const STRONG_HINT_AFTER := 4
const INDEPENDENT_SKIP_AFTER := 5
const MIN_REFLECTION_CHARS := 20
const TARGET_1 := [255, 140, 0]   # orange
const TARGET_2 := [140, 0, 200]   # purple
const CHANNELS := ["Red", "Green", "Blue"]

var stage_label: Label
var panels := {}

var explore_ui := {}
var challenge_ui := {}
var independent_ui := {}

# Challenge widgets
var ch_feedback: Label
var ch_hint_box: PanelContainer
var ch_hint_text: Label
var ch_submit: Button
var ch_continue: Button
var ch_attempt_label: Label

# Independent widgets
var ind_feedback: Label
var ind_submit: Button
var ind_continue: Button
var ind_skip: Button
var ind_attempt_label: Label

# Reflection / completion widgets
var reflection_input: TextEdit
var reflection_message: Label
var summary_label: Label
var log_label: Label
var save_label: Label

# Evidence for the report
var ch_attempts := 0
var ch_solved := false
var ch_scaffold_shown := false
var ch_solved_after_scaffold := false
var ind_attempts := 0
var ind_solved := false
var ind_skipped := false
var reflection_text := ""
var event_log: Array = []


func _ready() -> void:
	_build_layout()
	_show_intro()


# ---------------------------------------------------------------- layout

func _build_layout() -> void:
	var background := ColorRect.new()
	background.color = BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 56)
	outer.add_theme_constant_override("margin_right", 56)
	outer.add_theme_constant_override("margin_top", 28)
	outer.add_theme_constant_override("margin_bottom", 28)
	add_child(outer)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)

	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 12)
	scroll.add_child(column)

	column.add_child(_label("PIXEL QUEST   /   MISSION 02: RGB MIXING", 15, ACCENT))
	column.add_child(_label("Restore the Exoplanet's Colors", 30, TEXT))
	stage_label = _label("", 15, MUTED)
	column.add_child(stage_label)
	column.add_child(HSeparator.new())

	_build_intro(column)
	_build_explore(column)
	_build_challenge(column)
	_build_independent(column)
	_build_reflection(column)
	_build_complete(column)


func _new_panel(key: String, parent: Control, gap: int) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.add_theme_constant_override("separation", gap)
	parent.add_child(panel)
	panels[key] = panel
	return panel


# Stage 1
func _build_intro(parent: Control) -> void:
	var p := _new_panel("intro", parent, 18)
	p.add_child(_label("PIXELBOT  •  Mission briefing", 20, ACCENT))
	p.add_child(_label("Welcome, explorer! Our camera shows strange colors on the exoplanet. Before we repair them, let's discover how red, green, and blue light combine.", 20, TEXT))
	p.add_child(_label("Learning goal: every color on a screen is made from three numbers (red, green, blue), each from 0 to 255. By the end of this mission you will be able to predict how changing those numbers changes the color you see.", 17, MUTED))
	p.add_child(_label("Your first task: experiment with the three RGB controls. What changes when you increase just one channel?", 17, MUTED))
	var start := _button("Begin RGB exploration")
	start.pressed.connect(_show_explore)
	p.add_child(start)


# Stage 2
func _build_explore(parent: Control) -> void:
	var p := _new_panel("explore", parent, 12)
	p.add_child(_label("PIXELBOT  •  Exploration lab", 20, ACCENT))
	p.add_child(_label("Move the sliders. Watch the preview change immediately. RGB values range from 0 to 255.", 17, TEXT))
	explore_ui = _build_workspace(p, [218, 105, 168], [])
	p.add_child(HSeparator.new())
	p.add_child(_label("Think about it: What happens when all three channels are 0? What happens when all are 255? What happens when you raise only one?", 17, TEXT))
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 14)
	p.add_child(nav)
	var back := _button("Back to briefing")
	back.pressed.connect(_show_intro)
	nav.add_child(back)
	var next := _button("Next: restore a color →")
	next.pressed.connect(_show_challenge)
	nav.add_child(next)


# Stages 3 and 4
func _build_challenge(parent: Control) -> void:
	var p := _new_panel("challenge", parent, 10)
	p.add_child(_label("PIXELBOT  •  Challenge 1: match the target color", 20, ACCENT))
	p.add_child(_label("The exoplanet's sky should look like the TARGET swatch. Set the sliders so YOUR COLOR matches it, then press Submit.", 17, TEXT))
	challenge_ui = _build_workspace(p, [60, 60, 60], TARGET_1)
	ch_attempt_label = _label("Attempts: 0", 15, MUTED)
	p.add_child(ch_attempt_label)
	ch_feedback = _label("", 17, TEXT)
	p.add_child(ch_feedback)
	var hint := _make_callout()
	ch_hint_box = hint[0]
	ch_hint_text = hint[1]
	ch_hint_box.visible = false
	p.add_child(ch_hint_box)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 14)
	p.add_child(nav)
	var back := _button("Back to exploring")
	back.pressed.connect(_show_explore)
	nav.add_child(back)
	ch_submit = _button("Submit color")
	ch_submit.pressed.connect(_on_challenge_submit)
	nav.add_child(ch_submit)
	ch_continue = _button("Next: independent challenge →")
	ch_continue.visible = false
	ch_continue.pressed.connect(_show_independent)
	nav.add_child(ch_continue)


# Stage 5
func _build_independent(parent: Control) -> void:
	var p := _new_panel("independent", parent, 10)
	p.add_child(_label("PIXELBOT  •  Challenge 2: on your own", 20, ACCENT))
	p.add_child(_label("A new patch of the planet needs repairing. This time I won't give hints. Use what you learned to match the target.", 17, TEXT))
	independent_ui = _build_workspace(p, [60, 60, 60], TARGET_2)
	ind_attempt_label = _label("Attempts: 0", 15, MUTED)
	p.add_child(ind_attempt_label)
	ind_feedback = _label("", 17, TEXT)
	p.add_child(ind_feedback)
	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 14)
	p.add_child(nav)
	ind_submit = _button("Submit color")
	ind_submit.pressed.connect(_on_independent_submit)
	nav.add_child(ind_submit)
	ind_skip = _button("I'm stuck: move on")
	ind_skip.visible = false
	ind_skip.pressed.connect(_on_independent_skip)
	nav.add_child(ind_skip)
	ind_continue = _button("Next: reflection →")
	ind_continue.visible = false
	ind_continue.pressed.connect(_show_reflection)
	nav.add_child(ind_continue)


# Stage 6a
func _build_reflection(parent: Control) -> void:
	var p := _new_panel("reflection", parent, 12)
	p.add_child(_label("PIXELBOT  •  Reflection", 20, ACCENT))
	p.add_child(_label("Explain in your own words: how did changing the red, green, and blue values affect the resulting color?", 20, TEXT))
	p.add_child(_label("Tip: you can mention colors you made, or what happened when you raised or lowered each channel.", 15, MUTED))
	reflection_input = TextEdit.new()
	reflection_input.custom_minimum_size = Vector2(0, 140)
	reflection_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	reflection_input.placeholder_text = "Type your explanation here..."
	p.add_child(reflection_input)
	reflection_message = _label("", 16, WARN)
	p.add_child(reflection_message)
	var finish := _button("Finish mission")
	finish.pressed.connect(_on_reflection_submit)
	p.add_child(finish)


# Stage 6b
func _build_complete(parent: Control) -> void:
	var p := _new_panel("complete", parent, 12)
	p.add_child(_label("PIXELBOT  •  Mission complete!", 22, GOOD))
	p.add_child(_label("The exoplanet's colors are restored. You now know that any screen color is just three numbers: red, green and blue, each from 0 to 255.", 18, TEXT))
	p.add_child(HSeparator.new())
	p.add_child(_label("SESSION RECORD (evidence for the Week 1 report)", 14, ACCENT))
	summary_label = _label("", 16, TEXT)
	p.add_child(summary_label)
	log_label = _label("", 13, MUTED)
	p.add_child(log_label)
	save_label = _label("", 13, MUTED)
	p.add_child(save_label)
	var again := _button("Play again")
	again.pressed.connect(func(): get_tree().reload_current_scene())
	p.add_child(again)


# ------------------------------------------------------------ navigation

func _show_stage(key: String, title: String) -> void:
	for k in panels:
		panels[k].visible = (k == key)
	stage_label.text = title


func _show_intro() -> void:
	_show_stage("intro", "STAGE 1 OF 6  •  Introduction")


func _show_explore() -> void:
	_show_stage("explore", "STAGE 2 OF 6  •  Exploration")


func _show_challenge() -> void:
	if ch_scaffold_shown and not ch_solved:
		_show_stage("challenge", "STAGE 4 OF 6  •  Scaffold + revision")
	else:
		_show_stage("challenge", "STAGE 3 OF 6  •  Challenge")


func _show_independent() -> void:
	_show_stage("independent", "STAGE 5 OF 6  •  Independent application")


func _show_reflection() -> void:
	_show_stage("reflection", "STAGE 6 OF 6  •  Reflection")


func _show_complete() -> void:
	_show_stage("complete", "STAGE 6 OF 6  •  Completion")


# ------------------------------------------------------ stage 3/4 logic

func _on_challenge_submit() -> void:
	var values := _values(challenge_ui)
	var result := _evaluate(values, TARGET_1)
	var ok: bool = result["success"]
	var matched: int = result["matched"]
	var worst: int = result["worst"]
	var diffs: Array = result["diffs"]
	ch_attempts += 1
	ch_attempt_label.text = "Attempts: %d" % ch_attempts
	_log("Challenge 1, attempt %d: RGB(%d, %d, %d), %d of 3 channels in range" % [ch_attempts, values[0], values[1], values[2], matched])

	if ok:
		ch_solved = true
		ch_solved_after_scaffold = ch_scaffold_shown
		var message := "Match! Every channel is within ±%d of the target RGB(%d, %d, %d)." % [TOLERANCE, TARGET_1[0], TARGET_1[1], TARGET_1[2]]
		if ch_scaffold_shown:
			message += " You revised your answer after PixelBot's hint, and it worked."
		ch_feedback.text = message
		ch_feedback.add_theme_color_override("font_color", GOOD)
		ch_submit.visible = false
		ch_continue.visible = true
		_log("Challenge 1 solved (after scaffold: %s)" % str(ch_scaffold_shown))
		_show_challenge()
		return

	ch_feedback.add_theme_color_override("font_color", WARN)
	ch_feedback.text = "Not quite yet. %d of 3 channels are within range. Your %s value is the furthest from the target." % [matched, CHANNELS[worst]]

	if ch_attempts >= SCAFFOLD_AFTER:
		if not ch_scaffold_shown:
			ch_scaffold_shown = true
			_log("Scaffold shown after %d unsuccessful submissions" % ch_attempts)
		var channel: String = CHANNELS[worst]
		var hint := "PixelBot hint: Look at the target swatch. Is there a lot of %s light in it, or very little? Compare that with your %s slider. Remember: 0 means none of that light and 255 means the most. Should your %s go up or down?" % [channel.to_lower(), channel.to_lower(), channel.to_lower()]
		if ch_attempts >= STRONG_HINT_AFTER:
			var too_high: bool = int(diffs[worst]) > 0
			hint += "\n\nExtra clue: your %s is too %s compared with the target. Try %s it, then check the other two channels." % [channel.to_lower(), "high" if too_high else "low", "lowering" if too_high else "raising"]
		ch_hint_text.text = hint
		ch_hint_box.visible = true
		_show_challenge()


# ---------------------------------------------------------- stage 5 logic

func _on_independent_submit() -> void:
	var values := _values(independent_ui)
	var result := _evaluate(values, TARGET_2)
	var ok: bool = result["success"]
	var matched: int = result["matched"]
	ind_attempts += 1
	ind_attempt_label.text = "Attempts: %d" % ind_attempts
	_log("Challenge 2, attempt %d: RGB(%d, %d, %d), %d of 3 channels in range" % [ind_attempts, values[0], values[1], values[2], matched])

	if ok:
		ind_solved = true
		ind_feedback.text = "Match! You solved it without any hints. The target was RGB(%d, %d, %d)." % [TARGET_2[0], TARGET_2[1], TARGET_2[2]]
		ind_feedback.add_theme_color_override("font_color", GOOD)
		ind_submit.visible = false
		ind_skip.visible = false
		ind_continue.visible = true
		_log("Challenge 2 solved independently")
		return

	ind_feedback.add_theme_color_override("font_color", WARN)
	ind_feedback.text = "Not a match yet: %d of 3 channels are within range. Adjust and submit again." % matched
	if ind_attempts >= INDEPENDENT_SKIP_AFTER:
		ind_skip.visible = true


func _on_independent_skip() -> void:
	ind_skipped = true
	_log("Challenge 2 skipped after %d attempts" % ind_attempts)
	_show_reflection()


# ---------------------------------------------------------- stage 6 logic

func _on_reflection_submit() -> void:
	var text := reflection_input.text.strip_edges()
	if text.length() < MIN_REFLECTION_CHARS:
		reflection_message.text = "Please write a little more (at least %d characters) so your explanation is complete." % MIN_REFLECTION_CHARS
		return
	reflection_text = text
	_log("Reflection submitted (%d characters)" % text.length())
	var path := _save_log()
	summary_label.text = "Challenge 1: %d attempt(s), scaffold shown: %s, solved: %s\nChallenge 2: %d attempt(s), solved independently: %s%s\nYour reflection: \"%s\"" % [
		ch_attempts, "yes" if ch_scaffold_shown else "no", "yes" if ch_solved else "no",
		ind_attempts, "yes" if ind_solved else "no", " (skipped)" if ind_skipped else "",
		reflection_text]
	log_label.text = "Event log:\n" + "\n".join(event_log)
	save_label.text = "Saved to: " + path
	_show_complete()


func _save_log() -> String:
	var path := "user://pixelquest_session_%d.json" % int(Time.get_unix_time_from_system())
	var data := {
		"challenge1_attempts": ch_attempts,
		"challenge1_solved": ch_solved,
		"scaffold_shown": ch_scaffold_shown,
		"challenge1_solved_after_scaffold": ch_solved_after_scaffold,
		"challenge2_attempts": ind_attempts,
		"challenge2_solved": ind_solved,
		"challenge2_skipped": ind_skipped,
		"reflection": reflection_text,
		"events": event_log,
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "  "))
		file.close()
	return ProjectSettings.globalize_path(path)


# ----------------------------------------------------------------- rules

## Compares the player's RGB values with a target. Positive diff = player's value is too high.
func _evaluate(values: Array, target: Array) -> Dictionary:
	var diffs: Array = []
	var matched := 0
	var worst := 0
	for i in 3:
		var d: int = int(values[i]) - int(target[i])
		diffs.append(d)
		if absi(d) <= TOLERANCE:
			matched += 1
		if absi(d) > absi(int(diffs[worst])):
			worst = i
	return {"success": matched == 3, "matched": matched, "worst": worst, "diffs": diffs}


func _values(ui: Dictionary) -> Array:
	var out: Array = []
	for s in ui["sliders"]:
		out.append(int(s.value))
	return out


func _log(message: String) -> void:
	event_log.append("%s  %s" % [Time.get_time_string_from_system(), message])
	print(message)


# ----------------------------------------------------------- UI builders

## Sliders + live preview. If `target` is not empty, a TARGET swatch is shown above the player's swatch.
func _build_workspace(parent: Control, start: Array, target: Array) -> Dictionary:
	var ui := {}
	var activity := HBoxContainer.new()
	activity.add_theme_constant_override("separation", 40)
	parent.add_child(activity)

	var controls := VBoxContainer.new()
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_theme_constant_override("separation", 12)
	activity.add_child(controls)

	var sliders: Array = []
	var value_labels: Array = []
	for i in 3:
		var row := _make_slider_row(CHANNELS[i], float(start[i]))
		controls.add_child(row[0])
		sliders.append(row[1])
		value_labels.append(row[2])

	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(245, 0)
	right.add_theme_constant_override("separation", 6)
	activity.add_child(right)

	var swatch_height := 185
	if not target.is_empty():
		swatch_height = 70
		right.add_child(_label("TARGET COLOR", 14, MUTED))
		var target_rect := ColorRect.new()
		target_rect.custom_minimum_size = Vector2(245, swatch_height)
		target_rect.color = Color8(int(target[0]), int(target[1]), int(target[2]))
		right.add_child(target_rect)
		right.add_child(_label("YOUR COLOR", 14, MUTED))
	else:
		right.add_child(_label("LIVE COLOR PREVIEW", 14, MUTED))

	var preview := ColorRect.new()
	preview.custom_minimum_size = Vector2(245, swatch_height)
	right.add_child(preview)
	var readout := _label("", 16, TEXT)
	right.add_child(readout)

	ui["sliders"] = sliders
	ui["labels"] = value_labels
	ui["preview"] = preview
	ui["readout"] = readout
	for s in sliders:
		s.value_changed.connect(_refresh_workspace.bind(ui))
	_refresh_workspace(0.0, ui)
	return ui


func _refresh_workspace(_unused: float, ui: Dictionary) -> void:
	var values := _values(ui)
	ui["preview"].color = Color8(values[0], values[1], values[2])
	for i in 3:
		ui["labels"][i].text = str(values[i])
	ui["readout"].text = "RGB (%d, %d, %d)" % [values[0], values[1], values[2]]


func _make_slider_row(channel_name: String, initial: float) -> Array:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 4)
	var heading := HBoxContainer.new()
	group.add_child(heading)
	var name_label := _label(channel_name, 17, TEXT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(name_label)
	var value_label := _label(str(int(initial)), 17, MUTED)
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	value_label.custom_minimum_size = Vector2(48, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	heading.add_child(value_label)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 255
	slider.step = 1
	slider.value = initial
	slider.custom_minimum_size = Vector2(340, 24)
	group.add_child(slider)
	return [group, slider, value_label]


func _make_callout() -> Array:
	var box := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = ACCENT
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(14)
	box.add_theme_stylebox_override("panel", style)
	var text := _label("", 17, TEXT)
	box.add_child(text)
	return [box, text]


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
