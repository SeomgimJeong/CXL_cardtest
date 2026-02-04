--------------------------------------------------------------------------------
--
--      This source code is provided to you (the Licensee) under license
--      by BittWare, a Molex Company. To view or use this source code,
--      the Licensee must accept a Software License Agreement (viewable
--      at developer.bittware.com), which is commonly provided as a click-
--      through license agreement. The terms of the Software License
--      Agreement govern all use and distribution of this file unless an
--      alternative superseding license has been executed with BittWare.
--      This source code and its derivatives may not be distributed to
--      third parties in source code form. Software including or derived
--      from this source code, including derivative works thereof created
--      by Licensee, may be distributed to third parties with BittWare
--      hardware only and in executable form only.
--
--      The click-through license is available here:
--        https://developer.bittware.com/software_license.txt
--
--------------------------------------------------------------------------------
--      UNCLASSIFIED//FOR OFFICIAL USE ONLY
--------------------------------------------------------------------------------
-- Title       : Powerburner Controller
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This component provides a configurable dummy logic BRAM, DSP
--               and FF power consumption element. This instantiation can be
--               customised to target a power consumption level and Interfaces
--               with AXI4-Lite
--               6 addresses are reserved for config, status and control registers
--               0x0  = Powerburner Configuration (every bit represents 1 instance)
--               0x4  = Powerburner Core Clock Frequency (integer value = Hz)
--               0x8  = BRAM configuration per Powerburner Instance
--               0xC  = SREG configuration per Powerburner Instance
--               0x10 = DSP configuration per Powerburner Instance
--               0x14 = Powerburner Control
--               0x18 = Powerburner Status Controller Active Profile Base Address
--               0x1C = Powerburner Status Controller Active Profile Load
--               0x20 = Powerburner Status Controller Active Profile Enables
--
--               The following two registers allow direct reading and writing to
--               a Profile RAM:
--               0x40 = Profile RAM Address
--               0x44 = Profile RAM Data
--
--               A profile(n) consists of;
--               base address(n) + 0 = Lower 32bit value of Duration
--               base address(n) + 1 = Upper 32bit value of Duration
--               base address(n) + 2 = Byte_Enables sent to Powerburner(s)
--               base address(n) + 3 = Quantity of Powerburners released, each bit
--                                     represents 1 Powerburner Instance
--
--               To write/read to the Profile RAM, Address must be set first before
--               a data read/write.
--
--               Each valid profile (Duration > 0) is sequentially progressed
--               when Enable > 0. If Duration = 0, profile search restarts at
--               address 0x0 in profile RAM
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;

entity powerburner_controller is
  generic
  (
    CORE_CLK_FREQUENCY      : natural   := 100000000;      --Frequency in Hz
    POWERBURNER_INSTANCES   : natural range 1 to 32 := 1;  --Max 32
    BRAM_HW_TARGET          : natural   := 32;             --Target Hardware utilisation for device after compilation, min (16*instances)
    SREG_HW_TARGET          : natural   := 12;             --Target Hardware utilisation for device after compilation, min (64*instances)
    DSP_HW_TARGET           : natural   := 32              --Target Hardware utilisation for device after compilation, min (8*instances)
  );
