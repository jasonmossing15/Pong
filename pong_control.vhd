----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:39:08 02/10/2014 
-- Design Name: 
-- Module Name:    pong_control - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.Constants.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pong_control is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
           v_completed : in  STD_LOGIC;
           ball_x : out  unsigned(10 downto 0);
           ball_y : out  unsigned(10 downto 0);
           paddle_y : out  unsigned(10 downto 0));
end pong_control;

architecture Behavioral of pong_control is
	type ball_states is (movement, right_paddle, top_bottom, gameover, start);
	signal b_state_reg, b_state_next : ball_states;
	signal count_reg, count_next, ball_x_reg, ball_x_next, ball_y_reg, ball_y_next : unsigned(10 downto 0);
	constant speed : unsigned(10 downto 0) := to_unsigned(700,11);
	signal hitbottom, hittop, hitleft, hitright, hitpaddle : std_logic;
	signal dx, dy, dx_reg, dy_reg : signed(10 downto 0);
	
	
	type paddle_states is (start, p_up, p_down, idle, debounce, move);
	constant direction : integer := 0;
	signal p_state_reg, p_state_next : paddle_states;
	signal dcount_reg, dcount_next, paddle_y_temp, paddle : unsigned(10 downto 0);
	signal direction_temp : integer;
	
begin


	
	

--Count State Register
	process(clk, reset)
	begin
		if reset = '1' then
			paddle_y_temp <= to_unsigned(240,11);
		elsif rising_edge(clk) then
			paddle_y_temp <= paddle;
		end if;
	end process;
	
paddle <= (paddle_y_temp + 5) when rising_edge(up) and (paddle_y_temp > 0) else
			 (paddle_y_temp - 5) when rising_edge(down) and (paddle_y_temp < 470) else
			 paddle_y_temp;

paddle_y <= paddle_y_temp;



ball_x <= to_unsigned(300,11);
ball_y <= to_unsigned(400,11);

----Count State Register
--	process(clk, reset)
--	begin
--		if reset = '1' then
--			count_reg <= to_unsigned(0,11);
--		elsif rising_edge(v_completed) then
--			count_reg <= count_next;
--		end if;
--	end process;
--
--count_next <= count_reg + to_unsigned(1,11) when count_reg < speed else
--				  to_unsigned(0,11);
--
--
----State Register
--	process(clk, reset)
--	begin
--		if reset = '1' then
--			b_state_reg <= start;
--		elsif rising_edge(clk) then
--			b_state_reg <= b_state_next;
--		end if;
--	end process;
--	
----check boundaries
--	process(ball_x_reg, ball_y_reg, paddle_y_temp)
--	begin
--	hitbottom <= '0';
--	hittop <= '0';
--	hitleft <= '0';
--	hitright <= '0';
--	hitpaddle <= '0';
--		 if(ball_x_reg >= 635) then
--			hitright <= '1';
--		elsif (ball_x_reg <=( paddle_space +paddle_width) and (ball_y_reg <= paddle_y_temp or ball_y_reg >= (paddle_y_temp + paddle_height))) then
--			hitpaddle <= '1';
--		elsif ( ball_y_reg <= 0) then
--			hitbottom <= '1';
--		elsif (ball_y_reg >= 475) then
--			hittop <= '1';
--		elsif (ball_x_reg <= 0) then
--			hitleft <= '1';
--		end if;
--	end process;
--	
----Next Ball state
--	process(b_state_reg, count_reg, hitbottom, hittop, hitleft, hitright, hitpaddle)
--	begin
--	 b_state_next <= b_state_reg;
--	 
--	 if (count_reg = speed) then
--		 case b_state_reg is
--			when movement =>
--				if (hitright = '1' or hitpaddle = '1') then
--					b_state_next <= right_paddle;
--				elsif (hittop = '1' or hitbottom = '1') then
--					b_state_next <= top_bottom;
--				elsif (hitleft = '1') then
--					b_state_next <= gameover;
--				end if;
--			when right_paddle =>
--				b_state_next <= movement;
--			when top_bottom => 
--				b_state_next <= movement;
--			when gameover =>
--			when start =>
--				b_state_next <= movement;
--		end case;
--	 end if;
--	end process;
--	
----ball output
--	process(b_state_reg, count_reg)
--	begin
--		ball_x_next <= ball_x_reg;
--		ball_y_next <= ball_y_reg;
--		dx <= dx_reg;
--		dy <= dy_reg;
--		
--	if (count_reg = speed) then
--		 case b_state_reg is
--			when movement =>
--				ball_x_next <= ball_x_reg + unsigned(dx_reg);
--				ball_y_next <= ball_y_reg + unsigned(dy_reg);
--			when right_paddle =>
--				dx <= (-1)*dx_reg;
--			when top_bottom => 
--				dy <= (-1)*dy_reg;
--			when gameover =>
--			
--			when start =>
--				
--		end case;
--	 end if;
--	end process;
--	
--	--output buffer
--	process(v_completed, reset)
--	begin
--		if reset = '1' then
--			ball_x_reg <= to_unsigned(320,11);
--			ball_y_reg <= to_unsigned(240,11);
--			dx_reg <= to_signed(2,11);
--			dy_reg <= to_signed(2,11);
--		elsif rising_edge(v_completed) then
--			ball_x_reg <= ball_x_next;
--			ball_y_reg <= ball_y_next;
--			dx_reg <= dx;
--			dy_reg <= dy;
--		end if;
--	end process;


	
----Count State Register
--	process(clk, reset)
--	begin
--		if reset = '1' then
--			dcount_reg <= 0;
--		elsif rising_edge(clk) then
--			dcount_reg <= dcount_next;
--		end if;
--	end process;
--
--dcount_next <= dcount_reg + 1 when p_state_reg = debounce else
--				  0;
--	
--	--State Register
--	process(clk, reset)
--	begin
--		if reset = '1' then
--			p_state_reg <= start;
--		elsif rising_edge(clk) then
--			p_state_reg <= p_state_next;
--		end if;
--	end process;
--	
----Paddle Next logic
--	process(p_state_reg, up, down, dcount_reg)
--	begin
--		p_state_next <= p_state_reg;
--		
--		case p_state_reg is
--			when start =>
--				p_state_next <= idle;
--			when up =>
--				p_state_next <= debounce;
--			when down =>
--				p_state_next <= debounce;
--			when debounce =>
--				if dcount_reg > 4 then
--					p_state_next <= move;
--				end if;
--			when move =>
--				p_state_next <= idle;
--			when idle =>
--				if (up = '1') then
--					p_state_next <= up;
--				elsif (down= '1') then
--					p_state_next <= down;
--				end if;
--		end case;
--	end process;
--
--
--					
----Paddle output logic
--	process(p_state_reg)
--	begin
--		paddle_y <= paddle_y_temp;
--		direction <= direction_temp;
--		case p_state_reg is
--			when start =>
--				paddle_y_temp <= 240;
--			when up =>
--				direction <= 1;
--			when down =>
--				direction <= 2;
--			when debounce =>
--			when move =>
--				if direction = 1 then
--					paddle_y <= paddle_y_temp + 5;
--					direction <= 0;
--				elsif direction = 2 then
--					paddle_y <= paddle_y_temp - 5;
--					direction <= 0;
--				end if;
--			when idle =>
--				paddle_y <= paddle_y_temp;
--		end case;
--	end process;
			

end Behavioral;

