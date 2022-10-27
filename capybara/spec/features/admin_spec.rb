require 'rotp'

describe "Form admin", type: :feature do
  before do
    Capybara.default_driver = :headless_chrome
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
  end

  def totp
    totp = ROTP::TOTP.new(ENV.fetch("SIGNON_OTP") { raise "You must set SIGNON_OTP with the TOTP code for signon"})
    totp.now
  end
end
