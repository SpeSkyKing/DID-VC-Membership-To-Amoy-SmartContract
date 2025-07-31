import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("DIDRegistry", function () {
  async function deployDIDRegistryFixture() {
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const DIDRegistry = await hre.ethers.getContractFactory("DIDRegistry");
    const didRegistry = await DIDRegistry.deploy();

    return { didRegistry, owner, otherAccount };
  }

  describe("DID Creation", function () {
    it("Should create a new DID", async function () {
      const { didRegistry, owner } = await loadFixture(deployDIDRegistryFixture);
      const did = "did:example:123";
      const publicKey = "0x1234567890abcdef";

      await didRegistry.createDID(did, publicKey);
      const didDoc = await didRegistry.getDIDDocument(did);
      
      expect(didDoc.owner).to.equal(owner.address);
      expect(didDoc.publicKey).to.equal(publicKey);
      expect(didDoc.revoked).to.be.false;
    });

    it("Should fail if DID already exists", async function () {
      const { didRegistry } = await loadFixture(deployDIDRegistryFixture);
      const did = "did:example:123";
      const publicKey = "0x1234567890abcdef";

      await didRegistry.createDID(did, publicKey);
      await expect(didRegistry.createDID(did, publicKey)).to.be.revertedWith(
        "DID already exists"
      );
    });
  });

  describe("DID Management", function () {
    it("Should update public key by owner", async function () {
      const { didRegistry, owner } = await loadFixture(deployDIDRegistryFixture);
      const did = "did:example:123";
      const publicKey = "0x1234567890abcdef";
      const newPublicKey = "0xfedcba0987654321";

      await didRegistry.createDID(did, publicKey);
      await didRegistry.updatePublicKey(did, newPublicKey);
      
      const didDoc = await didRegistry.getDIDDocument(did);
      expect(didDoc.publicKey).to.equal(newPublicKey);
    });

    it("Should fail to update if not owner", async function () {
      const { didRegistry, otherAccount } = await loadFixture(deployDIDRegistryFixture);
      const did = "did:example:123";
      const publicKey = "0x1234567890abcdef";
      const newPublicKey = "0xfedcba0987654321";

      await didRegistry.createDID(did, publicKey);
      await expect(
        didRegistry.connect(otherAccount).updatePublicKey(did, newPublicKey)
      ).to.be.revertedWith("Not DID owner");
    });

    it("Should revoke DID", async function () {
      const { didRegistry } = await loadFixture(deployDIDRegistryFixture);
      const did = "did:example:123";
      const publicKey = "0x1234567890abcdef";

      await didRegistry.createDID(did, publicKey);
      await didRegistry.revokeDID(did);
      
      const didDoc = await didRegistry.getDIDDocument(did);
      expect(didDoc.revoked).to.be.true;
    });
  });
});
