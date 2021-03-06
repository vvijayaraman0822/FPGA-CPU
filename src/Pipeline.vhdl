library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity Pipeline is
  port(
    clock                     : in     std_logic;
    im_instr                  : in     unsigned(15 downto 0);
    im_addr                   : buffer unsigned(31 downto 1);
    dm_data_rd                : in     unsigned(31 downto 0);
    dm_addr                   : out    unsigned(31 downto 2);
    dm_data_wr                : out    unsigned(31 downto 0);
    dm_we                     : out    std_logic;
    radr1, radr2, radr3, wadr : buffer unsigned(3 downto 0);
    wdata                     : buffer unsigned(31 downto 0);
    rdata1, rdata2, rdata3    : in     unsigned(31 downto 0);
    rf_wr                     : out    std_logic;
    pc_out                    : out    unsigned(31 downto 1);
    branch_val_out            : out    signed(11 downto 1);
    instr_exec_out            : buffer unsigned(15 downto 0)
    );
end Pipeline;

architecture Pipeline of Pipeline is
  -- COMPONENTS --
  component Fetch is
    port(
      clock        : in     std_logic;
      branch_value : in     signed(11 downto 1);
      stall        : in     std_logic;
      im_addr      : buffer unsigned(31 downto 1);
      pc           : buffer unsigned(31 downto 1) := (others => '0')
      );
  end component;
  component Decode is
    port (
      clock               : in     std_logic;
      stall               : buffer std_logic;
      im_instr            : in     unsigned(15 downto 0);
      radr1, radr2, radr3 : out    unsigned(3 downto 0);
      instr               : buffer unsigned(15 downto 0)
      );
  end component;
  component Execute is
    port(
      clock                      : in     std_logic;
      instr                      : in     unsigned(15 downto 0);
      rdata1, rdata2, rdata3     : in     unsigned(31 downto 0);
      pc                         : in     unsigned(31 downto 1);
      defer_load                 : out    std_logic;
      branch_value               : out    signed(11 downto 1);
      Nflag, Zflag, Cflag, Vflag : buffer std_logic;
      wadr                       : out    unsigned(3 downto 0);
      wdata                      : out    unsigned(31 downto 0);
      rf_wr                      : out    std_logic;
      dm_addr                    : out    unsigned(31 downto 2);
      dm_data_wr                 : out    unsigned(31 downto 0);
      dm_we                      : out    std_logic
      );
  end component;
  component Store is
    port(
      defer_load : in  std_logic;
      dm_data_rd : in  unsigned(31 downto 0);
      instr      : in  unsigned(15 downto 0);
      wadr       : out unsigned(3 downto 0);
      wdata      : out unsigned(31 downto 0);
      write_reg  : out std_logic
      );
  end component;
  

-- SIGNALS --
  signal pc                                         : unsigned(31 downto 1);
  signal branch_value                               : signed(11 downto 1) := (others => '0');
  signal stall                                      : std_logic;
  signal defer_load                                 : std_logic;
  signal instr_exec                                 : unsigned(15 downto 0);
  signal Nflag, Zflag, Cflag, Vflag                 : std_logic;
  signal wadr_exec, wadr_store                      : unsigned(3 downto 0);
  signal write_reg_exec, write_reg_store, write_reg : std_logic;
  signal wdata_exec, wdata_store                    : unsigned(31 downto 0);
  signal radr1_exec, radr2_exec, radr3_exec         : unsigned(3 downto 0);
  signal rdata1_exec, rdata2_exec, rdata3_exec      : unsigned(31 downto 0);

begin
  branch_val_out <= branch_value;
  pc_out         <= pc;
  instr_exec_out <= instr_exec;

  -- Instantiations
  Fetch_Pipe : Fetch port map(clock, branch_value, stall, im_addr, pc);

  Decode_Pipe : Decode port map(clock, stall, im_instr, radr1, radr2, radr3, instr_exec);

  Exec_Pipe : Execute port map(clock, instr_exec, rdata1, rdata2, rdata3, pc, defer_load, branch_value, Nflag, Zflag, Cflag, Vflag, wadr_exec, wdata_exec, write_reg_exec, dm_addr, dm_data_wr, dm_we);

  Store_Pipe : Store port map(defer_load, dm_data_rd, instr_exec, wadr_store, wdata_store, write_reg_store);

  -- These might exist at this level...
  with defer_load select wadr <=
    wadr_exec       when '0',
    wadr_store      when '1',
    (others => 'X') when others;

  with defer_load select wdata <=
    wdata_exec      when '0',
    wdata_store     when '1',
    (others => 'X') when others;

  with defer_load select rf_wr <=
    write_reg_exec  when '0',
    write_reg_store when '1',
    'X'             when others;



end Pipeline;
