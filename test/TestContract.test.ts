import { ethers } from "hardhat";
import { Contract } from "@ethersproject/contracts"
import { expect } from "chai";

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
}

describe("Tests for test contract", () => {
    let contract: Contract;

    beforeEach(async () => {
        let contractF = await ethers.getContractFactory("TestContract")
        contract = await contractF.deploy()
    })

    describe("Should properly pass values to slot", () => {
        it("Two values, not tight", async () => {
            let values = [mv.u32, mv.u192]
            let bits = [32, 192]
            await contract.setValuesToSlot(values, bits)
            let valuesFS = await contract.getValuesFromSlot(bits)

            expect(valuesFS).to.deep.equal(values)
        })

        it("Four values, very tight", async () => {
            let values = [mv.u8, mv.u160, mv.u56, mv.u32]
            let bits = [8, 160, 56, 32]

            await contract.setValuesToSlot(values, bits)
            let valuesFS = await contract.getValuesFromSlot(bits)

            expect(valuesFS).to.deep.equal(values)
        })
    })

    describe("Should forbid to pass incorrect values", async () => {
        it("Too big value", async () => {
            let values = [mv.u32, mv.u8.add(1)]
            let bits = [32, 8]
            await expect(contract.setValuesToSlot(values, bits)).to.be.revertedWith(
                "too big value"
            )
        })

        it("Too many bits to shrink", async () => {
            let values = [mv.u8, mv.u248, mv.u16]
            let bits = [8, 248, 16]
            await expect(contract.setValuesToSlot(values, bits)).to.be.revertedWith(
                "too many bits"
            )
        })

        it("Too many bits to expand", async () => {
            let values = [mv.u248, mv.u8]
            let bits = [248, 8]
            await contract.setValuesToSlot(values, bits)

            await expect(contract.getValuesFromSlot([248, 16])).to.be.revertedWith(
                "too many bits"
            )
        })

        it("Invalid bits length", async () => {
            let values = [mv.u8, mv.u248, mv.u16]
            let bits = [8, 248]
            await expect(contract.setValuesToSlot(values, bits)).to.be.revertedWith(
                "invalid bits length"
            )
        })

        it("Too few bits", async () => {
            let values = [mv.u248, mv.u8]
            let bits = [248, 8]
            await contract.setValuesToSlot(values, bits)

            await expect(contract.getValuesFromSlot([])).to.be.revertedWith(
                "too few bits"
            )
        })
    })
})