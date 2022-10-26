import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("TestContract", {
    from: deployer,
    args: [],
    log: true,
    libraries: {
      Multislots: (await hre.ethers.getContract("Multislots")).address,
    },
  });
};

export default func;
func.tags = ["mock", "TestContract"];
