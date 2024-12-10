// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// Interface for the flash loan receiver (the contract calling the flash loan)
interface IFlashBorrower {
    function onFlashLoan(
        address sender,
        IERC20 token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external;
}

// Interface for the Cauldron protocol
interface Cauldron {
    function addCollateral(address to, bool skim, uint256 share) external;

    function borrow(
        address to,
        uint256 amount
    ) external returns (uint256 part, uint256 share);

    function repay(
        address to,
        bool skim,
        uint256 part
    ) external returns (uint256 amount);

    function removeCollateral(address to, uint256 share) external;
}

// Interface for the BentoBox protocol
interface Bentobox {
    function registerProtocol() external;

    function deposit(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);

    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);
}

// Interface for the LendingPool to perform flash loan
interface ILendingPool {
    function flashLoan(
        IFlashBorrower borrower,
        address receiver,
        IERC20 token,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract FlashLoanResearch is ReentrancyGuard {
    // Contract constants (addresses)
    address public constant MIM = 0x82f0B8B456c1A451378467398982d4834b6829c1;
    address public constant WFTM = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;
    address public constant LENDING_POOL =
        0x74A0BcA2eeEdf8883cb91E37e9ff49430f20a616;
    address public constant BENTO_BOX =
        0xF5BCE5077908a1b7370B9ae04AdC565EBd643966;
    address public constant CAULDRON_FTM =
        0xed745b045f9495B8bfC7b58eeA8E0d0597884e12;

    // Events
    event ApprovalSuccessful(
        address indexed spender,
        string tokenSymbol,
        uint256 amount
    );
    event FlashLoanInitiated(address indexed borrower, uint256 amount);

    // Constructor
    constructor() {
        // Empty constructor
    }

    // Helper function to approve token spending for external contracts (LendingPool, BentoBox, Cauldron)
    function approveToken(address token, address spender) internal {
        uint256 allowance = IERC20(token).allowance(address(this), spender);
        if (allowance < type(uint256).max) {
            require(
                IERC20(token).approve(spender, type(uint256).max),
                "Token approval failed"
            );
            emit ApprovalSuccessful(spender, "MIM", type(uint256).max);
        }
    }

    // Function to approve tokens (MIM, WFTM) for necessary external contracts
    function approveTokens() external {
        // Approve MIM for LendingPool
        approveToken(MIM, LENDING_POOL);

        // Approve MIM for BentoBox
        approveToken(MIM, BENTO_BOX);

        // Approve WFTM for BentoBox (in case you need to approve WFTM as collateral)
        approveToken(WFTM, BENTO_BOX);

        // Approve WFTM for Cauldron (in case you need to use WFTM as collateral)
        approveToken(WFTM, CAULDRON_FTM);
    }

    // Flash loan callback function
    function onFlashLoan(
        address sender,
        IERC20 token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external {
        require(msg.sender == LENDING_POOL, "Unauthorized lender");
        require(sender == address(this), "Unauthorized sender");

        // Ensure sufficient tokens to repay flash loan with fee
        uint256 totalDebt = amount + fee;
        require(
            token.balanceOf(address(this)) >= totalDebt,
            "Insufficient funds to repay flash loan"
        );

        // 1. Deposit MIM into BentoBox to use as collateral
        Bentobox(BENTO_BOX).registerProtocol();
        (uint256 amountOut, uint256 shareOut) = Bentobox(BENTO_BOX).deposit(
            IERC20(MIM),
            address(this),
            address(this),
            amount,
            0
        );

        // 2. Add collateral to Cauldron
        Cauldron(CAULDRON_FTM).addCollateral(address(this), false, shareOut);

        // 3. Borrow WFTM from Cauldron (e.g., 70% of the deposited MIM value)
        uint256 borrowAmount = (amountOut * 70) / 100; // 70% Loan-to-Value (LTV)
        (uint256 borrowPart, uint256 borrowShare) = Cauldron(CAULDRON_FTM)
            .borrow(address(this), borrowAmount);

        // 4. Repay WFTM borrowed from Cauldron
        Cauldron(CAULDRON_FTM).repay(address(this), false, borrowPart);

        // 5. Remove collateral from Cauldron
        Cauldron(CAULDRON_FTM).removeCollateral(address(this), shareOut);

        // 6. Withdraw MIM from BentoBox
        Bentobox(BENTO_BOX).withdraw(
            IERC20(MIM),
            address(this),
            address(this),
            amount,
            0
        );

        // 7. Repay the flash loan (MIM + fee)
        require(IERC20(MIM).approve(msg.sender, totalDebt), "Approval failed");
        require(
            IERC20(MIM).transfer(msg.sender, totalDebt),
            "Repayment failed"
        );
    }

    // Function to initiate the flash loan from the LendingPool
    function initiateFlashLoan(uint256 amount) external nonReentrant {
        emit FlashLoanInitiated(address(this), amount);

        // Perform flash loan
        ILendingPool(LENDING_POOL).flashLoan(
            IFlashBorrower(address(this)),
            address(this),
            IERC20(MIM),
            amount,
            bytes("") // Empty data for simplicity
        );
    }

    // Emergency withdrawal function in case of failure
    function emergencyWithdraw(address token, uint256 amount) external {
        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
    }

    // Fallback function in case there are any leftover funds
    receive() external payable {}
}
