
package icore is

    function gamma(slice : std_logic_vector; previousLayerSums : std_logic_vector; roundConstant : std_logic) return std_logic_vector;

    function pi(slice : std_logic_vector) return std_logic_vector;

    function chi(slice : std_logic_vector) return std_logic_vector;

    function theta(slice : std_logic_vector; previousLayerSums : std_logic_vector) return std_logic_vector;

end package icore;

package body icore is

    function gamma(slice : std_logic_vector; previousLayerSums : std_logic_vector; roundConstant : std_logic) return std_logic_vector is
        variable result : std_logic_vector(24 downto 0);
        variable sums : std_logic_vector(4 downto 0);
        variable pi_r : std_logic_vector(24 downto 0);
        variable chi_r : std_logic_vector(24 downto 0);
        variable iota_r : std_logic_vector(24 downto 0);
        variable theta_r : std_logic_vector(29 downto 0);
    begin
        pi_r := pi(slice);
        chi_r := chi(pi_r);
        iota_r := chi_r(24 downto 1) & (chi_r(0) xor roundConstant);
        theta_r := theta(iota_r, previousLayerSums);
        sums := theta(29 downto 25);
        result := theta(24 downto 0);
        return result & sums;
    end function;

    function pi(slice : std_logic_vector) return std_logic_vector is
        variable result : std_logic_vector(24 downto 0);
    begin
        perm_y : for y in 0 to 4 generate
            perm_x : for x in 0 to 4 generate
                result(y * 5 + x) := slice(x * 5 + (x + 3 * y) mod 5);
            end generate;
        end generate;
        return result;
    end function;

    function chi(slice : std_logic_vector) return std_logic_vector is
        variable result : std_logic_vector(24 downto 0);
    begin
        gen_y : for y in 0 to 4 generate
            gen_x : for x in 0 to 4 generate
                result(y * 5 + x) <= slice(y * 5 + x) xor ((not slice(y * 5 + (x + 1) mod 5)) and slice(y * 5 + (x + 2) mod 5));
            end generate;
        end generate;
    end function;

    function theta(slice : std_logic_vector; std_logic_vector; previousLayerSums : std_logic_vector) return std_logic_vector is
        variable currentLayerSums : std_logic_vector(4 downto 0) := "0000";
        variable combinedSums : std_logic_vector(4 downto 0) := "0000";
    begin
        for x in 0 to 4 loop
            currentLayerSums(x) := currentLayerSums(x) xor  currentLayerSums(x + 5) xor currentLayerSums(x + 10) xor currentLayerSums(x + 15) xor currentLayerSums(x + 20);
        end loop;
        for x in 0 to 4 loop
            combinedSums(x) := previousLayerSums((x + 1) mod 5) xor currentLayerSums((x + 4) mod 5);
        end loop;
        return (slice xor (combinedSums & combinedSums & combinedSums & combinedSums & combinedSums)) & currentLayerSums;
    end function;


end package body icore;
