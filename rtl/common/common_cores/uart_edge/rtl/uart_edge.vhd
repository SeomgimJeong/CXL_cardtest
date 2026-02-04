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
-- Title       : UART Edge Core
-- Project     : Common Gateware
--------------------------------------------------------------------------------
-- Description : This is the top level of the UART Edge Core.
--
--               Sample Ratio
--               ------------
--
--               This input can be set dynamically by a register and controls
--               the sampling of the incoming serial data on ‘host_proc_tx’ and
--               sets the timing of outgoing serial data on ‘host_proc_tx’.
--               The input should be set to a value equal to the ‘uart_clk’
--               frequency divided by the desired serial line rate
--               (minimum value = 10, maximum value = 4095).
--
--                 Example:
--                 uart_clk = 20MHz
--                 line rate = 2Mb/s
--                   => sample_ratio = 10 (0x00A)
--
--                 Example:
--                 uart_clk = 20MHz
--                 line rate = 115.200kb/s
--                   => sample_ratio = 174 (0x0AE)
--
--                 Example:
--                 uart_clk = 20MHz
--                 line rate = 9.600kb/s
--                   => sample_ratio = 2083 (0x823)
--
--
--------------------------------------------------------------------------------
-- Known Issues and Omissions:
--
--
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity uart_edge is
  port (
    -- Clocks & Reset
    uart_clk            : in  std_logic;
    sync_rst            : in  std_logic;
    -- Serial Communications
    sample_ratio        : in  std_logic_vector(11 downto 0);
    fpga_id             : in  std_logic_vector(3 downto 0);
    host_proc_tx        : in  std_logic;
    host_proc_rx        : out std_logic;
    -- Register Interface
    reg_addr            : out std_logic_vector(31 downto 0);
    reg_wr_data         : out std_logic_vector(31 downto 0);
    reg_wr_en           : out std_logic;
    reg_rd_en           : out std_logic;
    reg_rd_data         : in  std_logic_vector(31 downto 0);
    reg_rd_rdy          : in  std_logic
    );
end uart_edge;


architecture rtl of uart_edge is
  ---------
  -- Types
  ---------
  type T_uart_state is (
    IDLE,
    SKIP_SIZE,
    SKIP,
    SIZE,
    SHORT_WR,
    SHORT_RD,
    FULL_WR,
    FULL_RD);

  -----------
  -- Signals
  -----------
  signal sample_ratio_reg     : std_logic_vector(11 downto 0)         := (others => '1');
  signal host_proc_tx_meta    : std_logic_vector(4 downto 0)          := "00001";
  signal serial_capt_ctrl     : std_logic                             := '0';
  signal sample_count         : std_logic_vector(11 downto 0)         := (others => '0');
  signal sample_count_limit   : std_logic                             := '0';
  signal sample_count_half    : std_logic                             := '0';
  signal bit_count_in         : std_logic_vector(3 downto 0)          := (others => '0');
  signal shift_data_in        : std_logic_vector(7 downto 0)          := (others => '0');
  signal shift_data_rdy       : std_logic                             := '0';
  signal shift_out_ctrl       : std_logic_vector(1 downto 0)          := (others => '0');
  signal shift_data_out       : std_logic_vector(9 downto 0)          := (others => '0');
  signal rd_data_sel          : std_logic_vector(1 downto 0)          := (others => '0');
  signal host_proc_rx_i       : std_logic                             := '1';
  signal resp_count           : std_logic_vector(11 downto 0)         := (others => '0');
  signal resp_count_limit     : std_logic                             := '0';
  signal bit_count_out        : std_logic_vector(3 downto 0)          := (others => '0');
  signal word_count_out       : std_logic_vector(1 downto 0)          := (others => '0');
  signal uart_state           : T_uart_state                          := IDLE;
  signal read_flag            : std_logic                             := '0';
  signal fifo_flag            : std_logic                             := '0';
  signal pkt_byte_gauge       : std_logic_vector(10 downto 0)         := (others => '0');
  signal addr_ptr             : std_logic_vector(2 downto 0)          := (others => '0');
  signal reg_addr_acc_lo      : std_logic_vector(15 downto 0)         := (others => '0');
  signal reg_addr_acc_hi      : std_logic_vector(15 downto 0)         := (others => '0');
  signal reg_addr_acc_cr      : std_logic                             := '0';
  signal reg_wr_data_i        : std_logic_vector(31 downto 0)         := (others => '0');
  signal reg_wr_en_i          : std_logic                             := '0';
  signal reg_rd_en_i          : std_logic                             := '0';
  signal wd_bit_count         : std_logic_vector(11 downto 0)         := (others => '0');
  signal wd_count             : std_logic_vector(15 downto 0)         := (others => '0');
  signal wd_reset             : std_logic                             := '0';


