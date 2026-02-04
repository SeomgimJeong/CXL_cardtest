---------------------------------------------------------------------------
--
--      This source code is provided to you (the Licensee) under license
--      by BittWare, a Molex Company.  To view or use this source code,
--      the Licensee must accept a Software License Agreement (viewable
--      at developer.bittware.com), which is commonly provided as a click-
--      through license agreement.  The terms of the Software License
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
---------------------------------------------------------------------------
--      UNCLASSIFIED//FOR OFFICIAL USE ONLY
--------------------------------------------------------------------------------
-- Title       : SMBus Interface
-- Project     : Common Firmware
--------------------------------------------------------------------------------
-- Description : The I2C Interface allows a host to communicate with external
--               slave devices connected to the FPGA. The I2C consists
--               of a clock that is sourced from the FPGA (i2c_clk) and a
--               bi-directional data signal (i2c_dat).
--
--               I2C Clock:
--               The I2C clock speed is set by the generic I2C_CLK_WIDTH.
--
--
--               Control & Status Registers:
--
--               Register 0: Control & Status (Read/Write)
--               ---------------------------------------------------------------
--                Bit | Init | Description
--               -----+------+--------------------------------------------------
--                 00 |  0   | RESET            (1= Reset Pulse)
--                 01 |  0   | BUSY             (1= I2C Busy)
--                 02 |  0   | I2C REQ          (1= Request Access from BMC)
--                 03 |  0   | I2C GNT          (1= Access Granted from BMC)
--                 04 |  0   | CMD_FIFO_FULL    (1= Command FIFO Full)
--               13:05| x00  | CMD_FIFO_COUNT   (bit 13 = msb)
--                 14 |  1   | READ_FIFO_EMPTY  (1= Read FIFO Empty)
--               23:15| x00  | READ_FIFO_COUNT  (bit 23 = msb)
--                 24 |  0   | NO ACK           (1= No acknowledgement from slave. Read Clear)
--                 25 |  0   | BAD CMD          (1= Invalid Command reg command. Read Clear)
--               31:26| x00  | STATUS           (Application Specific)
--               ---------------------------------------------------------------
--
--               Register 1: Command (Write Only)
--               ---------------------------------------------------------------
--                Bit | Init | Description
--               -----+------+--------------------------------------------------
--               07:00| x00  | TX_BYTE          (bit 7 = msb)
--               16:08| x00  | QUANTITY         (0x001 to 0x1F4, bit 16 = msb)
--               19:17| x00  | Not Used
--                 20 |  0   | START            (1= Start)
--                 21 |  0   | NO_STOP          (1= Finish without a stop)
--               31:22|  0   | Not Used
--               ---------------------------------------------------------------
--
--               Register 2 :Read (Read Only)
--               ---------------------------------------------------------------
--                Bit | Init | Description
--               -----+------+--------------------------------------------------
--               07:00| x00  | READ_DATA        (bit 7 = msb)
--               31:08| x00  | Not Used
--               ---------------------------------------------------------------
--
--
--               Write Command Sequence
--               ----------------------
--
--               First Command:
--               TX_BYTE  = Slave Address & Write Flag
--               QUANTITY = Number of bytes to write (maximum 500)
--               START    = '1'
--               NO_STOP  = '0'
--
--               Subsequent Commands (number equal to QUANTITY):
--               TX_BYTE  = Data Byte (context to suit the slave, so the first
--                          byte could be a register address)
--               QUANTITY = Ignored
--               START    = '0'
--               NO_STOP  = Ignored
--
--               The state machine does not begin to transfer data to the
--               slave until the Command FIFO is holding at least QUANTITY
--               bytes of data when NO_STOP = '0' or QUANTITY + 1 bytes of
--               data when NO_STOP = '1'. The host software can monitor the
--               transfer progress by reading CMD_FIFO_COUNT.
--                 
--
--               Read Command Sequence (simple slave)
--               ------------------------------------
--
--               First Command:
--               TX_BYTE  = Slave Address & Read Flag
--               QUANTITY = Number of bytes to read (maximum 500)
--               START    = '1'
--               NO_STOP  = Ignored
--
--               Once the state machine sends the TX_BYTE, it then retrieves
--               QUANTITY bytes of data from the slave and writes them into
--               the Read FIFO. The host software can read out this data from
--               the Read FIFO in its received order. The host software can
--               monitor the transfer progress by reading READ_FIFO_COUNT.
--
--
--               Read Command Sequence  (slave with 256 addressed registers)
--               -----------------------------------------------------------
--
--               First Command:
--               TX_BYTE  = Slave Address & Write Flag
--               QUANTITY = 0x001
--               START    = '1'
--               NO_STOP  = '1'
--
--               Second Command:
--               TX_BYTE  = Data Byte (slave register address)
--               QUANTITY = Ignored
--               START    = '0'
--               NO_STOP  = Ignored
--
--               Third Command:
--               TX_BYTE  = Slave Address & Read Flag
--               QUANTITY = Number of bytes to read (maximum 500)
--               START    = '1'
--               NO_STOP  = Ignored
--
--               The first two commands cause a write to the slave to set it
--               up ready for reading, while the third command is the actual
--               read request. Setting the NO_STOP bit in the first command
--               prevents a stop at the end of the write (second command),
--               this causes the read (third command) to begins with a repeated
--               start.
--
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity i2c_master is
  generic (
    I2C_CLK_WIDTH       : integer := 400;         -- Period of I2C_CLK in 'config_clk' cycles (must be divisable by 4)
    ADDRESS_START       : std_logic_vector(11 downto 0) := (others => '0')
    );
  port (
    config_clk          : in    std_logic;
    config_rstn         : in    std_logic;
    avmm_read           : in    std_logic;
    avmm_write          : in    std_logic;
    avmm_byteenable     : in    std_logic_vector(3 downto 0);
    avmm_address        : in    std_logic_vector(11 downto 0);
    avmm_writedata      : in    std_logic_vector(31 downto 0);
    avmm_readdatavalid  : in    std_logic;
    dout_0              : out   std_logic_vector(31 downto 0);
    dout_1              : out   std_logic_vector(31 downto 0);
    dout_2              : out   std_logic_vector(31 downto 0);
    -- I2C Interface
    i2c_clk             : inout std_logic;
    i2c_dat             : inout std_logic;
    i2c_req_n           : out   std_logic;
    i2c_gnt_n           : in    std_logic;
    status              : in    std_logic_vector(7 downto 0)
    );
