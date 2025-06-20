const { format } = require('date-fns');

module.exports = function(eleventyConfig) {
  // Copy the `img` and `css` folders to the output
  eleventyConfig.addPassthroughCopy("img");

  eleventyConfig.addFilter("format_date", (date) => {
    return format(new Date(date), 'yyyy-MM-dd');
  });

return {
  dir: {
    input: ".",
    output: ".",
    dataDir: "_data"
}
  };
};
