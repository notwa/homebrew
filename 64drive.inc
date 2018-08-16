// set 64Drive interface constants.

// NOTE: although STATUSes are marked as halfwords,
//       you should use lw/sw to interact with them.

constant CI_BASE($B800)
constant CI_BASE_EXTENDED($BF80)

constant CI_GENERAL_BUFFER($0000)       // 512 bytes

constant CI_STATUS($0200)               // halfword
constant CI_COMMAND($0208)              // word
constant CI_LBA($0210)                  // word
constant CI_LENGTH($0218)               // word
constant CI_RESULT($0220)               // word

constant CI_SDRAM_SIZE($02E8)           // word
constant CI_HW_MAGIC($02EC)             // word ("UDEV")
constant CI_HW_VARIANT($02F0)           // word
constant CI_PERSISTENT($02F4)           // word (RESERVED)
constant CI_BUTTON_STATUS($02F8)        // halfword (needs debouncing)
constant CI_UPGRADE_MOD_STATUS($02FA)   // halfword
constant CI_REVISION_NUMBER($02FC)      // halfword

constant CI_USB_COMMAND_STATUS($0400)   // byte
constant CI_USB_PARAM_RESULT_0($0404)   // word
constant CI_USB_PARAM_RESULT_1($0408)   // word

constant CI_WIFI_COMMAND_STATUS($0420)  // byte
constant CI_WIFI_PARAM_RESULT_0($0424)  // word
constant CI_WIFI_PARAM_RESULT_1($0428)  // word

constant CI_EEPROM($1000)               // 2048 bytes
constant CI_WRITEBACK_LBA($1800)        // 1024 bytes (256 words)
