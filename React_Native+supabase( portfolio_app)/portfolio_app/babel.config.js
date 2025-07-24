module.exports = function(api) {
  api.cache(false);

  return {
    presets: ['babel-preset-expo'],
    plugins: [
      [
        'module-resolver',
        {
          root: ['./src'],
          extensions: [
            '.js',
            '.jsx',
            '.ts',
            '.tsx',
            '.json',
          ],
          alias: {
            '@': './src',
          }
        },
      ],
      'react-native-reanimated/plugin',
    ],
  };
};
