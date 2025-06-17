module.exports = function(eleventyConfig) {
  // Copy the `img` and `css` folders to the output
  eleventyConfig.addPassthroughCopy("img");
  eleventyConfig.addPassthroughCopy("css");

  return {
    dir: {
      input: "_posts",
      output: "_site"
    }
  };
};