port (
  -- AXI Clock and Reset
  aclk                            : in   std_logic;
  areset                          : in   std_logic;
  -- Write Address Interface
  awaddr                          : in   std_logic_vector(7 downto 0);
  awvalid                         : in   std_logic;
  awready                         : out  std_logic;
  awprot                          : in   std_logic_vector(2 downto 0);
  -- Write Data Interface
  wdata                           : in   std_logic_vector(31 downto 0);
  wstrb                           : in   std_logic_vector(3 downto 0);
  wvalid                          : in   std_logic;
  wready                          : out  std_logic;
  -- Write Response Interface
  bresp                           : out  std_logic_vector(1 downto 0);
  bvalid                          : out  std_logic;
  bready                          : in   std_logic;
  -- Read Address Interface
  araddr                          : in   std_logic_vector(7 downto 0);
  arvalid                         : in   std_logic;
  arready                         : out  std_logic;
  arprot                          : in   std_logic_vector(2 downto 0);
  -- Read Response Interface
  rdata                           : out  std_logic_vector(31 downto 0);
  rresp                           : out  std_logic_vector(1 downto 0);
  rvalid                          : out  std_logic;
  rready                          : in   std_logic;
  -- Powerburner Clock
  pb_clk                          : in   std_logic
  );
  end entity powerburner_controller;

  architecture rtl of powerburner_controller is

    constant BRAM_AWIDTH          : natural :=10;
    constant BRAM_DWIDTH          : natural :=32;
    constant BRAM_INSTANCE_SIZE   : natural :=((BRAM_HW_TARGET/2)/POWERBURNER_INSTANCES);
    constant X8_REG_INSTANCE_SIZE : natural :=((SREG_HW_TARGET/8)/POWERBURNER_INSTANCES);
    constant DSP_INSTANCE_SIZE    : natural :=((DSP_HW_TARGET)/POWERBURNER_INSTANCES);

  component altera_dprw_ram
  generic (
    AWIDTH   : natural := BRAM_AWIDTH;
    DWIDTH   : natural := BRAM_DWIDTH
    );
  port (
    clka     : in  std_logic;
    clkb     : in  std_logic;
    wea      : in  std_logic;
    web      : in  std_logic;
    addra    : in  std_logic_vector(AWIDTH-1 downto 0);
    addrb    : in  std_logic_vector(AWIDTH-1 downto 0);
    dia      : in  std_logic_vector(DWIDTH-1 downto 0);
    dib      : in  std_logic_vector(DWIDTH-1 downto 0);
    doa      : out std_logic_vector(DWIDTH-1 downto 0);
    dob      : out std_logic_vector(DWIDTH-1 downto 0)
    );
  end component;

  ----------------------
  -- AXI Address Map
  ----------------------
  --Powerburner control and stats
  constant powerburner_config                : std_logic_vector(7 downto 0)               := x"00";
  constant powerburner_clock                 : std_logic_vector(7 downto 0)               := x"04";
  constant powerburner_bram_config           : std_logic_vector(7 downto 0)               := x"08";
  constant powerburner_sreg_config           : std_logic_vector(7 downto 0)               := x"0C";
  constant powerburner_dsp_config            : std_logic_vector(7 downto 0)               := x"10";
  constant powerburner_control_reg           : std_logic_vector(7 downto 0)               := x"14";
  --Output for current active profile
  constant powerburner_status_base_addr      : std_logic_vector(7 downto 0)               := x"18";
  constant powerburner_status_byte_en        : std_logic_vector(7 downto 0)               := x"1C";
  constant powerburner_status_pb_en          : std_logic_vector(7 downto 0)               := x"20";
  --Profile RAM
  constant powerburner_profile_addr_reg      : std_logic_vector(7 downto 0)               := x"40";
  constant powerburner_profile_data_reg      : std_logic_vector(7 downto 0)               := x"44";
  --Data output
  signal axi_rdata_out                       : std_logic_vector(31 downto 0)              := (others => '0');

  ----------------------
  -- AXI R/W Controller
  ----------------------

  type READ_STATES is (RS_ADDR, RS_DATA);
  signal rstate                              : READ_STATES;

  type WRITE_STATES is (WS_ADDR, WS_DATA, WS_RESP);
  signal wstate                              : WRITE_STATES;

  signal arready_i                           : std_logic                                  := '0';
  signal rvalid_i                            : std_logic                                  := '0';
  signal awready_i                           : std_logic                                  := '0';
  signal wready_i                            : std_logic                                  := '0';
  signal bvalid_i                            : std_logic                                  := '0';
  signal waddr_i                             : std_logic_vector(7 downto 0)               := (others => '0');

  signal host_ram_addr                       : std_logic_vector(BRAM_AWIDTH-1 downto 0)   := (others => '0');
  signal host_ram_data                       : std_logic_vector(31 downto 0)              := (others => '0');
  signal host_profile_we                     : std_logic                                  := '0';

  ------------------
  -- PB Controller
  ------------------
  type PB_CONTROL_STATES is (IDLE, HOLD, DURATION_SET_LOW, DURATION_SET_UP, VALID_CHECK, LOAD_SET, ENABLES_SET, RELEASE_PB);
  signal pbstate                             : PB_CONTROL_STATES;

  signal pb_quantity_i                       : std_logic_vector(31 downto 0)              := (others => '0');
  signal pb_byte_en_i                        : std_logic_vector(31 downto 0)              := (others => '0');
  signal pb_quantity_set_i                   : std_logic_vector(31 downto 0)              := (others => '0');
  signal pb_byte_en_set_i                    : std_logic_vector(31 downto 0)              := (others => '0');
  signal pb_duration_i                       : std_logic_vector(63 downto 0)              := (others => '0');
  signal pb_profile_base                     : std_logic_vector(BRAM_AWIDTH-1 downto 0)   := (others => '0');
  signal pb_running                          : std_logic                                  := '0';
  signal pb_running_i                        : std_logic_vector(31 downto 0)              := (others => '0');

  ----------------------------------
  -- AXI Controller output retiming
  ----------------------------------
  constant RETIME_DEPTH : natural            := 4;

  type retimeType is array (0 to RETIME_DEPTH-1) of std_logic_vector(31 downto 0);

  signal q_i0           : retimeType         := (others => (others => '0'));
  signal q_i1           : retimeType         := (others => (others => '0'));
  signal q_i2           : retimeType         := (others => (others => '0'));
  signal base_address_current_out            : std_logic_vector(31 downto 0)              := (others => '0');
  signal load_current_out                    : std_logic_vector(31 downto 0)              := (others => '0');
  signal enable_current_out                  : std_logic_vector(31 downto 0)              := (others => '0');

  ------------------------------
  -- PB Profile RAM R/W signals
  ------------------------------
  signal addr_requested                      : std_logic_vector(31 downto 0)              := (others => '0');
  signal data_requested                      : std_logic_vector(31 downto 0)              := (others => '0');
  signal host_data_read                      : std_logic_vector(31 downto 0);
  signal write_requested                     : std_logic                                  := '0';
  signal write_complete                      : std_logic                                  := '0';
  signal pb_address                          : std_logic_vector(BRAM_AWIDTH-1 downto 0)   := (others => '0');
  signal pb_data_read                        : std_logic_vector(31 downto 0);
  signal read_complete                       : std_logic                                  := '0';
  signal read_delay                          : std_logic                                  := '0';

  begin

  -- Instantiate profile RAM
  profile_ram : altera_dprw_ram
  generic map (
    AWIDTH   => BRAM_AWIDTH,
    DWIDTH   => BRAM_DWIDTH
    )
  port map (
    clka     => aclk,
    clkb     => pb_clk,
    wea      => host_profile_we,
    web      => '0',
    addra    => host_ram_addr,
    addrb    => pb_address,
    dia      => host_ram_data,
    dib      => (others => '0'),
    doa      => host_data_read,
    dob      => pb_data_read
    );

  -- Set signals that aren't supported
  rresp <= (others => '0');
  bresp <= (others => '0');

  -- Read Handshake
  process (aclk)
  begin
    if rising_edge(aclk) then
      if areset='1' then
        arready_i      <= '0';
        rvalid_i       <= '0';
        rstate         <= RS_ADDR;
      else
        case rstate is
          when RS_ADDR =>
            if arvalid='1' and arready_i='1' then
              arready_i <= '0';
              rvalid_i  <= '0';
              rstate    <= RS_DATA;
            else
              arready_i <= '1';
              rvalid_i  <= '0';
            end if;
          when RS_DATA =>
            if rready='1' and rvalid_i='1' then
              arready_i <= '0';
              rvalid_i  <= '0';
              rstate    <= RS_ADDR;
            else
              arready_i <= '0';
              rvalid_i  <= '1';
            end if;
          when others =>
            arready_i   <= '0';
            rvalid_i    <= '0';
            rstate      <= RS_ADDR;
        end case;
      end if;
    end if;
  end process;

  arready <= arready_i;
  rvalid  <= rvalid_i;

  --Write Handshake
  process (aclk)
  begin
    if rising_edge(aclk) then
      if areset='1' then
        awready_i        <= '0';
        bvalid_i         <= '0';
        wready_i         <= '0';
        wstate           <= WS_ADDR;
      else
        case wstate is
          when WS_ADDR =>
            if awvalid='1' then
              wstate     <= WS_DATA;
              awready_i  <= '0';
              wready_i   <= '1';
              bvalid_i   <= '0';
            else
              awready_i  <= '1';
              wready_i   <= '0';
              bvalid_i   <= '0';
            end if;
          when WS_DATA =>
            if wvalid='1' then
              wstate     <= WS_RESP;
              awready_i  <= '0';
              wready_i   <= '0';
              bvalid_i   <= '1';
            else
              awready_i  <= '0';
              wready_i   <= '1';
              bvalid_i   <= '0';
            end if;
          when WS_RESP =>
            if bready='1' then
              wstate     <= WS_ADDR;
              awready_i  <= '1';
              wready_i   <= '0';
              bvalid_i   <= '0';
            else
              awready_i  <= '0';
              wready_i   <= '0';
              bvalid_i   <= '1';
            end if;
          when others =>
            wstate       <= WS_ADDR;
            awready_i    <= '0';
            bvalid_i     <= '0';
            wready_i     <= '0';
        end case;
      end if;
    end if;
  end process;

  awready  <= awready_i;
  bvalid   <= bvalid_i;
  wready   <= wready_i;

  process (aclk)
  begin
    if rising_edge(aclk) then
      if areset='1' then
        waddr_i       <= (others => '0');
      else
        if awready_i='1' and awvalid='1' then
          waddr_i     <= awaddr;
        end if;
      end if;
    end if;
  end process;

  --Configurable depth retiming for controller to axi clock crossing metastability
  process (aclk) is
    begin
      if rising_edge(aclk) then
        if (areset = '1') then
          q_i0        <= (others => (others => '0'));
          q_i1        <= (others => (others => '0'));
          q_i2        <= (others => (others => '0'));
        else
          for i in 0 to RETIME_DEPTH-1 loop
            if i = 0 then
              q_i0(i) <= (31 downto pb_profile_base'length => '0') & pb_profile_base;
              q_i1(i) <= pb_byte_en_set_i;
              q_i2(i) <= pb_running_i;
            else
              q_i0(i) <= q_i0(i-1);
              q_i1(i) <= q_i1(i-1);
              q_i2(i) <= q_i2(i-1);
            end if;
          end loop;
        end if;
      end if;
      base_address_current_out <= q_i0(RETIME_DEPTH-1);
      load_current_out         <= q_i1(RETIME_DEPTH-1);
      enable_current_out       <= q_i2(RETIME_DEPTH-1);
    end process;

  -- AXI Data output logic for stat registers
  process (aclk)
  begin
    if rising_edge(aclk) then
      if areset='1' then
        axi_rdata_out                           <= (others => '0');
      elsif arvalid='1' and arready_i='1' then
        case araddr is
          when powerburner_config           => axi_rdata_out <= conv_std_logic_vector(POWERBURNER_INSTANCES, rdata'length);
          when powerburner_clock            => axi_rdata_out <= conv_std_logic_vector(CORE_CLK_FREQUENCY, rdata'length);
          when powerburner_bram_config      => axi_rdata_out <= conv_std_logic_vector(BRAM_INSTANCE_SIZE, rdata'length);
          when powerburner_sreg_config      => axi_rdata_out <= conv_std_logic_vector(X8_REG_INSTANCE_SIZE, rdata'length);
          when powerburner_dsp_config       => axi_rdata_out <= conv_std_logic_vector(DSP_INSTANCE_SIZE, rdata'length);
          when powerburner_control_reg      => axi_rdata_out <= x"0000000" & b"000" & pb_running;
          when powerburner_status_base_addr => axi_rdata_out <= base_address_current_out;
          when powerburner_status_byte_en   => axi_rdata_out <= load_current_out;
          when powerburner_status_pb_en     => axi_rdata_out <= enable_current_out;
          when powerburner_profile_addr_reg => axi_rdata_out <= addr_requested;
          when powerburner_profile_data_reg => axi_rdata_out <= host_data_read;
          when others => axi_rdata_out <= x"DEADBEEF";
        end case;
      end if;
    end if;
  end process;

  rdata   <= axi_rdata_out;

  -- AXI Data input logic for Control and Profile_RAM
  process (aclk)
  begin
    if rising_edge(aclk) then
      if areset='1' then
        pb_running      <= '0';
        write_requested <= '0';
        write_complete  <= '0';
        host_profile_we <= '0';
      elsif wready_i='1' and wvalid='1' then
        case waddr_i is
          when powerburner_control_reg      => pb_running     <= wdata(0);
          when powerburner_profile_addr_reg => addr_requested <= wdata;
          when powerburner_profile_data_reg => data_requested <= wdata;
               write_requested  <= '1';
               write_complete   <= '0';
          when others => write_requested  <= '0';
         end case;
      end if;
      host_ram_addr <= addr_requested(BRAM_AWIDTH-1 downto 0);
      host_ram_data <= data_requested;
  -- Write setup to Profile RAM
      if write_requested = '1' then
        if write_complete = '0' then
          host_profile_we <= '1';
          write_complete  <= host_profile_we;
        else
          host_profile_we <= '0';
          write_requested <= '0';
        end if;
      end if;
    end if;
  end process;

  -- PowerBurner Controller | Profile setup and staging.
  process (pb_clk)
  begin
    if rising_edge(pb_clk) then
      if areset='1' or pb_running ='0' then
        pb_duration_i                     <= (others => '0');
        pb_byte_en_i                      <= (others => '0');
        pb_quantity_set_i                 <= (others => '0');
        pb_profile_base                   <= (others => '0');
        read_delay                        <= '0';
        read_complete                     <= '0';
        pbstate                           <= IDLE;
      elsif pb_running = '1' then
        case pbstate is
          when IDLE =>
            if pb_duration_i = 0 then
              pbstate                     <= DURATION_SET_LOW;
              read_complete               <= '0';
              read_delay                  <= '0';
            else
              pbstate                     <= HOLD;
            end if;

          when HOLD =>
            if pb_duration_i = 0 then
              if and_reduce(pb_profile_base + 4) = '1' then
                pb_profile_base            <= (others => '0');
              else
                pb_profile_base            <= pb_profile_base + 4;
              end if;
              read_delay                   <= '0';
              read_complete                <= '0';
              pbstate                      <= DURATION_SET_LOW;
            else
              pb_duration_i                <= pb_duration_i - 1;
            end if;

          when DURATION_SET_LOW =>
            if read_complete = '0' then
              pb_address                   <= pb_profile_base;
              read_delay                   <= '1';
              read_complete                <= read_delay;
            else
              pb_duration_i(31 downto 0)   <= pb_data_read;
              read_delay                   <= '0';
              read_complete                <= '0';
              pbstate                      <= DURATION_SET_UP;
            end if;

          when DURATION_SET_UP =>
            if read_complete = '0' then
              pb_address                   <= pb_profile_base + 1;
              read_delay                   <= '1';
              read_complete                <= read_delay;
            else
              pb_duration_i(63 downto 32)  <= pb_data_read;
              read_delay                   <= '0';
              read_complete                <= '0';
              pbstate                      <= VALID_CHECK;
            end if;

          when VALID_CHECK =>
          if or_reduce(pb_duration_i) = '1' then
            pbstate                        <= LOAD_SET;
          else
            pb_profile_base                <= (others => '0');
            pbstate                        <= DURATION_SET_LOW;
          end if;

          when LOAD_SET =>
            if read_complete = '0' then
              pb_address                   <= pb_profile_base + 2;
              read_delay                   <= '1';
              read_complete                <= read_delay;
            else
              pb_byte_en_i                 <= pb_data_read;
              read_delay                   <= '0';
              read_complete                <= '0';
              pbstate                      <= ENABLES_SET;
            end if;

          when ENABLES_SET =>
            if read_complete = '0' then
              pb_address                   <= pb_profile_base + 3;
              read_delay                   <= '1';
              read_complete                <= read_delay;
            else
              pb_quantity_i                <= pb_data_read;
              read_delay                   <= '0';
              read_complete                <= '0';
              pbstate                      <= RELEASE_PB;
            end if;

          when RELEASE_PB =>
            pb_byte_en_set_i               <= pb_byte_en_i;
            pb_quantity_set_i              <= pb_quantity_i;
            pbstate                        <= HOLD;

          when others =>
            pbstate                 <= IDLE;
        end case;
      end if;
    end if;
  end process;

powerburner_instance : for i in 0 to POWERBURNER_INSTANCES-1 generate
begin
powerburner_instantiation: entity work.powerburner
    generic map (
      BRAM_INSTANCE_SIZE   => BRAM_INSTANCE_SIZE,
      X8_REG_INSTANCE_SIZE => X8_REG_INSTANCE_SIZE,
      DSP_INSTANCE_SIZE    => DSP_INSTANCE_SIZE
      )
    port map(
      core_clk             => pb_clk,                                  -- Higher Frequency = Higher switching rate of BRAM
      enable               => pb_quantity_set_i(i),                    -- Signal to enable powerburner
      reset                => areset,                                  -- asyncronous reset
      block_enable         => pb_byte_en_set_i(23 downto 0),           -- Split into 1 byte for DSP, FF and BRAM.
      pb_running           => pb_running_i(i)                          -- Signals to external controller that control engine is running
      );
end generate;

end rtl;
