# Pixel Quest — Godot 4 Starter Project (Week 1)

This starter is based on the **RGB Mixing mission** in the supplied Pixel Quest HTML/Twine game. It is intentionally **not** a complete mission. Students must design and implement the challenge, learning supports, independent practice, and ending.

## Requirements

- Godot **4.x**, standard editor (no C#/.NET required).
- No plugins, external packages, API keys, or internet connection required after installation.

## Open and ru

1. Unzip the archive.
2. Open **Godot Project Manager** and select **Import**.
3. Browse to the unzipped `Pixel_Quest_Godot_Starter` folder and select `project.godot`.
4. Open the imported project.
5. Press **F6** while `scenes/main.tscn` is selected (or **F5** to run the project).
6. Click **Begin RGB exploration**. Move all three sliders, observe the preview, then try the navigation buttons.

If the editor asks to update compatibility/import metadata, allow it to run once. This folder was written for Godot 4.x.

## What is already provided

- A working project structure: `project.godot`, scene, script.
- Introduction with placeholder PixelBot dialogue.
- Navigable RGB exploration screen.
- Red, green, and blue sliders ranging from 0 to 255.
- Live color swatch and numeric RGB readout.
- A *deliberate placeholder* button showing where students continue implementation.

## What YOU build this week (one complete unit)

1. **Target color challenge:** display a target color and let the player submit RGB values to match it. Define a reasonable tolerance and test edge cases.
2. **Meaningful feedback:** indicate what aspect of the submitted combination might be changed, without automatically revealing the target values.
3. **Rule-based scaffold:** after a specified event (e.g., two unsuccessful attempts), show a PixelBot prompt that guides reasoning and permits revision.
4. **Independent application:** show a second, new target with automatic hints disabled. Preserve opportunities for ordinary task feedback.
5. **Completion and reflection:** an end screen asks the learner what they discovered about red, green, and blue values and how they used that knowledge.
6. **End-to-end test:** a teammate runs the mission from start to finish without using the editor to jump between screens.

**Important:** Do not add an LLM API, backend, paid services, or extra quests this week.

## Suggested design decisions to make as a team

- Which color values/tolerance make the first challenge fair and comprehensible?
- Does checking exact channel differences inadvertently give away the answer?
- What should cause a scaffold to appear and how can the learner revise?
- How can independent practice assess transfer rather than repetition?
- What should be logged or noted during peer testing? Avoid personal data.

You can coordinate among the six of you how to divide work. Work in a shared version-controlled repository, with short branches or agreed ownership of scenes/scripts to reduce merge conflicts.

## Project layout

```
Pixel_Quest_Godot_Starter/
  project.godot
  scenes/main.tscn
  scripts/main.gd
  docs/Week1_Checklist.md
  README.md
```

## Common issues

- **The game doesn't start:** ensure you imported `project.godot` and are using **Godot 4**, not Godot 3.
- **No image assets:** this is intentional. The first week focuses on functionality and learning design.
- **The 'Next' button opens a notice instead of a challenge:** this is intentional. Implement the challenge yourselves.
- **Sharing work:** commit source `.gd`, `.tscn`, and `project.godot`; generally don't commit generated `.godot/` cache files.

## Attribution

The RGB learning sequence and PixelBot setting are adapted as a starter for the Pixel Quest project provided by the instructor. This ZIP does not include the original HTML export.
