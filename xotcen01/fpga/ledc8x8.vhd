-- Autor reseni: MATEJ OTCENAS, xotcen01

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port (
    RESET: in std_logic;
    SMCLK: in std_logic;
    LED: out std_logic_vector(7 downto 0);
    ROW: out std_logic_vector(7 downto 0)
);
end ledc8x8;

architecture main of ledc8x8 is
----------------------------------- SIGNALS ----------------------------------
    signal enable :  std_logic;
    signal half_sec : std_logic_vector(21 downto 0) := (others => '0');
    signal rows : std_logic_vector(7 downto 0);
    signal change_state_en : std_logic_vector(1 downto 0) := (others => '0');
    signal freq_divider : std_logic_vector(7 downto 0) := (others => '0');
------------------------------------------------------------------------------

-- FREQUENTION = 7.3728 MHz = 7372800 Hz (ticks per second)
-- ROWS activation = log. 1
-- LED in active row are enabled with log. 0
begin
    --------------------- DIVIDER ------------------------
    clk_en_generator: process(RESET, SMCLK)
    begin
        if RESET = '1' then
            half_sec <= (others => '0'); -- always reset to 0
            freq_divider <= (others => '0');
        elsif rising_edge(SMCLK) then
            if half_sec = "1110000100000000000000" then -- 0.5 sec
                if change_state_en /= "10" then -- 3.state skip incrementation ............. CHANGE HERE TO ONE NORMAL STATEMENT NOT LIKE MTHRFCKR
                    change_state_en <= change_state_en + 1; -- increment to next state
                end if ;
                half_sec <= (others => '0');
            end if;
            freq_divider <= freq_divider + 1;
            half_sec <= half_sec + 1; 
        end if;
    end process clk_en_generator;

    enable <= '1' when freq_divider = "11111111" else '0';

    register_rotation: process(RESET, SMCLK, enable, rows)
    begin
        if (RESET = '1') then
            rows <= "10000000";
        elsif rising_edge(SMCLK) and enable = '1' then
            case rows is
                when "10000000" => rows <= "01000000";
                when "01000000" => rows <= "00100000";
                when "00100000" => rows <= "00010000";
                when "00010000" => rows <= "00001000";
                when "00001000" => rows <= "00000100";
                when "00000100" => rows <= "00000010";
                when "00000010" => rows <= "00000001";
                when "00000001" => rows <= "10000000";
                when others => null;
            end case;
        end if;
        ROW <= rows;
    end process;

    display: process(rows, change_state_en)
    begin
        if change_state_en = "00" then -- first state is ok
            case rows is
                when "10000000" => LED <= "01110111";
                when "01000000" => LED <= "00100111";
                when "00100000" => LED <= "01010111";
                when "00010000" => LED <= "01110001";
                when "00001000" => LED <= "01110110";
                when "00000100" => LED <= "11110110";
                when "00000010" => LED <= "11110110";
                when "00000001" => LED <= "11111001";
                when others => LED <= "11111111";
            end case;
                
        elsif change_state_en = "01" then  -- second state means shut down
            LED <= "11111111";
        else -- third and also the last state is ok too
            case rows is
                when "10000000" => LED <= "01110111";
                when "01000000" => LED <= "00100111";
                when "00100000" => LED <= "01010111";
                when "00010000" => LED <= "01110001";
                when "00001000" => LED <= "01110110";
                when "00000100" => LED <= "11110110";
                when "00000010" => LED <= "11110110";
                when "00000001" => LED <= "11111001";
                when others => LED <= "11111111";
            end case;
        end if;   
	end process display;
end main;
-- ISID: 75579
