library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library lpgbt_fpga;
use lpgbt_fpga.lpgbtfpga_package.all;

library hal;
use hal.lpgbt_pkg.all;
use hal.system_types_pkg.all;

entity lpgbt_link_wrapper is
  generic (
    -- lpgbt controls
    g_LPGBT_BYPASS_INTERLEAVER          : std_logic := '0';
    g_LPGBT_BYPASS_FEC                  : std_logic := '0';
    g_LPGBT_BYPASS_SCRAMBLER            : std_logic := '0';
    g_DOWNLINK_WORD_WIDTH               : integer   := 32;  -- IC + EC + User Data + FEC
    g_DOWNLINK_MULTICYCLE_DELAY         : integer   := 4;   -- Multicycle delay: USEd to relax the timing constraints
    g_DOWNLINK_CLOCK_RATIO              : integer   := 8;   -- Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
    g_UPLINK_DATARATE                   : integer   := DATARATE_10G24;
    g_UPLINK_FEC                        : integer   := FEC5;
    g_UPLINK_MULTICYCLE_DELAY           : integer   := 4;   -- --! Multicycle delay: Used to relax the timing constraints
    g_UPLINK_CLOCK_RATIO                : integer   := 8;   -- Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
    g_UPLINK_WORD_WIDTH                 : integer   := 32;
    g_UPLINK_ALLOWED_FALSE_HEADER       : integer   := 5;
    g_UPLINK_ALLOWED_FALSE_HEADER_OVERN : integer   := 64;
    g_UPLINK_REQUIRED_TRUE_HEADER       : integer   := 30;
    g_UPLINK_BITSLIP_MINDLY             : integer   := 1;
    g_UPLINK_BITSLIP_WAITDLY            : integer   := 40;

    -- quantities
    g_NUM_DOWNLINKS : integer := 1;
    g_NUM_UPLINKS   : integer := 2;

    -- pipeline registers
    g_PIPELINE_BITSLIP : boolean := true;
    g_PIPELINE_LPGBT   : boolean := true;
    g_PIPELINE_MGT     : boolean := true
    );
  port(

    reset : in std_logic;

    --------------------------------------------------------------------------------
    -- Downlink
    --------------------------------------------------------------------------------

    -- 320 Mhz Downlink Fabric Clock
    downlink_clk : in std_logic;

    -- 1 bit valid (strobe at 40MHz)
    -- 32 bits / bx from fabric
    -- 2 bits ic
    -- 2 bits ec
    downlink_data_i : in lpgbt_downlink_data_rt_array (g_NUM_DOWNLINKS-1 downto 0);

    -- reset
    downlink_reset_i : in std_logic_vector (g_NUM_DOWNLINKS-1 downto 0);

    -- ready
    downlink_ready_o : out std_logic_vector (g_NUM_DOWNLINKS-1 downto 0);

    -- 32 bits / bx to mgt
    downlink_mgt_word_array_o : out std32_array_t (g_NUM_DOWNLINKS-1 downto 0);

    --------------------------------------------------------------------------------
    -- Uplink
    --------------------------------------------------------------------------------

    -- 320 MHz Uplink Fabric Clock
    uplink_clk : in std_logic;          -- 320 MHz

    -- 1 bit valid output (strobes at 40MHz)
    -- 224 bits / bx to fabric
    -- 2 bits ic
    -- 2 bits ec
    uplink_data_o : out lpgbt_uplink_data_rt_array (g_NUM_UPLINKS-1 downto 0);

    -- 256 bits / bx from mgt
    uplink_mgt_word_array_i : in std32_array_t (g_NUM_UPLINKS-1 downto 0);

    -- reset
    uplink_reset_i : in std_logic_vector (g_NUM_UPLINKS-1 downto 0);

    -- ready
    uplink_ready_o : out std_logic_vector (g_NUM_UPLINKS-1 downto 0);

    -- bitslip flag to connect to mgt rxslide for alignment
    uplink_bitslip_o : out std_logic_vector (g_NUM_UPLINKS-1 downto 0);

    uplink_fec_err_o : out std_logic_vector (g_NUM_UPLINKS-1 downto 0)

    );
end lpgbt_link_wrapper;


architecture Behavioral of lpgbt_link_wrapper is

  constant COUNTER_WIDTH : integer := 16;
  type counter_array_t is array (integer range <>) of std_logic_vector(COUNTER_WIDTH-1 downto 0);
  -- counters
  signal fec_err_cnt     : counter_array_t(g_NUM_UPLINKS-1 downto 0);

  -- up/downlink ready flag
  signal downlink_ready : std_logic_vector (g_NUM_DOWNLINKS-1 downto 0);  --
  signal uplink_ready   : std_logic_vector (g_NUM_UPLINKS downto 0);

