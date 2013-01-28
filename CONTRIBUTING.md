# Process

1. Fork the [GitHub respository](https://github.com/BlackacreLabs/precedent)
2. Create a feature branch (`git checkout -b my-new-feature`).
3. Make your changes.
4. Regenerate the Treetop parsers (`rake`).
5. Make sure the specs still pass (`bundle exec rspec`).
6. Update the README or SYNTAX guide if necessary.
7. Commit your changes (`git commit -am 'Add some feature'`).
8. Push to the branch (`git push origin my-new-feature`).
9. Send a pull request.

# Style

1. Wrap to 72 columns (`par -w72r`).
2. Use 2 spaces, not tabs, for Ruby source.
