const { environment } = require('@rails/webpacker')
const webpack = require("webpack")

environment.plugins.append("Provide", new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  "window.jQuery": "jquery",
  "window.$": 'jquery',
  Popper: ['popper.js', 'default']
}))

environment.loaders.append('jquery', {
  test: require.resolve('jquery'),
  rules: [
    {
      loader: 'expose-loader',
      options: {
        exposes: ['$', 'jQuery'],
      },
    },
  ],
});

module.exports = environment
