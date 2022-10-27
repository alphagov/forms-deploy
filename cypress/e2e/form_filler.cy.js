describe('user fills in a form', () => {
  it('succesfully', () => {
    loadExampleForm()

    fillInHowLongPage()

    fillInWhatWillYouCatchPage()

    submitForm()
  })
})

const loadExampleForm = () => {
  cy.visit('https://submit.staging.forms.service.gov.uk/form/1')
}

const fillInHowLongPage = () => {
  cy.contains('How long do you need one?')
    .click()
    .type('5 months')

  cy.contains('Continue').click()
}

const fillInWhatWillYouCatchPage = () => {
  cy.contains('What are you likely to catch?')
    .click()
    .type('5 moths')

  cy.contains('Continue').click()
}

const submitForm = () => {
  cy.contains('Submit').click()
}
