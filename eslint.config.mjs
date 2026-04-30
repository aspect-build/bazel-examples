// @ts-check

import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';
import globals from 'globals';

export default tseslint.config(
  // Ignore generated and vendored files. `*_pb.{d.ts,js}` come out of
  // protoc-gen-es / protoc-gen-connect-es and aren't worth linting.
  {
    ignores: [
      '**/*_pb.d.ts',
      '**/*_pb.js',
      '**/genproto/**',
      'node_modules/**',
      'bazel-*/**',
    ],
  },

  eslint.configs.recommended,

  // CommonJS / Node.js source files — provide `module`, `require`, `console`,
  // etc. as globals so no-undef stops complaining about them.
  {
    files: ['**/*.js', '**/*.cjs', '**/*.mjs'],
    languageOptions: {
      sourceType: 'commonjs',
      globals: {
        ...globals.node,
      },
    },
  },

  // TypeScript source files — recommended (untyped) rule set only. The
  // type-checked rule sets require parserOptions.project, which needs the
  // referenced tsconfig.json to be present in the lint sandbox; many ts_project
  // targets in this repo use inline tsconfigs (passed to ts_project as a dict),
  // so the sandbox doesn't have a tsconfig.json file for ESLint to find.
  {
    files: ['**/*.ts', '**/*.tsx'],
    extends: [...tseslint.configs.recommended],
    languageOptions: {
      globals: {
        ...globals.node,
      },
    },
  },

  // Demonstrate override for a subdirectory.
  {
    files: ['src/subdir/**'],
    rules: {
      'no-debugger': 'off',
      'sort-imports': 'warn',
    },
  }
);
