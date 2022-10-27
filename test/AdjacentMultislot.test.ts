import { expect } from "chai";
import { deployments, ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import { AdjacentMultislotsExampleContract } from "../typechain";

describe("AdjacentMultislotsExampleContract tests", () => {
  let contract: AdjacentMultislotsExampleContract;

  let exampleStruct: {
    a: Address;
    b: Address;
    c: Address;
    d: Address;
    e: Address;
    f: Address;
    g: Address;
    h: Address;
  };

  beforeEach(async () => {
    await deployments.fixture("AdjacentMultislotsExampleContract");

    contract = await ethers.getContract<AdjacentMultislotsExampleContract>(
      "AdjacentMultislotsExampleContract"
    );

    const [a, b, c, d, e, f, g, h] = (await ethers.getSigners()).map(
      (e) => e.address
    );
    exampleStruct = { a, b, c, d, e, f, g, h };
  });

  it("Gas price logging", async () => {
    const tx1 = await contract.setUnoptimized(exampleStruct);
    const gasSpentUnoptimized = (await tx1.wait()).events!.find(
      (e) => e.event === "GasLog"
    )!.args!.gasSpent;

    const tx2 = await contract.setOptimized(exampleStruct);
    const gasSpentOptimized = (await tx2.wait()).events!.find(
      (e) => e.event === "GasLog"
    )!.args!.gasSpent;

    console.log("Default solidity structure:", gasSpentUnoptimized.toString());
    console.log(
      "Optimized adjacent-multislots structure:",
      gasSpentOptimized.toString()
    );
  });

  it("Should properly write values to the store", async () => {
    await contract.setOptimized(exampleStruct);
    await contract.setUnoptimized(exampleStruct);

    expect(await contract.getOptimized()).eql(await contract.getUnoptimized());
  });
});
