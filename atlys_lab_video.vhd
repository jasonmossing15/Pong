----------------------------------------------------------------------------------
-- Company: ECE383
-- Engineer: Jason Mossing
-- 
-- Create Date:    15:22:52 01/28/2014 
-- Design Name: 	 VGA Synchronization
-- Module Name:    atlys_lab_video - mossing 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity atlys_lab_video is
    port ( 
             clk   : in  std_logic; -- 100 MHz
             reset : in  std_logic;
				 up : in std_logic;
				 down : in std_logic;
             tmds  : out std_logic_vector(3 downto 0);
             tmdsb : out std_logic_vector(3 downto 0)
         );
end atlys_lab_video;


architecture mossing of atlys_lab_video is
    component vga_sync
			Generic (
				H_activeSize : natural;
				H_frontSize : natural;
				H_syncSize : natural;
				H_backSize : natural;
				V_activeSize : natural;
				V_frontSize : natural;
				V_syncSize : natural;
				V_backSize : natural
				);
		    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           h_sync : out  STD_LOGIC;
           v_sync : out  STD_LOGIC;
           v_completed : out  STD_LOGIC;
           blank : out  STD_LOGIC;
           row : out  unsigned(10 downto 0);
           column : out  unsigned(10 downto 0));
	end component;
	
	component pixel_gen
    port ( row      : in unsigned(10 downto 0);
           column   : in unsigned(10 downto 0);
           blank    : in std_logic;
           r        : out std_logic_vector(7 downto 0);
           g        : out std_logic_vector(7 downto 0);
           b        : out std_logic_vector(7 downto 0));
	end component;
	 
	 signal row_sig, column_sig : unsigned(10 downto 0);
	 signal blank_sig, h_sync_sig, v_sync_sig, clock_s, blue_s, green_s, red_s, serialize_clk_n, serialize_clk, pixel_clk : std_logic;
	 signal red, green, blue : std_logic_vector(7 downto 0);
begin

    -- Clock divider - creates pixel clock from 100MHz clock
    inst_DCM_pixel: DCM
    generic map(
                   CLKFX_MULTIPLY => 2,
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => pixel_clk
            );

    -- Clock divider - creates HDMI serial output clock
    inst_DCM_serialize: DCM
    generic map(
                   CLKFX_MULTIPLY => 10, -- 5x speed of pixel clock
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => serialize_clk,
                clkfx180 => serialize_clk_n
            );

    -- VGA component instantiation
	 vga : vga_sync
	 	 Generic map (
		H_activeSize => 640,
		H_frontSize => 16,
		H_syncSize => 96,
		H_backSize => 48,
		V_activeSize => 480,
		V_frontSize => 10,
		V_syncSize => 2,
		V_backSize => 33
		)
		port map(
			clk => pixel_clk,
         reset => reset,
         h_sync => h_sync_sig,
         v_sync => v_sync_sig,
         v_completed => open,
         blank => blank_sig,
         row => row_sig,
         column => column_sig);

    -- Pixel generator component instantiation
		pix_gen : pixel_gen
			port map ( 
				row => row_sig,
				column => column_sig,
				blank  => blank_sig,
				r => red,
				g => green,
				b => blue
				);
    -- Convert VGA signals to HDMI (actually, DVID ... but close enough)
    inst_dvid: entity work.dvid
    port map(
                clk       => serialize_clk,
                clk_n     => serialize_clk_n, 
                clk_pixel => pixel_clk,
                red_p     => red,
                green_p   => green,
                blue_p    => blue,
                blank     => blank_sig,
                hsync     => h_sync_sig,
                vsync     => v_sync_sig,
                -- outputs to TMDS drivers
                red_s     => red_s,
                green_s   => green_s,
                blue_s    => blue_s,
                clock_s   => clock_s
            );

    -- Output the HDMI data on differential signalling pins
    OBUFDS_blue  : OBUFDS port map
        ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
    OBUFDS_red   : OBUFDS port map
        ( O  => TMDS(1), OB => TMDSB(1), I  => green_s );
    OBUFDS_green : OBUFDS port map
        ( O  => TMDS(2), OB => TMDSB(2), I  => red_s   );
    OBUFDS_clock : OBUFDS port map
        ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );

end mossing;