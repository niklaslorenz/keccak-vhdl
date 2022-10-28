
library IEEE;
use IEEE.std_logic_1164.all;

package sha3_types is
    
    type sha3_type is (sha224, sha256, sha384, sha512);
    type sha3_mode is (append, init);
    
    function getHashSize(t : sha3_type) return natural;
    
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
    
end package body sha3_types;
