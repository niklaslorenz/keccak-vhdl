library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.test_types.all;
use work.test_util.all;

package test_data is

    constant test_block_a : block_t := to_slice_aligned_block((
        x"fc09dc55ea64707e",
        x"31727c62ccc930c1",
        x"0a7346af6cfa6a2c",
        x"45ecb35b9a49bb05",
        x"18a3f9bc1e4a8c4f",
        x"d97c8d02ec0d7547",
        x"24a535c923dd9dc6",
        x"1998bea97361cb1c",
        x"b6e88d08da3369d8",
        x"19ada08eb2f776f4",
        x"236977ac8a2ba5a8",
        x"5d34c3d65d3b71eb",
        x"c19981b38c60aaa2"
    ));

    constant test_block_b : block_t := to_slice_aligned_block((
        x"eaf0f786e5137167",
        x"70d74988a41256f8",
        x"55e840af75037ee3",
        x"6783b205e23b2e3a",
        x"c6c2f9c85e811d69",
        x"a1e37c5bafd4707f",
        x"2890ee7ca76465e7",
        x"f5765490804988fd",
        x"593125cbbef4e4bb",
        x"99352f5787e98d72",
        x"393b1506914ce931",
        x"015cabd4ed270582",
        x"fc09dc55ea64707e"
    ));

    constant theta_block_a : block_t := to_slice_aligned_block((
        x"7e0e2657aa3b903f",
        x"830c9333463e4e8c",
        x"34565f36f562ce50",
        x"a0dd9259dacd37a2",
        x"f23152783d9fc518",
        x"e2aeb03740b13e9b",
        x"63b9bbc493aca524",
        x"38d386ce957d1998",
        x"1b96cc5b10b1176d",
        x"2f6eef4d7105b598",
        x"15a5d45135ee96c4",
        x"d78edcba6bc32cba",
        x"45550631cd819983"
    ));
    constant theta_block_b : block_t := to_slice_aligned_block((
        x"e68ec8a761ef0f57",
        x"1f6a48251192eb0e",
        x"c77ec0aef50217aa",
        x"5c74dc47a04dc1e6",
        x"96b8817a139f4363",
        x"fe0e2bf5da3ec785",
        x"e7a626e53e770914",
        x"bf119201092a6eaf",
        x"dd272f7dd3a48c9a",
        x"4eb197e1eaf4ac99",
        x"8c97328960a8dc9c",
        x"41a0e4b72bd53a80",
        x"7e0e2657aa3b903f"
    ));

end package test_data;