# Building the error page

These are the steps used to build the gov.uk styled error page.

## Requirements

You'll need node and npm installed.

## install the gov-uk-frontend package

Create a new directory and run the following command:

```
npm i -SE govuk-frontend
```

Create a new directory called build which will contain the html and assets.


## Compile the sass

We need to compile the sass rather than use a pre-compiled version because we
need to use the `govuk-assets-path` variable.

Create a new file called `index.scss` and add the following code:

```scss
// index.scss
$govuk-global-styles: true;
$govuk-new-link-styles: true;
$govuk-assets-path: "/cloudfront/assets/";
$govuk-new-typography-scale: true;

@import "govuk-frontend/dist/govuk";
```

Compile the sass using the following command, which will install the sass compiler behind the scenes:

```sh
npx --yes sass@1.89.2 ./index.scss:./build/stylesheets/govuk-frontend.min.css --no-source-map --load-path=node_modules --quiet-deps --style compressed
```

## Copy the gov.uk javascript

We are not compiling the javascript so we just use the govuk build:

```sh
mkdir -p build/javascripts
cp -r node_modules/govuk-frontend/dist/govuk/govuk-frontend.min.js build/javascripts/
```

## Copy the gov.uk assets

Copy the gov.uk assets into the `build` directory.

```sh
cp -r node_modules/govuk-frontend/dist/govuk/assets build/
```

## Create an error page

Create a new file in the `build` directory called `error.html` and add the HTML from the page template.

Prefix all assets with '/cloudfront' to make sure they match the cloudfront distribution.

https://design-system.service.gov.uk/styles/page-template/

and

https://design-system.service.gov.uk/patterns/service-unavailable-pages/

## Test the error page

To test the error page locally you'll need to serve the `build` directory and route /cloudfront to it.

## Copy files to /html

Copy the `build` directory to the `/html` directory. The `html` directory is
the directory which will be uploaded to the S3 when the terraform is run. The
S3 bucket will be served  by the cloudfront distribution as `/cloudfront`.

```
cp -r build forms-deploy/infra/modules/cloudfront/html
```

## Deploying to dev
When the cloudfront distribution is updated, the files will be updated.

To deploy the changes to dev, run the following command:

```sh
gds aws forms-dev-admin -- make development forms/environment apply
```

The error page will be accessible from the product pages, admin, api, and runner domains.

For example

https://admin.dev.forms.service.gov.uk/cloudfront/error.html
