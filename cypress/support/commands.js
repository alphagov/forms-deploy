import '@testing-library/cypress/add-commands'
import totp from 'totp-generator'

Cypress.Commands.add('logIn', () => {
  cy.enterEmailAndPassword()
  cy.twoFactor()
})

Cypress.Commands.add('enterEmailAndPassword', () => {
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
})

Cypress.Commands.add('twoFactor', () => {
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
})
