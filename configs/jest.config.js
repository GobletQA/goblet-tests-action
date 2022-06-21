

/** @type {import('ts-jest/dist/types').InitialOptionsTsJest} */
module.exports = {
  rootDir: require('path').join(__dirname, '../'),
  verbose: false,
  clearMocks: true,
  maxWorkers: '50%',
  testEnvironment: 'node',
  coverageProvider: 'v8',
  roots: ['<rootDir>/src'],
  globals: {
    'ts-jest': {
      tsconfig: '<rootDir>/tsconfig.json',
    },
    __DEV__: true,
  },
  preset: 'ts-jest/presets/js-with-ts',
  testMatch: [
    '<rootDir>/**/*.spec.{js,jsx,ts,tsx}',
    '<rootDir>/**/*.test.{js,jsx,ts,tsx}',
    '<rootDir>/**/__tests__/*.{js,jsx,ts,tsx}',
  ],
  coverageDirectory: '<rootDir>/coverage',
  coverageReporters: ['lcov', 'text-summary', 'text', 'html'],
  collectCoverageFrom: [
    '**/*.{js,jsx,ts,tsx}',
    '!**/bin/**',
    '!**/*.d.ts',
    '!**/coverage/**',
    '!**/__tests__/**',
    '!**/node_modules/**',
    '!**/*.spec.{js,jsx,ts,tsx}',
  ],
  coveragePathIgnorePatterns: ['/node_modules/'],
}
