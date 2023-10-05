import { ethers } from "hardhat";
import { Signer } from "ethers";
import { expect } from "chai";
import { ERC20 } from "../typechain-types";

describe("ERC20", function () {
  let owner: Signer;
  let recipient: Signer;
  let erc20: ERC20;

  beforeEach(async function () {
    [owner, recipient] = await ethers.getSigners();

    const ERC20Factory = await ethers.getContractFactory("ERC20", owner);
    erc20 = (await ERC20Factory.deploy("MyToken", "MTK", 1000)) as ERC20;
    await erc20.waitForDeployment();
  });

  it("should have correct name, symbol, and decimals", async function () {
    expect(await erc20.name()).to.equal("MyToken");
    expect(await erc20.symbol()).to.equal("MTK");
    expect(await erc20.decimals()).to.equal(18);
  });

  it("should have correct initial supply", async function () {
    expect(await erc20.totalSupply()).to.equal(1000);
    expect(await erc20.balanceOf(await owner.getAddress())).to.equal(1000);
  });

  it("should transfer tokens between accounts", async function () {
    await erc20.transfer(await recipient.getAddress(), 100);
    expect(await erc20.balanceOf(await owner.getAddress())).to.equal(900);
    expect(await erc20.balanceOf(await recipient.getAddress())).to.equal(100);
  });

  it("should approve and transfer tokens between accounts", async function () {
    await erc20.approve(await recipient.getAddress(), 100);
    await erc20.transferFrom(
      await owner.getAddress(),
      await recipient.getAddress(),
      100
    );
    expect(await erc20.balanceOf(await owner.getAddress())).to.equal(900);
    expect(await erc20.balanceOf(await recipient.getAddress())).to.equal(100);
  });

  it("should not transfer tokens if spender has insufficient allowance", async function () {
    await erc20.approve(await recipient.getAddress(), 99);
    await expect(
      erc20.transferFrom(
        await owner.getAddress(),
        await recipient.getAddress(),
        100
      )
    ).to.be.revertedWith("not enough tokens!");
    expect(await erc20.balanceOf(await owner.getAddress())).to.equal(1000);
    expect(await erc20.balanceOf(await recipient.getAddress())).to.equal(0);
  });

  it("should mint tokens", async function () {
    await erc20.mint(100, await recipient.getAddress());
    expect(await erc20.totalSupply()).to.equal(1100);
    expect(await erc20.balanceOf(await recipient.getAddress())).to.equal(100);
  });

  it("should burn tokens", async function () {
    await erc20.burn(await owner.getAddress(), 100);
    expect(await erc20.totalSupply()).to.equal(900);
    expect(await erc20.balanceOf(await owner.getAddress())).to.equal(900);
  });
});
