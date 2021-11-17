const { expect } = require("chai");

const Campaign = artifacts.require("Campaign");
let campaign;

describe("Campaign", function () {
  beforeEach(async () => {
    campaign = await Campaign.new(10000);
  })


  it("Should deploy contract success", async function () {
    assert.ok(campaign.address);
  });
});
