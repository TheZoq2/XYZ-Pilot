library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Decoder is
    end Decoder;

architecture Behavioral of Decoder_tb is

      component lab
                Port (
                        clk : in STD_LOGIC;
                            Row : in STD_LOGIC_VECTOR (3 downto 0);
                                    Col : out STD_LOGIC_VECTOR (3 downto 0)
                                               );
                                                 end component;

                                                   -- Testsignaler
                                                   signal clk : STD_LOGIC;
                                                     signal Row : STD_LOGIC_VECTOR(3 downto 0);
                                                       signal Col : STD_LOGIC_VECTOR(3 downto 0);

begin

      uut: lab PORT MAP(
          clk => clk,
              Row => Row,
                  Col => Col);

                    -- Klocksignal 100MHz
                    clk <= not clk after 5 ns;

                      testcode
                        testcode

                        end;
                    )
                )
