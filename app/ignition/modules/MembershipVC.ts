import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MembershipVCModule = buildModule("MembershipVCModule", (m) => {
  const membershipVC = m.contract("MembershipVC");

  return { membershipVC };
});

export default MembershipVCModule;