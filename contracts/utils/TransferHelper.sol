// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../dependencies/IWBNB.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library TransferHelper {

    using Address for address payable;
    using SafeERC20 for IERC20;

    uint constant public BNB_CHAIN = 56;
    address constant public BNB_CHAIN_WRAPPED = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    uint constant public BNB_CHAIN_TESTNET = 97;
    address constant public BNB_CHAIN_TESTNET_WRAPPED = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    function transfer(address token, address to, uint256 amount) internal {
        if (token != nativeWrapped() || _isContract(to)) {
            IERC20(token).safeTransfer(to, amount);
        } else {
            IWBNB(token).withdraw(amount);
            payable(to).sendValue(amount);
        }
    }

    function transferFrom(address token, address from, uint256 amount) internal {
        if (token != nativeWrapped()) {
            IERC20(token).safeTransferFrom(from, address(this), amount);
        } else {
            require(msg.value >= amount, "insufficient transfers");
            IWBNB(token).deposit{value: amount}();
        }
    }

    function nativeWrapped() internal view returns (address) {
        uint256 chainId = block.chainid;
        if (chainId == BNB_CHAIN) {
            return BNB_CHAIN_WRAPPED;
        } else if (chainId == BNB_CHAIN_TESTNET) {
            return BNB_CHAIN_TESTNET_WRAPPED;
        } else {
            revert("unsupported chain id");
        }
    }

    function _isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
