library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Datatypes;

entity sin_table is
    port(
            angle: in unsigned(7 downto 0);
            result:  out datatypes.small_number_t
        );
end entity;

architecture behaviour of sin_table is
begin
    with angle select
        result <= x"0000" when x"00",
                  x"0006" when x"01",
                  x"000c" when x"02",
                  x"0012" when x"03",
                  x"0019" when x"04",
                  x"001f" when x"05",
                  x"0025" when x"06",
                  x"002b" when x"07",
                  x"0032" when x"08",
                  x"0038" when x"09",
                  x"003e" when x"0a",
                  x"0044" when x"0b",
                  x"004a" when x"0c",
                  x"0050" when x"0d",
                  x"0056" when x"0e",
                  x"005c" when x"0f",
                  x"0062" when x"10",
                  x"0068" when x"11",
                  x"006d" when x"12",
                  x"0073" when x"13",
                  x"0079" when x"14",
                  x"007e" when x"15",
                  x"0084" when x"16",
                  x"0089" when x"17",
                  x"008e" when x"18",
                  x"0093" when x"19",
                  x"0099" when x"1a",
                  x"009e" when x"1b",
                  x"00a2" when x"1c",
                  x"00a7" when x"1d",
                  x"00ac" when x"1e",
                  x"00b1" when x"1f",
                  x"00b5" when x"20",
                  x"00b9" when x"21",
                  x"00be" when x"22",
                  x"00c2" when x"23",
                  x"00c6" when x"24",
                  x"00ca" when x"25",
                  x"00ce" when x"26",
                  x"00d1" when x"27",
                  x"00d5" when x"28",
                  x"00d8" when x"29",
                  x"00dc" when x"2a",
                  x"00df" when x"2b",
                  x"00e2" when x"2c",
                  x"00e5" when x"2d",
                  x"00e7" when x"2e",
                  x"00ea" when x"2f",
                  x"00ec" when x"30",
                  x"00ef" when x"31",
                  x"00f1" when x"32",
                  x"00f3" when x"33",
                  x"00f5" when x"34",
                  x"00f7" when x"35",
                  x"00f8" when x"36",
                  x"00fa" when x"37",
                  x"00fb" when x"38",
                  x"00fc" when x"39",
                  x"00fd" when x"3a",
                  x"00fe" when x"3b",
                  x"00fe" when x"3c",
                  x"00ff" when x"3d",
                  x"00ff" when x"3e",
                  x"00ff" when x"3f",
                  x"00ff" when x"40",
                  x"00ff" when x"41",
                  x"00ff" when x"42",
                  x"00ff" when x"43",
                  x"00fe" when x"44",
                  x"00fd" when x"45",
                  x"00fc" when x"46",
                  x"00fb" when x"47",
                  x"00fa" when x"48",
                  x"00f9" when x"49",
                  x"00f7" when x"4a",
                  x"00f6" when x"4b",
                  x"00f4" when x"4c",
                  x"00f2" when x"4d",
                  x"00f0" when x"4e",
                  x"00ee" when x"4f",
                  x"00eb" when x"50",
                  x"00e9" when x"51",
                  x"00e6" when x"52",
                  x"00e3" when x"53",
                  x"00e0" when x"54",
                  x"00dd" when x"55",
                  x"00da" when x"56",
                  x"00d7" when x"57",
                  x"00d3" when x"58",
                  x"00d0" when x"59",
                  x"00cc" when x"5a",
                  x"00c8" when x"5b",
                  x"00c4" when x"5c",
                  x"00c0" when x"5d",
                  x"00bc" when x"5e",
                  x"00b7" when x"5f",
                  x"00b3" when x"60",
                  x"00ae" when x"61",
                  x"00aa" when x"62",
                  x"00a5" when x"63",
                  x"00a0" when x"64",
                  x"009b" when x"65",
                  x"0096" when x"66",
                  x"0091" when x"67",
                  x"008c" when x"68",
                  x"0086" when x"69",
                  x"0081" when x"6a",
                  x"007b" when x"6b",
                  x"0076" when x"6c",
                  x"0070" when x"6d",
                  x"006a" when x"6e",
                  x"0065" when x"6f",
                  x"005f" when x"70",
                  x"0059" when x"71",
                  x"0053" when x"72",
                  x"004d" when x"73",
                  x"0047" when x"74",
                  x"0041" when x"75",
                  x"003b" when x"76",
                  x"0035" when x"77",
                  x"002f" when x"78",
                  x"0028" when x"79",
                  x"0022" when x"7a",
                  x"001c" when x"7b",
                  x"0016" when x"7c",
                  x"000f" when x"7d",
                  x"0009" when x"7e",
                  x"0003" when x"7f",
                  x"8003" when x"80",
                  x"8009" when x"81",
                  x"800f" when x"82",
                  x"8016" when x"83",
                  x"801c" when x"84",
                  x"8022" when x"85",
                  x"8028" when x"86",
                  x"802f" when x"87",
                  x"8035" when x"88",
                  x"803b" when x"89",
                  x"8041" when x"8a",
                  x"8047" when x"8b",
                  x"804d" when x"8c",
                  x"8053" when x"8d",
                  x"8059" when x"8e",
                  x"805f" when x"8f",
                  x"8065" when x"90",
                  x"806a" when x"91",
                  x"8070" when x"92",
                  x"8076" when x"93",
                  x"807b" when x"94",
                  x"8081" when x"95",
                  x"8086" when x"96",
                  x"808c" when x"97",
                  x"8091" when x"98",
                  x"8096" when x"99",
                  x"809b" when x"9a",
                  x"80a0" when x"9b",
                  x"80a5" when x"9c",
                  x"80aa" when x"9d",
                  x"80ae" when x"9e",
                  x"80b3" when x"9f",
                  x"80b7" when x"a0",
                  x"80bc" when x"a1",
                  x"80c0" when x"a2",
                  x"80c4" when x"a3",
                  x"80c8" when x"a4",
                  x"80cc" when x"a5",
                  x"80d0" when x"a6",
                  x"80d3" when x"a7",
                  x"80d7" when x"a8",
                  x"80da" when x"a9",
                  x"80dd" when x"aa",
                  x"80e0" when x"ab",
                  x"80e3" when x"ac",
                  x"80e6" when x"ad",
                  x"80e9" when x"ae",
                  x"80eb" when x"af",
                  x"80ee" when x"b0",
                  x"80f0" when x"b1",
                  x"80f2" when x"b2",
                  x"80f4" when x"b3",
                  x"80f6" when x"b4",
                  x"80f7" when x"b5",
                  x"80f9" when x"b6",
                  x"80fa" when x"b7",
                  x"80fb" when x"b8",
                  x"80fc" when x"b9",
                  x"80fd" when x"ba",
                  x"80fe" when x"bb",
                  x"80ff" when x"bc",
                  x"80ff" when x"bd",
                  x"80ff" when x"be",
                  x"80ff" when x"bf",
                  x"80ff" when x"c0",
                  x"80ff" when x"c1",
                  x"80ff" when x"c2",
                  x"80fe" when x"c3",
                  x"80fe" when x"c4",
                  x"80fd" when x"c5",
                  x"80fc" when x"c6",
                  x"80fb" when x"c7",
                  x"80fa" when x"c8",
                  x"80f8" when x"c9",
                  x"80f7" when x"ca",
                  x"80f5" when x"cb",
                  x"80f3" when x"cc",
                  x"80f1" when x"cd",
                  x"80ef" when x"ce",
                  x"80ec" when x"cf",
                  x"80ea" when x"d0",
                  x"80e7" when x"d1",
                  x"80e5" when x"d2",
                  x"80e2" when x"d3",
                  x"80df" when x"d4",
                  x"80dc" when x"d5",
                  x"80d8" when x"d6",
                  x"80d5" when x"d7",
                  x"80d1" when x"d8",
                  x"80ce" when x"d9",
                  x"80ca" when x"da",
                  x"80c6" when x"db",
                  x"80c2" when x"dc",
                  x"80be" when x"dd",
                  x"80b9" when x"de",
                  x"80b5" when x"df",
                  x"80b1" when x"e0",
                  x"80ac" when x"e1",
                  x"80a7" when x"e2",
                  x"80a2" when x"e3",
                  x"809e" when x"e4",
                  x"8099" when x"e5",
                  x"8093" when x"e6",
                  x"808e" when x"e7",
                  x"8089" when x"e8",
                  x"8084" when x"e9",
                  x"807e" when x"ea",
                  x"8079" when x"eb",
                  x"8073" when x"ec",
                  x"806d" when x"ed",
                  x"8068" when x"ee",
                  x"8062" when x"ef",
                  x"805c" when x"f0",
                  x"8056" when x"f1",
                  x"8050" when x"f2",
                  x"804a" when x"f3",
                  x"8044" when x"f4",
                  x"803e" when x"f5",
                  x"8038" when x"f6",
                  x"8032" when x"f7",
                  x"802b" when x"f8",
                  x"8025" when x"f9",
                  x"801f" when x"fa",
                  x"8019" when x"fb",
                  x"8012" when x"fc",
                  x"800c" when x"fd",
                  x"8006" when x"fe",
        x"0000" when others;
