require "spec_helper"

describe ArgumentParser do

  it "should parse args" do
    expect(ArgumentParser.parse("bob, 10 am")).to    eq(["bob", "10 am"])
    expect(ArgumentParser.parse("bob 10 am")).to     eq(["bob", "10 am"])
    expect(ArgumentParser.parse("bob may 13th")).to  eq(["bob", "may 13th"])
    expect(ArgumentParser.parse("bob, may 13th")).to eq(["bob", "may 13th"])
    expect(ArgumentParser.parse("bob| may 13th")).to eq(["bob", "may 13th"])
    expect(ArgumentParser.parse("bloodgill marauder")).to eq(["bloodgill marauder", nil])
  end

end
