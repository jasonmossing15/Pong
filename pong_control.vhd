----------------------------------------------------------------------------------
-- Engineer: Jason Mossing
-- Module Name:    pong_control - Behavioral 
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
	Generic (screen_width : natural;
				screen_height : natural);
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           up : in  STD_LOGIC;
           down : in  STD_LOGIC;
			  switch : in std_logic;
           v_completed : in  STD_LOGIC;
           ball_x : out  unsigned(10 downto 0);
           ball_y : out  unsigned(10 downto 0);
           paddle_y : out  unsigned(10 downto 0));
end pong_control;

architecture Behavioral of pong_control is
	type ball_states is (start, movement, sright, spaddle, stop, sbottom, gameover);
	signal b_state_reg, b_state_next : ball_states;
	signal count_reg, count_next, ball_x_reg, ball_x_next, ball_y_reg, ball_y_next : unsigned(10 downto 0);
	signal speed : unsigned(10 downto 0);
	signal hitbottom, hittop, hitleft, hitright, hitpaddle : std_logic;
	signal corner_up, mid_up, mid, mid_down, corner_down, corner_up_temp, mid_up_temp, mid_temp, mid_down_temp, corner_down_temp : std_logic;
	signal dx, dy, dx_reg, dy_reg : std_logic;
	
	
	type paddle_states is (idle, p_up, p_down, debounceup, debouncedown, debouncedup, debounceddown);
	signal p_state_reg, p_state_next : paddle_states;
	signal paddle_y_temp, paddle : unsigned(10 downto 0);
	signal dcount_reg, dcount_next : unsigned(15 downto 0);
	
begin


--Count State Register
	process(clk, reset)
	begin
		if reset = '1' then
			count_reg <= to_unsigned(0,11);
		elsif rising_edge(clk) then
			count_reg <= count_next;
		end if;
	end process;

count_next <= count_reg + to_unsigned(1,11) when count_reg < speed and v_completed = '1' else
				  to_unsigned(0,11) when count_reg >= speed else
				  count_reg;


--State Register
	process(clk, reset)
	begin
		if reset = '1' then
			b_state_reg <= start;
		elsif rising_edge(clk) then
			b_state_reg <= b_state_next;
		end if;
	end process;
	
--Hot zone register
	process(clk, reset)
	begin
		if(reset = '1') then
			corner_up <= '0';
			mid_up <= '0';
			mid <= '0';
			mid_down <= '0';
			corner_down <= '0';
		elsif rising_edge(clk) then
			corner_up <= corner_up_temp;
			mid_up <= mid_up_temp;
			mid <= mid_temp;
			mid_down <= mid_down_temp;
			corner_down <= corner_down_temp;
		end if;
	end process;
	
--check boundaries
	process(ball_x_reg, ball_y_reg, paddle_y_temp, corner_up, mid_up, mid, mid_down, corner_down)
	begin
		hitbottom <= '0';
		hittop <= '0';
		hitleft <= '0';
		hitright <= '0';
		hitpaddle <= '0'; 
		
		corner_up_temp <= corner_up;
		mid_up_temp <= mid_up;
		mid_temp <= mid;
		mid_down_temp <= mid_down;
		corner_down_temp <= corner_down;
		
		
		 if(ball_x_reg >= 635) then
			hitright <= '1';
		
		elsif ((ball_x_reg <= (paddle_space + paddle_width)) and (ball_y_reg >= paddle_y_temp and ball_y_reg <= (paddle_y_temp + paddle_height))) then
			if (ball_y_reg >= paddle_y_temp and ball_y_reg <= (paddle_y_temp + paddle_height/5)) then
				corner_up_temp <= '1';
			
			elsif(ball_y_reg >= (paddle_y_temp + paddle_height/5) and ball_y_reg <= (paddle_y_temp + 2*paddle_height/5)) then
				mid_up_temp <= '1';
			
			elsif(ball_y_reg >= (paddle_y_temp + 2*paddle_height/5) and ball_y_reg <= (paddle_y_temp + 3*paddle_height/5)) then
				mid_temp <= '1';
				
			elsif(ball_y_reg >= (paddle_y_temp + 3*paddle_height/5) and ball_y_reg <= (paddle_y_temp + 4*paddle_height/5)) then
				mid_down_temp <= '1';
				
			else
				corner_down_temp <= '1';
				
			end if;
			
			hitpaddle <= '1';
		elsif ( ball_y_reg <= 5) then
			hittop <= '1';
			
			corner_up_temp <= '0';
			mid_up_temp <= '0';
			mid_temp <= '0';
			mid_down_temp <= '0';
			corner_down_temp <= '0';
			
		elsif (ball_y_reg >= 475) then
			hitbottom <= '1';
			
			corner_up_temp <= '0';
			mid_up_temp <= '0';
			mid_temp <= '0';
			mid_down_temp <= '0';
			corner_down_temp <= '0';
		elsif (ball_x_reg < paddle_space) then
			hitleft <= '1';
		end if;
	end process;
	
