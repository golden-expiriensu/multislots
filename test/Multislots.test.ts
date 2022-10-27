import { expect } from "chai";
import { deployments, ethers } from "hardhat";

import { MultislotExampleContract } from "../typechain";

let mv = {
  u8: ethers.BigNumber.from(255),
  u16: ethers.BigNumber.from(65535),
  u24: ethers.BigNumber.from(16777215),
  u32: ethers.BigNumber.from(4294967295),
  u48: ethers.utils.parseUnits("2.814749766", 14),
  u56: ethers.utils.parseUnits("7.205759403", 16),
  u64: ethers.utils.parseUnits("1.844674406", 19),
  u128: ethers.utils.parseUnits("3.402823668", 38),
  u160: ethers.utils.parseUnits("1.461501636", 48),
  u192: ethers.utils.parseUnits("6.277101734", 57),
  u232: ethers.utils.parseUnits("6.901746346", 69),
  u248: ethers.utils.parseUnits("4.523128485", 74),
};

describe("Tests for test contract", () => {
  let contract: MultislotExampleContract;

  beforeEach(async () => {
    await deployments.fixture(["Multislot", "MultislotExampleContract"]);
    contract = await ethers.getContract<MultislotExampleContract>(
      "MultislotExampleContract"
    );
  });

  describe("Should properly pass values to slot", () => {
    it("Two values, not tight", async () => {
      let values = [mv.u32, mv.u192];
      let bits = [32, 192];
      await contract.setValuesToSlot(values, bits);
      let valuesFS = await contract.getValuesFromSlot(bits);

      expect(valuesFS).to.deep.equal(values);

      await contract.setValueToSlot(mv.u16, 192, 32);
      valuesFS = await contract.getValuesFromSlot(bits);

      expect(valuesFS).to.deep.equal([mv.u16, mv.u192]);

      let singleValue = await contract.getValueFromSlot(192, 32);

      expect(singleValue).to.be.equal(mv.u16);
    });

    it("Four values, very tight", async () => {
      let values = [mv.u8, mv.u160, mv.u56, mv.u32];
      let bits = [8, 160, 56, 32];

      await contract.setValuesToSlot(values, bits);
      let valuesFS = await contract.getValuesFromSlot(bits);

      expect(valuesFS).to.deep.equal(values);

      await contract.setValueToSlot(mv.u64, 56 + 32, 160);
      await contract.setValueToSlot(mv.u16, 0, 32);
      valuesFS = await contract.getValuesFromSlot(bits);

      expect(valuesFS).to.deep.equal([mv.u8, mv.u64, mv.u56, mv.u16]);

      let singleValue = await contract.getValueFromSlot(56 + 32, 160);

      expect(singleValue).to.be.equal(mv.u64);
    });
  });

  describe("Should forbid to pass incorrect values", async () => {
    it("Too big value", async () => {
      let values = [mv.u32, mv.u8.add(1)];
      let bits = [32, 8];
      await expect(contract.setValuesToSlot(values, bits)).to.be.reverted;
      await expect(contract.setValueToSlot(mv.u64, 8, 32)).to.be.reverted;
    });

    it("Too many bits to shrink", async () => {
      let values = [mv.u8, mv.u248, mv.u16];
      let bits = [8, 248, 16];

      await expect(contract.setValuesToSlot(values, bits)).to.be.reverted;
      await expect(contract.setValueToSlot(mv.u8, 255, 2)).to.be.reverted;
    });

    it("Too many bits to expand", async () => {
      let values = [mv.u248, mv.u8];
      let bits = [248, 8];
      await contract.setValuesToSlot(values, bits);

      await expect(contract.getValuesFromSlot([248, 16])).to.be.reverted;
      await expect(contract.setValueToSlot(mv.u8, 255, 2)).to.be.reverted;
    });

    it("Invalid bits length", async () => {
      let values = [mv.u8, mv.u248, mv.u16];
      let bits = [8, 248];
      await expect(contract.setValuesToSlot(values, bits)).to.be.reverted;
    });

    it("Too few bits", async () => {
      let values = [mv.u248, mv.u8];
      let bits = [248, 8];
      await contract.setValuesToSlot(values, bits);

      await expect(contract.getValuesFromSlot([])).to.be.reverted;
    });
  });
});
