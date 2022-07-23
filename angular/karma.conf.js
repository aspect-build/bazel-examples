// Karma configuration file, see link for more information
// https://karma-runner.github.io/1.0/config/configuration-file.html
function supportChromeSandboxing() {
  if (process.platform === 'darwin') {
    // Chrome 73+ fails to initialize the sandbox on OSX when running under Bazel.
    // ```
    // ERROR [launcher]: Cannot start ChromeHeadless
    // ERROR:crash_report_database_mac.mm(96)] mkdir
    // /private/var/tmp/_bazel_greg/62ef096b0da251c6d093468a1efbfbd3/execroot/angular/bazel-out/darwin-fastbuild/bin/external/io_bazel_rules_webtesting/third_party/chromium/chromium.out/chrome-mac/Chromium.app/Contents/Versions/73.0.3683.0/Chromium
    // Framework.framework/Versions/A/new: Permission denied (13) ERROR:file_io.cc(89)]
    // ReadExactly: expected 8, observed 0 ERROR:crash_report_database_mac.mm(96)] mkdir
    // /private/var/tmp/_bazel_greg/62ef096b0da251c6d093468a1efbfbd3/execroot/angular/bazel-out/darwin-fastbuild/bin/external/io_bazel_rules_webtesting/third_party/chromium/chromium.out/chrome-mac/Chromium.app/Contents/Versions/73.0.3683.0/Chromium
    // Framework.framework/Versions/A/new: Permission denied (13) Chromium Helper[94642] <Error>:
    // SeatbeltExecServer: Failed to initialize sandbox: -1 Operation not permitted Failed to
    // initialize sandbox. [0213/201206.137114:FATAL:content_main_delegate.cc(54)] Check failed:
    // false. 0   Chromium Framework                  0x000000010c078bc9 ChromeMain + 43788137 1
    // Chromium Framework                  0x000000010bfc0f43 ChromeMain + 43035363
    // ...
    // ```
    return false;
  }

  if (process.platform === 'linux') {
    // Chrome on Linux uses sandboxing, which needs user namespaces to be enabled.
    // This is not available on all kernels and it might be turned off even if it is available.
    // Notable examples where user namespaces are not available include:
    // - In Debian it is compiled-in but disabled by default.
    // - The Docker daemon for Windows or OSX does not support user namespaces.
    // We can detect if user namespaces are supported via
    // /proc/sys/kernel/unprivileged_userns_clone. For more information see:
    // https://github.com/Googlechrome/puppeteer/issues/290
    // https://superuser.com/questions/1094597/enable-user-namespaces-in-debian-kernel#1122977
    // https://github.com/karma-runner/karma-chrome-launcher/issues/158
    // https://github.com/angular/angular/pull/24906
    try {
      const res = child_process
        .execSync('cat /proc/sys/kernel/unprivileged_userns_clone')
        .toString()
        .trim();
      return res === '1';
    } catch (error) {}
    return false;
  }
}

module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular-devkit/build-angular'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      require('karma-jasmine-html-reporter'),
      require('karma-coverage'),
      require('@angular-devkit/build-angular/plugins/karma'),
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
    jasmineHtmlReporter: {
      suppressAll: true, // removes the duplicated traces
    },
    coverageReporter: {
      dir: require('path').join(__dirname, './coverage/angular'),
      subdir: '.',
      reporters: [{ type: 'html' }, { type: 'text-summary' }],
    },
    reporters: ['progress', 'kjhtml'],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: false,
    browsers: [],
    singleRun: true,
    restartOnFileChange: true,
  });
  const browser = 'ChromeHeadless';
  if (!supportChromeSandboxing()) {
    const launcher = 'CustomChromeWithoutSandbox';
    config.customLaunchers = {
      [launcher]: { base: browser, flags: ['--no-sandbox'] },
    };
    config.browsers.push(launcher);
  } else {
    const launcher = 'CustomChrome';
    config.customLaunchers = {
      [launcher]: { base: browser },
    };
    config.browsers.push(launcher);
  }
  console.log('config', config);
};
