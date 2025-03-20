module.exports = {
    rules: {
        'code-complexity': ['error', 9],
        'compiler-version': ['error', '>=0.8.19'],
        'func-visibility': ['error', { ignoreConstructors: true }],
        'max-line-length': ['error', 136],
        'named-parameters-mapping': 'warn',
        'not-rely-on-time': 'off',
        'one-contract-per-file': 'off',
        'avoid-low-level-calls': 'off',
        'no-global-import': 'off',
    },
};