begin

  process(uart_clk)

  variable sample_count_chk_v : std_logic_vector(11 downto 0)         := (others => '0');

  begin
    if rising_edge(uart_clk) then
      ---------------------------------------
      -- Synchronise Changes in Sample Ratio
      ---------------------------------------
      if serial_capt_ctrl = '0' then
        sample_ratio_reg <= sample_ratio;
      end if;

      ------------------------------------------
      -- Capture Logic for Incoming Serial Data
      ------------------------------------------
      -- Double register host_proc_tx for meta-stability protection.
      -- Inversion used to force ISE to use an IOB register and not an SRL16.
      host_proc_tx_meta <= (host_proc_tx_meta(3 downto 1) & not host_proc_tx_meta(0) & host_proc_tx);

      -- Detect the rising edge of Start Bit and set the serial capture control
      -- flag. This flag is cleared when ten serial bit periods have passed.
      if (bit_count_in = 9) and (sample_count_half = '1') then
        serial_capt_ctrl <= '0';
      elsif host_proc_tx_meta(3 downto 2) = "01" then
        serial_capt_ctrl <= '1';
      end if;

      -- Counter to determine the sampling point of the serial data.
      -- The decoded outputs are registered to aid timing closure.
      if (serial_capt_ctrl = '0') or (sample_count_limit = '1') then
        sample_count       <= (others => '0');
        sample_count_limit <= '0';
        sample_count_half  <= '0';
      else 
        sample_count <= sample_count + 1;
        if sample_count = sample_ratio_reg - 2 then   -- Decode rollover limit
          sample_count_limit <= '1';
        end if;

        sample_count_chk_v := ('0' & sample_ratio_reg(11 downto 1));
        sample_count_chk_v := sample_count_chk_v - 2;

        if sample_count = sample_count_chk_v then     -- Decode halfway point
          sample_count_half <= '1';
        else
          sample_count_half <= '0';
        end if;
      end if;

      -- Count in the serial data bits.
      if serial_capt_ctrl = '0' then
        bit_count_in <= (others => '0');
      elsif sample_count_half = '1' then
        bit_count_in <= bit_count_in + 1;
      end if;

      -- Capture the serial data bits.
      if sample_count_half = '1' then
        shift_data_in <= (not host_proc_tx_meta(4) & shift_data_in(7 downto 1));
      end if;

      -- Indicate when shift register contains a new 8-bit data word.
      if (bit_count_in = 8) and (sample_count_half = '1') then
        shift_data_rdy <= '1';
      else
        shift_data_rdy <= '0';
      end if;

      -------------------------------------------
      -- Logic for Creating Response Serial Data
      -------------------------------------------
      -- Send the response as a block of four data bytes.
      if reg_rd_rdy = '1' then
        shift_out_ctrl <= (shift_out_ctrl(0) & '1');
      elsif (word_count_out = 3) and (bit_count_out = 9) and (resp_count_limit = '1') then
        shift_out_ctrl <= (others => '0');
      end if;

      -- Load and shift out the 10-bit serial word.
      if (shift_out_ctrl = "01") or ((bit_count_out = 9) and (resp_count_limit = '1') and (reg_rd_rdy = '1')) then
        case rd_data_sel is
          when "00" => shift_data_out <= ('0' & not reg_rd_data(7 downto 0)   & '1');
          when "01" => shift_data_out <= ('0' & not reg_rd_data(15 downto 8)  & '1');
          when "10" => shift_data_out <= ('0' & not reg_rd_data(23 downto 16) & '1');
          when "11" => shift_data_out <= ('0' & not reg_rd_data(31 downto 24) & '1');
          when others => null;
        end case;
      elsif resp_count_limit = '1' then
        shift_data_out <= ('0' & shift_data_out(9 downto 1));
      end if;

      -- Ensure that final register is placed in IOB.
      host_proc_rx_i <= not shift_data_out(0);

      -- Counter to determine the period of the serial data.
      -- The decoded outputs are registered to aid timing closure.
      if (shift_out_ctrl(1) = '0') or (resp_count_limit = '1') then
        resp_count       <= (others => '0');
        resp_count_limit <= '0';
      else
        resp_count <= resp_count + 1;
        if resp_count = sample_ratio_reg - 2 then     -- Decode rollover limit
          resp_count_limit <= '1';
        end if;
      end if;

      -- Count out the serial data bits (ten bits per data word).
      if (shift_out_ctrl(1) = '0') or ((bit_count_out = 9) and (resp_count_limit = '1')) then
        bit_count_out <= (others => '0');
      elsif resp_count = sample_ratio_reg - 1 then
        bit_count_out <= bit_count_out + 1;
      end if;

      -- Count out the serial data words.
      if shift_out_ctrl(1) = '0' then
        word_count_out <= (others => '0');
      elsif (bit_count_out = 9) and (resp_count_limit = '1') then
        word_count_out <= word_count_out + 1;
      end if;

      -- Count out the serial data words.
      if shift_out_ctrl(1) = '0' then
        rd_data_sel <= (others => '0');
      elsif (bit_count_out = 8) and (resp_count_limit = '1') then
        rd_data_sel <= rd_data_sel + 1;
      end if;

      ------------------------------------
      -- State Machine to Process Packets
      ------------------------------------
      case uart_state is
        when IDLE =>
          reg_wr_en_i <= '0';
          reg_rd_en_i <= '0';
          addr_ptr    <= (others => '0');

          if shift_data_rdy = '1' then
            read_flag <= shift_data_in(7);
            fifo_flag <= shift_data_in(5);

            case shift_data_in(7 downto 6) is
              when "00" => pkt_byte_gauge <= "00000000101";     -- Short Address Write (5)
              when "01" => pkt_byte_gauge <= "00000001000";     -- Full  Address Write (8)
              when "10" => pkt_byte_gauge <= "00000000001";     -- Short Address Read  (1)
              when "11" => pkt_byte_gauge <= "00000000100";     -- Full  Address Read  (4)
              when others => null;
            end case;

            if (shift_data_in(3 downto 0) = fpga_id) then
              if shift_data_in(6) = '1' then
                uart_state <= SIZE;
              elsif shift_data_in(7) = '0' then
                uart_state <= SHORT_WR;
              else
                uart_state <= SHORT_RD;
              end if;
            elsif ((shift_data_in(3 downto 0) = "1111") and (shift_data_in(7) = '0')) then    -- Broadcast write
              if shift_data_in(6) = '1' then
                uart_state <= SIZE;
              else
                uart_state <= SHORT_WR;
              end if;
            else
              if shift_data_in(6) = '1' then
                uart_state <= SKIP_SIZE;
              else
                uart_state <= SKIP;
              end if;
            end if;
          end if;

        when SKIP_SIZE =>
          if wd_reset = '1' then
            uart_state <= IDLE;

          elsif shift_data_rdy = '1' then
            if read_flag = '0' then
              pkt_byte_gauge <= pkt_byte_gauge + ('0' & shift_data_in & "00");
            end if;
            uart_state <= SKIP;
          end if;

        when SKIP =>
          if wd_reset = '1' then
            uart_state <= IDLE;

          elsif shift_data_rdy = '1' then
            pkt_byte_gauge <= pkt_byte_gauge - 1;

            if pkt_byte_gauge = 1 then
              uart_state <= IDLE;
            end if;
          end if;

        when SIZE =>
          if wd_reset = '1' then
            uart_state <= IDLE;

          elsif shift_data_rdy = '1' then
            pkt_byte_gauge <= pkt_byte_gauge + ('0' & shift_data_in & "00");

            if read_flag = '0' then
              uart_state <= FULL_WR;
            else
              uart_state <= FULL_RD;
            end if;
          end if;

        when SHORT_WR =>
          if wd_reset = '1' then
            uart_state <= IDLE;

          elsif shift_data_rdy = '1' then
            pkt_byte_gauge <= pkt_byte_gauge - 1;

            if pkt_byte_gauge = 5 then
              reg_addr_acc_lo <= (x"00" & shift_data_in);
              reg_addr_acc_hi <= (others => '0');
              reg_addr_acc_cr <= '0';
            elsif pkt_byte_gauge = 4 then
              reg_wr_data_i(7 downto 0)   <= shift_data_in;
            elsif pkt_byte_gauge = 3 then
              reg_wr_data_i(15 downto 8)  <= shift_data_in;
            elsif pkt_byte_gauge = 2 then
              reg_wr_data_i(23 downto 16) <= shift_data_in;
            elsif pkt_byte_gauge = 1 then
              reg_wr_data_i(31 downto 24) <= shift_data_in;
              reg_wr_en_i <= '1';
              uart_state  <= IDLE;
            end if;
          end if;

        when SHORT_RD =>
          if wd_reset = '1' then
            uart_state <= IDLE;

          elsif shift_data_rdy = '1' then
            pkt_byte_gauge  <= (others => '0');
            addr_ptr        <= addr_ptr + 1;
            reg_addr_acc_lo <= (x"00" & shift_data_in);
            reg_addr_acc_hi <= (others => '0');
            reg_addr_acc_cr <= '0';

          elsif addr_ptr = 1 then                     -- Send response data
            if sample_count_half = '1' then
              reg_rd_en_i   <= '1';
            elsif word_count_out = 3 then
              reg_rd_en_i   <= '0';
              uart_state    <= IDLE;
            end if;
          end if;

        when FULL_WR =>
          if wd_reset = '1' then
            uart_state <= IDLE;

          elsif shift_data_rdy = '1' then
            pkt_byte_gauge <= pkt_byte_gauge - 1;

            if addr_ptr < 5 then        
              addr_ptr <= addr_ptr + 1;
            end if;

            if addr_ptr = 0 then
              reg_addr_acc_lo(7 downto 0)  <= shift_data_in;
            elsif addr_ptr = 1 then
              reg_addr_acc_lo(15 downto 8) <= shift_data_in;
            elsif addr_ptr = 2 then
              reg_addr_acc_hi(7 downto 0)  <= shift_data_in;
            elsif addr_ptr = 3 then
              reg_addr_acc_hi(15 downto 8) <= shift_data_in;
              if reg_addr_acc_lo = x"FFFF" then
                reg_addr_acc_cr <= '1';
              else
                reg_addr_acc_cr <= '0';
              end if;
            elsif addr_ptr = 4 then
              reg_wr_data_i(7 downto 0) <= shift_data_in;
            else
              if pkt_byte_gauge(1 downto 0) = 0 then
                reg_wr_data_i(7 downto 0) <= shift_data_in;
                if (fifo_flag = '0') then
                  reg_addr_acc_lo <= reg_addr_acc_lo + 1;
                  if reg_addr_acc_lo = x"FFFE" then
                    reg_addr_acc_cr <= '1';
                  else
                    reg_addr_acc_cr <= '0';
                  end if;
                  if reg_addr_acc_cr = '1' then
                    reg_addr_acc_hi <= reg_addr_acc_hi + 1;
                  end if;
                end if;
              elsif pkt_byte_gauge(1 downto 0) = 3 then
                reg_wr_data_i(15 downto 8) <= shift_data_in;
              elsif pkt_byte_gauge(1 downto 0) = 2 then
                reg_wr_data_i(23 downto 16) <= shift_data_in;
              elsif pkt_byte_gauge(1 downto 0) = 1 then
                reg_wr_data_i(31 downto 24) <= shift_data_in;
                reg_wr_en_i <= '1';
              end if;
            end if;

            if pkt_byte_gauge = 1 then
              uart_state <= IDLE;
            end if;

          else
            reg_wr_en_i <= '0';
          end if;

        when FULL_RD =>
          if wd_reset = '1' then
            uart_state <= IDLE;

          elsif shift_data_rdy = '1' then
            pkt_byte_gauge <= pkt_byte_gauge - 1;
            addr_ptr       <= addr_ptr + 1;

            if addr_ptr = 0 then
              reg_addr_acc_lo(7 downto 0)  <= shift_data_in;
            elsif addr_ptr = 1 then
              reg_addr_acc_lo(15 downto 8) <= shift_data_in;
            elsif addr_ptr = 2 then
              reg_addr_acc_hi(7 downto 0)  <= shift_data_in;
            elsif addr_ptr = 3 then
              reg_addr_acc_hi(15 downto 8) <= shift_data_in;
              if reg_addr_acc_lo = x"FFFF" then
                reg_addr_acc_cr <= '1';
              else
                reg_addr_acc_cr <= '0';
              end if;
            end if;

          elsif addr_ptr = 4 then                     -- Send response data
            if sample_count_half = '1' then
              reg_rd_en_i <= '1';
              addr_ptr    <= addr_ptr + 1;
            end if;

          elsif addr_ptr = 5 then
            if word_count_out = 3 and reg_rd_en_i = '1' then
              reg_rd_en_i <= '0';
              if pkt_byte_gauge = 0 then
                uart_state <= IDLE;
              else
                addr_ptr       <= addr_ptr + 1;
                pkt_byte_gauge <= pkt_byte_gauge - 4;
              end if;
            end if;

          elsif addr_ptr = 6 then
            if reg_rd_rdy = '0' then
              addr_ptr    <= addr_ptr + 1;
              reg_rd_en_i <= '1';
              if (fifo_flag = '0') then
                reg_addr_acc_lo <= reg_addr_acc_lo + 1;
                if reg_addr_acc_lo = x"FFFE" then
                  reg_addr_acc_cr <= '1';
                else
                  reg_addr_acc_cr <= '0';
                end if;
                if reg_addr_acc_cr = '1' then
                  reg_addr_acc_hi <= reg_addr_acc_hi + 1;
                end if;
              end if;
            end if;

          elsif addr_ptr = 7 then
            if word_count_out = 0 then
              addr_ptr <= "101";
            end if;
          end if;

        when others =>
          null;
      end case;

      ------------------
      -- Watchdog Timer
      ------------------
      if sync_rst = '1' then
        wd_reset <= '1';
      else
        if uart_state = IDLE then
          wd_bit_count <= (others => '0');
          wd_count     <= (others => '0');
          wd_reset     <= '0';

        else
          if wd_bit_count /= sample_ratio_reg - 1 then
            wd_bit_count <= wd_bit_count + 1;
          else
            wd_bit_count <= (others => '0');
            if wd_count /= x"FFFF" then               -- Watchdog reset after 65536 bit periods
              wd_count <= wd_count + 1;
            else 
              wd_reset <= '1';
            end if;
          end if;
        end if;
      end if;

    end if;
  end process;


  -- Connect up outputs.
  host_proc_rx <= host_proc_rx_i;

  reg_addr     <= (reg_addr_acc_hi & reg_addr_acc_lo);
  reg_wr_data  <= reg_wr_data_i;
  reg_wr_en    <= reg_wr_en_i;
  reg_rd_en    <= reg_rd_en_i;


end rtl;