end i2c_master;


architecture rtl of i2c_master is
  
 
  -------------
  -- Constants
  -------------
  constant DATA_HOLD_TIME : integer := 10;  -- config_clk cycles

  ---------
  -- Types
  ---------
  type T_state is (IDLE, EXCEPTION, START, TX_BYTE, SLV_ACK, MST_ACK, RX_BYTE, STOP);

  -----------
  -- Signals
  -----------
  signal i2c_clk_buf          : std_logic;
  signal i2c_clk_in           : std_logic;
  signal cmd_wr_en            : std_logic;
  signal cmd_dout             : std_logic_vector(31 downto 0);
  signal cmd_afull            : std_logic;
  signal cmd_count            : std_logic_vector(8 downto 0);
  signal cmd_empty            : std_logic;
  signal cmd_rd_en            : std_logic                             := '0';
  signal read_wr_en           : std_logic                             := '0';
  signal read_rd_en           : std_logic;
  signal read_dout            : std_logic_vector(7 downto 0);
  signal read_empty           : std_logic;
  signal read_afull           : std_logic;
  signal read_count           : std_logic_vector(8 downto 0);
  signal rst_count            : std_logic_vector(3 downto 0)          := (others => '0');
  signal sync_rst             : std_logic                             := '1';
  signal control_i            : std_logic_vector(0 downto 0)          := (others => '0');
  signal busy                 : std_logic                             := '0';
  signal period_count         : std_logic_vector(15 downto 0)         := (others => '0');
  signal period_quarter       : std_logic                             := '0';
  signal slave_wait           : std_logic                             := '0';
  signal i2c_clk_a1           : std_logic                             := '1';
  signal i2c_clk_i            : std_logic                             := '1';
  signal state                : T_state                               := IDLE;
  signal sub_state_ptr        : std_logic_vector(2 downto 0)          := (others => '0');
  signal i2c_qty              : std_logic_vector(8 downto 0)          := (others => '0');
  signal i2c_read             : std_logic                             := '0';
  signal i2c_no_stop          : std_logic                             := '0';
  signal i2c_dat_out_a1       : std_logic                             := '1';
  signal i2c_dat_out          : std_logic                             := '1';
  signal i2c_dat_buf          : std_logic;
  signal i2c_dat_in           : std_logic                             := '0';
  signal clk_count            : std_logic_vector(3 downto 0)          := (others => '0');
  signal ts_dly               : std_logic_vector(3 downto 0)          := (others => '0');
  signal shift_out            : std_logic_vector(7 downto 0)          := (others => '0');
  signal shift_in             : std_logic_vector(7 downto 0)          := (others => '0');
  
  signal no_ack               : std_logic;
  signal no_ack_d1            : std_logic;
  signal no_ack_reg           : std_logic;
  
  signal bad_cmd              : std_logic;
  signal bad_cmd_d1           : std_logic;
  signal bad_cmd_reg          : std_logic;
  
  signal i2c_gnt_n_in         : std_logic                             := '1';
  signal i2c_gnt_in           : std_logic                             := '0';

  attribute altera_attribute : string;
  attribute altera_attribute of i2c_dat:     signal is "-name FAST_OUTPUT_REGISTER ON";
  attribute altera_attribute of i2c_clk:     signal is "-name FAST_OUTPUT_REGISTER ON";


