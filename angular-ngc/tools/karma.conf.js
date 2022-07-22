const fs = require("fs");

// Karma configuration file, see link for more information
// https://karma-runner.github.io/1.0/config/configuration-file.html
const STATIC_FILES = [
  // BEGIN STATIC FILES
  TMPL_static_files,
  // END STATIC FILES
];

const TEST_BOOTSTRAP_FILES = [
  // BEGIN BOOTSTRAP FILES
  TMPL_bootstrap_files,
  // END BOOTSTRAP FILES
];

// Test + runtime entry point files
const TEST_BUNDLE_DIRS = [
  // BEGIN TEST SPEC FILES
  TMPL_spec_files,
  // END TEST BUNDLE FILES
];

const BUNDLE_FILES = [];
TEST_BUNDLE_DIRS.forEach((dir) => {
  findAllFiles(__dirname + "/" + dir, BUNDLE_FILES);
});

const BOOTSTRAP_FILES = [];
TEST_BOOTSTRAP_FILES.forEach((file) => {
  const filePath = __dirname + "/" + file;
  BOOTSTRAP_FILES.push(filePath);
});

function findAllFiles(dir, found) {
  found = found || [];

  for (const file of fs.readdirSync(dir)) {
    const filePath = dir + "/" + file;

    if (fs.statSync(filePath).isDirectory()) {
      findAllFiles(filePath, found);
    } else {
      found.push(filePath);
    }
  }

  return found;
}

function addKarmaFile(f, files) {
  const isJs = f.endsWith(".js") || f.endsWith(".mjs");
  const isChunk = isJs && f.includes("chunk-");
  const isTestSetup = f.endsWith("/test_setup.js");

  const karmaFile = {
    pattern: f,
    type: isJs ? "module" : undefined,
    included: isJs && !isChunk,
  };
  if (isTestSetup) {
    files.unshift(karmaFile);
  }
  files.push(karmaFile);
}

function configureFiles(conf) {
  // Static files available but not included
  STATIC_FILES.forEach((f) => conf.files.push({ pattern: f, included: false }));
  BOOTSTRAP_FILES.forEach((f) => addKarmaFile(f, conf.files));
  const bundleFiles = [];
  BUNDLE_FILES.forEach((f) => addKarmaFile(f, bundleFiles));
  bundleFiles.forEach((f) => conf.files.push(f));
}

module.exports = function (config) {
  config.set({
    basePath: "",
    frameworks: ["jasmine"],
    plugins: [
      require("karma-jasmine"),
      require("karma-chrome-launcher"),
      require("karma-jasmine-html-reporter"),
    ],
    client: {
      jasmine: {
        // you can add configuration options for Jasmine here
        // the possible options are listed at https://jasmine.github.io/api/edge/Configuration.html
        // for example, you can disable the random execution with `random: false`
        // or set a specific seed with `seed: 4321`
      },
      clearContext: false, // leave Jasmine Spec Runner output visible in browser
    },
    reporters: ["progress", "kjhtml"],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    browsers: ["Chrome"],
    singleRun: false,
    restartOnFileChange: true,
  });
  configureFiles(config);
};
