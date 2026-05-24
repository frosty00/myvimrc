#!/bin/bash

tilde="0x700000035"
nonus="0x700000064"
right_shift="0x7000000E5"
capslock="0x700000039"
escape="0x700000029"


hidutil property --set "{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":$nonus,\"HIDKeyboardModifierMappingDst\":$tilde},{\"HIDKeyboardModifierMappingSrc\":$tilde,\"HIDKeyboardModifierMappingDst\":$nonus},{\"HIDKeyboardModifierMappingSrc\":$right_shift,\"HIDKeyboardModifierMappingDst\":$capslock},{\"HIDKeyboardModifierMappingSrc\":$capslock,\"HIDKeyboardModifierMappingDst\":$escape}]}"
