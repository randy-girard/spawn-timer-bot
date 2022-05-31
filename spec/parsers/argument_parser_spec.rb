require "spec_helper"

describe ArgumentParser do

  it "should parse args" do
    expect(ArgumentParser.parse("bob, 10 am")).to    eq(["bob", "10 am"])
    expect(ArgumentParser.parse("bob 10 am")).to     eq(["bob", "10 am"])
    expect(ArgumentParser.parse("bob may 13th")).to  eq(["bob", "may 13th"])
    expect(ArgumentParser.parse("bob, may 13th")).to eq(["bob", "may 13th"])
    expect(ArgumentParser.parse("bob| may 13th")).to eq(["bob", "may 13th"])
    expect(ArgumentParser.parse("bloodgill marauder")).to eq(["bloodgill marauder", nil])
    expect(ArgumentParser.parse("something May 30, 2022 12:00 AM")).to eq(["something", "may 30, 2022 12:00 am"])
    expect(ArgumentParser.parse("something May 30 2022 12:00 AM")).to eq(["something", "may 30 2022 12:00 am"])
  end

end
