const totp = require('totp-generator')

describe('user', () => {
  it('creates a form', () => {
    logIn()
    loadAdminPage()
    createAForm()
    fillInFormNamePage()
    addAQuestion()
    addADeclaration()
    addWhatHappensNext()
    addSubmissionEmail()
    addPrivacyInformation()
    addContactDetails()
    makeLive()
  })
})

const loadAdminPage = () => {
  cy.visit('http://forms-admin-dev.london.cloudapps.digital')
}

const logIn = () => {
  enterEmailAndPassword()
  twoFactor()
}

const enterEmailAndPassword = () => {
  cy.request('https://signon.integration.publishing.service.gov.uk/')
    .its('body')
    .then(body => {
      const $html = Cypress.$(body)
      const csrf = $html.find('input[name=authenticity_token]').val()

      cy.request({
        method: 'POST',
        url:
          'https://signon.integration.publishing.service.gov.uk/users/sign_in',
        headers: {
          Accept:
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'
        },
        body: {
          authenticity_token: csrf,
          'user[email]': Cypress.env('SIGNON_INTEGRATION_EMAIL'),
          'user[password]': Cypress.env('SIGNON_INTEGRATION_PASSWORD')
        },
        form: true
      })
    })
}

const twoFactor = () => {
  cy.request(
    'https://signon.integration.publishing.service.gov.uk/users/two_step_verification/session/new'
  )
    .its('body')
    .then(body => {
      const $html = Cypress.$(body)
      const csrf = $html.find('input[name=authenticity_token]').val()
      const code = totp(Cypress.env('SIGNON_INTEGRATION_2FA_SECRET'))

      const requestBody = {
        authenticity_token: csrf,
        code: code
      }

      cy.request({
        method: 'POST',
        url:
          'https://signon.integration.publishing.service.gov.uk/users/two_step_verification/session',
        headers: {
          Accept:
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'
        },
        body: requestBody,
        form: true
      })
        .its('body')
        .then(console.log)
    })
}

const createAForm = () => {
  cy.contains('Create a form').click()
}

const fillInFormNamePage = () => {
  cy.contains('What is the name of your form?')
    .click()
    .type('Smoke test form')

  cy.contains('Continue').click()
}

const addAQuestion = () => {
  cy.contains('Add and edit your questions').click()

  cy.contains('Question text')
    .click()
    .type('What is your name?')

  cy.contains('Hint text')
    .click()
    .type('This should be your full name, including any middle names.')

  cy.contains('Single line of text').click()

  cy.contains('Save question').click()

  cy.contains('Go to your questions').click()

  cy.contains('Back to create a form').click()
}

const addADeclaration = () => {
  cy.contains('Add a declaration for people to agree to').click()

  cy.contains('Enter a declaration for people to agree to')
    .click()
    .type(
      'By submitting this form you are confirming that, to the best of your knowledge, the answers you are providing are correct.'
    )

  cy.contains('Save and continue').click()
}

const addWhatHappensNext = () => {
  cy.contains('Add information about what happens next').click()

  cy.contains('Enter some information to tell people what will happen next')
    .click()
    .type(
      "We'll send you an email to let you know the outcome. You'll usually get a response within 10 working days."
    )

  cy.contains('Save and continue').click()
}

const addSubmissionEmail = () => {
  cy.contains('Set the email address completed forms will be sent to').click()

  cy.contains('What email address should completed forms be sent to?')
    .click()
    .type('govuk-forms-tech@digital.cabinet-office.gov.uk')

  cy.contains('Continue').click()
}

const addPrivacyInformation = () => {
  cy.contains('Provide a link to privacy information for this form').click()

  cy.contains('Enter a link to privacy information for this form')
    .click()
    .type('https://www.gov.uk/help/privacy-notice')

  cy.contains('Save and continue').click()
}

const addContactDetails = () => {
  cy.contains('Provide contact details for support').click()
  cy.contains('Email').click()
  cy.contains('Enter the email address')
    .click()
    .type('govuk-forms-tech@digital.cabinet-office.gov.uk')
  cy.contains('Phone').click()
  cy.contains('Enter the phone number and its opening times')
    .click()
    .type('01610123456')
  cy.contains('Online contact link').click()
  cy.contains('Enter the link')
    .click()
    .type('https://gov.uk/contact-form')
  cy.contains('What text should be used to describe this link?')
    .click()
    .type('Online contact form')
  cy.contains('Save and continue').click()
}

const makeLive = () => {
  cy.get('a')
    .contains('Make your form live')
    .click()
  cy.contains('Yes').click()
  cy.contains('Continue').click()
}