begin

  --------------------------------------------------------------------------------
  -- Downlink
  --------------------------------------------------------------------------------

  downlink_gen : for I in 0 to g_NUM_DOWNLINKS-1 generate

    signal downlink_data  : lpgbt_downlink_data_rt;
    signal mgt_data       : std_logic_vector(31 downto 0);
    signal downlink_reset : std_logic := '1';

  begin

    downlink_reset_fanout : process (downlink_clk) is
    begin  -- process reset_fanout
      if rising_edge(downlink_clk) then  -- rising clock edge
        downlink_reset <= not (reset or downlink_reset_i(I));
      end if;
    end process;

    downlink_inst : entity lpgbt_fpga.lpgbtfpga_downlink

      generic map (
        c_multicyleDelay => g_DOWNLINK_MULTICYCLE_DELAY,
        c_clockRatio     => g_DOWNLINK_CLOCK_RATIO,
        c_outputWidth    => g_DOWNLINK_WORD_WIDTH
        )
      port map (
        clk_i               => downlink_clk,
        rst_n_i             => downlink_reset,
        clken_i             => downlink_data.valid,
        userdata_i          => downlink_data.data,
        ecdata_i            => downlink_data.ec,
        icdata_i            => downlink_data.ic,
        mgt_word_o          => mgt_data,
        interleaverbypass_i => g_LPGBT_BYPASS_INTERLEAVER,
        encoderbypass_i     => g_LPGBT_BYPASS_FEC,
        scramblerbypass_i   => g_LPGBT_BYPASS_SCRAMBLER,
        rdy_o               => downlink_ready(I)
        );

    --------------------------------------------------------------------------------
    -- optionally pipeline some of the downlink registers
    -- (fixed some timing issues)
    --------------------------------------------------------------------------------

    lpgbtlatch : if (g_PIPELINE_LPGBT) generate
      downlink_data_pipe : process (downlink_clk) is
      begin  -- process downlink_data_pipe
        if downlink_clk'event and downlink_clk = '1' then  -- rising clock edge
          downlink_data <= downlink_data_i(I);
        end if;
      end process downlink_data_pipe;
    end generate;

    lpgbtnolatch : if (not g_PIPELINE_LPGBT) generate
      downlink_data <= downlink_data_i(I);
    end generate;

    mgtlatch : if (g_PIPELINE_MGT) generate
      downlink_data_pipe : process (downlink_clk) is
      begin  -- process downlink_data_pipe
        if downlink_clk'event and downlink_clk = '1' then  -- rising clock edge
          downlink_mgt_word_array_o(I) <= mgt_data;
        end if;
      end process downlink_data_pipe;
    end generate;

    mgtnolatch : if (not g_PIPELINE_MGT) generate
      downlink_mgt_word_array_o(I) <= mgt_data;
    end generate;

  end generate;

