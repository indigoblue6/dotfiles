-- Free window placement, with Omarchy's existing theme and bindings.
o.window(".*", { float = true, suppress_event = "" })
hl.config({
  general = { resize_on_border = true, extend_border_grab_area = 10 },
  input = { follow_mouse = 0, float_switch_override_focus = 0 },
})
-- Existing Omarchy bindings:
-- Super + left/right drag: move/resize; Super + Alt + F: maximize toggle.
-- Super + Alt + S: hide in scratchpad; Super + S: show/hide scratchpad.
-- Super + T: toggle floating/tiling for the active window.
