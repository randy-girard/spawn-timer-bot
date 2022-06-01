require "spec_helper"

describe ArgumentParser do

  it "should parse args" do
    expect(ArgumentParser.parse("vessel June 1, 2022 4:09 AM")).to eq(["vessel", "june 1, 2022 4:09 am"])    
    expect(ArgumentParser.parse("nortlav the scalekeeper|2022-06-01 00:23:11 -0400")).to eq(["nortlav the scalekeeper", "2022-06-01 00:23:11 -0400"])
    expect(ArgumentParser.parse("bob, 10 am")).to    eq(["bob", "10 am"])
    expect(ArgumentParser.parse("bob 10 am")).to     eq(["bob", "10 am"])
    expect(ArgumentParser.parse("bob may 13th")).to  eq(["bob", "may 13th"])
    expect(ArgumentParser.parse("bob, may 13th")).to eq(["bob", "may 13th"])
    expect(ArgumentParser.parse("bob| may 13th")).to eq(["bob", "may 13th"])
    expect(ArgumentParser.parse("bloodgill marauder")).to eq(["bloodgill marauder", nil])
    expect(ArgumentParser.parse("something May 30, 2022 12:00 AM")).to eq(["something", "may 30, 2022 12:00 am"])
    expect(ArgumentParser.parse("something May 30 2022 12:00 AM")).to eq(["something", "may 30 2022 12:00 am"])
    expect(ArgumentParser.parse("venril May 30, 2022 5:39 PM")).to eq(["venril", "may 30, 2022 5:39 pm"])
  end

end