--Next Ball state
	process(b_state_reg, count_reg, hitbottom, hittop, hitleft, hitright, hitpaddle, speed)
	begin
	 b_state_next <= b_state_reg;
	 
	 if (count_reg = speed) then
		 case b_state_reg is
			when movement =>
				if (hitright = '1') then
					b_state_next <= sright;
				elsif (hitpaddle = '1') then
					b_state_next <= spaddle;
				elsif (hittop = '1') then
					b_state_next <= stop;
				elsif (hitbottom = '1') then
					b_state_next <= sbottom;
				elsif (hitleft = '1') then
					b_state_next <= gameover;
				end if;
			when sright =>
				b_state_next <= movement;
			when spaddle =>
				b_state_next <= movement;
			when sbottom => 
				b_state_next <= movement;
			when stop =>
				b_state_next <= movement;
			when gameover =>
			
			when start =>
				b_state_next <= movement;
		end case;
	 end if;
	end process;
	
--ball output
	process(b_state_reg, count_reg, ball_x_reg, ball_y_reg, dx_reg, dy_reg, speed, corner_up, mid_up, mid, mid_down, corner_down)
	begin
		ball_x_next <= ball_x_reg;
		ball_y_next <= ball_y_reg;
		dx <= dx_reg;
		dy <= dy_reg;

	if (count_reg = speed) then
		 case b_state_reg is
			when movement =>
				if( dx_reg = '1') then
					ball_x_next <= ball_x_reg + to_unsigned(2,11);
				else
					ball_x_next <= ball_x_reg - to_unsigned(2,11);
				end if;
				
				if(corner_up = '1') then
					ball_y_next <= ball_y_reg - to_unsigned(4,11);
				elsif(mid_up = '1') then
					ball_y_next <= ball_y_reg - to_unsigned(1,11);
				elsif(mid = '1') then
					
				elsif(mid_down = '1') then
					ball_y_next <= ball_y_reg + to_unsigned(1,11);
				elsif(corner_down = '1') then
					ball_y_next <= ball_y_reg + to_unsigned(4,11);
				elsif( dy_reg = '1') then
					ball_y_next <= ball_y_reg - to_unsigned(2,11);
				else
					ball_y_next <= ball_y_reg + to_unsigned(2,11);
				end if;
			when sright =>
				dx <= '0';
			when spaddle =>
				dx <= '1';
			when stop =>
				dy <= '0';
			when sbottom => 
				dy <= '1';
			when gameover =>
			
			when start =>
				
		end case;
	 end if;
	end process;
	
	--output buffer
	process(clk, reset)
	begin
		if reset = '1' then
			ball_x_reg <= to_unsigned(500,11);
			ball_y_reg <= to_unsigned(350,11);
			dx_reg <= '0';
			dy_reg <= '0';
		elsif rising_edge(clk) then
			ball_x_reg <= ball_x_next;
			ball_y_reg <= ball_y_next;
			dx_reg <= dx;
			dy_reg <= dy;
		end if;
	end process;


ball_x <= ball_x_reg;
ball_y <= ball_y_reg;

speed <= to_unsigned(700,11) when switch = '0' else
			to_unsigned(400,11);


--Count State Register
	process(clk, reset)
	begin
		if (reset = '1') then
			dcount_reg <= to_unsigned(0,16);
		elsif rising_edge(clk) then
			dcount_reg <= dcount_next;
		end if;
	end process;

dcount_next <= dcount_reg + 1 when p_state_reg = debounceup or p_state_reg = debouncedown else
				  to_unsigned(0,16);
	
--	State Register
	process(clk, reset)
	begin
		if (reset = '1') then
			p_state_reg <= idle;
		elsif rising_edge(clk) then
			p_state_reg <= p_state_next;
		end if;
	end process;
	
--Paddle Next logic
	process(p_state_reg, up, down, dcount_reg)
	begin
		p_state_next <= p_state_reg;
		
		case p_state_reg is
			when p_up =>
				p_state_next <= debounceup;
			when p_down =>
				p_state_next <= debouncedown;
			when debounceup =>
				if dcount_reg > 45000 then
					p_state_next <= debouncedup;
				end if;
			when debouncedown =>
				if dcount_reg > 45000 then
					p_state_next <= debounceddown;
				end if;
			when debouncedup =>
				p_state_next <= idle;
			when debounceddown =>
				p_state_next <= idle;
			when idle =>
				if (up = '1') then
					p_state_next <= p_up;
				elsif (down= '1') then
					p_state_next <= p_down;
				end if;
		end case;
	end process;


					
--Paddle output logic
	process(p_state_reg, paddle_y_temp)
	begin
		paddle <= paddle_y_temp;
		case p_state_reg is
			when p_up =>
			when p_down =>
			when debounceup =>
			when debouncedown =>
			when debouncedup =>
				if (paddle_y_temp > 0) then
					paddle <= paddle_y_temp - to_unsigned(1,11);
				end if;
			when debounceddown =>
				if (paddle_y_temp < 480 - paddle_height) then
					paddle <= paddle_y_temp + to_unsigned(1,11);
				end if;
			when idle =>
		end case;
	end process;			

--output Register
	process(clk, reset)
	begin
		if (reset = '1') then
			paddle_y_temp <= to_unsigned(0,11);
		elsif rising_edge(clk) then
			paddle_y_temp <= paddle;
		end if;
	end process;
	

paddle_y <= paddle_y_temp;

end Behavioral;