end architecture;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Datatypes;

entity cos_table is
    port(
            angle: in unsigned(7 downto 0);
            result:  out datatypes.small_number_t
        );
end entity;

architecture behaviour of cos_table is
begin
    with angle select
        result <= x"0100" when x"00",
                  x"00ff" when x"01",
                  x"00ff" when x"02",
                  x"00ff" when x"03",
                  x"00fe" when x"04",
                  x"00fe" when x"05",
                  x"00fd" when x"06",
                  x"00fc" when x"07",
                  x"00fb" when x"08",
                  x"00f9" when x"09",
                  x"00f8" when x"0a",
                  x"00f6" when x"0b",
                  x"00f4" when x"0c",
                  x"00f2" when x"0d",
                  x"00f0" when x"0e",
                  x"00ee" when x"0f",
                  x"00ec" when x"10",
                  x"00e9" when x"11",
                  x"00e7" when x"12",
                  x"00e4" when x"13",
                  x"00e1" when x"14",
                  x"00de" when x"15",
                  x"00db" when x"16",
                  x"00d7" when x"17",
                  x"00d4" when x"18",
                  x"00d0" when x"19",
                  x"00cd" when x"1a",
                  x"00c9" when x"1b",
                  x"00c5" when x"1c",
                  x"00c1" when x"1d",
                  x"00bd" when x"1e",
                  x"00b8" when x"1f",
                  x"00b4" when x"20",
                  x"00af" when x"21",
                  x"00ab" when x"22",
                  x"00a6" when x"23",
                  x"00a1" when x"24",
                  x"009c" when x"25",
                  x"0097" when x"26",
                  x"0092" when x"27",
                  x"008d" when x"28",
                  x"0088" when x"29",
                  x"0082" when x"2a",
                  x"007d" when x"2b",
                  x"0077" when x"2c",
                  x"0072" when x"2d",
                  x"006c" when x"2e",
                  x"0066" when x"2f",
                  x"0060" when x"30",
                  x"005b" when x"31",
                  x"0055" when x"32",
                  x"004f" when x"33",
                  x"0049" when x"34",
                  x"0043" when x"35",
                  x"003c" when x"36",
                  x"0036" when x"37",
                  x"0030" when x"38",
                  x"002a" when x"39",
                  x"0024" when x"3a",
                  x"001d" when x"3b",
                  x"0017" when x"3c",
                  x"0011" when x"3d",
                  x"000b" when x"3e",
                  x"0004" when x"3f",
                  x"8001" when x"40",
                  x"8007" when x"41",
                  x"800e" when x"42",
                  x"8014" when x"43",
                  x"801a" when x"44",
                  x"8021" when x"45",
                  x"8027" when x"46",
                  x"802d" when x"47",
                  x"8033" when x"48",
                  x"8039" when x"49",
                  x"803f" when x"4a",
                  x"8046" when x"4b",
                  x"804c" when x"4c",
                  x"8052" when x"4d",
                  x"8058" when x"4e",
                  x"805d" when x"4f",
                  x"8063" when x"50",
                  x"8069" when x"51",
                  x"806f" when x"52",
                  x"8074" when x"53",
                  x"807a" when x"54",
                  x"807f" when x"55",
                  x"8085" when x"56",
                  x"808a" when x"57",
                  x"8090" when x"58",
                  x"8095" when x"59",
                  x"809a" when x"5a",
                  x"809f" when x"5b",
                  x"80a4" when x"5c",
                  x"80a8" when x"5d",
                  x"80ad" when x"5e",
                  x"80b2" when x"5f",
                  x"80b6" when x"60",
                  x"80bb" when x"61",
                  x"80bf" when x"62",
                  x"80c3" when x"63",
                  x"80c7" when x"64",
                  x"80cb" when x"65",
                  x"80cf" when x"66",
                  x"80d2" when x"67",
                  x"80d6" when x"68",
                  x"80d9" when x"69",
                  x"80dc" when x"6a",
                  x"80e0" when x"6b",
                  x"80e3" when x"6c",
                  x"80e5" when x"6d",
                  x"80e8" when x"6e",
                  x"80eb" when x"6f",
                  x"80ed" when x"70",
                  x"80ef" when x"71",
                  x"80f1" when x"72",
                  x"80f3" when x"73",
                  x"80f5" when x"74",
                  x"80f7" when x"75",
                  x"80f9" when x"76",
                  x"80fa" when x"77",
                  x"80fb" when x"78",
                  x"80fc" when x"79",
                  x"80fd" when x"7a",
                  x"80fe" when x"7b",
                  x"80ff" when x"7c",
                  x"80ff" when x"7d",
                  x"80ff" when x"7e",
                  x"80ff" when x"7f",
                  x"80ff" when x"80",
                  x"80ff" when x"81",
                  x"80ff" when x"82",
                  x"80ff" when x"83",
                  x"80fe" when x"84",
                  x"80fd" when x"85",
                  x"80fc" when x"86",
                  x"80fb" when x"87",
                  x"80fa" when x"88",
                  x"80f9" when x"89",
                  x"80f7" when x"8a",
                  x"80f5" when x"8b",
                  x"80f3" when x"8c",
                  x"80f1" when x"8d",
                  x"80ef" when x"8e",
                  x"80ed" when x"8f",
                  x"80eb" when x"90",
                  x"80e8" when x"91",
                  x"80e5" when x"92",
                  x"80e3" when x"93",
                  x"80e0" when x"94",
                  x"80dc" when x"95",
                  x"80d9" when x"96",
                  x"80d6" when x"97",
                  x"80d2" when x"98",
                  x"80cf" when x"99",
                  x"80cb" when x"9a",
                  x"80c7" when x"9b",
                  x"80c3" when x"9c",
                  x"80bf" when x"9d",
                  x"80bb" when x"9e",
                  x"80b6" when x"9f",
                  x"80b2" when x"a0",
                  x"80ad" when x"a1",
                  x"80a8" when x"a2",
                  x"80a4" when x"a3",
                  x"809f" when x"a4",
                  x"809a" when x"a5",
                  x"8095" when x"a6",
                  x"8090" when x"a7",
                  x"808a" when x"a8",
                  x"8085" when x"a9",
                  x"8080" when x"aa",
                  x"807a" when x"ab",
                  x"8074" when x"ac",
                  x"806f" when x"ad",
                  x"8069" when x"ae",
                  x"8063" when x"af",
                  x"805d" when x"b0",
                  x"8058" when x"b1",
                  x"8052" when x"b2",
                  x"804c" when x"b3",
                  x"8046" when x"b4",
                  x"803f" when x"b5",
                  x"8039" when x"b6",
                  x"8033" when x"b7",
                  x"802d" when x"b8",
                  x"8027" when x"b9",
                  x"8021" when x"ba",
                  x"801a" when x"bb",
                  x"8014" when x"bc",
                  x"800e" when x"bd",
                  x"8007" when x"be",
                  x"8001" when x"bf",
                  x"0004" when x"c0",
                  x"000b" when x"c1",
                  x"0011" when x"c2",
                  x"0017" when x"c3",
                  x"001d" when x"c4",
                  x"0024" when x"c5",
                  x"002a" when x"c6",
                  x"0030" when x"c7",
                  x"0036" when x"c8",
                  x"003c" when x"c9",
                  x"0043" when x"ca",
                  x"0049" when x"cb",
                  x"004f" when x"cc",
                  x"0055" when x"cd",
                  x"005b" when x"ce",
                  x"0060" when x"cf",
                  x"0066" when x"d0",
                  x"006c" when x"d1",
                  x"0072" when x"d2",
                  x"0077" when x"d3",
                  x"007d" when x"d4",
                  x"0082" when x"d5",
                  x"0088" when x"d6",
                  x"008d" when x"d7",
                  x"0092" when x"d8",
                  x"0097" when x"d9",
                  x"009c" when x"da",
                  x"00a1" when x"db",
                  x"00a6" when x"dc",
                  x"00ab" when x"dd",
                  x"00af" when x"de",
                  x"00b4" when x"df",
                  x"00b8" when x"e0",
                  x"00bd" when x"e1",
                  x"00c1" when x"e2",
                  x"00c5" when x"e3",
                  x"00c9" when x"e4",
                  x"00cd" when x"e5",
                  x"00d0" when x"e6",
                  x"00d4" when x"e7",
                  x"00d7" when x"e8",
                  x"00db" when x"e9",
                  x"00de" when x"ea",
                  x"00e1" when x"eb",
                  x"00e4" when x"ec",
                  x"00e7" when x"ed",
                  x"00e9" when x"ee",
                  x"00ec" when x"ef",
                  x"00ee" when x"f0",
                  x"00f0" when x"f1",
                  x"00f2" when x"f2",
                  x"00f4" when x"f3",
                  x"00f6" when x"f4",
                  x"00f8" when x"f5",
                  x"00f9" when x"f6",
                  x"00fb" when x"f7",
                  x"00fc" when x"f8",
                  x"00fd" when x"f9",
                  x"00fe" when x"fa",
                  x"00fe" when x"fb",
                  x"00ff" when x"fc",
                  x"00ff" when x"fd",
                  x"00ff" when x"fe",
        x"8100" when others;
end architecture;
