import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, get } = deployments;
  const token = await get("Token");
  const { deployer } = await getNamedAccounts();
  await deploy("DAO", {
    from: deployer,
    args: [token.address],
    log: true,
  });
};

export default func;
