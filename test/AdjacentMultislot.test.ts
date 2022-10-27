import { deployments, ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import { AdjacentMultislotsExampleContract } from "../typechain";

describe("AdjacentMultislotsExampleContract tests", () => {
  let contract: AdjacentMultislotsExampleContract;

  let exampleStruct: {
    a: Address;
    b: Address;
    c: Address;
  };

  beforeEach(async () => {
    await deployments.fixture("AdjacentMultislotsExampleContract");

    contract = await ethers.getContract<AdjacentMultislotsExampleContract>(
      "AdjacentMultislotsExampleContract"
    );

    const [a, b, c] = (await ethers.getSigners()).map((e) => e.address);
    exampleStruct = { a, b, c };
  });

  it("test", async () => {
    const tx1 = await contract.setUnoptimized(exampleStruct);
    const gasSpentUnoptimized = (await tx1.wait()).events!.find(
      (e) => e.event === "GasLog"
    )!.args!.gasSpent;

    const tx2 = await contract.setOptimized(exampleStruct);
    const gasSpentOptimized = (await tx2.wait()).events!.find(
      (e) => e.event === "GasLog"
    )!.args!.gasSpent;

    console.log({
      gasSpentUnoptimized: gasSpentUnoptimized.toString(),
      gasSpentOptimized: gasSpentOptimized.toString(),
    });

    console.log(await contract.unoptimized());
    console.log(await contract.getOptimized());
  });
});
