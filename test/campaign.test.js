const { assert } = require("chai");

const CampaignFactory = artifacts.require("CampaignFactory");
const Campaign = artifacts.require("Campaign");

describe("Campaign contract", function () {
  let factory;
  let accounts;
  let campaign;
  beforeEach(async () => {
    factory = await CampaignFactory.new(10000);
    accounts = await web3.eth.getAccounts();
    await factory.createCampaign(10000);
    const campaignAddress = await factory.deployedCampaigns(0);
    campaign = await new web3.eth.Contract(Campaign.abi, campaignAddress);
  });

  it("Should deploy contract success", async () => {
    assert.ok(factory.address);
  });

  it("The first account is the manager of created campaign", async () => {
    const manager = await campaign.methods.manager().call();
    assert.equal(manager, accounts[0]);
  });

  it("Can contribute", async () => {
    await campaign.methods.contribute().send({
      value: 40000,
      from: accounts[1],
    });

    assert.ok(await campaign.methods.approvers(accounts[1]).call());
  });

  it("Require minium contribution", async () => {
    try {
      await campaign.methods.contribute().send({
        value: 300,
        from: accounts[1],
      });
      assert.ok(false);
    } catch (e) {
      assert.ok(e);
    }
  });

  it("Only manager can create request", async () => {
    try {
      await campaign.methods
        .createRequest(10000, accounts[1], "Buy something")
        .send({
          from: accounts[1],
        });
      assert.ok(false);
    } catch (e) {
      assert.ok(e);
    }
  });

  it("Approve method work fine", async () => {
    await campaign.methods.contribute().send({
      value: 40000,
      from: accounts[1],
    });
    await campaign.methods
      .createRequest(10000, accounts[1], "Buy something")
      .send({
        from: accounts[0],
      });
    // Call approve
    await campaign.methods.approve(0).send({
      from: accounts[1],
    });
    //Check the request
    const request = await campaign.methods.requests(0).call();
    assert.equal(request.approveVoteCount, 1);
  });
});