--------------------------------------------------------------------------------
-- Uplink
--------------------------------------------------------------------------------

  uplink_gen : for I in 0 to g_NUM_UPLINKS-1 generate

    signal uplink_data : lpgbt_uplink_data_rt;
    signal mgt_data    : std_logic_vector(31 downto 0);
    signal bitslip     : std_logic;
    signal unused_bits : std_logic_vector(5 downto 0);

    signal fec_err       : std_logic := '0';
    signal datacorrected : std_logic_vector (229 downto 0);
    signal iccorrected   : std_logic_vector (1 downto 0);
    signal eccorrected   : std_logic_vector (1 downto 0);

    signal uplink_reset : std_logic := '1';

  begin

    uplink_reset_fanout : process (uplink_clk) is
    begin  -- process reset_fanout
      if rising_edge(uplink_clk) then                      -- rising clock edge
        uplink_reset <= not (reset or uplink_reset_i(I));  -- active LOW
      end if;
    end process;

    uplink_inst : entity lpgbt_fpga.lpgbtfpga_uplink

      generic map (
        datarate                  => g_UPLINK_DATARATE,
        fec                       => g_UPLINK_FEC,
        c_multicyledelay          => g_UPLINK_MULTICYCLE_DELAY,
        c_clockratio              => g_UPLINK_CLOCK_RATIO,
        c_mgtwordwidth            => g_UPLINK_WORD_WIDTH,
        c_allowedfalseheader      => g_UPLINK_ALLOWED_FALSE_HEADER,
        c_allowedfalseheaderovern => g_UPLINK_ALLOWED_FALSE_HEADER_OVERN,
        c_requiredtrueheader      => g_UPLINK_REQUIRED_TRUE_HEADER,
        c_bitslip_mindly          => g_UPLINK_BITSLIP_MINDLY,
        c_bitslip_waitdly         => g_UPLINK_BITSLIP_WAITDLY
        )

      port map (
        clk_freerunningclk_i       => std_logic0,  -- not used since reset on even feature is
                                                   -- disabled in frame aligner
        uplinkclk_i                => uplink_clk,
        uplinkrst_n_i              => uplink_reset,
        mgt_word_o                 => mgt_data,
        bypassinterleaver_i        => g_LPGBT_BYPASS_INTERLEAVER,
        bypassfecencoder_i         => g_LPGBT_BYPASS_FEC,
        bypassscrambler_i          => g_LPGBT_BYPASS_SCRAMBLER,
        uplinkclkouten_o           => uplink_data.valid,
        userdata_o(223 downto 0)   => uplink_data.data,
        userdata_o(229 downto 224) => unused_bits,
        ecdata_o                   => uplink_data.ec,
        icdata_o                   => uplink_data.ic,
        mgt_bitslipctrl_o          => bitslip,
        datacorrected_o            => datacorrected,
        iccorrected_o              => iccorrected,
        eccorrected_o              => eccorrected,
        rdy_o                      => uplink_ready(I)
        );

    --------------------------------------------------------------------------------
    -- Error Counters
    --------------------------------------------------------------------------------

    process (uplink_clk) is
      variable reduce_pipe_s0 : std_logic_vector (32*7+1-1 downto 0) := (others => '0');
    begin
      if (rising_edge(uplink_clk)) then
        -- pipeline to ease timing
        reduce_pipe_s0(0)   := or_reduce(datacorrected(31 downto 0));
        reduce_pipe_s0(1)   := or_reduce(datacorrected(63 downto 32));
        reduce_pipe_s0(2)   := or_reduce(datacorrected(95 downto 64));
        reduce_pipe_s0(3)   := or_reduce(datacorrected(127 downto 96));
        reduce_pipe_s0(4)   := or_reduce(datacorrected(159 downto 128));
        reduce_pipe_s0(5)   := or_reduce(datacorrected(191 downto 160));
        reduce_pipe_s0(6)   := or_reduce(datacorrected(223 downto 192));
        reduce_pipe_s0(7)   := or_reduce(iccorrected & eccorrected & datacorrected(229 downto 224));
        uplink_fec_err_o(I) <= or_reduce(reduce_pipe_s0 (7 downto 0));
      end if;
    end process;


    --------------------------------------------------------------------------------
    -- optionally pipeline some of the uplink registers
    -- (fixed some timing issues)
    --------------------------------------------------------------------------------

    lpgbtlatch : if (g_PIPELINE_LPGBT) generate
      uplink_data_pipe : process (uplink_clk) is
      begin  -- process uplink_data_pipe
        if uplink_clk'event and uplink_clk = '1' then  -- rising clock edge
          uplink_data_o(I) <= uplink_data;
        end if;
      end process uplink_data_pipe;
    end generate;

    lpgbtnolatch : if (not g_PIPELINE_LPGBT) generate
      uplink_data_o(I) <= uplink_data;
    end generate;

    mgtlatch : if (g_PIPELINE_MGT) generate
      uplink_data_pipe : process (uplink_clk) is
      begin  -- process uplink_data_pipe
        if uplink_clk'event and uplink_clk = '1' then  -- rising clock edge
          mgt_data <= uplink_mgt_word_array_i(I);
        end if;
      end process uplink_data_pipe;
    end generate;

    mgtnolatch : if (not g_PIPELINE_MGT) generate
      mgt_data <= uplink_mgt_word_array_i(I);
    end generate;

    bitsliplatch : if (g_PIPELINE_BITSLIP) generate
      uplink_data_pipe : process (uplink_clk) is
      begin  -- process uplink_data_pipe
        if uplink_clk'event and uplink_clk = '1' then  -- rising clock edge
          uplink_bitslip_o(I) <= bitslip;
        end if;
      end process uplink_data_pipe;
    end generate;

    bitslipnolatch : if (not g_PIPELINE_BITSLIP) generate
      uplink_bitslip_o(I) <= bitslip;
    end generate;

  end generate;

end Behavioral;