begin
  
  i2c_dat_buf <= i2c_dat;
  i2c_clk_buf <= i2c_clk;
  
  ----------------
  -- I2C_CLK Input
  ----------------
  i2c_clk_meta : entity work.bretime_async_rst
  generic map (
    DEPTH                     => 2
    )
  port map (
    clock                     => config_clk,                  -- in  std_logic
    d                         => i2c_clk_buf,                -- in  std_logic
    q                         => i2c_clk_in                  -- out std_logic
    );

  i2c_gnt_meta : entity work.bretime_async_rst
  generic map (
    DEPTH                     => 3
    )
  port map (
    clock                     => config_clk,
    d                         => i2c_gnt_n,
    q                         => i2c_gnt_n_in
    );
    
  i2c_gnt_in  <= not(i2c_gnt_n_in);

  ----------------
  -- Command FIFO
  ----------------
  fifo_cmd : entity work.general_fifo
  generic map (
    DWIDTH                    => 32,
    AWIDTH                    => 9,
    ALMOST_FULL_THOLD         => 504,
    RAMTYPE                   => "block",
    FIRST_WORD_FALL_THRU      => TRUE
    )
  port map (
    write_clock               => config_clk,                  -- in  std_logic
    read_clock                => config_clk,                  -- in  std_logic
    fifo_flush                => sync_rst,                  -- in  std_logic
    write_enable              => cmd_wr_en,                 -- in  std_logic
    write_data                => avmm_writedata,               -- in  std_logic_vector(DWIDTH-1 downto 0)
    read_enable               => cmd_rd_en,                 -- in  std_logic
    read_data                 => cmd_dout,                  -- out std_logic_vector(DWIDTH-1 downto 0)
    almost_full               => cmd_afull,                 -- out std_logic
    depth                     => cmd_count,                 -- out std_logic_vector(AWIDTH-1 downto 0);
    empty                     => cmd_empty                  -- out std_logic
    );

  -- Only write into the Command FIFO if there is room.
  cmd_wr_en <= '1' when (avmm_byteenable = "1111") and (avmm_write = '1') and
                        (avmm_address = ADDRESS_START + 4) and
                        (cmd_afull = '0') else '0';

  -------------
  -- Read FIFO
  -------------
  fifo_read : entity work.general_fifo
  generic map (
    DWIDTH                    => 8,
    AWIDTH                    => 9,
    ALMOST_FULL_THOLD         => 504,
    RAMTYPE                   => "block",
    FIRST_WORD_FALL_THRU      => TRUE
    )
  port map (
    write_clock               => config_clk,                  -- in  std_logic
    read_clock                => config_clk,                  -- in  std_logic
    fifo_flush                => sync_rst,                  -- in  std_logic
    write_enable              => read_wr_en,                -- in  std_logic
    write_data                => shift_in,                  -- in  std_logic_vector(DWIDTH-1 downto 0)
    read_enable               => read_rd_en,                -- in  std_logic
    read_data                 => read_dout,                 -- out std_logic_vector(DWIDTH-1 downto 0)
    almost_full               => read_afull,                -- out std_logic
    depth                     => read_count,                -- out std_logic_vector(AWIDTH-1 downto 0);
    empty                     => read_empty                 -- out std_logic
    );

  -- Only read from the Read FIFO if it is not empty.
  read_rd_en <= '1' when (avmm_read = '1') and
                         (avmm_address = ADDRESS_START + 8) and
                         (avmm_readdatavalid = '1') and
                         (read_empty = '0') else '0';


  process(config_clk)
  begin
    if rising_edge(config_clk) then
      ---------------------------------------
      -- Stretch the synchronous reset pulse
      ---------------------------------------
      -- The I2C always resets when a 'start' condition is detected, so 
      -- to reset the I2C it is only necessary to reset the transfer state
      -- machine and to flush the FIFOs.
      if config_rstn = '0' then
        rst_count <= (others => '0');
        sync_rst  <= '1';
      else
        if (avmm_byteenable(0) = '1') and (avmm_write = '1') and (avmm_address = ADDRESS_START) and (avmm_writedata(0) = '1') then
          rst_count <= (others => '0');
          sync_rst  <= '1';
        elsif rst_count /= "1111" then
          rst_count <= rst_count + 1;
        else
          sync_rst  <= '0';
        end if;
      end if;

      ----------------
      -- Control Bits
      ----------------
      if config_rstn = '0' then
        control_i     <= (others => '0');
        no_ack_reg    <= '0';
        bad_cmd_reg   <= '0';
      else
        if (avmm_byteenable(0) = '1') and (avmm_write = '1') and (avmm_address = ADDRESS_START) then
          control_i <= avmm_writedata(2 downto 2);
        end if;
        if no_ack='1' and no_ack_d1='0' then
          no_ack_reg <= '1';
        elsif (avmm_read = '1') and (avmm_address = ADDRESS_START) and (avmm_readdatavalid='1') then
          no_ack_reg <= '0';
        end if;

        if bad_cmd='1' and bad_cmd_d1='0' then
          bad_cmd_reg <= '1';
        elsif (avmm_read = '1') and (avmm_address = ADDRESS_START) and (avmm_readdatavalid='1') then
          bad_cmd_reg <= '0';
        end if;      
        
      end if;
      
      i2c_req_n         <= not(control_i(0));


      if sync_rst = '1' then
        busy            <= '0';
        i2c_clk_a1      <= '1';
        period_count    <= (others => '0');
        period_quarter  <= '0';
        slave_wait      <= '0';
        state           <= IDLE;
        sub_state_ptr   <= (others => '0');
        cmd_rd_en       <= '0';
        read_wr_en      <= '0';
        i2c_qty         <= (others => '0');
        i2c_read        <= '0';
        i2c_no_stop     <= '0';
        i2c_dat_out_a1  <= '1';
        clk_count       <= (others => '0');
        ts_dly          <= (others => '0');
        shift_out       <= (others => '0');
        shift_in        <= (others => '0');
        no_ack          <= '0';
        no_ack_d1       <= '0';
        bad_cmd         <= '0';
        bad_cmd_d1      <= '0';

      else
        -------------------------
        -- Determine BUSY status
        -------------------------
        if (state /= IDLE) or (cmd_empty = '0') then
          busy <= '1';
        else
          busy <= '0';
        end if;

        -----------------------------------
        -- Serial Clock (i2c_clk) generator
        -----------------------------------
        if (state = IDLE) then
          period_count   <= (others => '0');
          i2c_clk_a1      <= '1';
          period_quarter <= '0';
        else
          if (slave_wait = '0') then
            if period_count = (I2C_CLK_WIDTH/2)-1 then
              period_count <= (others => '0');
              i2c_clk_a1    <= not i2c_clk_a1;
            else
              period_count <= period_count + 1;
            end if;

            if period_count = (I2C_CLK_WIDTH/4)-1 then
              period_quarter <= '1';
            else
              period_quarter <= '0';
            end if;
          end if;
        end if;

        -- Slaves can hold the i2c_clk low (stretching) to stall the master until
        -- the slave is ready (e.g. until read data is present). This condition
        -- is detected and used to pause the period counter.
        if (i2c_clk_in = '0') and (i2c_clk_a1 = '1') then
          slave_wait <= '1';
        else
          slave_wait <= '0';
        end if;
        
        no_ack_d1         <= no_ack;
        bad_cmd_d1        <= bad_cmd;
        
        -------------------------------------
        -- State Machine for I2C transfers
        -------------------------------------
        case state is
          when IDLE =>
            no_ack        <= '0';
            bad_cmd       <= '0';
            sub_state_ptr <= (others => '0');
            cmd_rd_en     <= '0';
            read_wr_en    <= '0';
            clk_count     <= (others => '0');
            ts_dly        <= (others => '0');

            if (cmd_empty = '0') then
              if (cmd_dout(20) = '0') or (cmd_dout(16 downto 8) > 500) or (cmd_dout(16 downto 8) = 0) then
                cmd_rd_en <= '1';
                state     <= EXCEPTION;           -- Unexpected data in Command FIFO
              elsif ((cmd_dout(0) = '0') and (cmd_dout(21) = '0') and (cmd_count > cmd_dout(16 downto 8))) or
                    ((cmd_dout(0) = '0') and (cmd_dout(21) = '1') and (cmd_count > cmd_dout(16 downto 8) + 1)) or
                     (cmd_dout(0) = '1') then     -- I2C ready to Start
                i2c_qty     <= cmd_dout(16 downto 8);
                i2c_read    <= cmd_dout(0);
                i2c_no_stop <= cmd_dout(21);
                state       <= START;
              end if;
            end if;

          when EXCEPTION =>
            -- Remove one word from Command FIFO.
            cmd_rd_en <= '0';
            bad_cmd   <= '1';
            state     <= IDLE;

          when START =>
            -- Falling edge on I2C_DAT while I2C_CLK remains high.
            if (i2c_clk_a1 = '1') and (period_quarter = '1') then
              i2c_dat_out_a1 <= '0';
            end if;

            if (i2c_clk_a1 = '0') and (i2c_dat_out_a1 = '0') then
              shift_out <= cmd_dout(7 downto 0);
              state     <= TX_BYTE;
            end if;

          when TX_BYTE =>
            -- Data changes on I2C_DAT with the falling edge of I2C_CLK.
            -- Data is clocked into slave device on rising edge of I2C_CLK.
            -- Data byte is transmitted LSB first, MSB last.
            if (i2c_clk_a1 = '0') and (period_quarter = '1') then
              i2c_dat_out_a1 <= shift_out(7);
              shift_out     <= (shift_out(6 downto 0) & '0');
              clk_count     <= clk_count + 1;
            end if;

            if (i2c_clk_a1 = '1') and (period_quarter = '1') and (clk_count = 8) then
              clk_count <= (others => '0');
              state     <= SLV_ACK;
            end if;

          when SLV_ACK =>
            -- Slave device drives I2C_DAT low while I2C_CLK is high.
            if sub_state_ptr = 0 then
              if i2c_clk_a1 = '0' then
                sub_state_ptr <= sub_state_ptr + 1;
                cmd_rd_en     <= '1';
              end if;
            end if;

            if sub_state_ptr = 1 then
              cmd_rd_en <= '0';
              if ts_dly /= DATA_HOLD_TIME then
                ts_dly <= ts_dly + 1;
              else
                i2c_dat_out_a1 <= '1';
                sub_state_ptr <= sub_state_ptr + 1;
              end if;
            end if;

            if sub_state_ptr = 2 then
              if (i2c_clk_a1 = '1') and (period_quarter = '1') then
                sub_state_ptr <= (others => '0');
                ts_dly        <= (others => '0');

                if i2c_dat_in /= '0' then                    -- Not acknowledged
                  no_ack  <= '1'; 
                  state   <= IDLE;
                else
                  if i2c_read = '0' then                    -- Write
                    if (i2c_qty = 0) or (cmd_dout(20) = '1') then
                      -- Select how to end the write sequence (stop or repeated start)
                      if i2c_no_stop  = '0' then
                        state       <= STOP;
                      else
                        i2c_qty     <= cmd_dout(16 downto 8);
                        i2c_read    <= cmd_dout(0);
                        i2c_no_stop <= cmd_dout(21);
                        state       <= START;
                      end if;
                    else
                      i2c_qty   <= i2c_qty - 1;
                      shift_out <= cmd_dout(7 downto 0);
                      state     <= TX_BYTE;
                    end if;
                  else                                      -- Read
                    state <= RX_BYTE;
                  end if;
                end if;
              end if;
            end if;

          when RX_BYTE =>
            -- Data changes on I2C_DAT with the falling edge of I2C_CLK.
            -- Data is clocked into master device following the rising edge of I2C_CLK.
            -- Data byte is transmitted LSB first, MSB last.
            i2c_dat_out_a1 <= '1';
            if sub_state_ptr = 0 then
              if (i2c_clk_a1 = '1') and (period_quarter = '1') then
                shift_in  <= (shift_in(6 downto 0) & i2c_dat_in);
                clk_count <= clk_count + 1;
              end if;

              if (i2c_clk_a1 = '0') and (period_quarter = '1') and (clk_count = 8) then
                sub_state_ptr <= sub_state_ptr + 1;
                clk_count     <= (others => '0');
                i2c_qty       <= i2c_qty - 1;
                if read_count /= "111111111" then           -- Check Read FIFO is not full
                  read_wr_en <= '1';
                end if;
              end if;
            end if;

            if sub_state_ptr = 1 then
              sub_state_ptr <= (others => '0');
              read_wr_en    <= '0';
              if i2c_qty = 0 then
                state <= STOP;
              else
                state <= MST_ACK;
              end if;
            end if;

          when MST_ACK =>
            -- Master drives I2C_DAT low while I2C_CLK is high.
            if sub_state_ptr = 0 then
              sub_state_ptr <= sub_state_ptr + 1;
              i2c_dat_out_a1 <= '0';
            end if;

            if sub_state_ptr = 1 then
              if (i2c_clk_a1 = '1') then
                sub_state_ptr <= sub_state_ptr + 1;
              end if;
            end if;

            if sub_state_ptr = 2 then
              if (i2c_clk_a1 = '0') then
                sub_state_ptr <= sub_state_ptr + 1;
              end if;
            end if;

            if sub_state_ptr = 3 then
              if ts_dly /= DATA_HOLD_TIME then
                ts_dly <= ts_dly + 1;
              else
                i2c_dat_out_a1 <= '1';
                sub_state_ptr <= sub_state_ptr + 1;
              end if;
            end if;

            if sub_state_ptr = 4 then
              sub_state_ptr <= (others => '0');
              ts_dly        <= (others => '0');
              state         <= RX_BYTE;
            end if;

          when STOP =>
            -- An ACK period (unresponded) followed by a rising edge
            -- on I2C_DAT while I2C_CLK remains high.
            if (i2c_clk_a1 = '0') and (period_quarter = '1') then
              sub_state_ptr <= sub_state_ptr + 1;
              i2c_dat_out_a1 <= '0';
            end if;

            if sub_state_ptr = 1 then
              if (i2c_clk_a1 = '1') and (period_quarter = '1') then
                sub_state_ptr <= sub_state_ptr + 1;
                i2c_dat_out_a1 <= '1';
                sub_state_ptr <= (others => '0');
                state         <= IDLE;
              end if;
            end if;

          when others =>
            NULL;

        end case;
      end if;

      ---------------------------------------------
      -- Add pipeline stage to I/O to help routing
      ---------------------------------------------
      i2c_clk_i   <= i2c_clk_a1;
      i2c_dat_out <= i2c_dat_out_a1;
      i2c_dat_in  <= i2c_dat_buf;

    end if;
  end process;


  -------------------
  -- Connect Outputs
  -------------------
  dout_0  <= (status(5 downto 0) & bad_cmd_reg & no_ack_reg & read_count & read_empty & cmd_count & cmd_afull & i2c_gnt_in & control_i & busy & '0');
  dout_1  <= (others => '0');
  dout_2  <= (x"000000" & read_dout);
  
  i2c_dat  <= '0' when i2c_dat_out = '0' else 'Z';    
  i2c_clk  <= '0' when i2c_clk_i = '0'   else 'Z';

end rtl;
