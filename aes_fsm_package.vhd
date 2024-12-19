library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package aes_fsm_pkg is
    type state_type is (
        IDLE,
        LOAD_INPUT,
        LOAD_KEY,
        XOR_STATE,
        SUBBYTES_STATE,
        SHIFTROWS_LOAD,
        SHIFTROWS_PROCESS,
        SHIFTROWS_STORE,
        MIXCOLS_STATE,
        WRITE_RESULT,
        DISPLAY_STATE,
        DONE_STATE
    );
end package;