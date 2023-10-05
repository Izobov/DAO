import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();
  const dao = await get("DAO");
  await deploy("Demo", {
    from: deployer,
    log: true,
  });
  const demo = await hre.ethers.getContractAt("Demo", deployer);
  const tx = await demo.transferOwnership(dao.address);
  await tx.wait();
};

export default func;
