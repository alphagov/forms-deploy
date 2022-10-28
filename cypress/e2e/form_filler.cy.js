describe('user fills in a form', () => {
  it('succesfully', () => {
    loadExampleForm()

    fillInHowLongPage()

    fillInWhatWillYouCatchPage()

    submitForm()
  })
})

const loadExampleForm = () => {
  cy.visit(Cypress.env('form_url'))
}

const fillInHowLongPage = () => {
  cy.findByLabelText('How long do you need one?').type('5 months')

  cy.contains('Continue').click()
}

const fillInWhatWillYouCatchPage = () => {
  cy.findByLabelText('What are you likely to catch?').type('5 moths')

  cy.contains('Continue').click()
}

const submitForm = () => {
  // Don't actually submit the form here because it'll spam the inbox
  cy.contains('Submit')
}
