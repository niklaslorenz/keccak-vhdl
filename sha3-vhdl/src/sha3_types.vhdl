
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package sha3_types is
    
    type sha3_type is (sha224, sha256, sha384, sha512);
    type sha3_mode is (append, init);
    
    function getHashSize(t : sha3_type) return natural;

    function sha_pad(str : string; t : sha3_type) return std_logic_vector;
    
end package sha3_types;

package body sha3_types is
    
    function getHashSize(t : sha3_type) return natural is
        variable result : natural;
    begin
        case t is
        when sha224 => return 224;
        when sha256 => return 256;
        when sha384 => return 384;
        when sha512 => return 512;
        end case;
    end function getHashSize;

    function sha_pad(str : string; t : sha3_type) return std_logic_vector is
        variable block_size : natural;
        variable pad_begin : natural;
        variable blck : std_logic_vector(1599 - 2 * getHashSize(t) downto 0) := (others => '0');
        variable c : std_logic_vector(7 downto 0);
    begin
        block_size := 1600 - 2 * getHashSize(t);
        for i in 0 to str'length - 1 loop
            c := std_logic_vector(to_unsigned(character'pos(str(i + 1)), 8));
            blck(i * 8 + 7 downto i * 8) := c;
        end loop;
        pad_begin := str'length * 8;
        blck(pad_begin + 2 downto pad_begin) := "110";
        blck(block_size - 1) := '1';
        return blck;
    end function sha_pad;
    
end package body sha3_types;
