----------------------------------------------------------------------------------
-- Engineer: Jason Mossing
-- Create Date:    19:53:43 01/30/2014  
-- Module Name:    pixel_gen - Behavioral 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;
use work.Constants.all;

entity pixel_gen is
    Port ( row : in  unsigned(10 downto 0);
           column : in  unsigned(10 downto 0);
           blank : in  STD_LOGIC;
			  ball_x   : in unsigned(10 downto 0);
           ball_y   : in unsigned(10 downto 0);
           paddle_y : in unsigned(10 downto 0);
           r : out  STD_LOGIC_VECTOR (7 downto 0);
           g : out  STD_LOGIC_VECTOR (7 downto 0);
           b : out  STD_LOGIC_VECTOR (7 downto 0));
end pixel_gen;

architecture Behavioral of pixel_gen is
 constant af_r : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(51,8));
 constant af_g : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(153,8));
 constant af_b : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(255,8));
 constant zero : std_logic_vector(7 downto 0) := "00000000";

begin
	

	
	process (blank, row, column, paddle_y, ball_x, ball_y)
	begin
		r <= 	zero;
		g <=	zero;
		b <=	zero;
		
		if (blank = '0') then
		
			--paddle
			if (row > paddle_y and row < paddle_y + paddle_height) and (column > paddle_space and column < paddle_space + paddle_width) then
				g <= (others => '1');
			end if;
			--ball
			if (row > ball_y and row < ball_y + ball_sizey) and (column > ball_x and column < ball_x + ball_sizex) then
				r <= (others => '1');
			end if;
			--AF
			if (row < 360 and row > 120) and (column < 311 and column > 151) then
				if (((row < 222 and row > 154) or (row > 256)) and (column < 277 and column > 185)) then
				else	
					r <= af_r;
					g <= af_g;
					b <= af_b;
				end if;
			end if;

			if (row < 360 and row > 120) and (column < 489 and column > 329) then
				if (((row < 222 and row > 154) or (row > 256)) and (column > 363)) then
				else	
					r <= af_r;
					g <= af_g;
					b <= af_b;
				end if;
			end if;			
			
			
		end if;
	end process;

end Behavioral;