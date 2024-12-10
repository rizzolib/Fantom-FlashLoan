import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// Set the initial parameters for the FlashLoanResearch contract deployment
const FlashLoanResearchModule = buildModule("FlashLoanResearchModule", (m) => {
    // You can define any parameters that your contract constructor might require
    // For example, we don't have a constructor in FlashLoanResearch.sol, so no parameters are needed.

    const flashLoanContract = m.contract("FlashLoanResearch", [], {
        // Add any value or parameters if required in the constructor, though it's empty in this case.
    });

    return { flashLoanContract };
});

export default FlashLoanResearchModule;
