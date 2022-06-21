module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    tsconfigRootDir: require('path').join(__dirname, '../'),
  },
  extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended', 'prettier'],
  plugins: ['import', '@typescript-eslint', 'jest'],
  env: {
    es6: true,
    node: true,
  },
  globals: {
    jest: true,
    __DEV__: true,
    expect: true,
    React: true,
  },
  ignorePatterns: ['build', 'dist', 'node_modules', 'examples', 'scripts'],
  rules: {
    /* General */
    'brace-style': ['error', 'stroustrup'],
    indent: [
      'error',
      2,
      {
        offsetTernaryExpressions: true,
        ignoredNodes: ['ConditionalExpression > CallExpression'],
        SwitchCase: 1,
      },
    ],
    'no-use-before-define': 'off',
    '@typescript-eslint/no-use-before-define': ['error'],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-unused-vars': [
      'error',
      {
        args: 'none',
        ignoreRestSiblings: true,
        varsIgnorePattern: '_',
      },
    ],
    '@typescript-eslint/no-var-requires': 0,
    'import/no-extraneous-dependencies': [
      'error',
      {
        devDependencies: [
          'src/routes/swagger.ts',
          'src/config/jest.setup.ts',
          '**/*.test.js',
          '**/*.spec.js',
          '**/*.test.ts',
          '**/*.spec.ts',
        ],
      },
    ],
    'import/prefer-default-export': 'off',
    'object-curly-newline': 'off',
    'no-confusing-arrow': 'off',
    'implicit-arrow-linebreak': 'off',
    'no-else-return': 'error',
    'no-lonely-if': 'error',
    /* Jest */
    'jest/no-disabled-tests': 'warn',
    'jest/no-focused-tests': 'error',
    'jest/no-identical-title': 'error',
    'jest/prefer-to-have-length': 'warn',
    'jest/valid-expect': 'error',
  },
  overrides: [
    {
      files: ['**/*.test.js', '**/*.spec.js', '**/*.test.ts', '**/*.spec.ts'],
      rules: {
        '@typescript-eslint/no-explicit-any': 'off',
      },
    },
  ],
}
