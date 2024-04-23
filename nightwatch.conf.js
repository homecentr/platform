module.exports = {
  src_folders: ['tests'],
  filter : "**/*.spec.js",
  exclude : ["tests/client", "tests/nightwatch", "tests/test_output"],
  custom_commands_path: ['tests/nightwatch/commands'],
  custom_assertions_path: ['tests/nightwatch/assertions'],
  plugins: [],
  globals_path: 'tests/nightwatch/globals.js',
  output_folder: 'tests/tests_output',
  screenshots : {
    enabled : true,
    on_failure : true,
    on_error : false,
    path : "tests/screenshots"
  }

  webdriver: {},

  test_workers: {
    enabled: true
  },

  test_settings: {
    default: {
      globals: {
        waitForConditionTimeout: 30000,
        waitForConditionPollInterval: 500
      },
      persist_globals: true,
      screenshots: {
        enabled: "${SCREENSHOTS_ENABLED}",
        on_failure: "${SCREENSHOTS_ENABLED}",
        path: "screenshots"
      },
      selenium_port: "${WEBDRIVER_PORT}",
      selenium_host: "${WEBDRIVER_HOST}",
      desiredCapabilities: {
        browserName: "chrome",
        javascriptEnabled: true,
        acceptSslCerts: true,
        acceptInsecureCerts: true
      }
    },
    "local:lab": {
      globals: {
        domainSuffix: "-lab.homecentr.one",
        secretsFile: "secrets.lab.sops.yaml",
        envFile: "lab.local.env",
        isRemote: false
      }
    },
    "remote:lab": {
      globals: {
        domainSuffix: "-lab.homecentr.one",
        secretsFile: "secrets.lab.sops.yaml",
        envFile: "remote.env",
        isRemote: true
      }
    },
    "local:prod": {
      globals: {
        domainSuffix: ".homecentr.one",
        secretsFile: "secrets.prod.sops.yaml",
        envFile: "prod.local.env",
        isRemote: false
      }
    },
    "remote:prod": {
      globals: {
        domainSuffix: ".homecentr.one",
        secretsFile: "secrets.prod.sops.yaml",
        envFile: "remote.env",
        isRemote: true
      }
    }
  }
};