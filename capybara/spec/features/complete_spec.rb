require 'rotp'

describe "Full lifecyle", type: :feature do
  before do
    Capybara.app_host = 'https://admin.staging.forms.service.gov.uk/'
  end

  it "logs in" do
    visit '/'
    visit 'https://admin.staging.forms.service.gov.uk/'
    expect(page).to have_content 'Sign in to GOV.UK'

    fill_in "Email", :with => ENV.fetch("SIGNON_USERNAME") { raise "You must set SIGNON_USERNAME" }
    fill_in "Password", :with =>ENV.fetch("SIGNON_PASSWORD") { raise "You must set SIGNON_PASSWORD" }
    click_button "Sign in"
    fill_in "Your verification code", :with => totp
    click_button "Sign in"
    expect(page).to have_content 'GOV.UK Forms'

    # require 'pry'; binding.pry
    click_link "Create a form"
    expect(page.filter("h1")).to have_content 'What is the name of your form?'
    fill_in "What is the name of your form?", :with => "capybara test form"

    expect(page.filter("h1")).to have_content 'Create a form'
    click_link 'Add and edit your questions'

    expect(page.filter("h1")).to have_content 'Edit question'
    fill_in "Question text", :with => "What is your name?"
    # require 'pry'; binding.pry
    
    
    
    
  end

  def totp
    totp = ROTP::TOTP.new(ENV.fetch("SIGNON_OTP") { raise "You must set SIGNON_OTP with the TOTP code for signon"})
    totp.now
  end
end

# it "completes a form" do
#   visit 'preview-form/1/apply-for-a-fishing-license/1'
#   expect(page).to have_content 'Apply for a fishing license'
#   expect(page).to have_content 'How long do you need one?'
#   answer_single_line('one week')
#   expect(page).to have_content 'What are you likely to catch?'
#   answer_single_line('fish')
#   expect(page).to have_content 'Check your answers before submitting your form'
#   expect(page).to have_content 'one week'
#   expect(page).to have_content 'fish'
#   click_button 'Submit'
#   expect(page).to have_content 'Your form has been submitted'
# end

# def answer_single_line(text)
#   fill_in 'question[text]', with: text
#   click_button 'Continue'
# end
