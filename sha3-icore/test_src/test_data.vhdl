library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;
use work.test_types.all;
use work.test_util.all;

package test_data is

    constant test_block : full_lane_aligned_block_t := block_from_hex_array(x"eaf0f786e513716770d74988a41256f855e840af75037ee36783b205e23b2e3ac6c2f9c85e811d69a1e37c5bafd4707f2890ee7ca76465e7f5765490804988fd593125cbbef4e4bb99352f5787e98d72393b1506914ce931015cabd4ed270582fc09dc55ea64707e31727c62ccc930c10a7346af6cfa6a2c45ecb35b9a49bb0518a3f9bc1e4a8c4fd97c8d02ec0d754724a535c923dd9dc61998bea97361cb1cb6e88d08da3369d819ada08eb2f776f4236977ac8a2ba5a85d34c3d65d3b71ebc19981b38c60aaa2");
    constant test_block_0 : block_t := lower_block(test_block);
    constant test_block_1 : block_t := upper_block(test_block);

    constant theta_result : full_lane_aligned_block_t := block_from_hex_array(x"a9eefcc032d88a52d40c3a5deaf8759e9393f7381e3af0c2a70278a75ab818acab4c622718b00b47e2fd771d781f8b4a8c4b9da9e98e4681330de307eb7006dc99b0ef690677d22df4bbb4b8c1d89b5c7a251e4046871204a587d801a3cd26e43a726bc2815dfe5ff1f3b6c0744a065767fddd402acb7c0206f2b81d4d824030bc788a6950a0af291f073a958734fb66e424ff6b9b5eab50741625463550dd32f5f6864e0df892edbd76d35bfc1d5592e512c03be1122b899db50974e5b8477dac171a5cca51bc8c");
    constant theta_result_0 : block_t := lower_block(theta_result);
    constant theta_result_1 : block_t := upper_block(theta_result);

    constant gamma_result : full_lane_aligned_block_t := block_from_hex_array(x"d2b97167b900b11cbef93213c09649c10777eb698a4ece8b68cf034e4d38f270853b35256a886f39d47f305bca29439d54fa887c9517e4ce693d1b0593cb63732df46e9a26b2395d11c08bc1371cf2b8eb32bebab1fe8e0c9f7326a1e19155ce1f92443bc6360d3089b709aabb0e7f47da7ea7893dbedacabc10188c327060837690dd27737fa19c567568e456e975dee48442b85d9e45eb94f4a2a1b7e29d7d636c88bc89f5f3420e3db6a1e07baa5466a7a3b8d16765ccd45dc742730ee23a9edb0f2ca5e7613a");
    constant gamma_result_0 : block_t := lower_block(gamma_result);
    constant gamma_result_1 : block_t := upper_block(gamma_result);

end package test_data;