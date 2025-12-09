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
    expect(ArgumentParser.parse("venril -20")).to eq(["venril", "-20"])
    expect(ArgumentParser.parse("venril 3 days ago")).to eq(["venril", "3 days ago"])
    expect(ArgumentParser.parse("vessel drozlin Fri Jul 26 10:13:01 2024")).to eq(["vessel drozlin", "fri jul 26 10:13:01 2024"])
    expect(ArgumentParser.parse("vessel drozlin|Fri Jul 26 10:13:01 2024")).to eq(["vessel drozlin", "fri jul 26 10:13:01 2024"])
    expect(ArgumentParser.parse("Narandi, 12/7 11:23:12 PM")).to eq(["Narandi", "12/7 11:23:12 PM"])
  end

end
