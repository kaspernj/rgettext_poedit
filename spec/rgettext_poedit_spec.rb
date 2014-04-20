require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RgettextPoedit" do
  let(:rgp){ RgettextPoedit.new({}) }
  
  it "can parse various forms" do
    lines = [
      "  _('Test 1 %{name}', :name)  \n",
      "  _ 'Test 2 %{name}', :name  \n",
      "  _'Test 3 %{name}', :name  \n",
      '  _("Test 4 %{name}", :name)  ',
      '  _ "Test 5 %{name}", :name  ',
      '  _"Test 6 %{name}", :name  ',
      '  _"Test 7"  ',
      "  _'Test 8'  \n",
      "  str = \"Hejsa \#{_('Test 9')} ",
      "#. Dette er en test",
      '<%=_"Test 10"%>'
    ]
    
    lines.each do |line|
      rgp.__send__(:parse_content, nil, nil, line)
    end
    
    strs = rgp.instance_variable_get(:@translations)
    
    strs.keys.should include "Test 1 %{name}"
    strs.keys.should include "Test 2 %{name}"
    strs.keys.should include "Test 3 %{name}"
    strs.keys.should include "Test 4 %{name}"
    strs.keys.should include "Test 5 %{name}"
    strs.keys.should include "Test 6 %{name}"
    strs.keys.should include "Test 7"
    strs.keys.should include "Test 8"
    strs.keys.should include "Test 9"
    strs.keys.should include "Test 10"
    strs["Test 10"][:comments].should include "Dette er en test"
  end
end
