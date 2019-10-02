# CPLD_PS2
CPLD PS2 keyboard matrix interface

THIS IS UNTESTED

Created to check the feasibility of creating an interface from a PS2 keyboard to a keyboard matrix as used in many of the old micro based computers of the 70s and 80s. This was created to see if the logic might fit in an EPM7128S.

Using a PS2 keyboard interface written in VHDL by Scott Larson.

Key presses from PS2 keyboard are decoded to set one of 64 latches, while key releases reset the latches. The latches are then read as an 8 by 8 matrix through the input/output port of the micro processor. Intention is that this could allow original software of a 70s or 80s micro to read the PS2 keyboard input.

The current version is not mapped to a specific micro computer, but uses 98% of the EPM7128S macro cells. This might not allow mapping to some or even any actual micro computers.
