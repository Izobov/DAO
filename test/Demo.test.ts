// SPDX-License-Identifier: MIT
import { Demo } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

describe("Demo", function () {
  let demo: Demo;
  let owner: HardhatEthersSigner;
  let addr1: HardhatEthersSigner;
  let addr2: HardhatEthersSigner;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const Demo = await ethers.getContractFactory("Demo");
    demo = await Demo.deploy();
    await demo.waitForDeployment();
  });

  it("should set the owner to the deployer", async function () {
    expect(await demo.owner()).to.equal(owner.address);
  });

  it("should allow the owner to transfer ownership", async function () {
    await demo.transferOwnership(addr1.address);
    expect(await demo.owner()).to.equal(addr1.address);
  });

  it("should not allow non-owners to transfer ownership", async function () {
    await expect(demo.connect(addr1).transferOwnership(addr2.address)).to.be
      .reverted;
  });

  it("should set the message and update the sender's balance when paid", async function () {
    const message = "Hello, world!";
    const value = ethers.parseEther("1");

    await demo.pay(message, { value: value });

    expect(await demo.message()).to.equal(message);
    expect(await demo.balances(owner.address)).to.equal(value);
  });
});
