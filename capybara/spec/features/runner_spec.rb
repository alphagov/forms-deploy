describe "Form runner", type: :feature do
  before do
    Capybara.default_driver = :headless_chrome
    Capybara.app_host = 'https://submit.staging.forms.service.gov.uk/'
  end

  it "completes a form" do
    visit 'preview-form/1/apply-for-a-fishing-license/1'
    expect(page).to have_content 'Apply for a fishing license'
    expect(page).to have_content 'How long do you need one?'
    answer_single_line('one week')
    expect(page).to have_content 'What are you likely to catch?'
    answer_single_line('fish')
    expect(page).to have_content 'Check your answers before submitting your form'
    expect(page).to have_content 'one week'
    expect(page).to have_content 'fish'
    click_button 'Submit'
    expect(page).to have_content 'Your form has been submitted'
  end

  def answer_single_line(text)
    fill_in 'question[text]', with: text
    click_button 'Continue'
  end
end
